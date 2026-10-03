import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/services/location_service.dart';
import '../data/workspace_repository.dart';
import '../core/services/match_analyzer.dart';

import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import '../data/local/connection.dart';
import '../data/local/preferences_migration_helper.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/local_repository.dart';
import '../models/models.dart';

class AppState {
  const AppState({
    this.ready = false,
    this.onboardingComplete = false,
    this.authenticated = false,
    this.savedJobIds = const {},
    this.resumes = const [],
    this.applications = const [],
    this.matches = const [],
    this.jobs = const [],
    this.profile = const ProfileSettings(),
    this.defaultResumeId,
    this.selectedMatchJobId,
    this.selectedMatchResumeId,
    this.matchJobText = '',
    this.jobsLoading = false,
    this.jobsError,
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
  final List<Job> jobs;
  final ProfileSettings profile;
  final String? defaultResumeId, selectedMatchJobId, selectedMatchResumeId;
  final String matchJobText;
  final bool jobsLoading;
  final String? jobsError;
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
    List<Job>? jobs,
    ProfileSettings? profile,
    String? defaultResumeId,
    String? selectedMatchJobId,
    String? selectedMatchResumeId,
    String? matchJobText,
    bool? jobsLoading,
    String? jobsError,
    bool clearJobsError = false,
    bool clearResume = false,
    bool clearJob = false,
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
    jobs: jobs ?? this.jobs,
    profile: profile ?? this.profile,
    defaultResumeId: clearResume
        ? null
        : defaultResumeId ?? this.defaultResumeId,
    selectedMatchJobId: clearJob
        ? null
        : selectedMatchJobId ?? this.selectedMatchJobId,
    selectedMatchResumeId: clearResume
        ? null
        : selectedMatchResumeId ?? this.selectedMatchResumeId,
    matchJobText: matchJobText ?? this.matchJobText,
    jobsLoading: jobsLoading ?? this.jobsLoading,
    jobsError: clearJobsError ? null : jobsError ?? this.jobsError,
    isOffline: isOffline ?? this.isOffline,
    queuedJobText: queuedJobText ?? this.queuedJobText,
    queuedResumeId: queuedResumeId ?? this.queuedResumeId,
    newlyAddedApplicationId: newlyAddedApplicationId,
  );
}

String sanitizeOwner(String raw) {
  if (raw.isEmpty) return 'guest';
  return raw.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
}

final activeOwnerProvider = NotifierProvider<ActiveOwnerNotifier, String>(
  ActiveOwnerNotifier.new,
);

class ActiveOwnerNotifier extends Notifier<String> {
  @override
  String build() {
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.user;
    if (user != null && authRepo.authenticated) {
      return sanitizeOwner(user.id);
    }
    return 'guest';
  }

  void setOwner(String owner) {
    state = sanitizeOwner(owner);
  }
}

final appDatabaseProvider = Provider.family<AppDatabase, String>((ref, owner) {
  final cleanOwner = sanitizeOwner(owner);
  final db = AppDatabase(openDatabase(cleanOwner));
  ref.onDispose(() => db.close());
  return db;
});

final localRepositoryProvider =
    Provider.family<LocalRepository, String>((ref, owner) {
  final cleanOwner = sanitizeOwner(owner);
  final db = ref.watch(appDatabaseProvider(cleanOwner));
  final repo = LocalRepository(db, cleanOwner);
  ref.onDispose(() => repo.close());
  return repo;
});

final repositoryProvider = Provider<WorkspaceRepository>((ref) {
  final owner = ref.watch(activeOwnerProvider);
  return ref.watch(localRepositoryProvider(owner));
});

// Decoupled feature repository providers
final resumeRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => ref.watch(repositoryProvider),
);
final trackerRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => ref.watch(repositoryProvider),
);
final discoverRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => ref.watch(repositoryProvider),
);

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

class AppController extends Notifier<AppState> {
  WorkspaceRepository get _repo => ref.read(repositoryProvider);
  StreamSubscription? _subscription;
  StreamSubscription? _authSubscription;

  @override
  AppState build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _authSubscription?.cancel();
    });
    Future<void>.microtask(_load);
    return const AppState();
  }

  Future<void> _load() async {
    if (_repo is LocalRepository) {
      try {
        await PreferencesMigrationHelper.migrate(_repo as LocalRepository);
      } catch (e) {
        debugPrint('Migration notice: $e');
      }
    }

    final data = await _repo.read() ?? emptyWorkspace;
    state = _decode(data).copyWith(ready: true);

    if (_repo is LocalRepository) {
      _subscription?.cancel();
      _subscription = (_repo as LocalRepository).watch().listen((updated) {
        state = _decode(updated).copyWith(
          ready: true,
          matchJobText: state.matchJobText,
          selectedMatchJobId: state.selectedMatchJobId,
          selectedMatchResumeId: state.selectedMatchResumeId,
          isOffline: state.isOffline,
          jobsLoading: state.jobsLoading,
          jobsError: state.jobsError,
        );
      });
    }

    final authRepo = ref.read(authRepositoryProvider);
    _authSubscription?.cancel();
    _authSubscription = authRepo.onAuthStateChange.listen((authState) async {
      final user = authState.session?.user;
      if (user != null && authRepo.authenticated) {
        if (!state.authenticated || ref.read(activeOwnerProvider) != user.id) {
          final fullName = user.userMetadata?['full_name'] as String? ??
              user.userMetadata?['name'] as String?;
          final avatarUrl = user.userMetadata?['avatar_url'] as String? ??
              user.userMetadata?['picture'] as String?;
          await signIn(
            email: user.email,
            name: fullName,
            avatarUrl: avatarUrl,
            userId: user.id,
          );
        }
      } else if (authState.event == AuthChangeEvent.signedOut) {
        await signOut();
      }
    });

    if (AppConfig.configured) {
      final hasRealJobs = state.jobs.any(
        (j) => !RegExp(r'^j\d+$').hasMatch(j.id),
      );
      if (!hasRealJobs) {
        unawaited(searchJobs());
      }
    }
  }

  AppState _decode(Map<String, dynamic> j) {
    final resumes = (j['resumes'] as List? ?? [])
        .map((e) => ResumeVersion.fromJson(Map<String, dynamic>.from(e))).toList();
    final requestedResume = j['defaultResumeId'] as String?;
    final defaultRes = resumes.where((r) => r.id == requestedResume).firstOrNull?.id
        ?? resumes.firstOrNull?.id;
    final rawJobs = j['jobs'] as List?;
    final decodedJobs = (rawJobs != null && rawJobs.isNotEmpty)
        ? rawJobs
              .map((e) => Job.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
        : <Job>[];

    return AppState(
      onboardingComplete: j['onboardingComplete'] ?? false,
      authenticated: j['authenticated'] ?? false,
      savedJobIds: Set<String>.from(j['savedJobIds'] ?? []),
      defaultResumeId: defaultRes,
      selectedMatchResumeId: defaultRes,
      resumes: resumes,
      applications: (j['applications'] as List? ?? [])
          .map((e) => ApplicationRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      matches: (j['matches'] as List? ?? [])
          .map((e) => MatchResult.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      jobs: decodedJobs,
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
    'jobs': state.jobs.map((e) => e.toJson()).toList(),
    'profile': state.profile.toJson(),
  };

  Future<void> _save() => _repo.write(_encode());

  void setMatchJobText(String text) {
    state = state.copyWith(matchJobText: text, clearJob: true);
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
    _save();
  }

  Future<void> signIn({
    String? email,
    String? name,
    String? avatarUrl,
    String? userId,
  }) async {
    final String targetOwner = () {
      if (userId != null && userId.isNotEmpty) return userId;
      if (AppConfig.configured) {
        final currentUserId = ref.read(authRepositoryProvider).user?.id;
        if (currentUserId != null && currentUserId.isNotEmpty) {
          return currentUserId;
        }
      }
      if (email != null && email.isNotEmpty) {
        return 'user_${sanitizeOwner(email)}';
      }
      return 'user_default';
    }();

    final previousOwner = ref.read(activeOwnerProvider);
    final isSwitchingAccount =
        previousOwner != 'guest' && previousOwner != targetOwner;

    if (previousOwner != targetOwner) {
      _subscription?.cancel();
      _subscription = null;
      ref.read(activeOwnerProvider.notifier).setOwner(targetOwner);
    }

    final repoData = await _repo.read() ?? emptyWorkspace;

    // Preserve onboarding data only if graduating directly from a fresh guest session
    final bool preserveOnboardingData = previousOwner == 'guest' &&
        (repoData['resumes'] as List? ?? []).isEmpty &&
        (repoData['applications'] as List? ?? []).isEmpty;

    var loadedState = _decode(repoData);

    var profile = loadedState.profile;
    if (preserveOnboardingData && state.resumes.isNotEmpty) {
      loadedState = loadedState.copyWith(
        resumes: state.resumes,
        defaultResumeId: state.defaultResumeId,
        selectedMatchResumeId: state.selectedMatchResumeId,
      );
    }
    if (email != null && email.isNotEmpty) {
      profile = profile.copyWith(email: email);
    }
    if (name != null && name.isNotEmpty) {
      profile = profile.copyWith(name: name);
    }
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        (profile.avatarUrl.isEmpty || isSwitchingAccount)) {
      profile = profile.copyWith(avatarUrl: avatarUrl);
    }

    state = loadedState.copyWith(
      ready: true,
      onboardingComplete: true,
      authenticated: true,
      profile: profile,
      jobs: state.jobs.isNotEmpty ? state.jobs : loadedState.jobs,
    );

    if (_repo is LocalRepository) {
      _subscription?.cancel();
      _subscription = (_repo as LocalRepository).watch().listen((updated) {
        state = _decode(updated).copyWith(
          ready: true,
          authenticated: true,
          matchJobText: state.matchJobText,
          selectedMatchJobId: state.selectedMatchJobId,
          selectedMatchResumeId: state.selectedMatchResumeId,
          isOffline: state.isOffline,
          jobsLoading: state.jobsLoading,
          jobsError: state.jobsError,
        );
      });
    }

    await _save();
  }

  Future<void> signOut() async {
    if (AppConfig.configured) {
      try {
        await ref.read(authRepositoryProvider).signOut();
      } catch (e) {
        debugPrint('Sign out notice: $e');
      }
    }

    _subscription?.cancel();
    _subscription = null;

    // Completely wipe all user private data from memory
    state = AppState(
      ready: true,
      onboardingComplete: state.onboardingComplete,
      authenticated: false,
      savedJobIds: const {},
      resumes: const [],
      applications: const [],
      matches: const [],
      jobs: state.jobs, // Keep public job listings
      profile: const ProfileSettings(),
      defaultResumeId: null,
      selectedMatchJobId: null,
      selectedMatchResumeId: null,
      matchJobText: '',
      isOffline: state.isOffline,
    );

    ref.read(activeOwnerProvider.notifier).setOwner('guest');
    await _save();
  }

  void toggleSaved(String id) {
    final ids = {...state.savedJobIds};
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    state = state.copyWith(savedJobIds: ids);
    _save();
  }

  void selectForMatch(String jobId) {
    final job = state.jobs.where((j) => j.id == jobId).firstOrNull;
    state = state.copyWith(
      selectedMatchJobId: jobId,
      selectedMatchResumeId:
          state.selectedMatchResumeId ?? state.defaultResumeId,
      matchJobText: job == null ? state.matchJobText : jobText(job),
    );
  }

  void setJobs(List<Job> jobs) {
    state = state.copyWith(jobs: jobs);
    _save();
  }

  Future<void> fetchNearbyJobs({
    required double latitude,
    required double longitude,
    double radiusKm = 15.0,
  }) async {
    if (!AppConfig.configured) return;
    try {
      final client = Supabase.instance.client;
      final response = await client.functions.invoke(
        'get-nearby-jobs',
        queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius_km': radiusKm.toString(),
        },
      );
      if (response.status == 200 && response.data is List) {
        final incoming = (response.data as List)
            .map((e) => Job.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        if (incoming.isNotEmpty) {
          final incomingIds = {for (final j in incoming) j.id};
          final merged = [
            ...incoming,
            ...state.jobs.where((j) => !incomingIds.contains(j.id)),
          ];
          state = state.copyWith(jobs: merged);
          _save();
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch nearby jobs: $e');
    }
  }

  Future<List<Job>> searchJobs({
    String? keywords,
    String? location,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    if (!AppConfig.configured) {
      state = state.copyWith(
        jobsError:
            'Live job search is not configured. Cached jobs remain available.',
      );
      return state.jobs;
    }
    state = state.copyWith(jobsLoading: true, clearJobsError: true);
    final searchKeywords = (keywords != null && keywords.trim().isNotEmpty)
        ? keywords.trim()
        : (state.profile.targetRoles.isNotEmpty
              ? state.profile.targetRoles.first
              : 'developer');
    final searchLocation = (location != null && location.trim().isNotEmpty)
        ? location.trim()
        : (state.profile.location.isNotEmpty
              ? state.profile.location
              : 'Philippines');

    try {
      final client = Supabase.instance.client;
      final response = await client.functions
          .invoke(
            'search-jobs',
            body: {
              'keywords': searchKeywords,
              'location': searchLocation,
              'page': page,
              'forceRefresh': forceRefresh,
            },
          )
          .timeout(const Duration(seconds: 25));
      if (response.status == 200 && response.data is Map) {
        final raw = response.data['jobs'] as List? ?? [];
        final incoming = raw
            .map((e) => Job.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        if (incoming.isNotEmpty) {
          if (_repo is LocalRepository) {
            final localRepo = _repo as LocalRepository;
            for (final j in incoming) {
              await localRepo.put('jobs', j.toJson());
            }
          }
          final incomingIds = {for (final j in incoming) j.id};
          // Filter out seed mock jobs (id pattern: j1, j2, etc.) to prioritize real jobs
          final existing = state.jobs
              .where(
                (j) =>
                    !incomingIds.contains(j.id) &&
                    !RegExp(r'^j\d+$').hasMatch(j.id),
              )
              .toList();
          final merged = [...incoming, ...existing];
          state = state.copyWith(jobs: merged);
          await _save();
          return incoming;
        }
      } else {
        throw StateError('Unexpected job search response');
      }
    } catch (e) {
      state = state.copyWith(
        jobsError: 'Job search failed. Check your connection and retry.',
      );
    } finally {
      state = state.copyWith(jobsLoading: false);
    }
    return state.jobs;
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
      clearResume: next.isEmpty,
      defaultResumeId: state.defaultResumeId == id
          ? (next.isEmpty ? null : next.first.id)
          : state.defaultResumeId,
      selectedMatchResumeId: state.selectedMatchResumeId == id
          ? (next.isEmpty ? null : next.first.id)
          : state.selectedMatchResumeId,
    );
    _save();
  }

  ApplicationRecord trackJob(
    Job job, {
    String? resumeId,
    ApplicationStage stage = ApplicationStage.applied,
  }) {
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
      id: const Uuid().v4(),
      jobId: job.id,
      company: job.company,
      role: job.role,
      location: job.location,
      appliedAt: DateTime.now(),
      stage: stage,
      resumeId:
          resumeId ?? state.selectedMatchResumeId ?? state.defaultResumeId,
      link: job.applicationUrl ?? '',
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
      id: const Uuid().v4(),
      jobId: job.id,
      company: job.company,
      role: job.role,
      location: job.location,
      appliedAt: DateTime.now(),
      stage: ApplicationStage.wishlist,
      resumeId: state.selectedMatchResumeId ?? state.defaultResumeId,
      link: job.applicationUrl ?? '',
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

  ApplicationRecord trackMatch(MatchResult match) {
    final existing = state.applications
        .where(
          (a) =>
              (match.jobId != null && a.jobId == match.jobId) ||
              (a.role == match.role && a.company == match.company),
        )
        .firstOrNull;
    if (existing != null) return existing;
    final job = state.jobs.where((j) => j.id == match.jobId).firstOrNull;
    final record = ApplicationRecord(
      id: const Uuid().v4(),
      jobId: match.jobId,
      resumeId: match.resumeId,
      role: match.role,
      company: match.company,
      location: match.location,
      appliedAt: DateTime.now(),
      stage: ApplicationStage.wishlist,
      matchBadge: '${match.overall}% Match',
      link: job?.applicationUrl ?? '',
    );
    addApplication(record);
    return record;
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
    final job = state.jobs.where((j) => j.id == jobId).firstOrNull;
    final resume = state.resumes.where((r) => r.id == resumeId).firstOrNull;
    if (resume == null) {
      throw const FormatException('Choose a resume to continue.');
    }
    final result = MatchAnalyzer.analyze(
      resume: resume,
      job: job,
      text: pasted ?? (job == null ? '' : jobText(job)),
    );
    state = state.copyWith(
      matches: [result, ...state.matches],
      jobs: [
        for (final item in state.jobs)
          if (item.id == jobId)
            item.copyWith(
              matchScore: result.overall,
              badgeText: '${result.overall}% Match',
              badgeTone: result.overall >= 80 ? 'success' : 'warning',
            )
          else
            item,
      ],
    );
    _save();
    return result;
  }

  void updateProfile(ProfileSettings value) {
    state = state.copyWith(profile: value);
    if (_repo is LocalRepository) {
      (_repo as LocalRepository).enqueue('profiles', 'upsert', value.toJson());
    }
    _save();
    if (AppConfig.configured) {
      final role = value.targetRoles.isNotEmpty
          ? value.targetRoles.first
          : 'developer';
      unawaited(
        searchJobs(
          keywords: role,
          location: value.location,
          forceRefresh: true,
        ),
      );
    }
  }

  Future<void> reset() async {
    await _repo.clear();
    state = _decode(emptyWorkspace).copyWith(ready: true);
    await _save();
  }
}

String jobText(Job job) => [
  job.role,
  job.company,
  job.overview,
  ...job.responsibilities,
  ...job.qualifications,
  ...job.skills,
].join('\n');

List<Job> filterJobs({
  required List<Job> jobs,
  String query = '',
  Set<String> categoryFilters = const {},
  Set<WorkMode> modes = const {},
  Set<EmploymentType> types = const {},
  String location = '',
  int minimumSalary = 0,
  int? maximumSalary,
  bool savedOnly = false,
  Set<String> savedIds = const {},
  bool salaryDescending = false,
  UserLocation? userLocation,
  bool nearMeOnly = false,
  double maxRadiusKm = 15.0,
}) {
  final q = query.trim().toLowerCase();
  final isNearMeActive =
      nearMeOnly || categoryFilters.contains('Near Me (< 15 km)');

  final List<Job> mappedJobs = jobs.map((j) {
    if (userLocation != null && j.latitude != null && j.longitude != null) {
      final dist = computeHaversineDistanceKm(
        userLocation.latitude,
        userLocation.longitude,
        j.latitude!,
        j.longitude!,
      );
      return j.copyWith(distanceKm: dist);
    }
    return j;
  }).toList();

  final values = mappedJobs.where((j) {
    if (savedOnly && !savedIds.contains(j.id)) return false;
    if (isNearMeActive && userLocation == null) return false;
    if (isNearMeActive && userLocation != null) {
      if (j.distanceKm == null || j.distanceKm! > maxRadiusKm) {
        return false;
      }
    }
    if (q.isNotEmpty) {
      final combined =
          '${j.role} ${j.company} ${j.location} ${j.skills.join(' ')}'
              .toLowerCase();
      if (!combined.contains(q)) return false;
    }
    if (categoryFilters.isNotEmpty) {
      bool matchesCategory = false;
      for (final filter in categoryFilters) {
        if (filter == 'Near Me (< 15 km)') {
          matchesCategory = true;
        } else if (filter == 'Frontend' &&
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
    if (maximumSalary != null &&
        (j.salaryMin == null || j.salaryMin! >= maximumSalary)) {
      return false;
    }
    return true;
  }).toList();

  values.sort((a, b) {
    if (isNearMeActive) {
      final distA = a.distanceKm ?? double.infinity;
      final distB = b.distanceKm ?? double.infinity;
      final cmp = distA.compareTo(distB);
      if (cmp != 0) return cmp;
    }
    return salaryDescending
        ? (b.salaryMax ?? -1).compareTo(a.salaryMax ?? -1)
        : a.postedDays.compareTo(b.postedDays);
  });
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
