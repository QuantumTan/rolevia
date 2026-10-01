enum WorkMode { remote, hybrid, onSite }

enum EmploymentType { fullTime, contract, partTime }

enum ApplicationStage { saved, applied, interview, offer, rejected }

enum AppTheme { system, light, dark }

extension EnumLabel on Enum {
  String get label => switch (name) {
    'onSite' => 'On-site',
    'fullTime' => 'Full-time',
    'partTime' => 'Part-time',
    _ => name[0].toUpperCase() + name.substring(1),
  };
}

class Job {
  const Job({
    required this.id,
    required this.role,
    required this.company,
    required this.location,
    required this.mode,
    required this.type,
    required this.postedDays,
    required this.skills,
    required this.overview,
    required this.responsibilities,
    required this.qualifications,
    this.salaryMin,
    this.salaryMax,
    this.salaryPeriod = 'month',
  });
  final String id, role, company, location, overview, salaryPeriod;
  final WorkMode mode;
  final EmploymentType type;
  final int postedDays;
  final int? salaryMin, salaryMax;
  final List<String> skills, responsibilities, qualifications;
  String get salaryLabel => salaryMin == null
      ? 'Salary not disclosed'
      : 'PHP ${salaryMin! ~/ 1000}k-${salaryMax! ~/ 1000}k / $salaryPeriod';
}

class ResumeVersion {
  const ResumeVersion({
    required this.id,
    required this.title,
    required this.filename,
    required this.fileType,
    required this.addedAt,
    required this.isSample,
    this.summary,
    this.experience = const [],
    this.skills = const [],
    this.education = '',
  });
  final String id, title, filename, fileType;
  final DateTime addedAt;
  final bool isSample;
  final String? summary;
  final List<String> experience, skills;
  final String education;
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'filename': filename,
    'fileType': fileType,
    'addedAt': addedAt.toIso8601String(),
    'isSample': isSample,
    'summary': summary,
    'experience': experience,
    'skills': skills,
    'education': education,
  };
  factory ResumeVersion.fromJson(Map<String, dynamic> j) => ResumeVersion(
    id: j['id'],
    title: j['title'],
    filename: j['filename'],
    fileType: j['fileType'],
    addedAt: DateTime.parse(j['addedAt']),
    isSample: j['isSample'],
    summary: j['summary'],
    experience: List<String>.from(j['experience'] ?? []),
    skills: List<String>.from(j['skills'] ?? []),
    education: j['education'] ?? '',
  );
  ResumeVersion copyWith({String? title}) => ResumeVersion(
    id: id,
    title: title ?? this.title,
    filename: filename,
    fileType: fileType,
    addedAt: addedAt,
    isSample: isSample,
    summary: summary,
    experience: experience,
    skills: skills,
    education: education,
  );
}

class BulletSuggestion {
  const BulletSuggestion(this.original, this.suggested);
  final String original, suggested;
}

class MatchResult {
  const MatchResult({
    required this.id,
    required this.resumeId,
    this.jobId,
    required this.jobLabel,
    required this.createdAt,
    required this.overall,
    required this.components,
    required this.matched,
    required this.missing,
    required this.strengths,
    required this.gaps,
    required this.suggestions,
  });
  final String id, resumeId, jobLabel;
  final String? jobId;
  final DateTime createdAt;
  final int overall;
  final Map<String, int> components;
  final List<String> matched, missing, strengths, gaps;
  final List<BulletSuggestion> suggestions;
  Map<String, Object?> toJson() => {
    'id': id,
    'resumeId': resumeId,
    'jobId': jobId,
    'jobLabel': jobLabel,
    'createdAt': createdAt.toIso8601String(),
    'overall': overall,
    'components': components,
    'matched': matched,
    'missing': missing,
    'strengths': strengths,
    'gaps': gaps,
    'suggestions': suggestions
        .map((e) => {'original': e.original, 'suggested': e.suggested})
        .toList(),
  };
  factory MatchResult.fromJson(Map<String, dynamic> j) => MatchResult(
    id: j['id'],
    resumeId: j['resumeId'],
    jobId: j['jobId'],
    jobLabel: j['jobLabel'],
    createdAt: DateTime.parse(j['createdAt']),
    overall: j['overall'],
    components: Map<String, int>.from(j['components']),
    matched: List<String>.from(j['matched']),
    missing: List<String>.from(j['missing']),
    strengths: List<String>.from(j['strengths']),
    gaps: List<String>.from(j['gaps']),
    suggestions: (j['suggestions'] as List)
        .map((e) => BulletSuggestion(e['original'], e['suggested']))
        .toList(),
  );
}

class ApplicationRecord {
  const ApplicationRecord({
    required this.id,
    this.jobId,
    required this.company,
    required this.role,
    required this.location,
    required this.appliedAt,
    required this.stage,
    this.link = '',
    this.notes = const [],
    this.followUpAt,
  });
  final String id, company, role, location, link;
  final String? jobId;
  final DateTime appliedAt;
  final ApplicationStage stage;
  final List<String> notes;
  final DateTime? followUpAt;
  ApplicationRecord copyWith({
    ApplicationStage? stage,
    List<String>? notes,
    String? company,
    String? role,
    String? location,
    DateTime? appliedAt,
    DateTime? followUpAt,
  }) => ApplicationRecord(
    id: id,
    jobId: jobId,
    company: company ?? this.company,
    role: role ?? this.role,
    location: location ?? this.location,
    appliedAt: appliedAt ?? this.appliedAt,
    stage: stage ?? this.stage,
    link: link,
    notes: notes ?? this.notes,
    followUpAt: followUpAt ?? this.followUpAt,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'jobId': jobId,
    'company': company,
    'role': role,
    'location': location,
    'appliedAt': appliedAt.toIso8601String(),
    'stage': stage.name,
    'link': link,
    'notes': notes,
    'followUpAt': followUpAt?.toIso8601String(),
  };
  factory ApplicationRecord.fromJson(Map<String, dynamic> j) =>
      ApplicationRecord(
        id: j['id'],
        jobId: j['jobId'],
        company: j['company'],
        role: j['role'],
        location: j['location'],
        appliedAt: DateTime.parse(j['appliedAt']),
        stage: ApplicationStage.values.byName(j['stage']),
        link: j['link'] ?? '',
        notes: List<String>.from(j['notes'] ?? []),
        followUpAt: j['followUpAt'] == null
            ? null
            : DateTime.parse(j['followUpAt']),
      );
}

class ProfileSettings {
  const ProfileSettings({
    this.name = 'Demo User',
    this.headline = 'Software professional',
    this.location = 'Metro Manila',
    this.targetRoles = const ['Flutter Developer'],
    this.theme = AppTheme.system,
    this.reduceTransparency = false,
  });
  final String name, headline, location;
  final List<String> targetRoles;
  final AppTheme theme;
  final bool reduceTransparency;
  ProfileSettings copyWith({
    String? name,
    String? headline,
    String? location,
    List<String>? targetRoles,
    AppTheme? theme,
    bool? reduceTransparency,
  }) => ProfileSettings(
    name: name ?? this.name,
    headline: headline ?? this.headline,
    location: location ?? this.location,
    targetRoles: targetRoles ?? this.targetRoles,
    theme: theme ?? this.theme,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
  );
  Map<String, Object?> toJson() => {
    'name': name,
    'headline': headline,
    'location': location,
    'targetRoles': targetRoles,
    'theme': theme.name,
    'reduceTransparency': reduceTransparency,
  };
  factory ProfileSettings.fromJson(Map<String, dynamic> j) => ProfileSettings(
    name: j['name'],
    headline: j['headline'],
    location: j['location'],
    targetRoles: List<String>.from(j['targetRoles']),
    theme: AppTheme.values.byName(j['theme']),
    reduceTransparency: j['reduceTransparency'],
  );
}
