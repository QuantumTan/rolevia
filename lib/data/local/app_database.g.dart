// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ResumesTableTable extends ResumesTable
    with TableInfo<$ResumesTableTable, ResumesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResumesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atsStatusMeta = const VerificationMeta(
    'atsStatus',
  );
  @override
  late final GeneratedColumn<String> atsStatus = GeneratedColumn<String>(
    'ats_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sanitizedTextMeta = const VerificationMeta(
    'sanitizedText',
  );
  @override
  late final GeneratedColumn<String> sanitizedText = GeneratedColumn<String>(
    'sanitized_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _domainJsonMeta = const VerificationMeta(
    'domainJson',
  );
  @override
  late final GeneratedColumn<String> domainJson = GeneratedColumn<String>(
    'domain_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    filename,
    fileType,
    atsStatus,
    sanitizedText,
    storagePath,
    addedAt,
    isSynced,
    deletedAt,
    domainJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resumes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResumesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('ats_status')) {
      context.handle(
        _atsStatusMeta,
        atsStatus.isAcceptableOrUnknown(data['ats_status']!, _atsStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_atsStatusMeta);
    }
    if (data.containsKey('sanitized_text')) {
      context.handle(
        _sanitizedTextMeta,
        sanitizedText.isAcceptableOrUnknown(
          data['sanitized_text']!,
          _sanitizedTextMeta,
        ),
      );
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('domain_json')) {
      context.handle(
        _domainJsonMeta,
        domainJson.isAcceptableOrUnknown(data['domain_json']!, _domainJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_domainJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResumesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResumesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      )!,
      atsStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ats_status'],
      )!,
      sanitizedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sanitized_text'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      domainJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_json'],
      )!,
    );
  }

  @override
  $ResumesTableTable createAlias(String alias) {
    return $ResumesTableTable(attachedDatabase, alias);
  }
}

class ResumesTableData extends DataClass
    implements Insertable<ResumesTableData> {
  final String id;
  final String title;
  final String filename;
  final String fileType;
  final String atsStatus;
  final String sanitizedText;
  final String? storagePath;
  final DateTime addedAt;
  final bool isSynced;
  final DateTime? deletedAt;
  final String domainJson;
  const ResumesTableData({
    required this.id,
    required this.title,
    required this.filename,
    required this.fileType,
    required this.atsStatus,
    required this.sanitizedText,
    this.storagePath,
    required this.addedAt,
    required this.isSynced,
    this.deletedAt,
    required this.domainJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['filename'] = Variable<String>(filename);
    map['file_type'] = Variable<String>(fileType);
    map['ats_status'] = Variable<String>(atsStatus);
    map['sanitized_text'] = Variable<String>(sanitizedText);
    if (!nullToAbsent || storagePath != null) {
      map['storage_path'] = Variable<String>(storagePath);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['domain_json'] = Variable<String>(domainJson);
    return map;
  }

  ResumesTableCompanion toCompanion(bool nullToAbsent) {
    return ResumesTableCompanion(
      id: Value(id),
      title: Value(title),
      filename: Value(filename),
      fileType: Value(fileType),
      atsStatus: Value(atsStatus),
      sanitizedText: Value(sanitizedText),
      storagePath: storagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePath),
      addedAt: Value(addedAt),
      isSynced: Value(isSynced),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      domainJson: Value(domainJson),
    );
  }

  factory ResumesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResumesTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      filename: serializer.fromJson<String>(json['filename']),
      fileType: serializer.fromJson<String>(json['fileType']),
      atsStatus: serializer.fromJson<String>(json['atsStatus']),
      sanitizedText: serializer.fromJson<String>(json['sanitizedText']),
      storagePath: serializer.fromJson<String?>(json['storagePath']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      domainJson: serializer.fromJson<String>(json['domainJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'filename': serializer.toJson<String>(filename),
      'fileType': serializer.toJson<String>(fileType),
      'atsStatus': serializer.toJson<String>(atsStatus),
      'sanitizedText': serializer.toJson<String>(sanitizedText),
      'storagePath': serializer.toJson<String?>(storagePath),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'domainJson': serializer.toJson<String>(domainJson),
    };
  }

  ResumesTableData copyWith({
    String? id,
    String? title,
    String? filename,
    String? fileType,
    String? atsStatus,
    String? sanitizedText,
    Value<String?> storagePath = const Value.absent(),
    DateTime? addedAt,
    bool? isSynced,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? domainJson,
  }) => ResumesTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    filename: filename ?? this.filename,
    fileType: fileType ?? this.fileType,
    atsStatus: atsStatus ?? this.atsStatus,
    sanitizedText: sanitizedText ?? this.sanitizedText,
    storagePath: storagePath.present ? storagePath.value : this.storagePath,
    addedAt: addedAt ?? this.addedAt,
    isSynced: isSynced ?? this.isSynced,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    domainJson: domainJson ?? this.domainJson,
  );
  ResumesTableData copyWithCompanion(ResumesTableCompanion data) {
    return ResumesTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      filename: data.filename.present ? data.filename.value : this.filename,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      atsStatus: data.atsStatus.present ? data.atsStatus.value : this.atsStatus,
      sanitizedText: data.sanitizedText.present
          ? data.sanitizedText.value
          : this.sanitizedText,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      domainJson: data.domainJson.present
          ? data.domainJson.value
          : this.domainJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResumesTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filename: $filename, ')
          ..write('fileType: $fileType, ')
          ..write('atsStatus: $atsStatus, ')
          ..write('sanitizedText: $sanitizedText, ')
          ..write('storagePath: $storagePath, ')
          ..write('addedAt: $addedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('domainJson: $domainJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    filename,
    fileType,
    atsStatus,
    sanitizedText,
    storagePath,
    addedAt,
    isSynced,
    deletedAt,
    domainJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResumesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.filename == this.filename &&
          other.fileType == this.fileType &&
          other.atsStatus == this.atsStatus &&
          other.sanitizedText == this.sanitizedText &&
          other.storagePath == this.storagePath &&
          other.addedAt == this.addedAt &&
          other.isSynced == this.isSynced &&
          other.deletedAt == this.deletedAt &&
          other.domainJson == this.domainJson);
}

class ResumesTableCompanion extends UpdateCompanion<ResumesTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> filename;
  final Value<String> fileType;
  final Value<String> atsStatus;
  final Value<String> sanitizedText;
  final Value<String?> storagePath;
  final Value<DateTime> addedAt;
  final Value<bool> isSynced;
  final Value<DateTime?> deletedAt;
  final Value<String> domainJson;
  final Value<int> rowid;
  const ResumesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.filename = const Value.absent(),
    this.fileType = const Value.absent(),
    this.atsStatus = const Value.absent(),
    this.sanitizedText = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.domainJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResumesTableCompanion.insert({
    required String id,
    required String title,
    required String filename,
    required String fileType,
    required String atsStatus,
    this.sanitizedText = const Value.absent(),
    this.storagePath = const Value.absent(),
    required DateTime addedAt,
    this.isSynced = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String domainJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       filename = Value(filename),
       fileType = Value(fileType),
       atsStatus = Value(atsStatus),
       addedAt = Value(addedAt),
       domainJson = Value(domainJson);
  static Insertable<ResumesTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? filename,
    Expression<String>? fileType,
    Expression<String>? atsStatus,
    Expression<String>? sanitizedText,
    Expression<String>? storagePath,
    Expression<DateTime>? addedAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? deletedAt,
    Expression<String>? domainJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (filename != null) 'filename': filename,
      if (fileType != null) 'file_type': fileType,
      if (atsStatus != null) 'ats_status': atsStatus,
      if (sanitizedText != null) 'sanitized_text': sanitizedText,
      if (storagePath != null) 'storage_path': storagePath,
      if (addedAt != null) 'added_at': addedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (domainJson != null) 'domain_json': domainJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResumesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? filename,
    Value<String>? fileType,
    Value<String>? atsStatus,
    Value<String>? sanitizedText,
    Value<String?>? storagePath,
    Value<DateTime>? addedAt,
    Value<bool>? isSynced,
    Value<DateTime?>? deletedAt,
    Value<String>? domainJson,
    Value<int>? rowid,
  }) {
    return ResumesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      filename: filename ?? this.filename,
      fileType: fileType ?? this.fileType,
      atsStatus: atsStatus ?? this.atsStatus,
      sanitizedText: sanitizedText ?? this.sanitizedText,
      storagePath: storagePath ?? this.storagePath,
      addedAt: addedAt ?? this.addedAt,
      isSynced: isSynced ?? this.isSynced,
      deletedAt: deletedAt ?? this.deletedAt,
      domainJson: domainJson ?? this.domainJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (atsStatus.present) {
      map['ats_status'] = Variable<String>(atsStatus.value);
    }
    if (sanitizedText.present) {
      map['sanitized_text'] = Variable<String>(sanitizedText.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (domainJson.present) {
      map['domain_json'] = Variable<String>(domainJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResumesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filename: $filename, ')
          ..write('fileType: $fileType, ')
          ..write('atsStatus: $atsStatus, ')
          ..write('sanitizedText: $sanitizedText, ')
          ..write('storagePath: $storagePath, ')
          ..write('addedAt: $addedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('domainJson: $domainJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApplicationsTableTable extends ApplicationsTable
    with TableInfo<$ApplicationsTableTable, ApplicationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApplicationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchBadgeMeta = const VerificationMeta(
    'matchBadge',
  );
  @override
  late final GeneratedColumn<String> matchBadge = GeneratedColumn<String>(
    'match_badge',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _followUpAtMeta = const VerificationMeta(
    'followUpAt',
  );
  @override
  late final GeneratedColumn<DateTime> followUpAt = GeneratedColumn<DateTime>(
    'follow_up_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _domainJsonMeta = const VerificationMeta(
    'domainJson',
  );
  @override
  late final GeneratedColumn<String> domainJson = GeneratedColumn<String>(
    'domain_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    company,
    role,
    location,
    stage,
    matchBadge,
    link,
    notes,
    appliedAt,
    followUpAt,
    updatedAt,
    version,
    domainJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'applications_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApplicationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('match_badge')) {
      context.handle(
        _matchBadgeMeta,
        matchBadge.isAcceptableOrUnknown(data['match_badge']!, _matchBadgeMeta),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('follow_up_at')) {
      context.handle(
        _followUpAtMeta,
        followUpAt.isAcceptableOrUnknown(
          data['follow_up_at']!,
          _followUpAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('domain_json')) {
      context.handle(
        _domainJsonMeta,
        domainJson.isAcceptableOrUnknown(data['domain_json']!, _domainJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_domainJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApplicationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApplicationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      ),
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      matchBadge: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_badge'],
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
      followUpAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}follow_up_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      domainJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_json'],
      )!,
    );
  }

  @override
  $ApplicationsTableTable createAlias(String alias) {
    return $ApplicationsTableTable(attachedDatabase, alias);
  }
}

class ApplicationsTableData extends DataClass
    implements Insertable<ApplicationsTableData> {
  final String id;
  final String? jobId;
  final String company;
  final String role;
  final String location;
  final String stage;
  final String? matchBadge;
  final String link;
  final String notes;
  final DateTime appliedAt;
  final DateTime? followUpAt;
  final DateTime updatedAt;
  final int version;
  final String domainJson;
  const ApplicationsTableData({
    required this.id,
    this.jobId,
    required this.company,
    required this.role,
    required this.location,
    required this.stage,
    this.matchBadge,
    required this.link,
    required this.notes,
    required this.appliedAt,
    this.followUpAt,
    required this.updatedAt,
    required this.version,
    required this.domainJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || jobId != null) {
      map['job_id'] = Variable<String>(jobId);
    }
    map['company'] = Variable<String>(company);
    map['role'] = Variable<String>(role);
    map['location'] = Variable<String>(location);
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || matchBadge != null) {
      map['match_badge'] = Variable<String>(matchBadge);
    }
    map['link'] = Variable<String>(link);
    map['notes'] = Variable<String>(notes);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    if (!nullToAbsent || followUpAt != null) {
      map['follow_up_at'] = Variable<DateTime>(followUpAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['domain_json'] = Variable<String>(domainJson);
    return map;
  }

  ApplicationsTableCompanion toCompanion(bool nullToAbsent) {
    return ApplicationsTableCompanion(
      id: Value(id),
      jobId: jobId == null && nullToAbsent
          ? const Value.absent()
          : Value(jobId),
      company: Value(company),
      role: Value(role),
      location: Value(location),
      stage: Value(stage),
      matchBadge: matchBadge == null && nullToAbsent
          ? const Value.absent()
          : Value(matchBadge),
      link: Value(link),
      notes: Value(notes),
      appliedAt: Value(appliedAt),
      followUpAt: followUpAt == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      domainJson: Value(domainJson),
    );
  }

  factory ApplicationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApplicationsTableData(
      id: serializer.fromJson<String>(json['id']),
      jobId: serializer.fromJson<String?>(json['jobId']),
      company: serializer.fromJson<String>(json['company']),
      role: serializer.fromJson<String>(json['role']),
      location: serializer.fromJson<String>(json['location']),
      stage: serializer.fromJson<String>(json['stage']),
      matchBadge: serializer.fromJson<String?>(json['matchBadge']),
      link: serializer.fromJson<String>(json['link']),
      notes: serializer.fromJson<String>(json['notes']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      followUpAt: serializer.fromJson<DateTime?>(json['followUpAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      domainJson: serializer.fromJson<String>(json['domainJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobId': serializer.toJson<String?>(jobId),
      'company': serializer.toJson<String>(company),
      'role': serializer.toJson<String>(role),
      'location': serializer.toJson<String>(location),
      'stage': serializer.toJson<String>(stage),
      'matchBadge': serializer.toJson<String?>(matchBadge),
      'link': serializer.toJson<String>(link),
      'notes': serializer.toJson<String>(notes),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'followUpAt': serializer.toJson<DateTime?>(followUpAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'domainJson': serializer.toJson<String>(domainJson),
    };
  }

  ApplicationsTableData copyWith({
    String? id,
    Value<String?> jobId = const Value.absent(),
    String? company,
    String? role,
    String? location,
    String? stage,
    Value<String?> matchBadge = const Value.absent(),
    String? link,
    String? notes,
    DateTime? appliedAt,
    Value<DateTime?> followUpAt = const Value.absent(),
    DateTime? updatedAt,
    int? version,
    String? domainJson,
  }) => ApplicationsTableData(
    id: id ?? this.id,
    jobId: jobId.present ? jobId.value : this.jobId,
    company: company ?? this.company,
    role: role ?? this.role,
    location: location ?? this.location,
    stage: stage ?? this.stage,
    matchBadge: matchBadge.present ? matchBadge.value : this.matchBadge,
    link: link ?? this.link,
    notes: notes ?? this.notes,
    appliedAt: appliedAt ?? this.appliedAt,
    followUpAt: followUpAt.present ? followUpAt.value : this.followUpAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    domainJson: domainJson ?? this.domainJson,
  );
  ApplicationsTableData copyWithCompanion(ApplicationsTableCompanion data) {
    return ApplicationsTableData(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      company: data.company.present ? data.company.value : this.company,
      role: data.role.present ? data.role.value : this.role,
      location: data.location.present ? data.location.value : this.location,
      stage: data.stage.present ? data.stage.value : this.stage,
      matchBadge: data.matchBadge.present
          ? data.matchBadge.value
          : this.matchBadge,
      link: data.link.present ? data.link.value : this.link,
      notes: data.notes.present ? data.notes.value : this.notes,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      followUpAt: data.followUpAt.present
          ? data.followUpAt.value
          : this.followUpAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      domainJson: data.domainJson.present
          ? data.domainJson.value
          : this.domainJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApplicationsTableData(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('company: $company, ')
          ..write('role: $role, ')
          ..write('location: $location, ')
          ..write('stage: $stage, ')
          ..write('matchBadge: $matchBadge, ')
          ..write('link: $link, ')
          ..write('notes: $notes, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('followUpAt: $followUpAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('domainJson: $domainJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    company,
    role,
    location,
    stage,
    matchBadge,
    link,
    notes,
    appliedAt,
    followUpAt,
    updatedAt,
    version,
    domainJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApplicationsTableData &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.company == this.company &&
          other.role == this.role &&
          other.location == this.location &&
          other.stage == this.stage &&
          other.matchBadge == this.matchBadge &&
          other.link == this.link &&
          other.notes == this.notes &&
          other.appliedAt == this.appliedAt &&
          other.followUpAt == this.followUpAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.domainJson == this.domainJson);
}

class ApplicationsTableCompanion
    extends UpdateCompanion<ApplicationsTableData> {
  final Value<String> id;
  final Value<String?> jobId;
  final Value<String> company;
  final Value<String> role;
  final Value<String> location;
  final Value<String> stage;
  final Value<String?> matchBadge;
  final Value<String> link;
  final Value<String> notes;
  final Value<DateTime> appliedAt;
  final Value<DateTime?> followUpAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<String> domainJson;
  final Value<int> rowid;
  const ApplicationsTableCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.company = const Value.absent(),
    this.role = const Value.absent(),
    this.location = const Value.absent(),
    this.stage = const Value.absent(),
    this.matchBadge = const Value.absent(),
    this.link = const Value.absent(),
    this.notes = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.followUpAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.domainJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApplicationsTableCompanion.insert({
    required String id,
    this.jobId = const Value.absent(),
    required String company,
    required String role,
    required String location,
    required String stage,
    this.matchBadge = const Value.absent(),
    required String link,
    required String notes,
    required DateTime appliedAt,
    this.followUpAt = const Value.absent(),
    required DateTime updatedAt,
    this.version = const Value.absent(),
    required String domainJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       company = Value(company),
       role = Value(role),
       location = Value(location),
       stage = Value(stage),
       link = Value(link),
       notes = Value(notes),
       appliedAt = Value(appliedAt),
       updatedAt = Value(updatedAt),
       domainJson = Value(domainJson);
  static Insertable<ApplicationsTableData> custom({
    Expression<String>? id,
    Expression<String>? jobId,
    Expression<String>? company,
    Expression<String>? role,
    Expression<String>? location,
    Expression<String>? stage,
    Expression<String>? matchBadge,
    Expression<String>? link,
    Expression<String>? notes,
    Expression<DateTime>? appliedAt,
    Expression<DateTime>? followUpAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<String>? domainJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (company != null) 'company': company,
      if (role != null) 'role': role,
      if (location != null) 'location': location,
      if (stage != null) 'stage': stage,
      if (matchBadge != null) 'match_badge': matchBadge,
      if (link != null) 'link': link,
      if (notes != null) 'notes': notes,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (followUpAt != null) 'follow_up_at': followUpAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (domainJson != null) 'domain_json': domainJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApplicationsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? jobId,
    Value<String>? company,
    Value<String>? role,
    Value<String>? location,
    Value<String>? stage,
    Value<String?>? matchBadge,
    Value<String>? link,
    Value<String>? notes,
    Value<DateTime>? appliedAt,
    Value<DateTime?>? followUpAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<String>? domainJson,
    Value<int>? rowid,
  }) {
    return ApplicationsTableCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      company: company ?? this.company,
      role: role ?? this.role,
      location: location ?? this.location,
      stage: stage ?? this.stage,
      matchBadge: matchBadge ?? this.matchBadge,
      link: link ?? this.link,
      notes: notes ?? this.notes,
      appliedAt: appliedAt ?? this.appliedAt,
      followUpAt: followUpAt ?? this.followUpAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      domainJson: domainJson ?? this.domainJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (matchBadge.present) {
      map['match_badge'] = Variable<String>(matchBadge.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (followUpAt.present) {
      map['follow_up_at'] = Variable<DateTime>(followUpAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (domainJson.present) {
      map['domain_json'] = Variable<String>(domainJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApplicationsTableCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('company: $company, ')
          ..write('role: $role, ')
          ..write('location: $location, ')
          ..write('stage: $stage, ')
          ..write('matchBadge: $matchBadge, ')
          ..write('link: $link, ')
          ..write('notes: $notes, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('followUpAt: $followUpAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('domainJson: $domainJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTableTable extends MatchesTable
    with TableInfo<$MatchesTableTable, MatchesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resumeIdMeta = const VerificationMeta(
    'resumeId',
  );
  @override
  late final GeneratedColumn<String> resumeId = GeneratedColumn<String>(
    'resume_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  @override
  late final GeneratedColumn<int> overallScore = GeneratedColumn<int>(
    'overall_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _componentsJsonMeta = const VerificationMeta(
    'componentsJson',
  );
  @override
  late final GeneratedColumn<String> componentsJson = GeneratedColumn<String>(
    'components_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchedSkillsJsonMeta = const VerificationMeta(
    'matchedSkillsJson',
  );
  @override
  late final GeneratedColumn<String> matchedSkillsJson =
      GeneratedColumn<String>(
        'matched_skills_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _missingSkillsJsonMeta = const VerificationMeta(
    'missingSkillsJson',
  );
  @override
  late final GeneratedColumn<String> missingSkillsJson =
      GeneratedColumn<String>(
        'missing_skills_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _suggestionsJsonMeta = const VerificationMeta(
    'suggestionsJson',
  );
  @override
  late final GeneratedColumn<String> suggestionsJson = GeneratedColumn<String>(
    'suggestions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainJsonMeta = const VerificationMeta(
    'domainJson',
  );
  @override
  late final GeneratedColumn<String> domainJson = GeneratedColumn<String>(
    'domain_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    resumeId,
    jobId,
    role,
    company,
    overallScore,
    componentsJson,
    matchedSkillsJson,
    missingSkillsJson,
    suggestionsJson,
    createdAt,
    domainJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('resume_id')) {
      context.handle(
        _resumeIdMeta,
        resumeId.isAcceptableOrUnknown(data['resume_id']!, _resumeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resumeIdMeta);
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overallScoreMeta);
    }
    if (data.containsKey('components_json')) {
      context.handle(
        _componentsJsonMeta,
        componentsJson.isAcceptableOrUnknown(
          data['components_json']!,
          _componentsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_componentsJsonMeta);
    }
    if (data.containsKey('matched_skills_json')) {
      context.handle(
        _matchedSkillsJsonMeta,
        matchedSkillsJson.isAcceptableOrUnknown(
          data['matched_skills_json']!,
          _matchedSkillsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_matchedSkillsJsonMeta);
    }
    if (data.containsKey('missing_skills_json')) {
      context.handle(
        _missingSkillsJsonMeta,
        missingSkillsJson.isAcceptableOrUnknown(
          data['missing_skills_json']!,
          _missingSkillsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_missingSkillsJsonMeta);
    }
    if (data.containsKey('suggestions_json')) {
      context.handle(
        _suggestionsJsonMeta,
        suggestionsJson.isAcceptableOrUnknown(
          data['suggestions_json']!,
          _suggestionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suggestionsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('domain_json')) {
      context.handle(
        _domainJsonMeta,
        domainJson.isAcceptableOrUnknown(data['domain_json']!, _domainJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_domainJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      resumeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resume_id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overall_score'],
      )!,
      componentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}components_json'],
      )!,
      matchedSkillsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_skills_json'],
      )!,
      missingSkillsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}missing_skills_json'],
      )!,
      suggestionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggestions_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      domainJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_json'],
      )!,
    );
  }

  @override
  $MatchesTableTable createAlias(String alias) {
    return $MatchesTableTable(attachedDatabase, alias);
  }
}

class MatchesTableData extends DataClass
    implements Insertable<MatchesTableData> {
  final String id;
  final String resumeId;
  final String? jobId;
  final String role;
  final String company;
  final int overallScore;
  final String componentsJson;
  final String matchedSkillsJson;
  final String missingSkillsJson;
  final String suggestionsJson;
  final DateTime createdAt;
  final String domainJson;
  const MatchesTableData({
    required this.id,
    required this.resumeId,
    this.jobId,
    required this.role,
    required this.company,
    required this.overallScore,
    required this.componentsJson,
    required this.matchedSkillsJson,
    required this.missingSkillsJson,
    required this.suggestionsJson,
    required this.createdAt,
    required this.domainJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['resume_id'] = Variable<String>(resumeId);
    if (!nullToAbsent || jobId != null) {
      map['job_id'] = Variable<String>(jobId);
    }
    map['role'] = Variable<String>(role);
    map['company'] = Variable<String>(company);
    map['overall_score'] = Variable<int>(overallScore);
    map['components_json'] = Variable<String>(componentsJson);
    map['matched_skills_json'] = Variable<String>(matchedSkillsJson);
    map['missing_skills_json'] = Variable<String>(missingSkillsJson);
    map['suggestions_json'] = Variable<String>(suggestionsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['domain_json'] = Variable<String>(domainJson);
    return map;
  }

  MatchesTableCompanion toCompanion(bool nullToAbsent) {
    return MatchesTableCompanion(
      id: Value(id),
      resumeId: Value(resumeId),
      jobId: jobId == null && nullToAbsent
          ? const Value.absent()
          : Value(jobId),
      role: Value(role),
      company: Value(company),
      overallScore: Value(overallScore),
      componentsJson: Value(componentsJson),
      matchedSkillsJson: Value(matchedSkillsJson),
      missingSkillsJson: Value(missingSkillsJson),
      suggestionsJson: Value(suggestionsJson),
      createdAt: Value(createdAt),
      domainJson: Value(domainJson),
    );
  }

  factory MatchesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchesTableData(
      id: serializer.fromJson<String>(json['id']),
      resumeId: serializer.fromJson<String>(json['resumeId']),
      jobId: serializer.fromJson<String?>(json['jobId']),
      role: serializer.fromJson<String>(json['role']),
      company: serializer.fromJson<String>(json['company']),
      overallScore: serializer.fromJson<int>(json['overallScore']),
      componentsJson: serializer.fromJson<String>(json['componentsJson']),
      matchedSkillsJson: serializer.fromJson<String>(json['matchedSkillsJson']),
      missingSkillsJson: serializer.fromJson<String>(json['missingSkillsJson']),
      suggestionsJson: serializer.fromJson<String>(json['suggestionsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      domainJson: serializer.fromJson<String>(json['domainJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'resumeId': serializer.toJson<String>(resumeId),
      'jobId': serializer.toJson<String?>(jobId),
      'role': serializer.toJson<String>(role),
      'company': serializer.toJson<String>(company),
      'overallScore': serializer.toJson<int>(overallScore),
      'componentsJson': serializer.toJson<String>(componentsJson),
      'matchedSkillsJson': serializer.toJson<String>(matchedSkillsJson),
      'missingSkillsJson': serializer.toJson<String>(missingSkillsJson),
      'suggestionsJson': serializer.toJson<String>(suggestionsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'domainJson': serializer.toJson<String>(domainJson),
    };
  }

  MatchesTableData copyWith({
    String? id,
    String? resumeId,
    Value<String?> jobId = const Value.absent(),
    String? role,
    String? company,
    int? overallScore,
    String? componentsJson,
    String? matchedSkillsJson,
    String? missingSkillsJson,
    String? suggestionsJson,
    DateTime? createdAt,
    String? domainJson,
  }) => MatchesTableData(
    id: id ?? this.id,
    resumeId: resumeId ?? this.resumeId,
    jobId: jobId.present ? jobId.value : this.jobId,
    role: role ?? this.role,
    company: company ?? this.company,
    overallScore: overallScore ?? this.overallScore,
    componentsJson: componentsJson ?? this.componentsJson,
    matchedSkillsJson: matchedSkillsJson ?? this.matchedSkillsJson,
    missingSkillsJson: missingSkillsJson ?? this.missingSkillsJson,
    suggestionsJson: suggestionsJson ?? this.suggestionsJson,
    createdAt: createdAt ?? this.createdAt,
    domainJson: domainJson ?? this.domainJson,
  );
  MatchesTableData copyWithCompanion(MatchesTableCompanion data) {
    return MatchesTableData(
      id: data.id.present ? data.id.value : this.id,
      resumeId: data.resumeId.present ? data.resumeId.value : this.resumeId,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      role: data.role.present ? data.role.value : this.role,
      company: data.company.present ? data.company.value : this.company,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      componentsJson: data.componentsJson.present
          ? data.componentsJson.value
          : this.componentsJson,
      matchedSkillsJson: data.matchedSkillsJson.present
          ? data.matchedSkillsJson.value
          : this.matchedSkillsJson,
      missingSkillsJson: data.missingSkillsJson.present
          ? data.missingSkillsJson.value
          : this.missingSkillsJson,
      suggestionsJson: data.suggestionsJson.present
          ? data.suggestionsJson.value
          : this.suggestionsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      domainJson: data.domainJson.present
          ? data.domainJson.value
          : this.domainJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchesTableData(')
          ..write('id: $id, ')
          ..write('resumeId: $resumeId, ')
          ..write('jobId: $jobId, ')
          ..write('role: $role, ')
          ..write('company: $company, ')
          ..write('overallScore: $overallScore, ')
          ..write('componentsJson: $componentsJson, ')
          ..write('matchedSkillsJson: $matchedSkillsJson, ')
          ..write('missingSkillsJson: $missingSkillsJson, ')
          ..write('suggestionsJson: $suggestionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('domainJson: $domainJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    resumeId,
    jobId,
    role,
    company,
    overallScore,
    componentsJson,
    matchedSkillsJson,
    missingSkillsJson,
    suggestionsJson,
    createdAt,
    domainJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchesTableData &&
          other.id == this.id &&
          other.resumeId == this.resumeId &&
          other.jobId == this.jobId &&
          other.role == this.role &&
          other.company == this.company &&
          other.overallScore == this.overallScore &&
          other.componentsJson == this.componentsJson &&
          other.matchedSkillsJson == this.matchedSkillsJson &&
          other.missingSkillsJson == this.missingSkillsJson &&
          other.suggestionsJson == this.suggestionsJson &&
          other.createdAt == this.createdAt &&
          other.domainJson == this.domainJson);
}

class MatchesTableCompanion extends UpdateCompanion<MatchesTableData> {
  final Value<String> id;
  final Value<String> resumeId;
  final Value<String?> jobId;
  final Value<String> role;
  final Value<String> company;
  final Value<int> overallScore;
  final Value<String> componentsJson;
  final Value<String> matchedSkillsJson;
  final Value<String> missingSkillsJson;
  final Value<String> suggestionsJson;
  final Value<DateTime> createdAt;
  final Value<String> domainJson;
  final Value<int> rowid;
  const MatchesTableCompanion({
    this.id = const Value.absent(),
    this.resumeId = const Value.absent(),
    this.jobId = const Value.absent(),
    this.role = const Value.absent(),
    this.company = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.componentsJson = const Value.absent(),
    this.matchedSkillsJson = const Value.absent(),
    this.missingSkillsJson = const Value.absent(),
    this.suggestionsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.domainJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesTableCompanion.insert({
    required String id,
    required String resumeId,
    this.jobId = const Value.absent(),
    required String role,
    required String company,
    required int overallScore,
    required String componentsJson,
    required String matchedSkillsJson,
    required String missingSkillsJson,
    required String suggestionsJson,
    required DateTime createdAt,
    required String domainJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       resumeId = Value(resumeId),
       role = Value(role),
       company = Value(company),
       overallScore = Value(overallScore),
       componentsJson = Value(componentsJson),
       matchedSkillsJson = Value(matchedSkillsJson),
       missingSkillsJson = Value(missingSkillsJson),
       suggestionsJson = Value(suggestionsJson),
       createdAt = Value(createdAt),
       domainJson = Value(domainJson);
  static Insertable<MatchesTableData> custom({
    Expression<String>? id,
    Expression<String>? resumeId,
    Expression<String>? jobId,
    Expression<String>? role,
    Expression<String>? company,
    Expression<int>? overallScore,
    Expression<String>? componentsJson,
    Expression<String>? matchedSkillsJson,
    Expression<String>? missingSkillsJson,
    Expression<String>? suggestionsJson,
    Expression<DateTime>? createdAt,
    Expression<String>? domainJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resumeId != null) 'resume_id': resumeId,
      if (jobId != null) 'job_id': jobId,
      if (role != null) 'role': role,
      if (company != null) 'company': company,
      if (overallScore != null) 'overall_score': overallScore,
      if (componentsJson != null) 'components_json': componentsJson,
      if (matchedSkillsJson != null) 'matched_skills_json': matchedSkillsJson,
      if (missingSkillsJson != null) 'missing_skills_json': missingSkillsJson,
      if (suggestionsJson != null) 'suggestions_json': suggestionsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (domainJson != null) 'domain_json': domainJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? resumeId,
    Value<String?>? jobId,
    Value<String>? role,
    Value<String>? company,
    Value<int>? overallScore,
    Value<String>? componentsJson,
    Value<String>? matchedSkillsJson,
    Value<String>? missingSkillsJson,
    Value<String>? suggestionsJson,
    Value<DateTime>? createdAt,
    Value<String>? domainJson,
    Value<int>? rowid,
  }) {
    return MatchesTableCompanion(
      id: id ?? this.id,
      resumeId: resumeId ?? this.resumeId,
      jobId: jobId ?? this.jobId,
      role: role ?? this.role,
      company: company ?? this.company,
      overallScore: overallScore ?? this.overallScore,
      componentsJson: componentsJson ?? this.componentsJson,
      matchedSkillsJson: matchedSkillsJson ?? this.matchedSkillsJson,
      missingSkillsJson: missingSkillsJson ?? this.missingSkillsJson,
      suggestionsJson: suggestionsJson ?? this.suggestionsJson,
      createdAt: createdAt ?? this.createdAt,
      domainJson: domainJson ?? this.domainJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (resumeId.present) {
      map['resume_id'] = Variable<String>(resumeId.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<int>(overallScore.value);
    }
    if (componentsJson.present) {
      map['components_json'] = Variable<String>(componentsJson.value);
    }
    if (matchedSkillsJson.present) {
      map['matched_skills_json'] = Variable<String>(matchedSkillsJson.value);
    }
    if (missingSkillsJson.present) {
      map['missing_skills_json'] = Variable<String>(missingSkillsJson.value);
    }
    if (suggestionsJson.present) {
      map['suggestions_json'] = Variable<String>(suggestionsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (domainJson.present) {
      map['domain_json'] = Variable<String>(domainJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesTableCompanion(')
          ..write('id: $id, ')
          ..write('resumeId: $resumeId, ')
          ..write('jobId: $jobId, ')
          ..write('role: $role, ')
          ..write('company: $company, ')
          ..write('overallScore: $overallScore, ')
          ..write('componentsJson: $componentsJson, ')
          ..write('matchedSkillsJson: $matchedSkillsJson, ')
          ..write('missingSkillsJson: $missingSkillsJson, ')
          ..write('suggestionsJson: $suggestionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('domainJson: $domainJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobsTableTable extends JobsTable
    with TableInfo<$JobsTableTable, JobsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salaryMinMeta = const VerificationMeta(
    'salaryMin',
  );
  @override
  late final GeneratedColumn<int> salaryMin = GeneratedColumn<int>(
    'salary_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryMaxMeta = const VerificationMeta(
    'salaryMax',
  );
  @override
  late final GeneratedColumn<int> salaryMax = GeneratedColumn<int>(
    'salary_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryPeriodMeta = const VerificationMeta(
    'salaryPeriod',
  );
  @override
  late final GeneratedColumn<String> salaryPeriod = GeneratedColumn<String>(
    'salary_period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skillsJsonMeta = const VerificationMeta(
    'skillsJson',
  );
  @override
  late final GeneratedColumn<String> skillsJson = GeneratedColumn<String>(
    'skills_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applyUrlMeta = const VerificationMeta(
    'applyUrl',
  );
  @override
  late final GeneratedColumn<String> applyUrl = GeneratedColumn<String>(
    'apply_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainJsonMeta = const VerificationMeta(
    'domainJson',
  );
  @override
  late final GeneratedColumn<String> domainJson = GeneratedColumn<String>(
    'domain_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    role,
    company,
    location,
    mode,
    type,
    salaryMin,
    salaryMax,
    salaryPeriod,
    skillsJson,
    overview,
    applyUrl,
    latitude,
    longitude,
    createdAt,
    domainJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('salary_min')) {
      context.handle(
        _salaryMinMeta,
        salaryMin.isAcceptableOrUnknown(data['salary_min']!, _salaryMinMeta),
      );
    }
    if (data.containsKey('salary_max')) {
      context.handle(
        _salaryMaxMeta,
        salaryMax.isAcceptableOrUnknown(data['salary_max']!, _salaryMaxMeta),
      );
    }
    if (data.containsKey('salary_period')) {
      context.handle(
        _salaryPeriodMeta,
        salaryPeriod.isAcceptableOrUnknown(
          data['salary_period']!,
          _salaryPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salaryPeriodMeta);
    }
    if (data.containsKey('skills_json')) {
      context.handle(
        _skillsJsonMeta,
        skillsJson.isAcceptableOrUnknown(data['skills_json']!, _skillsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_skillsJsonMeta);
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    } else if (isInserting) {
      context.missing(_overviewMeta);
    }
    if (data.containsKey('apply_url')) {
      context.handle(
        _applyUrlMeta,
        applyUrl.isAcceptableOrUnknown(data['apply_url']!, _applyUrlMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('domain_json')) {
      context.handle(
        _domainJsonMeta,
        domainJson.isAcceptableOrUnknown(data['domain_json']!, _domainJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_domainJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      salaryMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_min'],
      ),
      salaryMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_max'],
      ),
      salaryPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salary_period'],
      )!,
      skillsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skills_json'],
      )!,
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      )!,
      applyUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apply_url'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      domainJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_json'],
      )!,
    );
  }

  @override
  $JobsTableTable createAlias(String alias) {
    return $JobsTableTable(attachedDatabase, alias);
  }
}

class JobsTableData extends DataClass implements Insertable<JobsTableData> {
  final String id;
  final String role;
  final String company;
  final String location;
  final String mode;
  final String type;
  final int? salaryMin;
  final int? salaryMax;
  final String salaryPeriod;
  final String skillsJson;
  final String overview;
  final String? applyUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final String domainJson;
  const JobsTableData({
    required this.id,
    required this.role,
    required this.company,
    required this.location,
    required this.mode,
    required this.type,
    this.salaryMin,
    this.salaryMax,
    required this.salaryPeriod,
    required this.skillsJson,
    required this.overview,
    this.applyUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.domainJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    map['company'] = Variable<String>(company);
    map['location'] = Variable<String>(location);
    map['mode'] = Variable<String>(mode);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || salaryMin != null) {
      map['salary_min'] = Variable<int>(salaryMin);
    }
    if (!nullToAbsent || salaryMax != null) {
      map['salary_max'] = Variable<int>(salaryMax);
    }
    map['salary_period'] = Variable<String>(salaryPeriod);
    map['skills_json'] = Variable<String>(skillsJson);
    map['overview'] = Variable<String>(overview);
    if (!nullToAbsent || applyUrl != null) {
      map['apply_url'] = Variable<String>(applyUrl);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['domain_json'] = Variable<String>(domainJson);
    return map;
  }

  JobsTableCompanion toCompanion(bool nullToAbsent) {
    return JobsTableCompanion(
      id: Value(id),
      role: Value(role),
      company: Value(company),
      location: Value(location),
      mode: Value(mode),
      type: Value(type),
      salaryMin: salaryMin == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryMin),
      salaryMax: salaryMax == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryMax),
      salaryPeriod: Value(salaryPeriod),
      skillsJson: Value(skillsJson),
      overview: Value(overview),
      applyUrl: applyUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(applyUrl),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      createdAt: Value(createdAt),
      domainJson: Value(domainJson),
    );
  }

  factory JobsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobsTableData(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      company: serializer.fromJson<String>(json['company']),
      location: serializer.fromJson<String>(json['location']),
      mode: serializer.fromJson<String>(json['mode']),
      type: serializer.fromJson<String>(json['type']),
      salaryMin: serializer.fromJson<int?>(json['salaryMin']),
      salaryMax: serializer.fromJson<int?>(json['salaryMax']),
      salaryPeriod: serializer.fromJson<String>(json['salaryPeriod']),
      skillsJson: serializer.fromJson<String>(json['skillsJson']),
      overview: serializer.fromJson<String>(json['overview']),
      applyUrl: serializer.fromJson<String?>(json['applyUrl']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      domainJson: serializer.fromJson<String>(json['domainJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'company': serializer.toJson<String>(company),
      'location': serializer.toJson<String>(location),
      'mode': serializer.toJson<String>(mode),
      'type': serializer.toJson<String>(type),
      'salaryMin': serializer.toJson<int?>(salaryMin),
      'salaryMax': serializer.toJson<int?>(salaryMax),
      'salaryPeriod': serializer.toJson<String>(salaryPeriod),
      'skillsJson': serializer.toJson<String>(skillsJson),
      'overview': serializer.toJson<String>(overview),
      'applyUrl': serializer.toJson<String?>(applyUrl),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'domainJson': serializer.toJson<String>(domainJson),
    };
  }

  JobsTableData copyWith({
    String? id,
    String? role,
    String? company,
    String? location,
    String? mode,
    String? type,
    Value<int?> salaryMin = const Value.absent(),
    Value<int?> salaryMax = const Value.absent(),
    String? salaryPeriod,
    String? skillsJson,
    String? overview,
    Value<String?> applyUrl = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    DateTime? createdAt,
    String? domainJson,
  }) => JobsTableData(
    id: id ?? this.id,
    role: role ?? this.role,
    company: company ?? this.company,
    location: location ?? this.location,
    mode: mode ?? this.mode,
    type: type ?? this.type,
    salaryMin: salaryMin.present ? salaryMin.value : this.salaryMin,
    salaryMax: salaryMax.present ? salaryMax.value : this.salaryMax,
    salaryPeriod: salaryPeriod ?? this.salaryPeriod,
    skillsJson: skillsJson ?? this.skillsJson,
    overview: overview ?? this.overview,
    applyUrl: applyUrl.present ? applyUrl.value : this.applyUrl,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    createdAt: createdAt ?? this.createdAt,
    domainJson: domainJson ?? this.domainJson,
  );
  JobsTableData copyWithCompanion(JobsTableCompanion data) {
    return JobsTableData(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      company: data.company.present ? data.company.value : this.company,
      location: data.location.present ? data.location.value : this.location,
      mode: data.mode.present ? data.mode.value : this.mode,
      type: data.type.present ? data.type.value : this.type,
      salaryMin: data.salaryMin.present ? data.salaryMin.value : this.salaryMin,
      salaryMax: data.salaryMax.present ? data.salaryMax.value : this.salaryMax,
      salaryPeriod: data.salaryPeriod.present
          ? data.salaryPeriod.value
          : this.salaryPeriod,
      skillsJson: data.skillsJson.present
          ? data.skillsJson.value
          : this.skillsJson,
      overview: data.overview.present ? data.overview.value : this.overview,
      applyUrl: data.applyUrl.present ? data.applyUrl.value : this.applyUrl,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      domainJson: data.domainJson.present
          ? data.domainJson.value
          : this.domainJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobsTableData(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('company: $company, ')
          ..write('location: $location, ')
          ..write('mode: $mode, ')
          ..write('type: $type, ')
          ..write('salaryMin: $salaryMin, ')
          ..write('salaryMax: $salaryMax, ')
          ..write('salaryPeriod: $salaryPeriod, ')
          ..write('skillsJson: $skillsJson, ')
          ..write('overview: $overview, ')
          ..write('applyUrl: $applyUrl, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('domainJson: $domainJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    role,
    company,
    location,
    mode,
    type,
    salaryMin,
    salaryMax,
    salaryPeriod,
    skillsJson,
    overview,
    applyUrl,
    latitude,
    longitude,
    createdAt,
    domainJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobsTableData &&
          other.id == this.id &&
          other.role == this.role &&
          other.company == this.company &&
          other.location == this.location &&
          other.mode == this.mode &&
          other.type == this.type &&
          other.salaryMin == this.salaryMin &&
          other.salaryMax == this.salaryMax &&
          other.salaryPeriod == this.salaryPeriod &&
          other.skillsJson == this.skillsJson &&
          other.overview == this.overview &&
          other.applyUrl == this.applyUrl &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.domainJson == this.domainJson);
}

class JobsTableCompanion extends UpdateCompanion<JobsTableData> {
  final Value<String> id;
  final Value<String> role;
  final Value<String> company;
  final Value<String> location;
  final Value<String> mode;
  final Value<String> type;
  final Value<int?> salaryMin;
  final Value<int?> salaryMax;
  final Value<String> salaryPeriod;
  final Value<String> skillsJson;
  final Value<String> overview;
  final Value<String?> applyUrl;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> createdAt;
  final Value<String> domainJson;
  final Value<int> rowid;
  const JobsTableCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.company = const Value.absent(),
    this.location = const Value.absent(),
    this.mode = const Value.absent(),
    this.type = const Value.absent(),
    this.salaryMin = const Value.absent(),
    this.salaryMax = const Value.absent(),
    this.salaryPeriod = const Value.absent(),
    this.skillsJson = const Value.absent(),
    this.overview = const Value.absent(),
    this.applyUrl = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.domainJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsTableCompanion.insert({
    required String id,
    required String role,
    required String company,
    required String location,
    required String mode,
    required String type,
    this.salaryMin = const Value.absent(),
    this.salaryMax = const Value.absent(),
    required String salaryPeriod,
    required String skillsJson,
    required String overview,
    this.applyUrl = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required DateTime createdAt,
    required String domainJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role),
       company = Value(company),
       location = Value(location),
       mode = Value(mode),
       type = Value(type),
       salaryPeriod = Value(salaryPeriod),
       skillsJson = Value(skillsJson),
       overview = Value(overview),
       createdAt = Value(createdAt),
       domainJson = Value(domainJson);
  static Insertable<JobsTableData> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? company,
    Expression<String>? location,
    Expression<String>? mode,
    Expression<String>? type,
    Expression<int>? salaryMin,
    Expression<int>? salaryMax,
    Expression<String>? salaryPeriod,
    Expression<String>? skillsJson,
    Expression<String>? overview,
    Expression<String>? applyUrl,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<String>? domainJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (company != null) 'company': company,
      if (location != null) 'location': location,
      if (mode != null) 'mode': mode,
      if (type != null) 'type': type,
      if (salaryMin != null) 'salary_min': salaryMin,
      if (salaryMax != null) 'salary_max': salaryMax,
      if (salaryPeriod != null) 'salary_period': salaryPeriod,
      if (skillsJson != null) 'skills_json': skillsJson,
      if (overview != null) 'overview': overview,
      if (applyUrl != null) 'apply_url': applyUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (domainJson != null) 'domain_json': domainJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? role,
    Value<String>? company,
    Value<String>? location,
    Value<String>? mode,
    Value<String>? type,
    Value<int?>? salaryMin,
    Value<int?>? salaryMax,
    Value<String>? salaryPeriod,
    Value<String>? skillsJson,
    Value<String>? overview,
    Value<String?>? applyUrl,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<DateTime>? createdAt,
    Value<String>? domainJson,
    Value<int>? rowid,
  }) {
    return JobsTableCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      company: company ?? this.company,
      location: location ?? this.location,
      mode: mode ?? this.mode,
      type: type ?? this.type,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      skillsJson: skillsJson ?? this.skillsJson,
      overview: overview ?? this.overview,
      applyUrl: applyUrl ?? this.applyUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      domainJson: domainJson ?? this.domainJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (salaryMin.present) {
      map['salary_min'] = Variable<int>(salaryMin.value);
    }
    if (salaryMax.present) {
      map['salary_max'] = Variable<int>(salaryMax.value);
    }
    if (salaryPeriod.present) {
      map['salary_period'] = Variable<String>(salaryPeriod.value);
    }
    if (skillsJson.present) {
      map['skills_json'] = Variable<String>(skillsJson.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (applyUrl.present) {
      map['apply_url'] = Variable<String>(applyUrl.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (domainJson.present) {
      map['domain_json'] = Variable<String>(domainJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsTableCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('company: $company, ')
          ..write('location: $location, ')
          ..write('mode: $mode, ')
          ..write('type: $type, ')
          ..write('salaryMin: $salaryMin, ')
          ..write('salaryMax: $salaryMax, ')
          ..write('salaryPeriod: $salaryPeriod, ')
          ..write('skillsJson: $skillsJson, ')
          ..write('overview: $overview, ')
          ..write('applyUrl: $applyUrl, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('domainJson: $domainJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxQueueTableTable extends OutboxQueueTable
    with TableInfo<$OutboxQueueTableTable, OutboxQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    action,
    payloadJson,
    idempotencyKey,
    status,
    retryCount,
    createdAt,
    nextAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_queue_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxQueueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxQueueTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxQueueTableTable createAlias(String alias) {
    return $OutboxQueueTableTable(attachedDatabase, alias);
  }
}

class OutboxQueueTableData extends DataClass
    implements Insertable<OutboxQueueTableData> {
  final String id;
  final String entity;
  final String action;
  final String payloadJson;
  final String idempotencyKey;
  final String status;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? nextAttemptAt;
  final String? lastError;
  const OutboxQueueTableData({
    required this.id,
    required this.entity,
    required this.action,
    required this.payloadJson,
    required this.idempotencyKey,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    this.nextAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity'] = Variable<String>(entity);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxQueueTableCompanion toCompanion(bool nullToAbsent) {
    return OutboxQueueTableCompanion(
      id: Value(id),
      entity: Value(entity),
      action: Value(action),
      payloadJson: Value(payloadJson),
      idempotencyKey: Value(idempotencyKey),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxQueueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxQueueTableData(
      id: serializer.fromJson<String>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entity': serializer.toJson<String>(entity),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxQueueTableData copyWith({
    String? id,
    String? entity,
    String? action,
    String? payloadJson,
    String? idempotencyKey,
    String? status,
    int? retryCount,
    DateTime? createdAt,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => OutboxQueueTableData(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    action: action ?? this.action,
    payloadJson: payloadJson ?? this.payloadJson,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxQueueTableData copyWithCompanion(OutboxQueueTableCompanion data) {
    return OutboxQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      action: data.action.present ? data.action.value : this.action,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxQueueTableData(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entity,
    action,
    payloadJson,
    idempotencyKey,
    status,
    retryCount,
    createdAt,
    nextAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxQueueTableData &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.idempotencyKey == this.idempotencyKey &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError);
}

class OutboxQueueTableCompanion extends UpdateCompanion<OutboxQueueTableData> {
  final Value<String> id;
  final Value<String> entity;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<String> idempotencyKey;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const OutboxQueueTableCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxQueueTableCompanion.insert({
    required String id,
    required String entity,
    required String action,
    required String payloadJson,
    required String idempotencyKey,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entity = Value(entity),
       action = Value(action),
       payloadJson = Value(payloadJson),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt);
  static Insertable<OutboxQueueTableData> custom({
    Expression<String>? id,
    Expression<String>? entity,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<String>? idempotencyKey,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxQueueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? entity,
    Value<String>? action,
    Value<String>? payloadJson,
    Value<String>? idempotencyKey,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return OutboxQueueTableCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String id;
  final String value;
  const SettingsTableData({required this.id, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(id: Value(id), value: Value(value));
  }

  factory SettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingsTableData copyWith({String? id, String? value}) =>
      SettingsTableData(id: id ?? this.id, value: value ?? this.value);
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.value == this.value);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> id;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String id,
    required String value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       value = Value(value);
  static Insertable<SettingsTableData> custom({
    Expression<String>? id,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ResumesTableTable resumesTable = $ResumesTableTable(this);
  late final $ApplicationsTableTable applicationsTable =
      $ApplicationsTableTable(this);
  late final $MatchesTableTable matchesTable = $MatchesTableTable(this);
  late final $JobsTableTable jobsTable = $JobsTableTable(this);
  late final $OutboxQueueTableTable outboxQueueTable = $OutboxQueueTableTable(
    this,
  );
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    resumesTable,
    applicationsTable,
    matchesTable,
    jobsTable,
    outboxQueueTable,
    settingsTable,
  ];
}

typedef $$ResumesTableTableCreateCompanionBuilder =
    ResumesTableCompanion Function({
      required String id,
      required String title,
      required String filename,
      required String fileType,
      required String atsStatus,
      Value<String> sanitizedText,
      Value<String?> storagePath,
      required DateTime addedAt,
      Value<bool> isSynced,
      Value<DateTime?> deletedAt,
      required String domainJson,
      Value<int> rowid,
    });
typedef $$ResumesTableTableUpdateCompanionBuilder =
    ResumesTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> filename,
      Value<String> fileType,
      Value<String> atsStatus,
      Value<String> sanitizedText,
      Value<String?> storagePath,
      Value<DateTime> addedAt,
      Value<bool> isSynced,
      Value<DateTime?> deletedAt,
      Value<String> domainJson,
      Value<int> rowid,
    });

class $$ResumesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ResumesTableTable> {
  $$ResumesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get atsStatus => $composableBuilder(
    column: $table.atsStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sanitizedText => $composableBuilder(
    column: $table.sanitizedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResumesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ResumesTableTable> {
  $$ResumesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get atsStatus => $composableBuilder(
    column: $table.atsStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanitizedText => $composableBuilder(
    column: $table.sanitizedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResumesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResumesTableTable> {
  $$ResumesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<String> get atsStatus =>
      $composableBuilder(column: $table.atsStatus, builder: (column) => column);

  GeneratedColumn<String> get sanitizedText => $composableBuilder(
    column: $table.sanitizedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => column,
  );
}

class $$ResumesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResumesTableTable,
          ResumesTableData,
          $$ResumesTableTableFilterComposer,
          $$ResumesTableTableOrderingComposer,
          $$ResumesTableTableAnnotationComposer,
          $$ResumesTableTableCreateCompanionBuilder,
          $$ResumesTableTableUpdateCompanionBuilder,
          (
            ResumesTableData,
            BaseReferences<_$AppDatabase, $ResumesTableTable, ResumesTableData>,
          ),
          ResumesTableData,
          PrefetchHooks Function()
        > {
  $$ResumesTableTableTableManager(_$AppDatabase db, $ResumesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResumesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResumesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResumesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<String> atsStatus = const Value.absent(),
                Value<String> sanitizedText = const Value.absent(),
                Value<String?> storagePath = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> domainJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResumesTableCompanion(
                id: id,
                title: title,
                filename: filename,
                fileType: fileType,
                atsStatus: atsStatus,
                sanitizedText: sanitizedText,
                storagePath: storagePath,
                addedAt: addedAt,
                isSynced: isSynced,
                deletedAt: deletedAt,
                domainJson: domainJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String filename,
                required String fileType,
                required String atsStatus,
                Value<String> sanitizedText = const Value.absent(),
                Value<String?> storagePath = const Value.absent(),
                required DateTime addedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String domainJson,
                Value<int> rowid = const Value.absent(),
              }) => ResumesTableCompanion.insert(
                id: id,
                title: title,
                filename: filename,
                fileType: fileType,
                atsStatus: atsStatus,
                sanitizedText: sanitizedText,
                storagePath: storagePath,
                addedAt: addedAt,
                isSynced: isSynced,
                deletedAt: deletedAt,
                domainJson: domainJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ResumesTableTable, ResumesTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ResumesTableTable,
                    ResumesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResumesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResumesTableTable,
      ResumesTableData,
      $$ResumesTableTableFilterComposer,
      $$ResumesTableTableOrderingComposer,
      $$ResumesTableTableAnnotationComposer,
      $$ResumesTableTableCreateCompanionBuilder,
      $$ResumesTableTableUpdateCompanionBuilder,
      (
        ResumesTableData,
        BaseReferences<_$AppDatabase, $ResumesTableTable, ResumesTableData>,
      ),
      ResumesTableData,
      PrefetchHooks Function()
    >;
typedef $$ApplicationsTableTableCreateCompanionBuilder =
    ApplicationsTableCompanion Function({
      required String id,
      Value<String?> jobId,
      required String company,
      required String role,
      required String location,
      required String stage,
      Value<String?> matchBadge,
      required String link,
      required String notes,
      required DateTime appliedAt,
      Value<DateTime?> followUpAt,
      required DateTime updatedAt,
      Value<int> version,
      required String domainJson,
      Value<int> rowid,
    });
typedef $$ApplicationsTableTableUpdateCompanionBuilder =
    ApplicationsTableCompanion Function({
      Value<String> id,
      Value<String?> jobId,
      Value<String> company,
      Value<String> role,
      Value<String> location,
      Value<String> stage,
      Value<String?> matchBadge,
      Value<String> link,
      Value<String> notes,
      Value<DateTime> appliedAt,
      Value<DateTime?> followUpAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<String> domainJson,
      Value<int> rowid,
    });

class $$ApplicationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ApplicationsTableTable> {
  $$ApplicationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchBadge => $composableBuilder(
    column: $table.matchBadge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get followUpAt => $composableBuilder(
    column: $table.followUpAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApplicationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ApplicationsTableTable> {
  $$ApplicationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchBadge => $composableBuilder(
    column: $table.matchBadge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get followUpAt => $composableBuilder(
    column: $table.followUpAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApplicationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApplicationsTableTable> {
  $$ApplicationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get matchBadge => $composableBuilder(
    column: $table.matchBadge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get followUpAt => $composableBuilder(
    column: $table.followUpAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => column,
  );
}

class $$ApplicationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApplicationsTableTable,
          ApplicationsTableData,
          $$ApplicationsTableTableFilterComposer,
          $$ApplicationsTableTableOrderingComposer,
          $$ApplicationsTableTableAnnotationComposer,
          $$ApplicationsTableTableCreateCompanionBuilder,
          $$ApplicationsTableTableUpdateCompanionBuilder,
          (
            ApplicationsTableData,
            BaseReferences<
              _$AppDatabase,
              $ApplicationsTableTable,
              ApplicationsTableData
            >,
          ),
          ApplicationsTableData,
          PrefetchHooks Function()
        > {
  $$ApplicationsTableTableTableManager(
    _$AppDatabase db,
    $ApplicationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApplicationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApplicationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApplicationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String?> matchBadge = const Value.absent(),
                Value<String> link = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<DateTime?> followUpAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> domainJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApplicationsTableCompanion(
                id: id,
                jobId: jobId,
                company: company,
                role: role,
                location: location,
                stage: stage,
                matchBadge: matchBadge,
                link: link,
                notes: notes,
                appliedAt: appliedAt,
                followUpAt: followUpAt,
                updatedAt: updatedAt,
                version: version,
                domainJson: domainJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> jobId = const Value.absent(),
                required String company,
                required String role,
                required String location,
                required String stage,
                Value<String?> matchBadge = const Value.absent(),
                required String link,
                required String notes,
                required DateTime appliedAt,
                Value<DateTime?> followUpAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                required String domainJson,
                Value<int> rowid = const Value.absent(),
              }) => ApplicationsTableCompanion.insert(
                id: id,
                jobId: jobId,
                company: company,
                role: role,
                location: location,
                stage: stage,
                matchBadge: matchBadge,
                link: link,
                notes: notes,
                appliedAt: appliedAt,
                followUpAt: followUpAt,
                updatedAt: updatedAt,
                version: version,
                domainJson: domainJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ApplicationsTableTable, ApplicationsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ApplicationsTableTable,
                    ApplicationsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApplicationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApplicationsTableTable,
      ApplicationsTableData,
      $$ApplicationsTableTableFilterComposer,
      $$ApplicationsTableTableOrderingComposer,
      $$ApplicationsTableTableAnnotationComposer,
      $$ApplicationsTableTableCreateCompanionBuilder,
      $$ApplicationsTableTableUpdateCompanionBuilder,
      (
        ApplicationsTableData,
        BaseReferences<
          _$AppDatabase,
          $ApplicationsTableTable,
          ApplicationsTableData
        >,
      ),
      ApplicationsTableData,
      PrefetchHooks Function()
    >;
typedef $$MatchesTableTableCreateCompanionBuilder =
    MatchesTableCompanion Function({
      required String id,
      required String resumeId,
      Value<String?> jobId,
      required String role,
      required String company,
      required int overallScore,
      required String componentsJson,
      required String matchedSkillsJson,
      required String missingSkillsJson,
      required String suggestionsJson,
      required DateTime createdAt,
      required String domainJson,
      Value<int> rowid,
    });
typedef $$MatchesTableTableUpdateCompanionBuilder =
    MatchesTableCompanion Function({
      Value<String> id,
      Value<String> resumeId,
      Value<String?> jobId,
      Value<String> role,
      Value<String> company,
      Value<int> overallScore,
      Value<String> componentsJson,
      Value<String> matchedSkillsJson,
      Value<String> missingSkillsJson,
      Value<String> suggestionsJson,
      Value<DateTime> createdAt,
      Value<String> domainJson,
      Value<int> rowid,
    });

class $$MatchesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resumeId => $composableBuilder(
    column: $table.resumeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentsJson => $composableBuilder(
    column: $table.componentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchedSkillsJson => $composableBuilder(
    column: $table.matchedSkillsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missingSkillsJson => $composableBuilder(
    column: $table.missingSkillsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestionsJson => $composableBuilder(
    column: $table.suggestionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatchesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resumeId => $composableBuilder(
    column: $table.resumeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentsJson => $composableBuilder(
    column: $table.componentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchedSkillsJson => $composableBuilder(
    column: $table.matchedSkillsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missingSkillsJson => $composableBuilder(
    column: $table.missingSkillsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestionsJson => $composableBuilder(
    column: $table.suggestionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatchesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get resumeId =>
      $composableBuilder(column: $table.resumeId, builder: (column) => column);

  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get componentsJson => $composableBuilder(
    column: $table.componentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchedSkillsJson => $composableBuilder(
    column: $table.matchedSkillsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get missingSkillsJson => $composableBuilder(
    column: $table.missingSkillsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestionsJson => $composableBuilder(
    column: $table.suggestionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => column,
  );
}

class $$MatchesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchesTableTable,
          MatchesTableData,
          $$MatchesTableTableFilterComposer,
          $$MatchesTableTableOrderingComposer,
          $$MatchesTableTableAnnotationComposer,
          $$MatchesTableTableCreateCompanionBuilder,
          $$MatchesTableTableUpdateCompanionBuilder,
          (
            MatchesTableData,
            BaseReferences<_$AppDatabase, $MatchesTableTable, MatchesTableData>,
          ),
          MatchesTableData,
          PrefetchHooks Function()
        > {
  $$MatchesTableTableTableManager(_$AppDatabase db, $MatchesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> resumeId = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<int> overallScore = const Value.absent(),
                Value<String> componentsJson = const Value.absent(),
                Value<String> matchedSkillsJson = const Value.absent(),
                Value<String> missingSkillsJson = const Value.absent(),
                Value<String> suggestionsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> domainJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesTableCompanion(
                id: id,
                resumeId: resumeId,
                jobId: jobId,
                role: role,
                company: company,
                overallScore: overallScore,
                componentsJson: componentsJson,
                matchedSkillsJson: matchedSkillsJson,
                missingSkillsJson: missingSkillsJson,
                suggestionsJson: suggestionsJson,
                createdAt: createdAt,
                domainJson: domainJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String resumeId,
                Value<String?> jobId = const Value.absent(),
                required String role,
                required String company,
                required int overallScore,
                required String componentsJson,
                required String matchedSkillsJson,
                required String missingSkillsJson,
                required String suggestionsJson,
                required DateTime createdAt,
                required String domainJson,
                Value<int> rowid = const Value.absent(),
              }) => MatchesTableCompanion.insert(
                id: id,
                resumeId: resumeId,
                jobId: jobId,
                role: role,
                company: company,
                overallScore: overallScore,
                componentsJson: componentsJson,
                matchedSkillsJson: matchedSkillsJson,
                missingSkillsJson: missingSkillsJson,
                suggestionsJson: suggestionsJson,
                createdAt: createdAt,
                domainJson: domainJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MatchesTableTable, MatchesTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MatchesTableTable,
                    MatchesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatchesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchesTableTable,
      MatchesTableData,
      $$MatchesTableTableFilterComposer,
      $$MatchesTableTableOrderingComposer,
      $$MatchesTableTableAnnotationComposer,
      $$MatchesTableTableCreateCompanionBuilder,
      $$MatchesTableTableUpdateCompanionBuilder,
      (
        MatchesTableData,
        BaseReferences<_$AppDatabase, $MatchesTableTable, MatchesTableData>,
      ),
      MatchesTableData,
      PrefetchHooks Function()
    >;
typedef $$JobsTableTableCreateCompanionBuilder = JobsTableCompanion Function({
  required String id,
  required String role,
  required String company,
  required String location,
  required String mode,
  required String type,
  Value<int?> salaryMin,
  Value<int?> salaryMax,
  required String salaryPeriod,
  required String skillsJson,
  required String overview,
  Value<String?> applyUrl,
  Value<double?> latitude,
  Value<double?> longitude,
  required DateTime createdAt,
  required String domainJson,
  Value<int> rowid,
});
typedef $$JobsTableTableUpdateCompanionBuilder = JobsTableCompanion Function({
  Value<String> id,
  Value<String> role,
  Value<String> company,
  Value<String> location,
  Value<String> mode,
  Value<String> type,
  Value<int?> salaryMin,
  Value<int?> salaryMax,
  Value<String> salaryPeriod,
  Value<String> skillsJson,
  Value<String> overview,
  Value<String?> applyUrl,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<DateTime> createdAt,
  Value<String> domainJson,
  Value<int> rowid,
});

class $$JobsTableTableFilterComposer
    extends Composer<_$AppDatabase, $JobsTableTable> {
  $$JobsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salaryMin => $composableBuilder(
    column: $table.salaryMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salaryMax => $composableBuilder(
    column: $table.salaryMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salaryPeriod => $composableBuilder(
    column: $table.salaryPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skillsJson => $composableBuilder(
    column: $table.skillsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get applyUrl => $composableBuilder(
    column: $table.applyUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JobsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $JobsTableTable> {
  $$JobsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salaryMin => $composableBuilder(
    column: $table.salaryMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salaryMax => $composableBuilder(
    column: $table.salaryMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salaryPeriod => $composableBuilder(
    column: $table.salaryPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skillsJson => $composableBuilder(
    column: $table.skillsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get applyUrl => $composableBuilder(
    column: $table.applyUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsTableTable> {
  $$JobsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get salaryMin =>
      $composableBuilder(column: $table.salaryMin, builder: (column) => column);

  GeneratedColumn<int> get salaryMax =>
      $composableBuilder(column: $table.salaryMax, builder: (column) => column);

  GeneratedColumn<String> get salaryPeriod => $composableBuilder(
    column: $table.salaryPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get skillsJson => $composableBuilder(
    column: $table.skillsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<String> get applyUrl =>
      $composableBuilder(column: $table.applyUrl, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get domainJson => $composableBuilder(
    column: $table.domainJson,
    builder: (column) => column,
  );
}

class $$JobsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTableTable,
          JobsTableData,
          $$JobsTableTableFilterComposer,
          $$JobsTableTableOrderingComposer,
          $$JobsTableTableAnnotationComposer,
          $$JobsTableTableCreateCompanionBuilder,
          $$JobsTableTableUpdateCompanionBuilder,
          (
            JobsTableData,
            BaseReferences<_$AppDatabase, $JobsTableTable, JobsTableData>,
          ),
          JobsTableData,
          PrefetchHooks Function()
        > {
  $$JobsTableTableTableManager(_$AppDatabase db, $JobsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> salaryMin = const Value.absent(),
                Value<int?> salaryMax = const Value.absent(),
                Value<String> salaryPeriod = const Value.absent(),
                Value<String> skillsJson = const Value.absent(),
                Value<String> overview = const Value.absent(),
                Value<String?> applyUrl = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> domainJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsTableCompanion(
                id: id,
                role: role,
                company: company,
                location: location,
                mode: mode,
                type: type,
                salaryMin: salaryMin,
                salaryMax: salaryMax,
                salaryPeriod: salaryPeriod,
                skillsJson: skillsJson,
                overview: overview,
                applyUrl: applyUrl,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                domainJson: domainJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String role,
                required String company,
                required String location,
                required String mode,
                required String type,
                Value<int?> salaryMin = const Value.absent(),
                Value<int?> salaryMax = const Value.absent(),
                required String salaryPeriod,
                required String skillsJson,
                required String overview,
                Value<String?> applyUrl = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                required DateTime createdAt,
                required String domainJson,
                Value<int> rowid = const Value.absent(),
              }) => JobsTableCompanion.insert(
                id: id,
                role: role,
                company: company,
                location: location,
                mode: mode,
                type: type,
                salaryMin: salaryMin,
                salaryMax: salaryMax,
                salaryPeriod: salaryPeriod,
                skillsJson: skillsJson,
                overview: overview,
                applyUrl: applyUrl,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                domainJson: domainJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JobsTableTable, JobsTableData>(table),
                  BaseReferences<_$AppDatabase, $JobsTableTable, JobsTableData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTableTable,
      JobsTableData,
      $$JobsTableTableFilterComposer,
      $$JobsTableTableOrderingComposer,
      $$JobsTableTableAnnotationComposer,
      $$JobsTableTableCreateCompanionBuilder,
      $$JobsTableTableUpdateCompanionBuilder,
      (
        JobsTableData,
        BaseReferences<_$AppDatabase, $JobsTableTable, JobsTableData>,
      ),
      JobsTableData,
      PrefetchHooks Function()
    >;
typedef $$OutboxQueueTableTableCreateCompanionBuilder =
    OutboxQueueTableCompanion Function({
      required String id,
      required String entity,
      required String action,
      required String payloadJson,
      required String idempotencyKey,
      Value<String> status,
      Value<int> retryCount,
      required DateTime createdAt,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$OutboxQueueTableTableUpdateCompanionBuilder =
    OutboxQueueTableCompanion Function({
      Value<String> id,
      Value<String> entity,
      Value<String> action,
      Value<String> payloadJson,
      Value<String> idempotencyKey,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$OutboxQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxQueueTableTable> {
  $$OutboxQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxQueueTableTable> {
  $$OutboxQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxQueueTableTable> {
  $$OutboxQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxQueueTableTable,
          OutboxQueueTableData,
          $$OutboxQueueTableTableFilterComposer,
          $$OutboxQueueTableTableOrderingComposer,
          $$OutboxQueueTableTableAnnotationComposer,
          $$OutboxQueueTableTableCreateCompanionBuilder,
          $$OutboxQueueTableTableUpdateCompanionBuilder,
          (
            OutboxQueueTableData,
            BaseReferences<
              _$AppDatabase,
              $OutboxQueueTableTable,
              OutboxQueueTableData
            >,
          ),
          OutboxQueueTableData,
          PrefetchHooks Function()
        > {
  $$OutboxQueueTableTableTableManager(
    _$AppDatabase db,
    $OutboxQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxQueueTableCompanion(
                id: id,
                entity: entity,
                action: action,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entity,
                required String action,
                required String payloadJson,
                required String idempotencyKey,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxQueueTableCompanion.insert(
                id: id,
                entity: entity,
                action: action,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxQueueTableTable, OutboxQueueTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $OutboxQueueTableTable,
                    OutboxQueueTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxQueueTableTable,
      OutboxQueueTableData,
      $$OutboxQueueTableTableFilterComposer,
      $$OutboxQueueTableTableOrderingComposer,
      $$OutboxQueueTableTableAnnotationComposer,
      $$OutboxQueueTableTableCreateCompanionBuilder,
      $$OutboxQueueTableTableUpdateCompanionBuilder,
      (
        OutboxQueueTableData,
        BaseReferences<
          _$AppDatabase,
          $OutboxQueueTableTable,
          OutboxQueueTableData
        >,
      ),
      OutboxQueueTableData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String id,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> id,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsTableData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $SettingsTableTable,
              SettingsTableData
            >,
          ),
          SettingsTableData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsTableCompanion(id: id, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                id: id,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTableTable, SettingsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsTableTable,
                    SettingsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsTableData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsTableData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>,
      ),
      SettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ResumesTableTableTableManager get resumesTable =>
      $$ResumesTableTableTableManager(_db, _db.resumesTable);
  $$ApplicationsTableTableTableManager get applicationsTable =>
      $$ApplicationsTableTableTableManager(_db, _db.applicationsTable);
  $$MatchesTableTableTableManager get matchesTable =>
      $$MatchesTableTableTableManager(_db, _db.matchesTable);
  $$JobsTableTableTableManager get jobsTable =>
      $$JobsTableTableTableManager(_db, _db.jobsTable);
  $$OutboxQueueTableTableTableManager get outboxQueueTable =>
      $$OutboxQueueTableTableTableManager(_db, _db.outboxQueueTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
