enum WorkMode { remote, hybrid, onSite }

enum EmploymentType { fullTime, contract, partTime }

enum ApplicationStage { wishlist, applied, interview, offer, rejected }

enum AppTheme { system, light, dark }

extension EnumLabel on Enum {
  String get label => switch (name) {
    'onSite' => 'On-site',
    'fullTime' => 'Full-time',
    'partTime' => 'Part-time',
    'wishlist' => 'Wishlist',
    'applied' => 'Applied',
    'interview' => 'Interview',
    'offer' => 'Offer',
    'rejected' => 'Rejected',
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
    this.matchScore,
    this.badgeText,
    this.badgeTone = 'neutral',
    this.salaryMin,
    this.salaryMax,
    this.salaryPeriod = 'month',
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.applicationUrl,
  });

  final String id, role, company, location, overview, salaryPeriod;
  final WorkMode mode;
  final EmploymentType type;
  final int postedDays;
  final int? matchScore;
  final String? badgeText;
  final String badgeTone; // 'success', 'warning', 'neutral'
  final int? salaryMin, salaryMax;
  final List<String> skills, responsibilities, qualifications;
  final double? latitude, longitude;
  final double? distanceKm;
  final String? applicationUrl;

  String get salaryLabel => salaryMin == null
      ? 'Salary not disclosed'
      : 'PHP ${salaryMin! ~/ 1000}k-${salaryMax! ~/ 1000}k / $salaryPeriod';

  String? get distanceLabel {
    if (distanceKm == null) return null;
    if (distanceKm! < 1.0) {
      return '📍 ${(distanceKm! * 1000).round()}m away';
    }
    return '📍 ${distanceKm!.toStringAsFixed(1)}km away';
  }

  Job copyWith({
    String? id,
    String? role,
    String? company,
    String? location,
    WorkMode? mode,
    EmploymentType? type,
    int? postedDays,
    int? matchScore,
    String? badgeText,
    String? badgeTone,
    int? salaryMin,
    int? salaryMax,
    String? salaryPeriod,
    List<String>? skills,
    String? overview,
    List<String>? responsibilities,
    List<String>? qualifications,
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? applicationUrl,
  }) => Job(
    id: id ?? this.id,
    role: role ?? this.role,
    company: company ?? this.company,
    location: location ?? this.location,
    mode: mode ?? this.mode,
    type: type ?? this.type,
    postedDays: postedDays ?? this.postedDays,
    matchScore: matchScore ?? this.matchScore,
    badgeText: badgeText ?? this.badgeText,
    badgeTone: badgeTone ?? this.badgeTone,
    salaryMin: salaryMin ?? this.salaryMin,
    salaryMax: salaryMax ?? this.salaryMax,
    salaryPeriod: salaryPeriod ?? this.salaryPeriod,
    skills: skills ?? this.skills,
    overview: overview ?? this.overview,
    responsibilities: responsibilities ?? this.responsibilities,
    qualifications: qualifications ?? this.qualifications,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    distanceKm: distanceKm ?? this.distanceKm,
    applicationUrl: applicationUrl ?? this.applicationUrl,
  );

  factory Job.fromJson(Map<String, dynamic> j) {
    WorkMode parseMode(dynamic val) {
      if (val is String) {
        return WorkMode.values.where((m) => m.name == val).firstOrNull ??
            WorkMode.onSite;
      }
      return WorkMode.onSite;
    }

    EmploymentType parseType(dynamic val) {
      if (val is String) {
        return EmploymentType.values.where((t) => t.name == val).firstOrNull ??
            EmploymentType.fullTime;
      }
      return EmploymentType.fullTime;
    }

    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return Job(
      id: (j['id'] ?? '').toString(),
      role: (j['role'] ?? '').toString(),
      company: (j['company'] ?? '').toString(),
      location: (j['location'] ?? '').toString(),
      mode: parseMode(j['mode'] ?? j['work_mode']),
      type: parseType(j['type'] ?? j['employment_type']),
      postedDays: (j['postedDays'] ?? j['posted_days'] ?? 1) as int,
      matchScore: (j['matchScore'] ?? j['match_score']) as int?,
      badgeText: (j['badgeText'] ?? j['badge_text']) as String?,
      badgeTone: (j['badgeTone'] ?? j['badge_tone'] ?? 'neutral') as String,
      salaryMin: (j['salaryMin'] ?? j['salary_min']) as int?,
      salaryMax: (j['salaryMax'] ?? j['salary_max']) as int?,
      salaryPeriod: (j['salaryPeriod'] ?? j['salary_period'] ?? 'month') as String,
      skills: parseList(j['skills']),
      overview: (j['overview'] ?? '').toString(),
      responsibilities: parseList(j['responsibilities']),
      qualifications: parseList(j['qualifications']),
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      distanceKm: (j['distanceKm'] ?? j['distance_km'] as num?)?.toDouble(),
      applicationUrl: (j['application_url'] ?? j['applyUrl'] ?? j['link'] ?? j['applicationUrl'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'company': company,
    'location': location,
    'mode': mode.name,
    'type': type.name,
    'postedDays': postedDays,
    'matchScore': matchScore,
    'badgeText': badgeText,
    'badgeTone': badgeTone,
    'salaryMin': salaryMin,
    'salaryMax': salaryMax,
    'salaryPeriod': salaryPeriod,
    'skills': skills,
    'overview': overview,
    'responsibilities': responsibilities,
    'qualifications': qualifications,
    'latitude': latitude,
    'longitude': longitude,
    'distanceKm': distanceKm,
    'application_url': applicationUrl,
    'applyUrl': applicationUrl,
  };
}

class ResumeVersion {
  const ResumeVersion({
    required this.id,
    required this.title,
    required this.filename,
    required this.fileType,
    required this.addedAt,
    required this.isSample,
    this.atsStatus = 'ATS OK',
    this.summary,
    this.experience = const [],
    this.skills = const [],
    this.education = '',
  });

  final String id, title, filename, fileType;
  final DateTime addedAt;
  final bool isSample;
  final String atsStatus; // 'ATS OK', 'Complex layout', 'Not analyzed'
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
    'atsStatus': atsStatus,
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
    atsStatus: j['atsStatus'] ?? 'ATS OK',
    summary: j['summary'],
    experience: List<String>.from(j['experience'] ?? []),
    skills: List<String>.from(j['skills'] ?? []),
    education: j['education'] ?? '',
  );

  ResumeVersion copyWith({String? title, String? atsStatus}) => ResumeVersion(
    id: id,
    title: title ?? this.title,
    filename: filename,
    fileType: fileType,
    addedAt: addedAt,
    isSample: isSample,
    atsStatus: atsStatus ?? this.atsStatus,
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
    this.resumeTitle = 'v2_IT_Final',
    this.jobId,
    required this.jobLabel,
    this.role = 'Junior Flutter Developer',
    this.company = 'Northwind Digital',
    this.location = 'Davao City',
    required this.createdAt,
    required this.overall,
    this.summaryTitle = 'A promising fit',
    this.summaryText =
        'Your skills are a good starting point. Focus on the gaps below.',
    required this.components,
    required this.matched,
    required this.missing,
    required this.strengths,
    required this.gaps,
    required this.suggestions,
  });

  final String id, resumeId, resumeTitle, jobLabel, role, company, location;
  final String? jobId;
  final DateTime createdAt;
  final int overall;
  final String summaryTitle, summaryText;
  final Map<String, int> components;
  final List<String> matched, missing, strengths, gaps;
  final List<BulletSuggestion> suggestions;

  Map<String, Object?> toJson() => {
    'id': id,
    'resumeId': resumeId,
    'resumeTitle': resumeTitle,
    'jobId': jobId,
    'jobLabel': jobLabel,
    'role': role,
    'company': company,
    'location': location,
    'createdAt': createdAt.toIso8601String(),
    'overall': overall,
    'summaryTitle': summaryTitle,
    'summaryText': summaryText,
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
    resumeTitle: j['resumeTitle'] ?? 'v2_IT_Final',
    jobId: j['jobId'],
    jobLabel: j['jobLabel'] ?? 'Role Match',
    role: j['role'] ?? 'Junior Flutter Developer',
    company: j['company'] ?? 'Northwind Digital',
    location: j['location'] ?? 'Davao City',
    createdAt: DateTime.parse(j['createdAt']),
    overall: j['overall'],
    summaryTitle:
        j['summaryTitle'] ??
        (j['overall'] >= 80 ? 'A promising fit' : 'Room to strengthen'),
    summaryText:
        j['summaryText'] ??
        (j['overall'] >= 80
            ? 'Your skills are a good starting point. Focus on the gaps below.'
            : 'Build on your strengths and tailor your resume to this role.'),
    components: Map<String, int>.from(j['components'] ?? {}),
    matched: List<String>.from(j['matched'] ?? []),
    missing: List<String>.from(j['missing'] ?? []),
    strengths: List<String>.from(j['strengths'] ?? []),
    gaps: List<String>.from(j['gaps'] ?? []),
    suggestions: ((j['suggestions'] ?? []) as List)
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
    this.matchBadge,
    this.link = '',
    this.notes = const [],
    this.followUpAt,
  });

  final String id, company, role, location, link;
  final String? jobId;
  final DateTime appliedAt;
  final ApplicationStage stage;
  final String? matchBadge;
  final List<String> notes;
  final DateTime? followUpAt;

  ApplicationRecord copyWith({
    ApplicationStage? stage,
    List<String>? notes,
    String? company,
    String? role,
    String? location,
    DateTime? appliedAt,
    String? matchBadge,
    DateTime? followUpAt,
  }) => ApplicationRecord(
    id: id,
    jobId: jobId,
    company: company ?? this.company,
    role: role ?? this.role,
    location: location ?? this.location,
    appliedAt: appliedAt ?? this.appliedAt,
    stage: stage ?? this.stage,
    matchBadge: matchBadge ?? this.matchBadge,
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
    'matchBadge': matchBadge,
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
        stage: ApplicationStage.values.byName(
          j['stage'] == 'saved' ? 'wishlist' : j['stage'],
        ),
        matchBadge: j['matchBadge'],
        link: j['link'] ?? '',
        notes: List<String>.from(j['notes'] ?? []),
        followUpAt: j['followUpAt'] == null
            ? null
            : DateTime.parse(j['followUpAt']),
      );
}

class ProfileSettings {
  const ProfileSettings({
    this.name = 'Alex',
    this.email = 'alex@example.com',
    this.headline = 'Fresh Graduate · Junior Software & Support',
    this.location = 'Philippines',
    this.targetRoles = const [
      'Junior Flutter Developer',
      'IT Support Associate',
    ],
    this.preferredWorkMode,
    this.theme = AppTheme.system,
    this.reduceTransparency = false,
    this.scanQuota = 3,
    this.interviewLanguage = 'English',
  });

  final String name, email, headline, location;
  final List<String> targetRoles;
  final WorkMode? preferredWorkMode;
  final AppTheme theme;
  final bool reduceTransparency;
  final int scanQuota;
  final String interviewLanguage; // 'English' | 'Taglish'

  ProfileSettings copyWith({
    String? name,
    String? email,
    String? headline,
    String? location,
    List<String>? targetRoles,
    WorkMode? preferredWorkMode,
    AppTheme? theme,
    bool? reduceTransparency,
    int? scanQuota,
    String? interviewLanguage,
  }) => ProfileSettings(
    name: name ?? this.name,
    email: email ?? this.email,
    headline: headline ?? this.headline,
    location: location ?? this.location,
    targetRoles: targetRoles ?? this.targetRoles,
    preferredWorkMode: preferredWorkMode ?? this.preferredWorkMode,
    theme: theme ?? this.theme,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
    scanQuota: scanQuota ?? this.scanQuota,
    interviewLanguage: interviewLanguage ?? this.interviewLanguage,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'email': email,
    'headline': headline,
    'location': location,
    'targetRoles': targetRoles,
    'preferredWorkMode': preferredWorkMode?.name,
    'theme': theme.name,
    'reduceTransparency': reduceTransparency,
    'scanQuota': scanQuota,
    'interviewLanguage': interviewLanguage,
  };

  factory ProfileSettings.fromJson(Map<String, dynamic> j) => ProfileSettings(
    name: j['name'] ?? 'Alex',
    email: j['email'] ?? 'alex@example.com',
    headline: j['headline'] ?? 'Fresh Graduate',
    location: j['location'] ?? 'Philippines',
    targetRoles: List<String>.from(
      j['targetRoles'] ?? ['Junior Flutter Developer'],
    ),
    preferredWorkMode: j['preferredWorkMode'] != null
        ? WorkMode.values
            .where((m) => m.name == j['preferredWorkMode'])
            .firstOrNull
        : null,
    theme: AppTheme.values.byName(j['theme'] ?? 'system'),
    reduceTransparency: j['reduceTransparency'] ?? false,
    scanQuota: j['scanQuota'] ?? 3,
    interviewLanguage: j['interviewLanguage'] ?? 'English',
  );
}
