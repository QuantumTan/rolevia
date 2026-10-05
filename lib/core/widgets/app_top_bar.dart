import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import '../services/ad_service.dart';
import 'adaptive_button.dart';
import 'adaptive_dialog.dart';
import 'adaptive_sheet.dart';
import 'adaptive_text_field.dart';
import 'adaptive_toast.dart';
import 'pressable.dart';
import 'user_avatar.dart';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/cupertino.dart';

import '../../features/tracker_screen.dart' show showAddApplicationSheet;

class SliverAppTopBar extends ConsumerWidget {
  const SliverAppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showAvatar = true,
    this.avatarLetter = 'U',
    this.avatarUrl,
    this.trailing,
    this.bottom,
    this.bottomHeight = 0,
    this.actions,
    this.expandedHeight = 64.0,
    this.onAdd,
  });

  final String title;
  final String? subtitle;
  final bool showAvatar;
  final String avatarLetter;
  final String? avatarUrl;
  final Widget? trailing;
  final PreferredSizeWidget? bottom;
  final double bottomHeight;
  final List<Widget>? actions;
  final double expandedHeight;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final state = ref.watch(appControllerProvider);
    final scanQuota = state.profile.scanQuota;
    final profile = state.profile;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // Quota pill: tabular figures, amber at 1, red at 0
    final Color quotaTextColor;
    final Color quotaBgColor;
    final Color quotaBorderColor;
    if (scanQuota == 0) {
      quotaTextColor = colors.error;
      quotaBgColor = colors.error.withValues(alpha: 0.12);
      quotaBorderColor = colors.error;
    } else if (scanQuota == 1) {
      quotaTextColor = colors.warning;
      quotaBgColor = colors.warning.withValues(alpha: 0.12);
      quotaBorderColor = colors.warning;
    } else {
      quotaTextColor = colors.labelPrimary;
      quotaBgColor = colors.elevatedSurface;
      quotaBorderColor = colors.hairlineBorder;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isUltraNarrow = screenWidth < 280;
    final countText = '$scanQuota ${scanQuota == 1 ? 'scan' : 'scans'} left';
    final displayText = isUltraNarrow ? '$scanQuota' : countText;
    final quotaPill = Semantics(
      button: true,
      label: countText,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppMotion.selectionHaptic();
          showScanCreditSheet(context);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 36, minWidth: 32),
          padding: EdgeInsets.symmetric(
            horizontal: isUltraNarrow ? 6 : 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: quotaBgColor,
            borderRadius: BorderRadius.circular(AppRadius.capsule),
            border: Border.all(
              color: quotaBorderColor,
              width: AppRadius.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 15,
                color: scanQuota == 0
                    ? colors.error
                    : (scanQuota == 1 ? colors.warning : colors.accent),
              ),
              const SizedBox(width: 4),
              Text(
                displayText,
                maxLines: 1,
                softWrap: false,
                style: AppTypography.caption.copyWith(
                  color: quotaTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textScaler: MediaQuery.textScalerOf(context)
                    .clamp(maxScaleFactor: 1.3),
              ),
            ],
          ),
        ),
      ),
    );

    // Avatar opening Profile
    final avatarWidget = showAvatar
        ? Tooltip(
            message: 'Profile',
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: UserAvatar(
                avatarUrl: profile.avatarUrl.isNotEmpty
                    ? profile.avatarUrl
                    : null,
                initial: profile.initialLetter,
                size: 32,
                onTap: () {
                  AppMotion.selectionHaptic();
                  showTopSettingsSheet(context);
                },
              ),
            ),
          )
        : (trailing ?? const SizedBox(width: 44));

    // Pipeline Add Button (only on Pipeline / Tracker tab)
    final showAdd = onAdd != null || title == 'Pipeline' || title == 'Tracker';
    final addButton = showAdd
        ? Tooltip(
            message: 'Add application',
            child: IconButton(
              icon: const Icon(Icons.add_rounded, size: 22),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: onAdd ?? () => showAddApplicationSheet(context, ref),
            ),
          )
        : null;

    if (isIOS) {
      return CupertinoSliverNavigationBar(
        largeTitle: Text(
          title,
          style: TextStyle(color: colors.labelPrimary, letterSpacing: -0.5),
        ),
        backgroundColor: colors.surface.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: colors.hairlineBorder,
            width: AppRadius.hairline,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            quotaPill,
            if (addButton != null) ...[const SizedBox(width: 4), addButton],
            const SizedBox(width: 4),
            avatarWidget,
          ],
        ),
      );
    }

    return SliverAppBar.large(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          maxLines: 1,
          style: TextStyle(
            color: colors.labelPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      centerTitle: false,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      actions: [quotaPill, ?addButton, avatarWidget, const SizedBox(width: 8)],
      bottom: bottom,
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.accent,
    required this.selected,
    required this.onSelected,
  });

  final AppAccentColor accent;
  final bool selected;
  final VoidCallback onSelected;

  Color get color => switch (accent) {
    AppAccentColor.indigo => AppColors.accentIndigo,
    AppAccentColor.ocean => AppColors.accentOcean,
    AppAccentColor.emerald => AppColors.accentEmerald,
    AppAccentColor.violet => AppColors.accentViolet,
    AppAccentColor.coral => AppColors.accentCoral,
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Tooltip(
      message: accent.label,
      child: Semantics(
        button: true,
        selected: selected,
        label: '${accent.label} accent',
        child: PressableScale(
          onPressed: onSelected,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? colors.labelPrimary
                        : colors.hairlineBorder,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        color: colors.onAccent,
                        size: 18,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the scan credit bottom sheet (rewarded ad option lives only here)
void showScanCreditSheet(BuildContext context) {
  AppMotion.selectionHaptic();
  showAdaptiveSheet<void>(
    context: context,
    title: 'Scan Credits',
    builder: (sheetContext) => const _ScanCreditSheet(),
  );
}

class _ScanCreditSheet extends ConsumerStatefulWidget {
  const _ScanCreditSheet();

  @override
  ConsumerState<_ScanCreditSheet> createState() => _ScanCreditSheetState();
}

class _ScanCreditSheetState extends ConsumerState<_ScanCreditSheet> {
  bool _adLoading = false;

  Future<void> _watchAd() async {
    if (_adLoading) return;
    setState(() => _adLoading = true);
    AppMotion.selectionHaptic();
    try {
      final ads = ref.read(adServiceProvider);
      final loaded = await ads.loadRewardedAd(
        userId: ref.read(authRepositoryProvider).user?.id,
      );
      if (!loaded || !ads.isAdAvailable) {
        if (mounted) {
          showGlassToast(context, 'No rewarded ad available. Try again later.');
        }
        return;
      }
      await ads.showRewardedAd(
        onUserEarnedReward: (_) {
          if (mounted) {
            ref.read(appControllerProvider.notifier).unlockRewardedScan();
            showGlassToast(context, '+1 scan credit added');
          }
        },
      );
    } catch (_) {
      if (mounted) {
        showGlassToast(context, 'No rewarded ad available. Try again later.');
      }
    } finally {
      if (mounted) setState(() => _adLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final quota = state.profile.scanQuota;
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: colors.hairlineBorder,
                width: AppRadius.hairline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.paleIndigoSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        color: colors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVAILABLE SCANS',
                            style: AppTypography.monoBadge.copyWith(
                              color: colors.labelSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$quota ${quota == 1 ? 'Scan' : 'Scans'} Available',
                            style: AppTypography.headline.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Free daily quota resets at 00:00 Asia/Manila. Each scan performs deep resume and requirement matching analysis.',
                  style: AppTypography.caption.copyWith(
                    color: colors.labelTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AdaptiveButton.primary(
            onPressed: _adLoading ? null : _watchAd,
            label: _adLoading ? 'Loading Ad...' : 'Watch ad for +1 scan',
            icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Displays the top-appbar modal sheet for Profile, Rate Limits, and Settings
void showTopSettingsSheet(BuildContext context) {
  AppMotion.selectionHaptic();
  showAdaptiveSheet<void>(
    context: context,
    title: 'Account & Settings',
    builder: (sheetContext) => const _TopSettingsSheet(),
  );
}

class _TopSettingsSheet extends ConsumerStatefulWidget {
  const _TopSettingsSheet();

  @override
  ConsumerState<_TopSettingsSheet> createState() => _TopSettingsSheetState();
}

class _TopSettingsSheetState extends ConsumerState<_TopSettingsSheet> {
  bool _adLoading = false;

  Future<void> _watchAd() async {
    if (_adLoading) return;
    setState(() => _adLoading = true);
    AppMotion.selectionHaptic();
    try {
      final ads = ref.read(adServiceProvider);
      final loaded = await ads.loadRewardedAd(
        userId: ref.read(authRepositoryProvider).user?.id,
      );
      if (!loaded || !ads.isAdAvailable) {
        if (mounted) {
          showGlassToast(context, 'No rewarded ad available. Try again later.');
        }
        return;
      }
      await ads.showRewardedAd(
        onUserEarnedReward: (_) {
          if (mounted) {
            ref.read(appControllerProvider.notifier).unlockRewardedScan();
            showGlassToast(context, '+1 scan credit added');
          }
        },
      );
    } catch (_) {
      if (mounted) {
        showGlassToast(context, 'No rewarded ad available. Try again later.');
      }
    } finally {
      if (mounted) setState(() => _adLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.image);
      final path = file?.path;
      if (path != null && path.isNotEmpty) {
        final profile = ref.read(appControllerProvider).profile;
        ref
            .read(appControllerProvider.notifier)
            .updateProfile(profile.copyWith(avatarUrl: path));
        if (mounted) {
          showGlassToast(context, 'Profile picture updated');
        }
      }
    } catch (e) {
      if (mounted) {
        showGlassToast(context, 'Could not select image: $e');
      }
    }
  }

  void _editNameDialog() {
    final profile = ref.read(appControllerProvider).profile;
    final controller = TextEditingController(text: profile.name);
    showAdaptiveSheet<void>(
      context: context,
      title: 'Edit Name',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: controller,
              labelText: 'Full Name',
              hintText: 'Enter your name',
              autofocus: true,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              onPressed: () {
                final newName = controller.text.trim();
                ref
                    .read(appControllerProvider.notifier)
                    .updateProfile(profile.copyWith(name: newName));
                Navigator.of(sheetContext).pop();
                showGlassToast(context, 'Name updated');
              },
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _editHeadlineDialog() {
    final profile = ref.read(appControllerProvider).profile;
    final controller = TextEditingController(text: profile.headline);
    showAdaptiveSheet<void>(
      context: context,
      title: 'Professional Headline',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: controller,
              labelText: 'Headline',
              hintText: 'e.g. Senior Flutter Developer, UI/UX Designer',
              autofocus: true,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              onPressed: () {
                final text = controller.text.trim();
                ref
                    .read(appControllerProvider.notifier)
                    .updateProfile(profile.copyWith(headline: text));
                Navigator.of(sheetContext).pop();
                showGlassToast(context, 'Headline updated');
              },
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _editSalaryDialog() {
    final profile = ref.read(appControllerProvider).profile;
    final controller = TextEditingController(
      text: profile.expectedSalary != null
          ? profile.expectedSalary.toString()
          : '',
    );
    showAdaptiveSheet<void>(
      context: context,
      title: 'Target Monthly Salary (PHP)',
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveTextField(
              controller: controller,
              labelText: 'Monthly Salary in PHP',
              hintText: 'e.g. 50000',
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            AdaptiveButton.primary(
              onPressed: () {
                final text = controller.text.trim();
                final salary = int.tryParse(text);
                ref
                    .read(appControllerProvider.notifier)
                    .updateProfile(profile.copyWith(expectedSalary: salary));
                Navigator.of(sheetContext).pop();
                showGlassToast(context, 'Target salary updated');
              },
              label: 'Save',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetWorkspace() async {
    final confirmed = await showAdaptiveConfirmDialog(
      context,
      title: 'Reset Workspace Data',
      message: 'This will purge all local cached applications, resumes, and match logs. This action cannot be undone.',
      confirmLabel: 'Reset Workspace',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      final router = GoRouter.of(context);
      await ref.read(appControllerProvider.notifier).reset();
      if (mounted) {
        Navigator.pop(context);
      }
      router.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final state = ref.watch(appControllerProvider);
    final profile = state.profile;
    final outboxCount = ref.watch(outboxCountProvider).value ?? 0;
    final hasPending = outboxCount > 0;
    final isOffline = state.isOffline;
    final isSynced = !hasPending && !isOffline;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile preview header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: colors.hairlineBorder, width: 0.5),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    UserAvatar(
                      avatarUrl: profile.avatarUrl.isNotEmpty
                          ? profile.avatarUrl
                          : null,
                      initial: profile.initialLetter,
                      size: 52,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name.isNotEmpty
                                  ? profile.name
                                  : 'Job Seeker',
                              style: AppTypography.headline.copyWith(
                                color: colors.labelPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            color: colors.labelSecondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _editNameDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: _editHeadlineDialog,
                        child: Text(
                          profile.headline.isNotEmpty
                              ? profile.headline
                              : '+ Add professional title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: profile.headline.isNotEmpty
                                ? colors.labelSecondary
                                : colors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (profile.email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: AppTypography.caption.copyWith(
                            color: colors.labelTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Quota & AI Scans Tile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: colors.hairlineBorder, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.paleIndigoSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: colors.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI MATCH QUOTA',
                        style: AppTypography.monoBadge.copyWith(
                          color: colors.labelSecondary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${profile.scanQuota} Scans Available',
                        style: AppTypography.monoData.copyWith(
                          color: colors.labelPrimary,
                          fontSize: 14,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                AdaptiveButton.secondary(
                  onPressed: _adLoading ? null : _watchAd,
                  label: _adLoading ? 'Loading...' : 'Watch ad for +1 scan',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Career Preferences Section (Inset Grouped)
          _buildGroupHeader('CAREER PREFERENCES', colors),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: colors.hairlineBorder, width: 0.5),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seniority Target',
                        style: AppTypography.caption.copyWith(
                          color: colors.labelSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ExperienceLevel>(
                          segments: const [
                            ButtonSegment(
                              value: ExperienceLevel.entry,
                              label: Text('Entry'),
                            ),
                            ButtonSegment(
                              value: ExperienceLevel.mid,
                              label: Text('Mid'),
                            ),
                            ButtonSegment(
                              value: ExperienceLevel.senior,
                              label: Text('Senior'),
                            ),
                            ButtonSegment(
                              value: ExperienceLevel.lead,
                              label: Text('Lead'),
                            ),
                          ],
                          selected: {profile.experienceLevel},
                          onSelectionChanged: (selected) {
                            AppMotion.selectionHaptic();
                            ref
                                .read(appControllerProvider.notifier)
                                .updateProfile(
                                  profile.copyWith(
                                    experienceLevel: selected.first,
                                  ),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.separator),
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    title: Text(
                      'Target Monthly Salary',
                      style: AppTypography.subheadline.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.expectedSalary != null
                              ? '₱${profile.expectedSalary}'
                              : 'Set Target',
                          style: AppTypography.subheadline.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: colors.labelTertiary,
                        ),
                      ],
                    ),
                    onTap: _editSalaryDialog,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Appearance Section (Inset Grouped)
          _buildGroupHeader('APPEARANCE & THEME', colors),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: colors.hairlineBorder, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: AppTypography.caption.copyWith(
                    color: colors.labelSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppTheme>(
                    segments: const [
                      ButtonSegment(
                        value: AppTheme.system,
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: AppTheme.light,
                        label: Text('Light'),
                      ),
                      ButtonSegment(value: AppTheme.dark, label: Text('Dark')),
                    ],
                    selected: {profile.theme},
                    onSelectionChanged: (selected) {
                      AppMotion.selectionHaptic();
                      ref
                          .read(appControllerProvider.notifier)
                          .updateProfile(
                            profile.copyWith(theme: selected.first),
                          );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Brand Accent',
                  style: AppTypography.caption.copyWith(
                    color: colors.labelSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final accent in AppAccentColor.values)
                      _AccentSwatch(
                        accent: accent,
                        selected: profile.accentColor == accent,
                        onSelected: () {
                          AppMotion.segmentedControlOrChip();
                          ref
                              .read(appControllerProvider.notifier)
                              .updateProfile(
                                profile.copyWith(accentColor: accent),
                              );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Database & Sync Health (Inset Grouped)
          _buildGroupHeader('DATA & CLOUD SYNC', colors),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: colors.hairlineBorder, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isSynced
                            ? colors.diffAddedText
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSynced
                            ? null
                            : Border.all(color: colors.warning, width: 2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSynced
                                ? 'Synced with Supabase Cloud'
                                : (hasPending
                                      ? '$outboxCount queued in local Drift outbox'
                                      : 'Offline Mode · Local SQLite Active'),
                            style: AppTypography.caption.copyWith(
                              color: colors.labelPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Local-first Drift database with automatic synchronization',
                            style: AppTypography.caption.copyWith(
                              color: colors.labelTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: colors.separator),
                const SizedBox(height: 14),
                AdaptiveButton.secondary(
                  isFullWidth: true,
                  label: 'Reset Local Workspace',
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: colors.error,
                  ),
                  onPressed: _resetWorkspace,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Sign Out Action
          AdaptiveButton.secondary(
            isFullWidth: true,
            label: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, size: 16),
            onPressed: () async {
              AppMotion.selectionHaptic();
              final router = GoRouter.of(context);
              Navigator.pop(context);
              await ref.read(authRepositoryProvider).signOut();
              router.go('/sign-in');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.monoBadge.copyWith(
          color: colors.labelSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}
