import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/services/location_service.dart';
import '../core/services/scam_shield_service.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_text_field.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/container_transform.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/staggered_entrance.dart';
import '../core/widgets/skeleton.dart';
import '../core/widgets/tactile_card.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';
import 'detail_screens.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with AutomaticKeepAliveClientMixin {
  String query = '';
  final Set<String> selectedCategories = {};
  bool showFilters = true;
  late final TextEditingController _searchController;
  Timer? _debounce;
  final Set<WorkMode> selectedModes = {};
  String _radius = 'All Philippines';
  int _salaryMin = 0;
  int? _salaryMax;
  final Set<String> _matching = {};

  static const filterOptions = [
    'Remote',
    'BPO / Shared Services',
    'Junior / Entry-Level',
    'Saved Matches',
  ];

  bool _isJobDescription(String text) {
    final trimmed = text.trim();
    if (trimmed.length > 50 &&
        (trimmed.startsWith('http://') ||
            trimmed.startsWith('https://') ||
            trimmed.contains('\n') ||
            trimmed.toLowerCase().contains('role:') ||
            trimmed.toLowerCase().contains('company:') ||
            trimmed.toLowerCase().contains('requirement') ||
            trimmed.toLowerCase().contains('responsibilit') ||
            trimmed.toLowerCase().contains('qualificat') ||
            trimmed.toLowerCase().contains('experience') ||
            trimmed.toLowerCase().contains('salary') ||
            trimmed.toLowerCase().contains('job description') ||
            trimmed.length > 120)) {
      return true;
    }
    return false;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    _debounce?.cancel();
    setState(() {
      query = '';
      _searchController.clear();
      selectedCategories.clear();
      selectedModes.clear();
      _radius = 'All Philippines';
      _salaryMin = 0;
      _salaryMax = null;
    });
  }

  void _showLocationPickerSheet() {
    if (!mounted) return;
    final colors = AppColors.of(context);
    final currentLoc = ref.read(userLocationProvider);

    showAdaptiveSheet(
      context: context,
      title: 'Select Job Location',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PressableScale(
              onPressed: () async {
                Navigator.pop(sheetContext);
                final detected = await ref
                    .read(userLocationProvider.notifier)
                    .detectLocation();
                if (!mounted) return;
                if (detected) {
                  final loc = ref.read(userLocationProvider);
                  if (loc != null) {
                    ref
                        .read(appControllerProvider.notifier)
                        .fetchNearbyJobs(
                          latitude: loc.latitude,
                          longitude: loc.longitude,
                        );
                    showGlassToast(context, 'Location set: ${loc.label}');
                  }
                } else {
                  showGlassToast(
                    context,
                    'Could not detect GPS. Choose a city below.',
                  );
                  _showLocationPickerSheet();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.paleIndigoSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.accent, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      color: colors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use device GPS',
                            style: AppTypography.subheadline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Detect approximate city or district',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Philippine Growth Hubs',
              style: AppTypography.caption.copyWith(
                color: colors.labelSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...PhilippineHubs.all.map((hub) {
              final isSelected = currentLoc?.label == hub.label;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: PressableScale(
                  onPressed: () {
                    AppMotion.selectionHaptic();
                    ref.read(userLocationProvider.notifier).setLocation(hub);
                    ref
                        .read(appControllerProvider.notifier)
                        .fetchNearbyJobs(
                          latitude: hub.latitude,
                          longitude: hub.longitude,
                        );
                    Navigator.pop(sheetContext);
                    showGlassToast(context, 'Location set: ${hub.label}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.paleIndigoSurface
                          : colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: isSelected
                          ? Border.all(color: colors.accent, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? colors.accent
                              : colors.labelTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          hub.label,
                          style: AppTypography.body.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required AppColors colors,
    int activeCount = 0,
  }) {
    final displayLabel = activeCount > 0 ? '$label ($activeCount)' : label;
    return PressableScale(
      onPressed: onTap,
      child: Semantics(
        button: true,
        label:
            '$label filter, ${activeCount > 0 ? "$activeCount active" : "none active"}',
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? colors.paleIndigoSurface : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.capsule),
            border: Border.all(
              color: isActive ? colors.accent : colors.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayLabel,
                style: AppTypography.footnote.copyWith(
                  color: isActive ? colors.accent : colors.labelPrimary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isActive ? colors.accent : colors.labelSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleTypeSheet() {
    AppMotion.selectionHaptic();
    final colors = AppColors.of(context);
    final userLocation = ref.read(userLocationProvider);

    showAdaptiveSheet(
      context: context,
      title: 'Role Type',
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: filterOptions.map((filter) {
                    final isSelected = selectedCategories.contains(filter);
                    return FilterChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: colors.primary.withValues(alpha: 0.15),
                      checkmarkColor: colors.primary,
                      labelStyle: AppTypography.footnote.copyWith(
                        color: isSelected
                            ? colors.primary
                            : colors.labelPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        AppMotion.selectionHaptic();
                        setState(() {
                          if (selected) {
                            selectedCategories.add(filter);
                          } else {
                            selectedCategories.remove(filter);
                          }
                        });
                        setSheetState(() {});
                        if (selected) {
                          if (filter == 'Remote') {
                            ref
                                .read(appControllerProvider.notifier)
                                .searchJobs(
                                  keywords: query.isNotEmpty
                                      ? query
                                      : 'developer',
                                  location: 'Remote',
                                );
                          } else if (filter == 'BPO / Shared Services') {
                            ref
                                .read(appControllerProvider.notifier)
                                .searchJobs(
                                  keywords:
                                      'customer support BPO technical helpdesk',
                                  location:
                                      userLocation?.label ?? 'Philippines',
                                );
                          } else if (filter == 'Junior / Entry-Level') {
                            ref
                                .read(appControllerProvider.notifier)
                                .searchJobs(
                                  keywords:
                                      'junior associate trainee entry-level',
                                  location:
                                      userLocation?.label ?? 'Philippines',
                                );
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (selectedCategories.isNotEmpty) ...[
                      Expanded(
                        child: AdaptiveButton.secondary(
                          label: 'Reset',
                          onPressed: () {
                            AppMotion.selectionHaptic();
                            setState(() => selectedCategories.clear());
                            setSheetState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: AdaptiveButton.primary(
                        label: 'Apply',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWorkArrangementSheet() {
    AppMotion.selectionHaptic();
    final colors = AppColors.of(context);

    showAdaptiveSheet(
      context: context,
      title: 'Work Arrangement',
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: WorkMode.values.map((mode) {
                    final isSelected = selectedModes.contains(mode);
                    return FilterChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(mode.label),
                      selected: isSelected,
                      selectedColor: colors.primary.withValues(alpha: 0.15),
                      checkmarkColor: colors.primary,
                      labelStyle: AppTypography.footnote.copyWith(
                        color: isSelected
                            ? colors.primary
                            : colors.labelPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        AppMotion.selectionHaptic();
                        setState(() {
                          if (selected) {
                            selectedModes.add(mode);
                          } else {
                            selectedModes.remove(mode);
                          }
                        });
                        setSheetState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (selectedModes.isNotEmpty) ...[
                      Expanded(
                        child: AdaptiveButton.secondary(
                          label: 'Reset',
                          onPressed: () {
                            AppMotion.selectionHaptic();
                            setState(() => selectedModes.clear());
                            setSheetState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: AdaptiveButton.primary(
                        label: 'Apply',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSalaryRangeSheet() {
    AppMotion.selectionHaptic();
    final colors = AppColors.of(context);

    const salaryBands = [
      (0, null, 'Any salary'),
      (20000, 35000, '₱20k – ₱35k'),
      (35000, 50000, '₱35k – ₱50k'),
      (50000, null, '₱50k+'),
    ];

    showAdaptiveSheet(
      context: context,
      title: 'Salary Range (PHP)',
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isFiltered = _salaryMin > 0 || _salaryMax != null;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: salaryBands.map((band) {
                    final isSelected =
                        _salaryMin == band.$1 && _salaryMax == band.$2;
                    return ChoiceChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(band.$3),
                      selected: isSelected,
                      selectedColor: colors.primary.withValues(alpha: 0.15),
                      labelStyle: AppTypography.footnote.copyWith(
                        color: isSelected
                            ? colors.primary
                            : colors.labelPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      onSelected: (_) {
                        AppMotion.selectionHaptic();
                        setState(() {
                          _salaryMin = band.$1;
                          _salaryMax = band.$2;
                        });
                        setSheetState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (isFiltered) ...[
                      Expanded(
                        child: AdaptiveButton.secondary(
                          label: 'Reset',
                          onPressed: () {
                            AppMotion.selectionHaptic();
                            setState(() {
                              _salaryMin = 0;
                              _salaryMax = null;
                            });
                            setSheetState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: AdaptiveButton.primary(
                        label: 'Apply',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRadiusSheet() {
    AppMotion.selectionHaptic();
    final colors = AppColors.of(context);
    final userLocation = ref.read(userLocationProvider);

    const radiusOptions = [
      'All Philippines',
      'Near Me (< 10 km)',
      'Metro Hub (< 25 km)',
    ];

    showAdaptiveSheet(
      context: context,
      title: 'Radius & Location',
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isFiltered = _radius != 'All Philippines';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: radiusOptions.map((radius) {
                    final isSelected = _radius == radius;
                    return ChoiceChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(radius),
                      selected: isSelected,
                      selectedColor: colors.primary.withValues(alpha: 0.15),
                      labelStyle: AppTypography.footnote.copyWith(
                        color: isSelected
                            ? colors.primary
                            : colors.labelPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      onSelected: (_) {
                        AppMotion.selectionHaptic();
                        setState(() => _radius = radius);
                        setSheetState(() {});
                        if (userLocation != null &&
                            (radius.startsWith('Near') ||
                                radius.startsWith('Metro'))) {
                          ref
                              .read(appControllerProvider.notifier)
                              .fetchNearbyJobs(
                                latitude: userLocation.latitude,
                                longitude: userLocation.longitude,
                                radiusKm: radius.startsWith('Near') ? 10 : 25,
                              );
                        }
                        if ((radius.startsWith('Near') ||
                                radius.startsWith('Metro')) &&
                            userLocation == null) {
                          Navigator.pop(sheetContext);
                          _showLocationPickerSheet();
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (isFiltered) ...[
                      Expanded(
                        child: AdaptiveButton.secondary(
                          label: 'Reset',
                          onPressed: () {
                            AppMotion.selectionHaptic();
                            setState(() => _radius = 'All Philippines');
                            setSheetState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: AdaptiveButton.primary(
                        label: 'Apply',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final userLocation = ref.watch(userLocationProvider);
    final colors = AppColors.of(context);

    final allJobs = state.jobs;
    final filteredJobs = filterJobs(
      jobs: allJobs,
      query: query,
      categoryFilters: selectedCategories,
      savedIds: state.savedJobIds,
      userLocation: userLocation,
      nearMeOnly: _radius.startsWith('Near') || _radius.startsWith('Metro'),
      maxRadiusKm: _radius.startsWith('Near') ? 10 : 25,
      modes: selectedModes,
      minimumSalary: _salaryMin,
      maximumSalary: _salaryMax,
    );

    return SafeArea(
      bottom: false,
      child: ContentState(
        isLoading: !state.ready,
        onRetry: () => ref.invalidate(appControllerProvider),
        empty: const EmptyState(
          icon: Icons.work_off_outlined,
          title: 'No roles found',
          message: 'Try another role, company, or Philippine location.',
        ),
        normal: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(appControllerProvider.notifier)
                .searchJobs(
                  keywords: query,
                  location: userLocation?.label ?? 'Philippines',
                  forceRefresh: true,
                );
          },
          child: CustomScrollView(
            key: const PageStorageKey('discover-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverAppTopBar(
                title: 'Discover',
                avatarLetter: state.profile.initialLetter,
                avatarUrl: state.profile.avatarUrl,
                expandedHeight: 64,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Indicator
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PressableScale(
                          onPressed: _showLocationPickerSheet,
                          child: Semantics(
                            button: true,
                            label:
                                'Select location, currently ${userLocation?.label ?? "not set"}',
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.capsule,
                                ),
                                border: Border.all(
                                  color: colors.borderSubtle,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    userLocation?.isGps == true
                                        ? Icons.my_location_rounded
                                        : Icons.location_on_outlined,
                                    size: 14,
                                    color: colors.accent,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      userLocation != null
                                          ? userLocation.label
                                          : 'Set location',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: colors.labelPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: colors.labelSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Search Bar
                      AdaptiveTextField(
                        controller: _searchController,
                        hintText: 'Search role, company, or paste a job post',
                        minLines: 1,
                        maxLines: 3,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colors.labelSecondary,
                          size: 20,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: colors.labelSecondary,
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _debounce?.cancel();
                                  _searchController.clear();
                                  setState(() => query = '');
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: showFilters
                                    ? colors.primary
                                    : colors.labelSecondary,
                              ),
                              tooltip: 'Toggle filters',
                              onPressed: () {
                                AppMotion.selectionHaptic();
                                setState(() => showFilters = !showFilters);
                              },
                            ),
                          ],
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (val) {
                          _debounce?.cancel();
                          setState(() => query = val);
                          if (val.trim().isNotEmpty) {
                            ref
                                .read(appControllerProvider.notifier)
                                .searchJobs(
                                  keywords: val.trim(),
                                  location:
                                      userLocation?.label ?? 'Philippines',
                                  forceRefresh: true,
                                );
                          }
                        },
                        onChanged: (val) {
                          setState(() {});
                          _debounce?.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 350),
                            () {
                              if (mounted) {
                                setState(() => query = val);
                                if (val.trim().length >= 3) {
                                  ref
                                      .read(appControllerProvider.notifier)
                                      .searchJobs(
                                        keywords: val.trim(),
                                        location:
                                            userLocation?.label ??
                                            'Philippines',
                                      );
                                }
                              }
                            },
                          );
                        },
                      ),

                      // Omnibar Job Description Auto-Detection Banner
                      if (_isJobDescription(_searchController.text)) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.paleIndigoSurface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: colors.accent.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    color: colors.accent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Job post detected in search',
                                      style: AppTypography.caption.copyWith(
                                        color: colors.labelPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AdaptiveButton.primary(
                                label: 'Analyze Against Active Resume',
                                onPressed: () {
                                  final resumeId =
                                      state.selectedMatchResumeId ??
                                      state.defaultResumeId ??
                                      state.resumes.firstOrNull?.id;
                                  if (resumeId == null) {
                                    showGlassToast(
                                      context,
                                      'Upload a resume in Vault first',
                                    );
                                    return;
                                  }
                                  AppMotion.selectionHaptic();
                                  try {
                                    final res = ref
                                        .read(appControllerProvider.notifier)
                                        .analyze(
                                          resumeId: resumeId,
                                          pasted: _searchController.text.trim(),
                                        );
                                    context.push('/matches/${res.id}');
                                  } catch (e) {
                                    showGlassToast(
                                      context,
                                      e is FormatException ? e.message : 'Could not analyze job description. Add responsibilities or requirements.',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      // One Horizontal Row of Outlined Filter Chips
                      if (showFilters) ...[
                        const SizedBox(height: AppSpacing.sm),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildOutlinedFilterChip(
                                label: 'Role Type',
                                isActive: selectedCategories.isNotEmpty,
                                activeCount: selectedCategories.length,
                                onTap: _showRoleTypeSheet,
                                colors: colors,
                              ),
                              const SizedBox(width: 8),
                              _buildOutlinedFilterChip(
                                label: 'Arrangement',
                                isActive: selectedModes.isNotEmpty,
                                activeCount: selectedModes.length,
                                onTap: _showWorkArrangementSheet,
                                colors: colors,
                              ),
                              const SizedBox(width: 8),
                              _buildOutlinedFilterChip(
                                label: 'Salary',
                                isActive: _salaryMin > 0 || _salaryMax != null,
                                activeCount:
                                    (_salaryMin > 0 || _salaryMax != null)
                                    ? 1
                                    : 0,
                                onTap: _showSalaryRangeSheet,
                                colors: colors,
                              ),
                              const SizedBox(width: 8),
                              _buildOutlinedFilterChip(
                                label: 'Radius',
                                isActive: _radius != 'All Philippines',
                                activeCount: _radius != 'All Philippines'
                                    ? 1
                                    : 0,
                                onTap: _showRadiusSheet,
                                colors: colors,
                              ),
                              if (selectedCategories.isNotEmpty ||
                                  selectedModes.isNotEmpty ||
                                  _radius != 'All Philippines' ||
                                  _salaryMin > 0) ...[
                                const SizedBox(width: 8),
                                PressableScale(
                                  onPressed: () {
                                    AppMotion.selectionHaptic();
                                    _clearAllFilters();
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 44,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.elevatedSurface,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.capsule,
                                      ),
                                      border: Border.all(
                                        color: colors.borderSubtle,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: colors.labelSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Clear',
                                          style: AppTypography.caption.copyWith(
                                            color: colors.labelSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      if (state.jobsLoading) const SkeletonBox(height: 64),
                      if (state.jobsError != null) ...[
                        Text(
                          state.jobsError!,
                          style: AppTypography.body.copyWith(
                            color: colors.error,
                          ),
                        ),
                        AdaptiveButton.secondary(
                          label: 'Retry job search',
                          onPressed: () => ref
                              .read(appControllerProvider.notifier)
                              .searchJobs(keywords: query, forceRefresh: true),
                        ),
                      ],

                      // Section Heading
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Recommended for you (${filteredJobs.length})',
                              style: AppTypography.headline.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Job List or Empty State
              if (filteredJobs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colors.paleIndigoSurface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            size: 32,
                            color: colors.labelSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No roles found',
                          style: AppTypography.title2.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Try another role, company, or Philippine location.',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AdaptiveButton.secondary(
                          onPressed: _clearAllFilters,
                          label: 'Clear filters',
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 108),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final job = filteredJobs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StaggeredEntrance(
                          index: index.clamp(0, 7),
                          key: ValueKey(job.id),
                          child: _JobCard(
                            job: job,
                            onTap: (sourceRect) =>
                                context.pushWithContainerTransform(
                                  (_) => JobDetailScreen(id: job.id),
                                  sourceRect: sourceRect,
                                  sourceRadius: AppRadius.card,
                                  sourceColor: colors.surface,
                                ),
                            matching: _matching.contains(job.id),
                            onMatch: () async {
                              final resumeId =
                                  state.selectedMatchResumeId ??
                                  state.defaultResumeId;
                              if (resumeId == null) {
                                showGlassToast(
                                  context,
                                  'Upload a resume in Vault first',
                                );
                                return;
                              }
                              setState(() => _matching.add(job.id));
                              try {
                                ref
                                    .read(appControllerProvider.notifier)
                                    .analyze(
                                      jobId: job.id,
                                      resumeId: resumeId,
                                    );
                              } finally {
                                if (mounted) {
                                  setState(() => _matching.remove(job.id));
                                }
                              }
                            },
                          ),
                        ),
                      );
                    }, childCount: filteredJobs.length),
                  ),
                ),

              // Footer spacing
              const SliverToBoxAdapter(child: SizedBox(height: 108)),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({
    required this.job,
    required this.onTap,
    required this.onMatch,
    this.matching = false,
  });

  final Job job;
  final ValueChanged<Rect> onTap;
  final VoidCallback onMatch;
  final bool matching;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final state = ref.watch(appControllerProvider);
    final isSaved = state.savedJobIds.contains(job.id);
    final scamResult = ScamShieldService.evaluate(
      role: job.role,
      company: job.company,
      overview: job.overview,
      salaryMin: job.salaryMin,
      salaryMax: job.salaryMax,
    );
    void openDetails() {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      onTap(box.localToGlobal(Offset.zero) & box.size);
    }

    return RepaintBoundary(
      child: Dismissible(
        key: ValueKey('job-wishlist-${job.id}'),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          AppMotion.mediumHaptic();
          final item = ref
              .read(appControllerProvider.notifier)
              .saveToWishlist(job);
          showGlassToast(
            context,
            'Added ${job.role} to Wishlist',
            actionLabel: 'Undo',
            onAction: () {
              ref
                  .read(appControllerProvider.notifier)
                  .deleteApplication(item.id);
            },
          );
          return false;
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: colors.diffAddedBg,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: colors.diffAddedText.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.playlist_add_check_rounded,
                color: colors.diffAddedText,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Add to Wishlist',
                style: AppTypography.caption.copyWith(
                  color: colors.diffAddedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        child: TactileCard(
          onTap: openDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CompanyAvatar(job.company, size: 40),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.role,
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.company,
                          style: AppTypography.footnote.copyWith(
                            color: colors.labelSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (job.matchScore != null)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.diffAddedBg,
                            borderRadius: BorderRadius.circular(
                              AppRadius.capsule,
                            ),
                            border: Border.all(
                              color: colors.diffAddedText.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 12,
                                color: colors.diffAddedText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Quick estimate: ${job.matchScore}%',
                                style: AppTypography.monoBadge.copyWith(
                                  color: colors.diffAddedText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: isSaved ? 'Unsave job' : 'Save job',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () {
                        AppMotion.selectionHaptic();
                        ref
                            .read(appControllerProvider.notifier)
                            .toggleSaved(job.id);
                      },
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: colors.accent,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.elevatedSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: colors.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: colors.labelSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            job.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: colors.labelSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.elevatedSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: colors.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      job.salaryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (job.distanceLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.paleIndigoSurface,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: colors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        job.distanceLabel!,
                        style: AppTypography.monoBadge.copyWith(
                          color: colors.accent,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              if (scamResult.isSuspicious) ...[
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scamResult.risk == ScamRisk.high
                        ? colors.error.withValues(alpha: 0.12)
                        : colors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(
                      color: scamResult.risk == ScamRisk.high
                          ? colors.error
                          : colors.warning,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 13,
                        color: scamResult.risk == ScamRisk.high
                            ? colors.error
                            : colors.warning,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          scamResult.risk == ScamRisk.high
                              ? 'Scam Shield: High risk'
                              : 'Scam Shield: Caution',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: scamResult.risk == ScamRisk.high
                                ? colors.error
                                : colors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${job.mode.label} · ${job.type.label}${job.applicationUrl != null && job.applicationUrl!.isNotEmpty ? " · Source: Original posting" : ""}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: colors.labelTertiary,
                      ),
                    ),
                  ),
                  if (job.matchScore == null)
                    IconButton(
                      tooltip: 'Instant Match',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: matching ? null : onMatch,
                      icon: matching
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(colors.accent),
                              ),
                            )
                          : Icon(
                              Icons.fact_check_outlined,
                              color: colors.accent,
                              size: 18,
                            ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
