import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../fixtures.dart';
import '../repositories/local_repository.dart';

class PreferencesMigrationHelper {
  static const legacyKey = 'job_matcher_demo_v1';
  static Future<void> migrate(LocalRepository repo) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(legacyKey);
    if (raw == null) {
      final marker = await (repo.db.select(repo.db.settingsTable)
        ..where((s) => s.id.isIn(['seeded', 'legacyMigrated']))).getSingleOrNull();
      if (marker == null) {
        final seed = fixtureSnapshot();
        await repo.write(seed);
        for (final m in seed['matches'] as List? ?? []) {
          await repo.put('matches', Map<String, dynamic>.from(m as Map));
        }
        await repo.setting('seeded', true);
      }
      return;
    }
    final marker = await (repo.db.select(repo.db.settingsTable)
      ..where((s) => s.id.equals('legacyMigrated'))).getSingleOrNull();
    if (marker == null) {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final ids = <String, String>{};
      String remap(String id) => ids.putIfAbsent(id, () => const Uuid().v4());
      await repo.db.transaction(() async {
        for (final entity in ['resumes', 'applications', 'matches']) {
          for (final rawItem in data[entity] as List? ?? []) {
            final item = Map<String, dynamic>.from(rawItem as Map);
            item['id'] = remap(item['id'] as String);
            if (item['resumeId'] != null) item['resumeId'] = remap(item['resumeId'] as String);
            // Fixture job IDs cannot be foreign keys into a real catalog.
            if (item['jobId'] != null && !Uuid.isValidUUID(fromString: item['jobId'] as String)) item['jobId'] = null;
            await repo.put(entity, item);
          }
        }
        if (data['defaultResumeId'] != null) await repo.setting('defaultResumeId', remap(data['defaultResumeId']));
        await repo.setting('onboardingComplete', data['onboardingComplete'] ?? false);
        await repo.setting('legacyMigrated', true);
      });
    }
    // Keep the source until both SQLite commit and backup storage succeed.
    if (!await prefs.setString('${legacyKey}_migrated_backup', raw)) throw StateError('Unable to back up legacy workspace.');
    await prefs.remove(legacyKey);
  }
}
