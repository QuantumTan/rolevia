import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
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

    return SafeArea(
      bottom: false,
      child: ContentState(
        isLoading: !state.ready,
        onRetry: () => ref.invalidate(appControllerProvider),
        empty: EmptyState(
          icon: Icons.view_kanban_outlined,
          title: 'No applications',
          message: 'Add an application or track one from a job.',
          action: AdaptiveButton.primary(
            label: 'Add application',
            icon: const Icon(Icons.add_rounded, size: 20),
            onPressed: () => showAddApplicationSheet(context, ref),
          ),
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
                title: 'Tracker',
                subtitle: 'Every application is a step forward.',
                avatarLetter: state.profile.initialLetter,
                avatarUrl: state.profile.avatarUrl,
                expandedHeight: 96,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Horizontally scrollable status controls
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ApplicationStage.values.map((stage) {
                            final isSelected = stage == _selectedStage;
                            final count = counts[stage] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: StageDropTarget(
                                onDrop: (record) {
                                  ref
                                      .read(appControllerProvider.notifier)
                                      .updateApplication(
                                        record.copyWith(stage: stage),
                                      );
                                  AppMotion.successHaptic();
                                  showGlassToast(
                                    context,
                                    'Moved to ${stage.label}',
                                  );
                                },
                                child: PressableScale(
                                  selected: isSelected,
                                  onPressed: () {
                                    AppMotion.selectionHaptic();
                                    setState(() => _selectedStage = stage);
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 200),
                                    constraints: const BoxConstraints(
                                      minHeight: 44,
                                    ),
                                    alignment: Alignment.center,
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
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isSelected
                                              ? colors.accent
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          stage.label,
                                          style: AppTypography.footnote
                                              .copyWith(
                                                color: isSelected
                                                    ? Colors.white
                                                    : colors.labelPrimary,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white.withValues(
                                                    alpha: 0.25,
                                                  )
                                                : colors.separator,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.capsule,
                                            ),
                                          ),
                                          child: Text(
                                            '$count',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? Colors.white
                                                  : colors.labelSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Section header showing selected column & count
                      Wrap(
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
                        const SizedBox(height: AppSpacing.lg),
                        AdaptiveButton.secondary(
                          onPressed: () => showAddApplicationSheet(
                            context,
                            ref,
                            initialStage: _selectedStage,
                          ),
                          label: 'Add an application',
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

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.record,
    required this.isHighlight,
    required this.onTap,
  });

  final ApplicationRecord record;
  final bool isHighlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PressableScale(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isHighlight ? colors.paleIndigoSurface : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
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
                if (record.matchBadge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.paleIndigoSurface,
                      borderRadius: BorderRadius.circular(AppRadius.capsule),
                    ),
                    child: Text(
                      record.matchBadge!,
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
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
                      relativeDate(record.appliedAt),
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
