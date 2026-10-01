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
    this.defaultResumeId,
    this.selectedMatchJobId,
    this.selectedMatchResumeId,
    this.scenario = DemoScenario.normal,
  });
  final bool ready, onboardingComplete, authenticated;
  final Set<String> savedJobIds;
  final List<ResumeVersion> resumes;
  final List<ApplicationRecord> applications;
  final List<MatchResult> matches;
  final ProfileSettings profile;
  final String? defaultResumeId, selectedMatchJobId, selectedMatchResumeId;
  final DemoScenario scenario;
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
    DemoScenario? scenario,
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
    scenario: scenario ?? this.scenario,
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

  AppState _decode(Map<String, dynamic> j) => AppState(
    onboardingComplete: j['onboardingComplete'] ?? false,
    authenticated: j['authenticated'] ?? false,
    savedJobIds: Set<String>.from(j['savedJobIds'] ?? []),
    defaultResumeId: j['defaultResumeId'],
    resumes: (j['resumes'] as List)
        .map((e) => ResumeVersion.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    applications: (j['applications'] as List)
        .map((e) => ApplicationRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    matches: (j['matches'] as List)
        .map((e) => MatchResult.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    profile: ProfileSettings.fromJson(Map<String, dynamic>.from(j['profile'])),
  );
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
    state = state.copyWith(
      selectedMatchJobId: jobId,
      selectedMatchResumeId: state.defaultResumeId,
    );
  }

  void selectMatchInputs({String? jobId, String? resumeId}) {
    state = state.copyWith(
      selectedMatchJobId: jobId,
      selectedMatchResumeId: resumeId,
    );
  }

  void addResume(ResumeVersion resume) {
    state = state.copyWith(
      resumes: [resume, ...state.resumes],
      defaultResumeId: state.defaultResumeId ?? resume.id,
    );
    _save();
  }

  void renameResume(String id, String title) {
    state = state.copyWith(
      resumes: [
        for (final r in state.resumes)
          if (r.id == id) r.copyWith(title: title) else r,
      ],
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
    );
    _save();
  }

  ApplicationRecord trackJob(Job job) {
    final existing = state.applications
        .where((a) => a.jobId == job.id)
        .firstOrNull;
    if (existing != null) return existing;
    final item = ApplicationRecord(
      id: 'a${DateTime.now().microsecondsSinceEpoch}',
      jobId: job.id,
      company: job.company,
      role: job.role,
      location: job.location,
      appliedAt: DateTime.now(),
      stage: ApplicationStage.saved,
    );
    state = state.copyWith(applications: [item, ...state.applications]);
    _save();
    return item;
  }

  void addApplication(ApplicationRecord value) {
    state = state.copyWith(applications: [value, ...state.applications]);
    _save();
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

  MatchResult analyze({
    required String resumeId,
    String? jobId,
    String? pasted,
  }) {
    final job = jobId == null
        ? null
        : seedJobs.firstWhere((j) => j.id == jobId);
    final base = job == null ? 72 : 76 + (job.skills.length * 2);
    final result = MatchResult(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
      resumeId: resumeId,
      jobId: jobId,
      jobLabel: job == null
          ? 'Pasted job description'
          : '${job.role} at ${job.company}',
      createdAt: DateTime.now(),
      overall: base,
      components: {
        'Skills': base + 4,
        'Experience': base - 2,
        'Role language': base - 5,
      },
      matched:
          job?.skills.take(2).toList() ??
          const ['Communication', 'Software delivery'],
      missing: job?.skills.skip(2).toList() ?? const ['Role-specific tooling'],
      strengths: const [
        'Relevant delivery experience is visible',
        'Core skills are stated directly',
      ],
      gaps: const ['Add truthful context about scope and outcomes'],
      suggestions: const [
        BulletSuggestion(
          'Built and maintained app features.',
          'Delivered tested app workflows in partnership with product and design.',
        ),
        BulletSuggestion(
          'Worked with the development team.',
          'Reviewed changes and documented repeatable release checks for the team.',
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
  Set<WorkMode> modes = const {},
  Set<EmploymentType> types = const {},
  String location = '',
  int minimumSalary = 0,
  bool savedOnly = false,
  Set<String> savedIds = const {},
  bool salaryDescending = false,
}) {
  final q = query.trim().toLowerCase();
  final values = jobs
      .where(
        (j) =>
            (!savedOnly || savedIds.contains(j.id)) &&
            (q.isEmpty ||
                '${j.role} ${j.company} ${j.skills.join(' ')}'
                    .toLowerCase()
                    .contains(q)) &&
            (location.isEmpty ||
                j.location.toLowerCase().contains(location.toLowerCase())) &&
            (modes.isEmpty || modes.contains(j.mode)) &&
            (types.isEmpty || types.contains(j.type)) &&
            (minimumSalary == 0 || (j.salaryMax ?? 0) >= minimumSalary),
      )
      .toList();
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
  if (pastedMode ? pasted.trim().length < 40 : jobId == null) {
    return pastedMode
        ? 'Paste at least 40 characters of the job description.'
        : 'Choose a job to continue.';
  }
  return null;
}
