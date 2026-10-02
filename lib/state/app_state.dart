import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_repository.dart';
import '../data/fixtures.dart';
import '../models/models.dart';

enum DemoScenario { normal, loading, empty, error }

class AppState {
  const AppState({
    this.ready = false,
    this.onboardingComplete = false,
    this.authenticated = false,
    this.savedJobIds = const {},
    this.resumes = const [],
    this.applications = const [],
    this.matches = const [],
    this.profile = const ProfileSettings(),
    this.defaultResumeId = 'r1',
    this.selectedMatchJobId,
    this.selectedMatchResumeId = 'r1',
    this.matchJobText = '',
    this.scenario = DemoScenario.normal,
    this.isOffline = false,
    this.queuedJobText,
    this.queuedResumeId,
    this.newlyAddedApplicationId,
  });

  final bool ready, onboardingComplete, authenticated;
  final Set<String> savedJobIds;
  final List<ResumeVersion> resumes;
  final List<ApplicationRecord> applications;
  final List<MatchResult> matches;
  final ProfileSettings profile;
  final String? defaultResumeId, selectedMatchJobId, selectedMatchResumeId;
  final String matchJobText;
  final DemoScenario scenario;
  final bool isOffline;
  final String? queuedJobText, queuedResumeId;
  final String? newlyAddedApplicationId;

  AppState copyWith({
    bool? ready,
    bool? onboardingComplete,
    bool? authenticated,
    Set<String>? savedJobIds,
    List<ResumeVersion>? resumes,
    List<ApplicationRecord>? applications,
    List<MatchResult>? matches,
    ProfileSettings? profile,
    String? defaultResumeId,
    String? selectedMatchJobId,
    String? selectedMatchResumeId,
    String? matchJobText,
    DemoScenario? scenario,
    bool? isOffline,
    String? queuedJobText,
    String? queuedResumeId,
    String? newlyAddedApplicationId,
  }) => AppState(
    ready: ready ?? this.ready,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    authenticated: authenticated ?? this.authenticated,
    savedJobIds: savedJobIds ?? this.savedJobIds,
    resumes: resumes ?? this.resumes,
    applications: applications ?? this.applications,
    matches: matches ?? this.matches,
    profile: profile ?? this.profile,
    defaultResumeId: defaultResumeId ?? this.defaultResumeId,
    selectedMatchJobId: selectedMatchJobId ?? this.selectedMatchJobId,
    selectedMatchResumeId: selectedMatchResumeId ?? this.selectedMatchResumeId,
    matchJobText: matchJobText ?? this.matchJobText,
    scenario: scenario ?? this.scenario,
    isOffline: isOffline ?? this.isOffline,
    queuedJobText: queuedJobText ?? this.queuedJobText,
    queuedResumeId: queuedResumeId ?? this.queuedResumeId,
    newlyAddedApplicationId: newlyAddedApplicationId,
  );
}

final repositoryProvider = Provider<DemoRepository>(
  (ref) => PreferencesDemoRepository(),
);

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

class AppController extends Notifier<AppState> {
  DemoRepository get _repo => ref.read(repositoryProvider);

  @override
  AppState build() {
    Future<void>.microtask(_load);
    return const AppState();
  }

  Future<void> _load() async {
    final data = await _repo.read() ?? fixtureSnapshot();
    state = _decode(data).copyWith(ready: true);
  }

  AppState _decode(Map<String, dynamic> j) {
    final defaultRes = j['defaultResumeId'] ?? 'r1';
    return AppState(
      onboardingComplete: j['onboardingComplete'] ?? false,
      authenticated: j['authenticated'] ?? false,
      savedJobIds: Set<String>.from(j['savedJobIds'] ?? ['j1']),
      defaultResumeId: defaultRes,
      selectedMatchResumeId: defaultRes,
      resumes: (j['resumes'] as List? ?? seedResumes)
          .map((e) => ResumeVersion.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      applications: (j['applications'] as List? ?? seedApplications)
          .map((e) => ApplicationRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      matches: (j['matches'] as List? ?? seedMatches)
          .map((e) => MatchResult.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      profile: j['profile'] != null
          ? ProfileSettings.fromJson(Map<String, dynamic>.from(j['profile']))
          : const ProfileSettings(),
    );
  }

  Map<String, dynamic> _encode() => {
    'onboardingComplete': state.onboardingComplete,
    'authenticated': state.authenticated,
    'savedJobIds': state.savedJobIds.toList(),
    'defaultResumeId': state.defaultResumeId,
    'resumes': state.resumes.map((e) => e.toJson()).toList(),
    'applications': state.applications.map((e) => e.toJson()).toList(),
    'matches': state.matches.map((e) => e.toJson()).toList(),
    'profile': state.profile.toJson(),
  };

  Future<void> _save() => _repo.write(_encode());

  void setMatchJobText(String text) {
    state = state.copyWith(matchJobText: text);
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
    _save();
  }

  void signIn() {
    state = state.copyWith(authenticated: true);
    _save();
  }

  void signOut() {
    state = state.copyWith(authenticated: false);
    _save();
  }

  void toggleSaved(String id) {
    final ids = {...state.savedJobIds};
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    state = state.copyWith(savedJobIds: ids);
    _save();
  }

  void selectForMatch(String jobId) {
    final job = seedJobs.where((j) => j.id == jobId).firstOrNull;
    state = state.copyWith(
      selectedMatchJobId: jobId,
      selectedMatchResumeId:
          state.selectedMatchResumeId ?? state.defaultResumeId ?? 'r1',
      matchJobText: job?.overview ?? state.matchJobText,
    );
  }

  void selectMatchInputs({String? jobId, String? resumeId}) {
    state = state.copyWith(
      selectedMatchJobId: jobId,
      selectedMatchResumeId: resumeId ?? state.selectedMatchResumeId,
    );
  }

  void addResume(ResumeVersion resume) {
    state = state.copyWith(
      resumes: [resume, ...state.resumes],
      defaultResumeId: resume.id,
      selectedMatchResumeId: resume.id,
    );
    _save();
  }

  void setDefaultResume(String id) {
    state = state.copyWith(defaultResumeId: id, selectedMatchResumeId: id);
    _save();
  }

  void deleteResume(String id) {
    final next = state.resumes.where((r) => r.id != id).toList();
    state = state.copyWith(
      resumes: next,
      defaultResumeId: state.defaultResumeId == id
          ? (next.isEmpty ? null : next.first.id)
          : state.defaultResumeId,
      selectedMatchResumeId: state.selectedMatchResumeId == id
          ? (next.isEmpty ? null : next.first.id)
          : state.selectedMatchResumeId,
    );
    _save();
  }

  ApplicationRecord trackJob(Job job) {
    final existing = state.applications
        .where(
          (a) =>
              a.jobId == job.id ||
              (a.company.toLowerCase() == job.company.toLowerCase() &&
                  a.role.toLowerCase() == job.role.toLowerCase()),
        )
        .firstOrNull;
    if (existing != null) return existing;

    final item = ApplicationRecord(
      id: 'a${DateTime.now().microsecondsSinceEpoch}',
      jobId: job.id,
      company: job.company,
      role: job.role,
      location: job.location,
      appliedAt: DateTime.now(),
      stage: ApplicationStage.applied,
      matchBadge: job.badgeText ?? 'Not analyzed',
    );
    state = state.copyWith(
      applications: [item, ...state.applications],
      newlyAddedApplicationId: item.id,
    );
    _save();
    return item;
  }

  ApplicationRecord saveToWishlist(Job job) {
    final existing = state.applications
        .where(
          (a) =>
              a.jobId == job.id ||
              (a.company.toLowerCase() == job.company.toLowerCase() &&
                  a.role.toLowerCase() == job.role.toLowerCase()),
        )
        .firstOrNull;
    if (existing != null) {
      if (existing.stage != ApplicationStage.wishlist) {
        final updated = existing.copyWith(stage: ApplicationStage.wishlist);
        updateApplication(updated);
        return updated;
      }
      return existing;
    }

    final item = ApplicationRecord(
      id: 'a${DateTime.now().microsecondsSinceEpoch}',
      jobId: job.id,
      company: job.company,
      role: job.role,
      location: job.location,
      appliedAt: DateTime.now(),
      stage: ApplicationStage.wishlist,
      matchBadge: job.badgeText ?? 'Not analyzed',
    );
    state = state.copyWith(
      applications: [item, ...state.applications],
      newlyAddedApplicationId: item.id,
    );
    _save();
    return item;
  }

  bool addApplication(ApplicationRecord value) {
    final isDuplicate = state.applications.any(
      (a) =>
          a.company.toLowerCase().trim() ==
              value.company.toLowerCase().trim() &&
          a.role.toLowerCase().trim() == value.role.toLowerCase().trim(),
    );
    if (isDuplicate) return false;

    state = state.copyWith(
      applications: [value, ...state.applications],
      newlyAddedApplicationId: value.id,
    );
    _save();
    return true;
  }

  void updateApplication(ApplicationRecord value) {
    state = state.copyWith(
      applications: [
        for (final a in state.applications)
          if (a.id == value.id) value else a,
      ],
    );
    _save();
  }

  void deleteApplication(String id) {
    state = state.copyWith(
      applications: state.applications.where((a) => a.id != id).toList(),
    );
    _save();
  }

  bool consumeScan() {
    if (state.profile.scanQuota <= 0) return false;
    final nextQuota = state.profile.scanQuota - 1;
    state = state.copyWith(
      profile: state.profile.copyWith(scanQuota: nextQuota),
    );
    _save();
    return true;
  }

  void refundScan() {
    final nextQuota = state.profile.scanQuota + 1;
    state = state.copyWith(
      profile: state.profile.copyWith(scanQuota: nextQuota),
    );
    _save();
  }

  void unlockRewardedScan() {
    final nextQuota = state.profile.scanQuota + 1;
    state = state.copyWith(
      profile: state.profile.copyWith(scanQuota: nextQuota),
    );
    _save();
  }

  void toggleOffline(bool offline) {
    state = state.copyWith(isOffline: offline);
    if (!offline && state.queuedJobText != null) {
      // Reconnected and have queued analysis
      if (consumeScan()) {
        final resumeId = state.queuedResumeId ?? state.defaultResumeId ?? 'r1';
        analyze(resumeId: resumeId, pasted: state.queuedJobText);
        state = state.copyWith(queuedJobText: null, queuedResumeId: null);
      }
    }
  }

  void queueOfflineAnalysis({
    required String jobText,
    required String resumeId,
  }) {
    state = state.copyWith(queuedJobText: jobText, queuedResumeId: resumeId);
  }

  MatchResult analyze({
    required String resumeId,
    String? jobId,
    String? pasted,
  }) {
    final job = jobId == null
        ? null
        : seedJobs.where((j) => j.id == jobId).firstOrNull;

    final resume = state.resumes.where((r) => r.id == resumeId).firstOrNull;
    final resumeTitle = resume?.title ?? 'v2_IT_Final';

    final int score;
    final String summaryTitle;
    final String summaryText;
    final List<String> matched;
    final List<String> missing;

    if (job?.id == 'j2' ||
        (pasted != null && pasted.toLowerCase().contains('it support'))) {
      score = 62;
      summaryTitle = 'Room to strengthen';
      summaryText =
          'Build on your strengths and tailor your resume to this role.';
      matched = const ['Customer Support', 'Hardware', 'Windows', 'Ticketing'];
      missing = const ['Active Directory', 'ITIL', 'VoIP'];
    } else {
      score = 85;
      summaryTitle = 'A promising fit';
      summaryText =
          'Your skills are a good starting point. Focus on the gaps below.';
      matched = const ['Flutter', 'REST APIs', 'Git', 'SQL'];
      missing = const ['Docker', 'GraphQL', 'CI/CD'];
    }

    final result = MatchResult(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
      resumeId: resumeId,
      resumeTitle: resumeTitle,
      jobId: jobId,
      jobLabel: job == null
          ? 'Junior Flutter Developer at Northwind Digital'
          : '${job.role} at ${job.company}',
      role: job?.role ?? 'Junior Flutter Developer',
      company: job?.company ?? 'Northwind Digital',
      location: job?.location ?? 'Davao City',
      createdAt: DateTime.now(),
      overall: score,
      summaryTitle: summaryTitle,
      summaryText: summaryText,
      components: {
        'Skills match': score + 3,
        'Experience alignment': score - 3,
        'Role keywords': score,
      },
      matched: matched,
      missing: missing,
      strengths: const [
        'Relevant technical delivery experience is visible',
        'Core development skills align directly with team responsibilities',
      ],
      gaps: const [
        'Containerization and pipeline tools could strengthen your application',
      ],
      suggestions: const [
        BulletSuggestion(
          'Worked on making the app faster',
          'Reduced app load time by 35% by caching API responses, improving retention for 2,000+ users',
        ),
        BulletSuggestion(
          'Helped fix bugs in the mobile app',
          'Resolved 40+ Flutter defects and reduced crash reports by 28% across Android devices',
        ),
        BulletSuggestion(
          'Made APIs for the team',
          'Built 6 REST API endpoints that cut mobile data retrieval time from 3.2s to 1.4s',
        ),
      ],
    );

    state = state.copyWith(matches: [result, ...state.matches]);
    _save();
    return result;
  }

  void updateProfile(ProfileSettings value) {
    state = state.copyWith(profile: value);
    _save();
  }

  void setScenario(DemoScenario value) =>
      state = state.copyWith(scenario: value);

  Future<void> resetDemoSession() async {
    await _repo.clear();
    state = _decode(fixtureSnapshot()).copyWith(
      ready: true,
      onboardingComplete: false,
      authenticated: false,
      matchJobText: '',
      selectedMatchResumeId: 'r1',
      defaultResumeId: 'r1',
    );
    await _save();
  }

  Future<void> reset() async {
    await _repo.clear();
    state = _decode(fixtureSnapshot())
        .copyWith(ready: true, onboardingComplete: true, authenticated: true);
    await _save();
  }
}

List<Job> filterJobs({
  required List<Job> jobs,
  String query = '',
  Set<String> categoryFilters = const {},
  Set<WorkMode> modes = const {},
  Set<EmploymentType> types = const {},
  String location = '',
  int minimumSalary = 0,
  bool savedOnly = false,
  Set<String> savedIds = const {},
  bool salaryDescending = false,
}) {
  final q = query.trim().toLowerCase();
  final values = jobs.where((j) {
    if (savedOnly && !savedIds.contains(j.id)) return false;
    if (q.isNotEmpty) {
      final combined =
          '${j.role} ${j.company} ${j.location} ${j.skills.join(' ')}'
              .toLowerCase();
      if (!combined.contains(q)) return false;
    }
    if (categoryFilters.isNotEmpty) {
      bool matchesCategory = false;
      for (final filter in categoryFilters) {
        if (filter == 'Frontend' &&
            (j.role.toLowerCase().contains('frontend') ||
                j.skills.contains('React'))) {
          matchesCategory = true;
        } else if (filter == 'Remote' &&
            (j.mode == WorkMode.remote ||
                j.location.toLowerCase().contains('remote'))) {
          matchesCategory = true;
        } else if (filter == 'BPO' &&
            (j.role.toLowerCase().contains('bpo') ||
                j.role.toLowerCase().contains('support'))) {
          matchesCategory = true;
        } else if (filter == 'Entry level' &&
            (j.role.toLowerCase().contains('junior') ||
                j.role.toLowerCase().contains('trainee') ||
                j.role.toLowerCase().contains('associate'))) {
          matchesCategory = true;
        }
      }
      if (!matchesCategory) return false;
    }
    if (location.isNotEmpty &&
        !j.location.toLowerCase().contains(location.toLowerCase())) {
      return false;
    }
    if (modes.isNotEmpty && !modes.contains(j.mode)) return false;
    if (types.isNotEmpty && !types.contains(j.type)) return false;
    if (minimumSalary > 0 && (j.salaryMax ?? 0) < minimumSalary) return false;
    return true;
  }).toList();

  values.sort(
    (a, b) => salaryDescending
        ? (b.salaryMax ?? -1).compareTo(a.salaryMax ?? -1)
        : a.postedDays.compareTo(b.postedDays),
  );
  return values;
}

Map<ApplicationStage, int> stageCounts(List<ApplicationRecord> applications) =>
    {
      for (final stage in ApplicationStage.values)
        stage: applications.where((a) => a.stage == stage).length,
    };

String? validateMatch({
  String? resumeId,
  String? jobId,
  String pasted = '',
  bool pastedMode = false,
}) {
  if (resumeId == null) return 'Choose a resume to continue.';
  if (pastedMode
      ? pasted.trim().length < 40
      : jobId == null && pasted.trim().length < 20) {
    return 'Add a job description to compare.';
  }
  return null;
}
