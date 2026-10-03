import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/pii_sanitizer.dart';
import '../demo_repository.dart';
import '../local/app_database.dart';

const emptyWorkspace = <String, dynamic>{
  'onboardingComplete': false, 'authenticated': false, 'savedJobIds': <String>[],
  'resumes': <dynamic>[], 'applications': <dynamic>[], 'matches': <dynamic>[],
  'profile': {'name': '', 'email': '', 'headline': '', 'location': 'Philippines',
    'targetRoles': <String>[], 'scanQuota': 0},
};

class LocalRepository implements DemoRepository {
  LocalRepository(this.db, this.owner);
  final AppDatabase db;
  final String owner;
  Future<void> _writes = Future.value();
  final _changes = StreamController<void>.broadcast();
  Stream<void> get mutations => _changes.stream;

  TableInfo table(String entity) => switch (entity) {
    'resumes' => db.resumesTable, 'applications' => db.applicationsTable,
    'matches' => db.matchesTable, 'jobs' => db.jobsTable,
    _ => throw ArgumentError('Unknown entity'),
  };

  Future<List<Map<String, dynamic>>> records(String entity) async =>
    (await db.customSelect('SELECT domain_json FROM ${table(entity).actualTableName}',
      readsFrom: {table(entity)}).get()).map((r) =>
        Map<String, dynamic>.from(jsonDecode(r.read<String>('domain_json')) as Map)).toList();

  @override
  Future<Map<String, dynamic>> read() async {
    final settings = await db.select(db.settingsTable).get();
    final result = <String, dynamic>{...emptyWorkspace,
      for (final s in settings) s.id: jsonDecode(s.value)};
    for (final name in ['resumes', 'applications', 'matches', 'jobs']) {
      result[name] = await records(name);
    }
    return result;
  }

  Stream<Map<String, dynamic>> watch() => db.customSelect('SELECT 1', readsFrom: {
    db.resumesTable, db.applicationsTable, db.matchesTable, db.jobsTable, db.settingsTable,
  }).watch().asyncMap((_) => read());

  Future<void> setting(String key, Object? value) => db.into(db.settingsTable)
    .insertOnConflictUpdate(SettingsTableCompanion.insert(id: key, value: jsonEncode(value)));

  Future<void> put(String entity, Map<String, dynamic> j, {String? sanitizedText}) async {
    final now = DateTime.now().toUtc();
    int stamp(dynamic value) => (value == null ? now : DateTime.parse(value as String)).millisecondsSinceEpoch ~/ 1000;
    final row = <String, Object?>{'id': j['id'], 'domain_json': jsonEncode(j)};
    switch (entity) {
      case 'resumes':
        row.addAll({'title': j['title'], 'filename': j['filename'], 'file_type': j['fileType'],
          'ats_status': j['atsStatus'] ?? 'Not analyzed', 'added_at': stamp(j['addedAt'])});
        if (sanitizedText != null) row['sanitized_text'] = PiiSanitizer.sanitize(sanitizedText);
      case 'applications':
        row.addAll({'job_id': j['jobId'], 'company': j['company'], 'role': j['role'],
          'location': j['location'], 'stage': j['stage'], 'match_badge': j['matchBadge'],
          'link': j['link'] ?? '', 'notes': jsonEncode(j['notes'] ?? []),
          'applied_at': stamp(j['appliedAt']), 'follow_up_at': j['followUpAt'] == null ? null : stamp(j['followUpAt']),
          'updated_at': stamp(j['updatedAt']), 'version': j['version'] ?? 0});
      case 'matches':
        row.addAll({'resume_id': j['resumeId'], 'job_id': j['jobId'], 'role': j['role'],
          'company': j['company'], 'overall_score': j['overall'],
          'components_json': jsonEncode(j['components']), 'matched_skills_json': jsonEncode(j['matched']),
          'missing_skills_json': jsonEncode(j['missing']), 'suggestions_json': jsonEncode(j['suggestions']),
          'created_at': stamp(j['createdAt'])});
      case 'jobs':
        row.addAll({'role': j['role'] ?? '', 'company': j['company'] ?? '', 'location': j['location'] ?? '',
          'mode': j['work_mode'] ?? j['mode'] ?? 'onSite',
          'type': j['employment_type'] ?? j['type'] ?? 'fullTime',
          'salary_min': j['salary_min'] ?? j['salaryMin'],
          'salary_max': j['salary_max'] ?? j['salaryMax'],
          'salary_period': j['salary_period'] ?? j['salaryPeriod'] ?? 'month',
          'skills_json': jsonEncode(j['skills'] ?? []),
          'overview': j['overview'] ?? '',
          'apply_url': j['application_url'] ?? j['applyUrl'],
          'latitude': j['latitude'], 'longitude': j['longitude'],
          'created_at': stamp(j['published_at'] ?? j['createdAt'] ?? DateTime.now().toIso8601String())});
    }
    final columns = row.keys.join(',');
    await db.customInsert('INSERT INTO ${table(entity).actualTableName} ($columns) VALUES (${row.keys.map((_) => '?').join(',')}) '
      'ON CONFLICT(id) DO UPDATE SET ${row.keys.where((k) => k != 'id').map((k) => '$k=excluded.$k').join(',')}',
      variables: [for (final v in row.values) Variable(v)], updates: {table(entity)});
  }

  Future<void> enqueue(String entity, String action, Map<String, dynamic> payload) async {
    final key = const Uuid().v4();
    await db.into(db.outboxQueueTable).insert(OutboxQueueTableCompanion.insert(
      id: key, entity: entity, action: action, payloadJson: jsonEncode(payload),
      idempotencyKey: key, createdAt: DateTime.now().toUtc()));
  }

  @override
  Future<void> write(Map<String, dynamic> data) {
    final captured = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
    final next = _writes.then((_) => _write(captured));
    _writes = next.catchError((Object _) {});
    return next;
  }

  Future<void> _write(Map<String, dynamic> data) async {
    await db.transaction(() async {
      for (final entity in ['resumes', 'applications']) {
        final previous = {for (final j in await records(entity)) j['id'] as String: j};
        final incoming = {for (final value in data[entity] as List? ?? [])
          value['id'] as String: Map<String, dynamic>.from(value as Map)};
        for (final entry in incoming.entries) {
          final before = previous[entry.key];
          final item = entry.value;
          // Versions are server metadata, not an editable part of the UI model.
          final comparable = {...?before}..remove('version')..remove('updatedAt');
          if (jsonEncode(comparable) == jsonEncode(item)) continue;
          item['version'] = before?['version'] ?? 0;
          item['updatedAt'] = DateTime.now().toUtc().toIso8601String();
          await put(entity, item);
          if (owner != 'device') {
            await enqueue(entity, 'upsert', item);
          }
        }
        for (final id in previous.keys.where((id) => !incoming.containsKey(id))) {
          await db.customUpdate('DELETE FROM ${table(entity).actualTableName} WHERE id=?',
            variables: [Variable(id)], updates: {table(entity)});
          if (owner != 'device') {
            await enqueue(entity, 'delete', {'id': id,
              'updatedAt': DateTime.now().toUtc().toIso8601String()});
          }
        }
      }
      final oldSaved = (await read())['savedJobIds'] as List;
      final saved = data['savedJobIds'] as List? ?? [];
      if (owner != 'device') {
        for (final id in saved.where((id) => !oldSaved.contains(id))) {
          await enqueue('saved_jobs', 'upsert', {'id': id});
        }
        for (final id in oldSaved.where((id) => !saved.contains(id))) {
          await enqueue('saved_jobs', 'delete', {'id': id});
        }
      }
      if (data.containsKey('jobs')) {
        for (final item in data['jobs'] as List? ?? []) {
          await put('jobs', Map<String, dynamic>.from(item as Map));
        }
      }
      for (final key in ['onboardingComplete', 'savedJobIds', 'defaultResumeId', 'profile']) {
        if (data.containsKey(key)) await setting(key, data[key]);
      }
    });
    _changes.add(null);
  }

  Future<void> storeExtracted(String id, String text) => (db.update(db.resumesTable)
    ..where((r) => r.id.equals(id))).write(ResumesTableCompanion(
      sanitizedText: Value(PiiSanitizer.sanitize(text))));

  Future<String> resumeText(String id) async => (await (db.select(db.resumesTable)
    ..where((r) => r.id.equals(id))).getSingle()).sanitizedText;

  @override
  Future<void> clear() => db.transaction(() async {
    for (final t in db.allTables) { await db.delete(t).go(); }
  });
  Future<void> close() async { await _writes; await _changes.close(); await db.close(); }
}
