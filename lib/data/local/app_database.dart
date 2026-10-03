import 'package:drift/drift.dart';
part 'app_database.g.dart';

class ResumesTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get filename => text()();
  TextColumn get fileType => text()();
  TextColumn get atsStatus => text()();
  TextColumn get sanitizedText => text().withDefault(const Constant(''))();
  TextColumn get storagePath => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get domainJson => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class ApplicationsTable extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text().nullable()();
  TextColumn get company => text()();
  TextColumn get role => text()();
  TextColumn get location => text()();
  TextColumn get stage => text()();
  TextColumn get matchBadge => text().nullable()();
  TextColumn get link => text()();
  TextColumn get notes => text()();
  DateTimeColumn get appliedAt => dateTime()();
  DateTimeColumn get followUpAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(0))();
  TextColumn get domainJson => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class MatchesTable extends Table {
  TextColumn get id => text()();
  TextColumn get resumeId => text()();
  TextColumn get jobId => text().nullable()();
  TextColumn get role => text()();
  TextColumn get company => text()();
  IntColumn get overallScore => integer()();
  TextColumn get componentsJson => text()();
  TextColumn get matchedSkillsJson => text()();
  TextColumn get missingSkillsJson => text()();
  TextColumn get suggestionsJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get domainJson => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class JobsTable extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get company => text()();
  TextColumn get location => text()();
  TextColumn get mode => text()();
  TextColumn get type => text()();
  IntColumn get salaryMin => integer().nullable()();
  IntColumn get salaryMax => integer().nullable()();
  TextColumn get salaryPeriod => text()();
  TextColumn get skillsJson => text()();
  TextColumn get overview => text()();
  TextColumn get applyUrl => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get domainJson => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class OutboxQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get action => text()();
  TextColumn get payloadJson => text()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class SettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ResumesTable, ApplicationsTable, MatchesTable, JobsTable, OutboxQueueTable, SettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);
  @override
  int get schemaVersion => 1;
}

