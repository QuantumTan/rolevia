import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_text_field.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/pressable.dart';
import '../core/widgets/stage_drop_target.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';
import 'application_details_sheet.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen>
    with AutomaticKeepAliveClientMixin {
  ApplicationStage _selectedStage = ApplicationStage.applied;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final outboxCount = ref.watch(outboxCountProvider).value ?? 0;
    final colors = AppColors.of(context);

    if (!state.authenticated) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.paleIndigoSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 36,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Application Tracker is Locked',
                  style: AppTypography.title2.copyWith(
                    color: colors.labelPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Please sign in to securely access your tracked applications, interview stages, and notes.',
                  style: AppTypography.body.copyWith(
                    color: colors.labelSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AdaptiveButton.primary(
                  label: 'Sign in to access',
                  icon: const Icon(Icons.login_rounded, size: 18),
                  onPressed: () => context.go('/sign-in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final counts = stageCounts(state.applications);
    final stageRecords = state.applications
        .where((a) => a.stage == _selectedStage)
        .toList();

    // Compute velocity metrics
    final appliedCount = state.applications
        .where((a) => a.stage == ApplicationStage.applied)
        .length;
    final interviewCount = state.applications
        .where(
          (a) => a.stage == ApplicationStage.interview || a.interviewAt != null,
        )
        .length;
    final offerCount = state.applications
        .where((a) => a.stage == ApplicationStage.offer)
        .length;
    final totalTracked = state.applications.length;
    final totalProgressed = interviewCount + offerCount;
    final conversionRate = appliedCount > 0
        ? ((totalProgressed / (appliedCount + totalProgressed)) * 100).round()
        : (totalProgressed > 0 ? 100 : 0);

    return SafeArea(
      bottom: false,
      child: ContentState(
        isLoading: !state.ready,
        onRetry: () => ref.invalidate(appControllerProvider),
        empty: const EmptyState(
          icon: Icons.view_kanban_outlined,
          title: 'No applications',
          message: 'Track applications to monitor pipeline stages.',
        ),
        normal: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() < 150) return;
            final index = ApplicationStage.values.indexOf(_selectedStage);
            final next = (index + (velocity < 0 ? 1 : -1)).clamp(
              0,
              ApplicationStage.values.length - 1,
            );
            AppMotion.selectionHaptic();
            setState(() => _selectedStage = ApplicationStage.values[next]);
          },
          child: CustomScrollView(
            key: const PageStorageKey('tracker-scroll'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverAppTopBar(
                title: 'Pipeline',
                avatarLetter: state.profile.initialLetter,
                avatarUrl: state.profile.avatarUrl,
                expandedHeight: 64,
                onAdd: () => showAddApplicationSheet(context, ref),
              ),

              // Compact conversion ribbon keeps the pipeline readable at a glance.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: AdaptiveCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Text(
                          '$totalTracked Tracked  •  $appliedCount Applied  •  $conversionRate% Conversion',
                          style: AppTypography.monoData.copyWith(
                            color: colors.labelPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final hasPending = outboxCount > 0;
                            final isOffline = state.isOffline;
                            final isSynced = !hasPending && !isOffline;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSynced
                                      ? Icons.cloud_done_outlined
                                      : Icons.cloud_off_outlined,
                                  size: 15,
                                  color: isSynced
                                      ? colors.success
                                      : colors.warning,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hasPending
                                      ? '$outboxCount queued'
                                      : (isOffline ? 'Offline' : 'Synced'),
                                  style: AppTypography.caption.copyWith(
                                    color: isSynced
                                        ? colors.labelSecondary
                                        : colors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: _PipelineStageSwitcher(
                    selected: _selectedStage,
                    counts: counts,
                    onSelected: (stage) {
                      AppMotion.segmentedControlOrChip();
                      setState(() => _selectedStage = stage);
                    },
                    onMoved: (record, stage) {
                      ref
                          .read(appControllerProvider.notifier)
                          .updateApplication(record.copyWith(stage: stage));
                      AppMotion.drop();
                      showGlassToast(context, 'Moved to ${stage.label}');
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        '${_selectedStage.label} (${stageRecords.length})',
                        style: AppTypography.headline.copyWith(
                          color: colors.labelPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Tap a card to update',
                        style: AppTypography.caption.copyWith(
                          color: colors.labelTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (stageRecords.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.paleIndigoSurface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox_rounded,
                            size: 28,
                            color: colors.labelSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No ${_selectedStage.label.toLowerCase()} jobs',
                          style: AppTypography.title2.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Jobs you add to ${_selectedStage.label.toLowerCase()} will show here.',
                          style: AppTypography.body.copyWith(
                            color: colors.labelSecondary,
                          ),
                          textAlign: TextAlign.center,
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
                      final item = stageRecords[index];
                      final isNewlyAdded =
                          state.newlyAddedApplicationId == item.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LongPressDraggable<ApplicationRecord>(
                          data: item,
                          onDragStarted: AppMotion.mediumHaptic,
                          onDragEnd: (_) => AppMotion.lightHaptic(),
                          feedback: Material(
                            color: Colors.transparent,
                            elevation: 8,
                            borderRadius: AppRadius.cardRadius,
                            child: SizedBox(
                              width: 280,
                              child: IgnorePointer(
                                child: _ApplicationCard(
                                  record: item,
                                  isHighlight: true,
                                  onTap: () {},
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.35,
                            child: _ApplicationCard(
                              record: item,
                              isHighlight: isNewlyAdded,
                              onTap: () {},
                            ),
                          ),
                          child: _ApplicationCard(
                            record: item,
                            isHighlight: isNewlyAdded,
                            onTap: () =>
                                showEditApplicationSheet(context, ref, item),
                          ),
                        ),
                      );
                    }, childCount: stageRecords.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipelineStageSwitcher extends StatelessWidget {
  const _PipelineStageSwitcher({
    required this.selected,
    required this.counts,
    required this.onSelected,
    required this.onMoved,
  });

  final ApplicationStage selected;
  final Map<ApplicationStage, int> counts;
  final ValueChanged<ApplicationStage> onSelected;
  final void Function(ApplicationRecord, ApplicationStage) onMoved;

  Widget _label(
    BuildContext context,
    ApplicationStage stage,
    AppColors colors,
  ) {
    final isSelected = stage == selected;
    return StageDropTarget(
      onDrop: (record) => onMoved(record, stage),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 88),
        child: Center(
          child: Text(
            '${stage.label} ${counts[stage] ?? 0}',
            maxLines: 1,
            style: AppTypography.caption.copyWith(
              color: isSelected ? colors.onAccent : colors.labelPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final stages = ApplicationStage.values;
    final width = math.max(
      MediaQuery.sizeOf(context).width - 32,
      stages.length * 96.0,
    );

    return RepaintBoundary(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: Theme.of(context).platform == TargetPlatform.iOS
              ? CupertinoSlidingSegmentedControl<ApplicationStage>(
                  groupValue: selected,
                  thumbColor: colors.accent,
                  backgroundColor: colors.elevatedSurface,
                  onValueChanged: (value) {
                    if (value != null) onSelected(value);
                  },
                  children: {
                    for (final stage in stages)
                      stage: _label(context, stage, colors),
                  },
                )
              : SegmentedButton<ApplicationStage>(
                  showSelectedIcon: false,
                  selected: {selected},
                  onSelectionChanged: (value) => onSelected(value.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: colors.accent,
                    selectedForegroundColor: colors.onAccent,
                    backgroundColor: colors.elevatedSurface,
                    foregroundColor: colors.labelPrimary,
                    side: BorderSide(color: colors.hairlineBorder),
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    for (final stage in stages)
                      ButtonSegment<ApplicationStage>(
                        value: stage,
                        label: _label(context, stage, colors),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  const _ApplicationCard({
    required this.record,
    required this.isHighlight,
    required this.onTap,
  });

  final ApplicationRecord record;
  final bool isHighlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final daysSinceContact = math.max(
      0,
      DateTime.now().difference(record.appliedAt).inDays,
    );
    final needsFollowUp =
        daysSinceContact > 7 &&
        (record.stage == ApplicationStage.applied ||
            record.stage == ApplicationStage.interview);

    return RepaintBoundary(
      child: PressableScale(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isHighlight ? colors.paleIndigoSurface : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isHighlight ? colors.accent : colors.borderSubtle,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (MediaQuery.textScalerOf(context).scale(13) <= 18) ...[
                    CompanyAvatar(record.company),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.role,
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.company,
                          style: AppTypography.subheadline.copyWith(
                            color: colors.labelSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (record.matchBadge != null &&
                      record.matchBadge != 'Not analyzed')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.diffAddedBg,
                        borderRadius: BorderRadius.circular(AppRadius.capsule),
                        border: Border.all(
                          color: colors.diffAddedText.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        record.matchBadge!,
                        style: AppTypography.monoBadge.copyWith(
                          color: colors.diffAddedText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              if (needsFollowUp) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.diffPrunedBg,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(
                      color: colors.diffPrunedText.withValues(alpha: 0.35),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: colors.diffPrunedText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Follow-up due (>7d)',
                          style: AppTypography.monoBadge.copyWith(
                            color: colors.diffPrunedText,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 8,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: colors.labelTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysSinceContact == 0
                            ? 'Today'
                            : '${daysSinceContact}d since contact',
                        style: AppTypography.caption.copyWith(
                          color: colors.labelTertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: colors.labelTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.location,
                        style: AppTypography.caption.copyWith(
                          color: colors.labelTertiary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: colors.labelTertiary,
                  ),
                ],
              ),
              if (record.notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.paleIndigoSurface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    record.notes.last,
                    style: AppTypography.caption.copyWith(
                      color: colors.labelSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void showAddApplicationSheet(
  BuildContext context,
  WidgetRef ref, {
  ApplicationStage initialStage = ApplicationStage.applied,
}) {
  final roleController = TextEditingController();
  final companyController = TextEditingController();
  final notesController = TextEditingController();
  ApplicationStage selectedStage = initialStage;

  showAdaptiveSheet(
    context: context,
    title: 'Add application',
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: roleController,
              autofocus: true,
              labelText: 'Role *',
              hintText: 'e.g. Junior Flutter Developer',
            ),
            const SizedBox(height: AppSpacing.sm),
            AdaptiveTextField(
              controller: companyController,
              labelText: 'Company *',
              hintText: 'e.g. Northwind Digital',
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Status',
              style: AppTypography.subheadline.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.of(context).labelPrimary,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ApplicationStage.values.map((stage) {
                  final isSelected = stage == selectedStage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PressableScale(
                      onPressed: () {
                        setSheetState(() => selectedStage = stage);
                      },
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.of(context).primary
                              : AppColors.of(context).paleIndigoSurface,
                          borderRadius: BorderRadius.circular(
                            AppRadius.capsule,
                          ),
                        ),
                        child: Text(
                          stage.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.of(context).labelPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AdaptiveTextField(
              controller: notesController,
              labelText: 'Notes (optional)',
              hintText: 'e.g. Interview scheduled next Tuesday',
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),
            AdaptiveButton.primary(
              isFullWidth: true,
              onPressed: () {
                final role = roleController.text.trim();
                final company = companyController.text.trim();
                final note = notesController.text.trim();

                if (role.isEmpty || company.isEmpty) {
                  showGlassToast(context, 'Role and company are required');
                  return;
                }

                final newRecord = ApplicationRecord(
                  id: 'a_${DateTime.now().microsecondsSinceEpoch}',
                  company: company,
                  role: role,
                  location: 'Philippines',
                  appliedAt: DateTime.now(),
                  stage: selectedStage,
                  matchBadge: 'Added manually',
                  notes: note.isNotEmpty ? [note] : const [],
                );

                final added = ref
                    .read(appControllerProvider.notifier)
                    .addApplication(newRecord);

                Navigator.pop(sheetContext);

                if (added) {
                  showGlassToast(
                    context,
                    'Application added',
                    icon: Icons.check_circle_rounded,
                  );
                } else {
                  showGlassToast(context, 'Duplicate application detected');
                }
              },
              label: 'Add application',
            ),
          ],
        ),
      ),
    ),
  );
}

void showEditApplicationSheet(
  BuildContext context,
  WidgetRef ref,
  ApplicationRecord record,
) {
  showApplicationDetailsSheet(context, record);
}

String relativeDate(DateTime date) {
  final days = DateTime.now().difference(date).inDays;
  if (days < 0) return shortDate(date);
  return days == 0 ? 'Today' : '${days}d ago';
}
