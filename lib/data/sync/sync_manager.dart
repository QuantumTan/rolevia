import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/app_database.dart';
import '../repositories/local_repository.dart';

class SyncManager with WidgetsBindingObserver {
  SyncManager(this.local, this.client, {this.onError, this.onConnectivity});
  final LocalRepository local;
  final SupabaseClient client;
  final void Function(Object)? onError;
  final void Function(bool)? onConnectivity;
  StreamSubscription<List<ConnectivityResult>>? _network;
  StreamSubscription<void>? _mutations;
  Timer? _retry;
  bool _running = false, _disposed = false;
  bool get _active => !_disposed && client.auth.currentUser?.id == local.owner;

  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    await (local.db.update(local.db.outboxQueueTable)..where((q) => q.status.equals('syncing')))
      .write(const OutboxQueueTableCompanion(status: Value('pending')));
    _network = Connectivity().onConnectivityChanged.listen((values) {
      onConnectivity?.call(values.contains(ConnectivityResult.none));
      if (!values.contains(ConnectivityResult.none)) unawaited(flush());
    });
    _mutations = local.mutations.listen((_) => unawaited(flush()));
    await flush();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(flush());
  }

  Future<void> flush() async {
    if (_running || !_active) return;
    _running = true;
    _retry?.cancel();
    try {
      while (_active) {
        final row = await (local.db.select(local.db.outboxQueueTable)
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt), (q) => OrderingTerm.asc(q.id)])
          ..limit(1)).getSingleOrNull();
        if (row == null) break;
        if (row.nextAttemptAt?.isAfter(DateTime.now()) == true) {
          _retry = Timer(row.nextAttemptAt!.difference(DateTime.now()), () => unawaited(flush()));
          return;
        }
        await (local.db.update(local.db.outboxQueueTable)..where((q) => q.id.equals(row.id)))
          .write(const OutboxQueueTableCompanion(status: Value('syncing')));
        try {
          final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
          if (row.entity == 'analysis') {
            final response = await client.functions.invoke('analyze-job', body: {...payload, 'idempotency_key': row.idempotencyKey});
            if (response.status != 200) throw StateError('Analysis failed (${response.status})');
            if (!_active) return;
            await local.put('matches', Map<String, dynamic>.from(response.data as Map));
          } else {
            final result = await client.rpc('apply_mutation', params: {
              'p_key': row.idempotencyKey, 'p_entity': row.entity,
              'p_action': row.action, 'p_payload': payload});
            if (!_active) return;
            if (row.entity == 'applications' && result is Map && result['id'] != null) {
              // Pull handles reconciliation once all later local edits have been sent.
              await (local.db.update(local.db.applicationsTable)..where((a) => a.id.equals(payload['id'] as String)))
                .write(ApplicationsTableCompanion(version: Value((result['version'] as num).toInt())));
            }
            if (row.entity == 'resumes') {
              await (local.db.update(local.db.resumesTable)..where((r) => r.id.equals(payload['id'] as String)))
                .write(const ResumesTableCompanion(isSynced: Value(true)));
            }
          }
          await (local.db.delete(local.db.outboxQueueTable)..where((q) => q.id.equals(row.id))).go();
        } catch (error) {
          if (!_active) return;
          final delay = Duration(milliseconds: min(30000, 1000 * pow(2, min(row.retryCount, 5)).toInt() + Random().nextInt(1000)));
          await (local.db.update(local.db.outboxQueueTable)..where((q) => q.id.equals(row.id)))
            .write(OutboxQueueTableCompanion(status: const Value('failed'), retryCount: Value(row.retryCount + 1),
              nextAttemptAt: Value(DateTime.now().add(delay)), lastError: Value(error.toString())));
          onError?.call(error);
          _retry = Timer(delay, () => unawaited(flush()));
          return;
        }
      }
      if (_active) await pull();
    } catch (error) {
      onError?.call(error);
      if (_active) _retry = Timer(const Duration(seconds: 30), () => unawaited(flush()));
    } finally { _running = false; }
  }

  Future<void> pull() async {
    if (!_active) return;
    try {
      final results = await Future.wait([
        client.from('applications').select(), client.from('resumes').select(),
        client.from('matches').select(), client.from('jobs').select().order('published_at', ascending: false).limit(500),
        client.from('profiles').select().eq('id', local.owner), client.from('saved_jobs').select(),
      ]);
      if (!_active) return;
    await local.db.transaction(() async {
      final pending = await local.db.select(local.db.outboxQueueTable).get();
      bool dirty(String entity, String id) => pending.any((q) => q.entity == entity && (jsonDecode(q.payloadJson) as Map)['id'] == id);
      for (final j in results[0]) {
        if (dirty('applications', j['id'])) continue;
        if (j['deleted_at'] != null) {
          await (local.db.delete(local.db.applicationsTable)..where((a) => a.id.equals(j['id']))).go();
          continue;
        }
        await local.put('applications', {'id': j['id'], 'jobId': j['job_id'], 'company': j['company'],
          'role': j['role'], 'location': j['location'], 'stage': j['stage'], 'link': j['link'], 'notes': j['notes'],
          'matchBadge': j['match_badge'], 'appliedAt': j['applied_at'] ?? j['created_at'],
          'followUpAt': j['follow_up_at'], 'resumeId': j['resume_id'],
          'interviewAt': j['interview_at'], 'salaryOffered': j['salary_offered'],
          'version': j['version'], 'updatedAt': j['client_updated_at']});
      }
      for (final j in results[1]) {
        if (dirty('resumes', j['id'])) continue;
        if (j['deleted_at'] != null) {
          await (local.db.delete(local.db.resumesTable)..where((r) => r.id.equals(j['id']))).go();
          continue;
        }
        final existing = (await local.records('resumes')).where((r) => r['id'] == j['id']).firstOrNull;
        await local.put('resumes', {...?existing, 'id': j['id'], 'title': j['title'], 'filename': j['filename'],
          'fileType': j['file_type'], 'atsStatus': existing?['atsStatus'] ?? j['ats_status'],
          'addedAt': j['created_at'], 'isSample': false});
      }
      for (final j in results[2]) { await local.put('matches', Map<String, dynamic>.from(j['result'] as Map)); }
      await local.db.delete(local.db.jobsTable).go();
      for (final j in results[3]) { await local.put('jobs', j); }
      if (results[4].isNotEmpty) {
        final p = results[4].first;
        final current = (await local.read())['profile'] as Map;
        await local.setting('profile', {...current, 'name': p['name'], 'email': p['email'] ?? '',
          'headline': p['headline'], 'location': p['location'], 'targetRoles': p['target_roles'], 'scanQuota': p['scan_quota']});
      }
      if (!pending.any((q) => q.entity == 'saved_jobs')) {
        await local.setting('savedJobIds', results[5].map((j) => j['job_id']).toList());
      }
    });
    } catch (error) {
      onError?.call(error);
    }
  }

  Future<void> dispose() async {
    _disposed = true; _retry?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    await _network?.cancel(); await _mutations?.cancel();
    while (_running) { await Future<void>.delayed(const Duration(milliseconds: 10)); }
  }
}
