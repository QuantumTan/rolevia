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
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_text_field.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/staggered_entrance.dart';
import '../data/fixtures.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

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

  static const filterOptions = [
    'Near Me (< 15 km)',
    'Frontend',
    'Remote',
    'BPO',
    'Entry level',
  ];

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final userLocation = ref.watch(userLocationProvider);
    final colors = AppColors.of(context);

    final hasRealJobs = state.jobs.any((j) => !RegExp(r'^j\d+$').hasMatch(j.id));
    final allJobs = hasRealJobs
        ? state.jobs.where((j) => !RegExp(r'^j\d+$').hasMatch(j.id)).toList()
        : (state.jobs.isNotEmpty ? state.jobs : seedJobs);
    final filteredJobs = filterJobs(
      jobs: allJobs,
      query: query,
      categoryFilters: selectedCategories,
      userLocation: userLocation,
    );

    return SafeArea(
      bottom: false,
      child: ScenarioState(
        scenario: state.scenario,
        onRetry: () => ref
            .read(appControllerProvider.notifier)
            .setScenario(DemoScenario.normal),
        empty: const EmptyState(
          icon: Icons.work_off_outlined,
          title: 'No roles found',
          message: 'Try another role, company, or Philippine location.',
        ),
        normal: CustomScrollView(
          key: const PageStorageKey('discover-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppTopBar(
              title: 'Discover',
              subtitle: 'A first role. A fresh start. Your next move.',
              expandedHeight: 96,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              userLocation?.isGps == true
                                  ? Icons.my_location_rounded
                                  : Icons.location_on_rounded,
                              size: 14,
                              color: colors.accent,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                userLocation != null
                                    ? 'Near ${userLocation.label}'
                                    : 'Set location',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: colors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: colors.accent,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search Bar
                    AdaptiveTextField(
                      controller: _searchController,
                      hintText: 'Role, company, or location',
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
                          ref.read(appControllerProvider.notifier).searchJobs(
                            keywords: val.trim(),
                            location: userLocation?.label ?? 'Philippines',
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
                                ref.read(appControllerProvider.notifier).searchJobs(
                                  keywords: val.trim(),
                                  location: userLocation?.label ?? 'Philippines',
                                );
                              }
                            }
                          },
                        );
                      },
                    ),

                    // Filter Chips
                    if (showFilters) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filterOptions.map((filter) {
                            final isSelected = selectedCategories.contains(
                              filter,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: PressableScale(
                                selected: isSelected,
                                onPressed: () async {
                                  AppMotion.selectionHaptic();
                                  if (isSelected) {
                                    setState(() {
                                      selectedCategories.remove(filter);
                                    });
                                  } else {
                                    setState(() {
                                      selectedCategories.add(filter);
                                    });
                                    if (filter == 'Near Me (< 15 km)') {
                                      final cur = ref.read(userLocationProvider);
                                      if (cur == null) {
                                        final ok = await ref
                                            .read(userLocationProvider.notifier)
                                            .detectLocation();
                                        if (!mounted) return;
                                        if (!ok) {
                                          _showLocationPickerSheet();
                                        } else {
                                          final l = ref.read(userLocationProvider);
                                          if (l != null) {
                                            ref
                                                .read(appControllerProvider.notifier)
                                                .fetchNearbyJobs(
                                                  latitude: l.latitude,
                                                  longitude: l.longitude,
                                                );
                                            ref
                                                .read(appControllerProvider.notifier)
                                                .searchJobs(
                                                  keywords: query.isNotEmpty ? query : 'developer',
                                                  location: l.label,
                                                );
                                          }
                                        }
                                      } else {
                                        ref
                                            .read(appControllerProvider.notifier)
                                            .fetchNearbyJobs(
                                              latitude: cur.latitude,
                                              longitude: cur.longitude,
                                            );
                                        ref
                                            .read(appControllerProvider.notifier)
                                            .searchJobs(
                                              keywords: query.isNotEmpty ? query : 'developer',
                                              location: cur.label,
                                            );
                                      }
                                    } else if (filter == 'Remote') {
                                      ref.read(appControllerProvider.notifier).searchJobs(
                                        keywords: query.isNotEmpty ? query : 'developer',
                                        location: 'Remote',
                                      );
                                    } else if (filter == 'Frontend') {
                                      ref.read(appControllerProvider.notifier).searchJobs(
                                        keywords: 'frontend developer',
                                        location: userLocation?.label ?? 'Philippines',
                                      );
                                    } else if (filter == 'BPO') {
                                      ref.read(appControllerProvider.notifier).searchJobs(
                                        keywords: 'customer support bpo',
                                        location: userLocation?.label ?? 'Philippines',
                                      );
                                    } else if (filter == 'Entry level') {
                                      ref.read(appControllerProvider.notifier).searchJobs(
                                        keywords: 'junior associate trainee',
                                        location: userLocation?.label ?? 'Philippines',
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colors.primary
                                        : colors.paleIndigoSurface,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.capsule,
                                    ),
                                  ),
                                  child: Text(
                                    filter,
                                    style: AppTypography.footnote.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : colors.labelPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final job = filteredJobs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StaggeredEntrance(
                        index: index,
                        key: ValueKey(job.id),
                        child: _JobCard(
                          job: job,
                          onTap: () {
                            if (job.matchScore != null) {
                              // Pre-analyzed card: open sample Results
                              final match = state.matches
                                  .where((m) => m.jobId == job.id)
                                  .firstOrNull;
                              if (match != null) {
                                context.push('/matches/${match.id}');
                              } else {
                                context.push('/jobs/${job.id}');
                              }
                            } else {
                              // Unanalyzed card: open Job Detail
                              context.push('/jobs/${job.id}');
                            }
                          },
                        ),
                      ),
                    );
                  }, childCount: filteredJobs.length),
                ),
              ),

            // Footer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 108),
                child: Center(
                  child: Text(
                    'Explore roles that match your interests',
                    style: AppTypography.caption.copyWith(
                      color: colors.labelTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({required this.job, required this.onTap});

  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Badge styling based on tone
    final (badgeBg, badgeFg) = switch (job.badgeTone) {
      'success' => (
        isDark ? const Color(0xFF173323) : const Color(0xFFE8F5E9),
        isDark ? const Color(0xFF9ED5AB) : const Color(0xFF2E7D32),
      ),
      'warning' => (
        isDark ? const Color(0xFF352B15) : const Color(0xFFFFF8E1),
        isDark ? const Color(0xFFE8C578) : const Color(0xFF8A5C13),
      ),
      _ => (colors.paleIndigoSurface, colors.accent),
    };

    return PressableScale(
      onPressed: onTap,
      child: AdaptiveCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Solid company initial mark
                Hero(
                  tag: 'company-${job.id}',
                  child: CompanyAvatar(job.company),
                ),
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
                IconButton(
                  tooltip:
                      ref
                          .watch(appControllerProvider)
                          .savedJobIds
                          .contains(job.id)
                      ? 'Unsave job'
                      : 'Save job',
                  onPressed: () => ref
                      .read(appControllerProvider.notifier)
                      .toggleSaved(job.id),
                  icon: Icon(
                    ref
                            .watch(appControllerProvider)
                            .savedJobIds
                            .contains(job.id)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: colors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colors.labelTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                      ),
                      if (job.distanceLabel != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.paleIndigoSurface,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            job.distanceLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Badge
                if (job.matchScore != null)
                  MatchBadge(job.matchScore!)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(AppRadius.capsule),
                    ),
                    child: Text(
                      job.badgeText ?? 'Tap to analyze',
                      style: TextStyle(
                        color: badgeFg,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
