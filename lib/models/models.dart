import 'matching_models.dart';

enum WorkMode { remote, hybrid, onSite }

enum EmploymentType { fullTime, contract, partTime }

enum ApplicationStage { wishlist, applied, interview, offer, rejected }

enum AppTheme { system, light, dark }

enum AppAccentColor { indigo, ocean, emerald, violet, coral }

enum ExperienceLevel { entry, mid, senior, lead }

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
    'ocean' => 'Precision Teal',
    'emerald' => 'Emerald',
    'violet' => 'Royal Violet',
    'coral' => 'Sunset Coral',
    'indigo' => 'Electric Cobalt',
    'entry' => 'Entry-Level',
    'mid' => 'Mid-Level',
    'senior' => 'Senior',
    'lead' => 'Lead / Principal',
    'high' => 'High confidence',
    'medium' => 'Medium confidence',
    'low' => 'Low confidence',
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
    this.originalDescription,
    this.descriptionTruncated = false,
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
  final String? originalDescription;
  final bool descriptionTruncated;

  String get salaryLabel => salaryMin == null && salaryMax == null
      ? 'Salary not disclosed'
      : salaryMax == null
      ? 'PHP $salaryMin+ / $salaryPeriod'
      : salaryMin == null
      ? 'Up to PHP $salaryMax / $salaryPeriod'
      : 'PHP $salaryMin - $salaryMax / $salaryPeriod';

  String? get distanceLabel {
    if (distanceKm == null) return null;
    if (distanceKm! < 1.0) {
      return '${(distanceKm! * 1000).round()}m away';
    }
    return '${distanceKm!.toStringAsFixed(1)}km away';
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
    String? originalDescription,
    bool? descriptionTruncated,
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
    originalDescription: originalDescription ?? this.originalDescription,
    descriptionTruncated: descriptionTruncated ?? this.descriptionTruncated,
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
      postedDays: ((j['postedDays'] ?? j['posted_days'] ?? 1) as num).round(),
      matchScore: ((j['matchScore'] ?? j['match_score']) as num?)?.round(),
      badgeText: (j['badgeText'] ?? j['badge_text']) as String?,
      badgeTone: (j['badgeTone'] ?? j['badge_tone'] ?? 'neutral') as String,
      salaryMin: ((j['salaryMin'] ?? j['salary_min']) as num?)?.round(),
      salaryMax: ((j['salaryMax'] ?? j['salary_max']) as num?)?.round(),
      salaryPeriod:
          (j['salaryPeriod'] ?? j['salary_period'] ?? 'month') as String,
      skills: parseList(j['skills']),
      overview: (j['overview'] ?? '').toString(),
      responsibilities: parseList(j['responsibilities']),
      qualifications: parseList(j['qualifications']),
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      distanceKm: ((j['distanceKm'] ?? j['distance_km']) as num?)?.toDouble(),
      applicationUrl:
          (j['application_url'] ??
                  j['applyUrl'] ??
                  j['link'] ??
                  j['applicationUrl'])
              ?.toString(),
      originalDescription:
          (j['originalDescription'] ?? j['original_description'])?.toString(),
      descriptionTruncated:
          (j['descriptionTruncated'] ?? j['description_truncated']) == true,
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
    'originalDescription': originalDescription,
    'descriptionTruncated': descriptionTruncated,
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
    this.extractedText = '',
    this.atsChecks = const {},
  });

  final String id, title, filename, fileType;
  final DateTime addedAt;
  final bool isSample;
  final String atsStatus; // 'ATS OK', 'Complex layout', 'Not analyzed'
  final String? summary;
  final List<String> experience, skills;
  final String education;
  final String extractedText;
  final Map<String, bool> atsChecks;

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
    'extractedText': extractedText,
    'atsChecks': atsChecks,
  };

  factory ResumeVersion.fromJson(Map<String, dynamic> j) => ResumeVersion(
    id: (j['id'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    filename: (j['filename'] ?? '').toString(),
    fileType: (j['fileType'] ?? 'PDF').toString(),
    addedAt: j['addedAt'] != null
        ? (DateTime.tryParse(j['addedAt'].toString()) ?? DateTime.now())
        : DateTime.now(),
    isSample: j['isSample'] == true,
    atsStatus: (j['atsStatus'] ?? 'ATS OK').toString(),
    summary: j['summary']?.toString(),
    experience: (j['experience'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    skills: (j['skills'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    education: (j['education'] ?? '').toString(),
    extractedText: (j['extractedText'] ?? '').toString(),
    atsChecks: (j['atsChecks'] as Map? ?? const {}).map(
      (k, v) => MapEntry(k.toString(), v == true),
    ),
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
    extractedText: extractedText,
    atsChecks: atsChecks,
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
    this.resumeTitle = 'Resume',
    this.jobId,
    required this.jobLabel,
    this.role = 'Pasted job post',
    this.company = 'Company not specified',
    this.location = 'Location not specified',
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
    this.atsChecks = const {},
    this.jobDescription = '',
    this.originalJobDescription = '',
    this.jobTextTruncated = false,
    this.requirementMatches = const [],
    this.evidenceScore,
    this.analysisLabel = 'Quick estimate',
    this.quickEstimateScore,
  });

  final String id, resumeId, resumeTitle, jobLabel, role, company, location;
  final String? jobId;
  final DateTime createdAt;
  final int overall;
  final String summaryTitle, summaryText;
  final Map<String, int> components;
  final List<String> matched, missing, strengths, gaps;
  final List<BulletSuggestion> suggestions;
  final Map<String, bool> atsChecks;
  final String jobDescription, originalJobDescription;
  final bool jobTextTruncated;
  final List<RequirementEvidenceMatch> requirementMatches;
  final EvidenceScoreBreakdown? evidenceScore;
  final String analysisLabel;
  final int? quickEstimateScore;

  String get markdownReport => [
    '# Match report: $jobLabel',
    'Resume: $resumeTitle',
    'Score: $overall/100',
    summaryText,
    'Analysis: $analysisLabel',
    if (evidenceScore != null) 'Confidence: ${evidenceScore!.confidence.label}',
    for (final entry in components.entries)
      '- ${entry.key}: ${entry.value}/100',
    for (final match in requirementMatches)
      '- ${match.requirement.priority.label}: ${match.requirement.text} [${match.verdict.label}]',
    for (final entry in atsChecks.entries)
      '- ${entry.key}: ${entry.value ? 'Pass' : 'Review'}',
    ...gaps,
    'Evidence-based comparison. Not a hiring prediction. Only add truthful experience.',
  ].join('\n\n');

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
    'atsChecks': atsChecks,
    'jobDescription': jobDescription,
    'originalJobDescription': originalJobDescription,
    'jobTextTruncated': jobTextTruncated,
    'requirementMatches': requirementMatches
        .map((match) => match.toJson())
        .toList(),
    'evidenceScore': evidenceScore?.toJson(),
    'analysisLabel': analysisLabel,
    'quickEstimateScore': quickEstimateScore,
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
    resumeTitle: j['resumeTitle'] ?? 'Resume',
    jobId: j['jobId'],
    jobLabel: j['jobLabel'] ?? 'Role Match',
    role: j['role'] ?? 'Pasted job post',
    company: j['company'] ?? 'Company not specified',
    location: j['location'] ?? 'Location not specified',
    atsChecks: Map<String, bool>.from(j['atsChecks'] ?? {}),
    jobDescription: j['jobDescription'] ?? '',
    originalJobDescription:
        j['originalJobDescription'] ?? j['jobDescription'] ?? '',
    jobTextTruncated: j['jobTextTruncated'] == true,
    requirementMatches: ((j['requirementMatches'] ?? const []) as List)
        .whereType<Map>()
        .map(
          (value) => RequirementEvidenceMatch.fromJson(
            Map<String, dynamic>.from(value),
          ),
        )
        .toList(),
    evidenceScore: j['evidenceScore'] is Map
        ? EvidenceScoreBreakdown.fromJson(
            Map<String, dynamic>.from(j['evidenceScore'] as Map),
          )
        : null,
    analysisLabel: j['analysisLabel'] ?? 'Quick estimate',
    quickEstimateScore: (j['quickEstimateScore'] as num?)?.round(),
    createdAt: j['createdAt'] != null
        ? (DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now())
        : DateTime.now(),
    overall: (j['overall'] as num?)?.round() ?? 0,
    summaryTitle:
        j['summaryTitle'] ??
        (((j['overall'] as num?)?.round() ?? 0) >= 80
            ? 'A promising fit'
            : 'Room to strengthen'),
    summaryText:
        j['summaryText'] ??
        (((j['overall'] as num?)?.round() ?? 0) >= 80
            ? 'Your skills are a good starting point. Focus on the gaps below.'
            : 'Build on your strengths and tailor your resume to this role.'),
    components: (j['components'] as Map? ?? const {}).map(
      (k, v) => MapEntry(k.toString(), (v as num).round()),
    ),
    matched: (j['matched'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    missing: (j['missing'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    strengths: (j['strengths'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    gaps: (j['gaps'] as List? ?? const []).map((e) => e.toString()).toList(),
    suggestions: ((j['suggestions'] ?? const []) as List)
        .whereType<Map>()
        .map(
          (e) => BulletSuggestion(
            (e['original'] ?? '').toString(),
            (e['suggested'] ?? '').toString(),
          ),
        )
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
    this.resumeId,
    this.interviewAt,
    this.salaryOffered,
  });

  final String id, company, role, location, link;
  final String? jobId;
  final DateTime appliedAt;
  final ApplicationStage stage;
  final String? matchBadge;
  final List<String> notes;
  final DateTime? followUpAt;
  final String? resumeId;
  final DateTime? interviewAt;
  final int? salaryOffered;

  ApplicationRecord copyWith({
    ApplicationStage? stage,
    List<String>? notes,
    String? company,
    String? role,
    String? location,
    DateTime? appliedAt,
    String? matchBadge,
    DateTime? followUpAt,
    String? resumeId,
    DateTime? interviewAt,
    int? salaryOffered,
    bool clearInterview = false,
    bool clearSalary = false,
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
    resumeId: resumeId ?? this.resumeId,
    interviewAt: clearInterview ? null : interviewAt ?? this.interviewAt,
    salaryOffered: clearSalary ? null : salaryOffered ?? this.salaryOffered,
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
    'resumeId': resumeId,
    'interviewAt': interviewAt?.toIso8601String(),
    'salaryOffered': salaryOffered,
  };

  factory ApplicationRecord.fromJson(
    Map<String, dynamic> j,
  ) => ApplicationRecord(
    id: (j['id'] ?? '').toString(),
    jobId: j['jobId']?.toString(),
    company: (j['company'] ?? '').toString(),
    role: (j['role'] ?? '').toString(),
    location: (j['location'] ?? '').toString(),
    appliedAt: j['appliedAt'] != null
        ? (DateTime.tryParse(j['appliedAt'].toString()) ?? DateTime.now())
        : DateTime.now(),
    stage:
        ApplicationStage.values
            .where(
              (s) =>
                  s.name == (j['stage'] == 'saved' ? 'wishlist' : j['stage']),
            )
            .firstOrNull ??
        ApplicationStage.applied,
    matchBadge: j['matchBadge']?.toString(),
    resumeId: j['resumeId']?.toString(),
    interviewAt: j['interviewAt'] != null
        ? DateTime.tryParse(j['interviewAt'].toString())
        : null,
    salaryOffered: (j['salaryOffered'] as num?)?.round(),
    link: (j['link'] ?? '').toString(),
    notes: (j['notes'] as List? ?? const []).map((e) => e.toString()).toList(),
    followUpAt: j['followUpAt'] != null
        ? DateTime.tryParse(j['followUpAt'].toString())
        : null,
  );
}

class ProfileSettings {
  const ProfileSettings({
    this.name = '',
    this.email = '',
    this.avatarUrl = '',
    this.headline = '',
    this.bio = '',
    this.location = 'Philippines',
    this.targetRoles = const [],
    this.primarySkills = const [],
    this.preferredWorkMode,
    this.experienceLevel = ExperienceLevel.mid,
    this.expectedSalary,
    this.theme = AppTheme.system,
    this.accentColor = AppAccentColor.ocean,
    this.reduceTransparency = false,
    this.hapticFeedback = true,
    this.defaultTab = 'discover',
    this.scanQuota = 3,
    this.interviewLanguage = 'English',
  });

  final String name, email, avatarUrl, headline, bio, location;
  final List<String> targetRoles;
  final List<String> primarySkills;
  final WorkMode? preferredWorkMode;
  final ExperienceLevel experienceLevel;
  final int? expectedSalary;
  final AppTheme theme;
  final AppAccentColor accentColor;
  final bool reduceTransparency;
  final bool hapticFeedback;
  final String defaultTab;
  final int scanQuota;
  final String interviewLanguage; // 'English' | 'Taglish'

  String get initialLetter {
    if (name.trim().isNotEmpty) {
      return name.trim()[0].toUpperCase();
    }
    if (email.trim().isNotEmpty) {
      return email.trim()[0].toUpperCase();
    }
    return 'U';
  }

  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    if (email.trim().isNotEmpty) {
      final handle = email.split('@').first;
      if (handle.isNotEmpty) {
        return handle[0].toUpperCase() + handle.substring(1);
      }
    }
    return 'Job Seeker';
  }

  ProfileSettings copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? headline,
    String? bio,
    String? location,
    List<String>? targetRoles,
    List<String>? primarySkills,
    WorkMode? preferredWorkMode,
    ExperienceLevel? experienceLevel,
    int? expectedSalary,
    AppTheme? theme,
    AppAccentColor? accentColor,
    bool? reduceTransparency,
    bool? hapticFeedback,
    String? defaultTab,
    int? scanQuota,
    String? interviewLanguage,
  }) => ProfileSettings(
    name: name ?? this.name,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    headline: headline ?? this.headline,
    bio: bio ?? this.bio,
    location: location ?? this.location,
    targetRoles: targetRoles ?? this.targetRoles,
    primarySkills: primarySkills ?? this.primarySkills,
    preferredWorkMode: preferredWorkMode ?? this.preferredWorkMode,
    experienceLevel: experienceLevel ?? this.experienceLevel,
    expectedSalary: expectedSalary ?? this.expectedSalary,
    theme: theme ?? this.theme,
    accentColor: accentColor ?? this.accentColor,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
    hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    defaultTab: defaultTab ?? this.defaultTab,
    scanQuota: scanQuota ?? this.scanQuota,
    interviewLanguage: interviewLanguage ?? this.interviewLanguage,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'headline': headline,
    'bio': bio,
    'location': location,
    'targetRoles': targetRoles,
    'primarySkills': primarySkills,
    'preferredWorkMode': preferredWorkMode?.name,
    'experienceLevel': experienceLevel.name,
    'expectedSalary': expectedSalary,
    'theme': theme.name,
    'accentColor': accentColor.name,
    'reduceTransparency': reduceTransparency,
    'hapticFeedback': hapticFeedback,
    'defaultTab': defaultTab,
    'scanQuota': scanQuota,
    'interviewLanguage': interviewLanguage,
  };

  factory ProfileSettings.fromJson(Map<String, dynamic> j) => ProfileSettings(
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    avatarUrl: j['avatarUrl'] ?? j['avatar_url'] ?? '',
    headline: j['headline'] ?? '',
    bio: j['bio'] ?? '',
    location: j['location'] ?? 'Philippines',
    targetRoles: List<String>.from(j['targetRoles'] ?? []),
    primarySkills: List<String>.from(j['primarySkills'] ?? []),
    preferredWorkMode: j['preferredWorkMode'] != null
        ? WorkMode.values
              .where((m) => m.name == j['preferredWorkMode'])
              .firstOrNull
        : null,
    experienceLevel: j['experienceLevel'] != null
        ? ExperienceLevel.values
                  .where((e) => e.name == j['experienceLevel'])
                  .firstOrNull ??
              ExperienceLevel.mid
        : ExperienceLevel.mid,
    expectedSalary: j['expectedSalary'] is int
        ? j['expectedSalary'] as int
        : (j['expectedSalary'] is num
              ? (j['expectedSalary'] as num).toInt()
              : null),
    theme:
        AppTheme.values.where((t) => t.name == j['theme']).firstOrNull ??
        AppTheme.system,
    accentColor: j['accentColor'] != null
        ? AppAccentColor.values
                  .where((a) => a.name == j['accentColor'])
                  .firstOrNull ??
              AppAccentColor.ocean
        : AppAccentColor.ocean,
    reduceTransparency: j['reduceTransparency'] ?? false,
    hapticFeedback: j['hapticFeedback'] ?? true,
    defaultTab: (j['defaultTab'] == 'match' || j['defaultTab'] == 'arena')
        ? 'discover'
        : (j['defaultTab'] ?? 'discover'),
    scanQuota: j['scanQuota'] ?? 3,
    interviewLanguage: j['interviewLanguage'] ?? 'English',
  );
}
