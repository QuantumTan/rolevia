import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../repositories/local_repository.dart';

class PreferencesMigrationHelper {
  static const legacyKey = 'job_matcher_demo_v1';
  static Future<void> migrate(LocalRepository repo) async {
    await _removePrototypeData(repo);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(legacyKey);
    if (raw == null) {
      return;
    }
    final marker = await (repo.db.select(
      repo.db.settingsTable,
    )..where((s) => s.id.equals('legacyMigrated'))).getSingleOrNull();
    if (marker == null) {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final ids = <String, String>{};
      String remap(String id) => ids.putIfAbsent(id, () => const Uuid().v4());
      await repo.db.transaction(() async {
        for (final entity in ['resumes', 'applications', 'matches']) {
          for (final rawItem in data[entity] as List? ?? []) {
            final item = Map<String, dynamic>.from(rawItem as Map);
            if (_isPrototype(entity, item)) continue;
            item['id'] = remap(item['id'] as String);
            if (item['resumeId'] != null) {
              item['resumeId'] = remap(item['resumeId'] as String);
            }
            // Fixture job IDs cannot be foreign keys into a real catalog.
            if (item['jobId'] != null &&
                !Uuid.isValidUUID(fromString: item['jobId'] as String)) {
              item['jobId'] = null;
            }
            await repo.put(entity, item);
          }
        }
        if (data['defaultResumeId'] != null) {
          await repo.setting('defaultResumeId', remap(data['defaultResumeId']));
        }
        await repo.setting(
          'onboardingComplete',
          data['onboardingComplete'] ?? false,
        );
        await repo.setting('legacyMigrated', true);
      });
    }
    // Keep the source until both SQLite commit and backup storage succeed.
    if (!await prefs.setString('${legacyKey}_migrated_backup', raw)) {
      throw StateError('Unable to back up legacy workspace.');
    }
    await prefs.remove(legacyKey);
  }

  static bool _isPrototype(String entity, Map<String, dynamic> item) {
    if (entity == 'resumes') return item['isSample'] == true;
    final id = item['id']?.toString() ?? '';
    return switch (entity) {
      'jobs' => RegExp(r'^j[1-5]$').hasMatch(id),
      'applications' => RegExp(r'^a[1-4]$').hasMatch(id),
      'matches' =>
        RegExp(r'^m\d+$').hasMatch(id) ||
            (id.startsWith('m') &&
                item['company'] == 'Northwind Digital' &&
                (item['suggestions']?.toString().contains('2,000+ users') ??
                    false)),
      _ => false,
    };
  }

  static Future<void> _removePrototypeData(LocalRepository repo) async {
    final snapshot = await repo.read();
    if (snapshot['prototypeCleanup'] == true) return;
    await repo.db.transaction(() async {
      final removedResumes = <String>{};
      final removedJobs = <String>{};
      await repo.setting('prototypeBackup', snapshot);
      for (final entity in ['resumes', 'jobs', 'matches', 'applications']) {
        for (final item in await repo.records(entity)) {
          if (entity == 'jobs' && !_isPrototype(entity, item)) {
            await repo.put('jobs', {...item, 'matchScore': null,
              'badgeText': null, 'badgeTone': 'neutral'});
          }
          if (!_isPrototype(entity, item)) continue;
          final id = item['id'] as String;
          if (entity == 'resumes') removedResumes.add(id);
          if (entity == 'jobs') removedJobs.add(id);
          await repo.removeRecord(entity, id);
        }
      }
      if (removedResumes.contains(snapshot['defaultResumeId'])) {
        await repo.setting('defaultResumeId', null);
      }
      await repo.setting(
        'savedJobIds',
        (snapshot['savedJobIds'] as List)
            .where((id) => !removedJobs.contains(id))
            .toList(),
      );
      await repo.setting('prototypeCleanup', true);
    });
  }
}
