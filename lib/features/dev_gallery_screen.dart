import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/models.dart';

/// Hidden developer gallery screen (debug only).
/// Showcases every design system widget in light, dark, all accents, and text scale 1.3.
class DevGalleryScreen extends StatefulWidget {
  const DevGalleryScreen({super.key});

  @override
  State<DevGalleryScreen> createState() => _DevGalleryScreenState();
}

class _DevGalleryScreenState extends State<DevGalleryScreen> {
  Brightness _brightness = Brightness.dark;
  AppAccentColor _accent = AppAccentColor.ocean;
  double _textScale = 1.0;
  String _selectedSegment = 'All';
  int _activeNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug only screen')),
      );
    }

    final themeData = AppThemeSingletons.resolve(
      _brightness,
      accentColor: _accent,
    );

    return Theme(
      data: themeData,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(_textScale),
        ),
        child: Builder(
          builder: (context) {
            final colors = AppColors.of(context);

            return Scaffold(
              backgroundColor: colors.background,
              appBar: TopBar(
                title: 'Widget Gallery',
                quotaCount: 3,
                avatarName: 'Dev User',
                onQuotaTap: () {
                  AppToast.show(
                    context,
                    'Quota pill tapped: 3 scans remaining',
                    type: AppToastType.info,
                  );
                },
                onAvatarTap: () {
                  AppToast.show(
                    context,
                    'Avatar tapped',
                    type: AppToastType.success,
                  );
                },
              ),
              body: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s16,
                ),
                children: [
                  // Gallery Controls Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gallery Controls',
                          style: AppTypography.headline.copyWith(
                            color: colors.labelPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        // Mode & Scale Controls
                        Row(
                          children: [
                            Text(
                              'Mode: ',
                              style: AppTypography.caption.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                            SegmentedControl<Brightness>(
                              isFullWidth: false,
                              selected: _brightness,
                              onChanged: (b) => setState(() => _brightness = b),
                              segments: const [
                                SegmentItem(value: Brightness.light, label: 'Light'),
                                SegmentItem(value: Brightness.dark, label: 'Dark'),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'Scale: ',
                              style: AppTypography.caption.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                            SegmentedControl<double>(
                              isFullWidth: false,
                              selected: _textScale,
                              onChanged: (s) => setState(() => _textScale = s),
                              segments: const [
                                SegmentItem(value: 1.0, label: '1.0x'),
                                SegmentItem(value: 1.3, label: '1.3x'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        // Accent Picker
                        Text(
                          'Accent Tint:',
                          style: AppTypography.caption.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Wrap(
                          spacing: AppSpacing.s8,
                          children: AppAccentColor.values.map((accent) {
                            final isSelected = accent == _accent;
                            final color = switch (accent) {
                              AppAccentColor.indigo => AppColors.accentIndigo,
                              AppAccentColor.ocean => AppColors.accentOcean,
                              AppAccentColor.emerald => AppColors.accentEmerald,
                              AppAccentColor.violet => AppColors.accentViolet,
                              AppAccentColor.coral => AppColors.accentCoral,
                            };
                            return GestureDetector(
                              onTap: () => setState(() => _accent = accent),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.labelPrimary
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // 1. Typography & MonoText
                  const SectionHeader(title: 'Typography & Numerals'),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Display 28/600/-0.5', style: AppTypography.display),
                        const SizedBox(height: AppSpacing.s4),
                        Text('Title 20/600/-0.3', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.s4),
                        Text('Headline 17/600', style: AppTypography.headline),
                        const SizedBox(height: AppSpacing.s4),
                        Text('Body 15/400/1.45', style: AppTypography.body),
                        const SizedBox(height: AppSpacing.s4),
                        Text('Caption 12/500/+0.2', style: AppTypography.caption),
                        const SizedBox(height: AppSpacing.s8),
                        const MonoText('Mono/Tabular: PHP 85,000 / mo | 84.5% fit | 2026-10-05'),
                      ],
                    ),
                  ),

                  // 2. Buttons
                  const SectionHeader(title: 'Buttons (AppButton 50px)'),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      AppButton.primary(
                        label: 'Primary Button',
                        onPressed: () {
                          AppToast.show(context, 'Primary pressed', type: AppToastType.success);
                        },
                      ),
                      AppButton.secondary(
                        label: 'Secondary Button',
                        onPressed: () {
                          AppToast.show(context, 'Secondary pressed', type: AppToastType.info);
                        },
                      ),
                      AppButton.text(
                        label: 'Text Action',
                        onPressed: () {},
                      ),
                      AppButton.destructive(
                        label: 'Destructive',
                        onPressed: () {
                          AppToast.show(context, 'Destructive triggered', type: AppToastType.error);
                        },
                      ),
                      AppButton.primary(
                        label: 'Loading',
                        isLoading: true,
                        onPressed: () {},
                      ),
                    ],
                  ),

                  // 3. Tactile Card & Specular Border
                  const SectionHeader(title: 'Cards & Specular Borders'),
                  TactileCard(
                    onTap: () {
                      AppToast.show(context, 'TactileCard spring pressed', type: AppToastType.info);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TactileCard (press spring 0.98)', style: AppTypography.headline),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          'Carries a hairline 0.5 border and faint specular top edge on dark surfaces.',
                          style: AppTypography.body.copyWith(color: colors.labelSecondary),
                        ),
                      ],
                    ),
                  ),

                  // 4. ScoreRing & MatchBadge
                  const SectionHeader(title: 'ScoreRing & MatchBadge'),
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const ScoreRing(88, size: 76),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            MatchBadge(92),
                            SizedBox(height: AppSpacing.s8),
                            MatchBadge(68),
                            SizedBox(height: AppSpacing.s8),
                            MatchBadge(44),
                            SizedBox(height: AppSpacing.s8),
                            MatchBadge(25),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 5. Chips
                  const SectionHeader(title: 'Chip Variants'),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      AppFilterChip(
                        label: 'Role type',
                        isActive: true,
                        activeCount: 2,
                        onTap: () {},
                      ),
                      AppFilterChip(
                        label: 'Radius',
                        isActive: false,
                        onTap: () {},
                      ),
                      const AppStatusChip(
                        label: 'Offered',
                        status: AppStatusType.offered,
                      ),
                      const AppStatusChip(
                        label: 'Interviewing',
                        status: AppStatusType.interviewing,
                      ),
                      const AppStatusChip(
                        label: 'Applied',
                        status: AppStatusType.applied,
                      ),
                      const AppStatusChip(
                        label: 'Rejected',
                        status: AppStatusType.rejected,
                      ),
                      const AppSkillChip(
                        label: 'Flutter',
                        matchType: AppSkillMatchType.matched,
                        yearsExperience: 3.5,
                      ),
                      const AppSkillChip(
                        label: 'Kubernetes',
                        matchType: AppSkillMatchType.missing,
                      ),
                    ],
                  ),

                  // 6. Segmented Control
                  const SectionHeader(title: 'Segmented Control'),
                  SegmentedControl<String>(
                    selected: _selectedSegment,
                    onChanged: (val) => setState(() => _selectedSegment = val),
                    segments: const [
                      SegmentItem(value: 'All', label: 'All roles'),
                      SegmentItem(value: 'Direct', label: 'Direct fit'),
                      SegmentItem(value: 'Gaps', label: 'Gap focus'),
                    ],
                  ),

                  // 7. StatTile
                  const SectionHeader(title: 'StatTile'),
                  Row(
                    children: const [
                      Expanded(
                        child: StatTile(
                          label: 'Applications',
                          value: '14',
                          trend: '+3 this wk',
                          trendPositive: true,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: StatTile(
                          label: 'Avg fit score',
                          value: '82%',
                          trend: 'High match',
                          trendPositive: true,
                        ),
                      ),
                    ],
                  ),

                  // 8. CompanyAvatar (8 Palettes + Logo + Fallback)
                  const SectionHeader(title: 'CompanyAvatar (Deterministic Contrast Palettes)'),
                  AppCard(
                    child: Wrap(
                      spacing: AppSpacing.s12,
                      runSpacing: AppSpacing.s12,
                      children: const [
                        CompanyAvatar('Google', size: 44),
                        CompanyAvatar('Accenture', size: 44),
                        CompanyAvatar('Canva', size: 44),
                        CompanyAvatar('Mondelez', size: 44),
                        CompanyAvatar('Shopee', size: 44),
                        CompanyAvatar('TaskUs', size: 44),
                        CompanyAvatar('Jollibee', size: 44),
                        CompanyAvatar('BDO Unibank', size: 44),
                        CompanyAvatar('', size: 44), // Empty name briefcase fallback
                      ],
                    ),
                  ),

                  // 9. Custom Vector Icons
                  const SectionHeader(title: 'Custom Vector Icons (24dp 1.8px stroke)'),
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            AppCustomIcon.atsPass(color: colors.diffAddedText),
                            const SizedBox(height: 4),
                            Text('ats_pass', style: AppTypography.caption),
                          ],
                        ),
                        Column(
                          children: [
                            AppCustomIcon.atsWarn(color: colors.warning),
                            const SizedBox(height: 4),
                            Text('ats_warn', style: AppTypography.caption),
                          ],
                        ),
                        Column(
                          children: [
                            AppCustomIcon.evidence(color: colors.accent),
                            const SizedBox(height: 4),
                            Text('evidence', style: AppTypography.caption),
                          ],
                        ),
                        Column(
                          children: [
                            AppCustomIcon.constellation(color: colors.accent),
                            const SizedBox(height: 4),
                            Text('constellation', style: AppTypography.caption),
                          ],
                        ),
                        Column(
                          children: [
                            AppCustomIcon.scan(color: colors.labelPrimary),
                            const SizedBox(height: 4),
                            Text('scan', style: AppTypography.caption),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 10. DiffSpan
                  const SectionHeader(title: 'DiffSpan (ATS Keyword Match)'),
                  AppCard(
                    child: Wrap(
                      spacing: AppSpacing.s8,
                      runSpacing: AppSpacing.s8,
                      children: const [
                        DiffSpan.added('Flutter Architecture'),
                        DiffSpan.added('Dart 3 Patterns'),
                        DiffSpan.pruned('Legacy Objective-C'),
                        DiffSpan.unchanged('REST APIs'),
                      ],
                    ),
                  ),

                  // 11. OfflineBanner & SkeletonBox
                  const SectionHeader(title: 'OfflineBanner & SkeletonBox'),
                  const OfflineBanner(offline: true),
                  const SizedBox(height: AppSpacing.s12),
                  const SkeletonCard(),

                  // 12. Modal Bottom Sheet Trigger
                  const SectionHeader(title: 'BottomSheetScaffold'),
                  AppButton.secondary(
                    label: 'Open BottomSheetScaffold (0.55 & 0.95 snaps)',
                    onPressed: () {
                      BottomSheetScaffold.show(
                        context: context,
                        title: 'Filter Criteria',
                        builder: (ctx) => ListView(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          children: [
                            Text(
                              'Adaptive draggable bottom sheet with 28 top radius, 36x5 grabber, and no size buttons.',
                              style: AppTypography.body,
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            AppButton.primary(
                              label: 'Apply Filters',
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 13. Empty & Error States
                  const SectionHeader(title: 'Empty & Error States'),
                  const AppCard(
                    child: EmptyState(
                      title: 'No applications yet',
                      message: 'Track jobs and comparison scores in your pipeline.',
                      actionLabel: 'Discover roles',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  const AppCard(
                    child: ErrorState(
                      title: 'Connection interrupted',
                      message: 'Check mobile data or Wi-Fi to refresh matches.',
                      retryLabel: 'Retry connection',
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
              bottomNavigationBar: FloatingNav(
                currentIndex: _activeNavIndex,
                onTap: (idx) => setState(() => _activeNavIndex = idx),
                items: const [
                  FloatingNavItem(
                    label: 'Discover',
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                  ),
                  FloatingNavItem(
                    label: 'Tracker',
                    icon: Icons.view_kanban_outlined,
                    activeIcon: Icons.view_kanban_rounded,
                  ),
                  FloatingNavItem(
                    label: 'Match',
                    icon: Icons.bolt_outlined,
                    activeIcon: Icons.bolt_rounded,
                  ),
                  FloatingNavItem(
                    label: 'Vault',
                    icon: Icons.folder_outlined,
                    activeIcon: Icons.folder_rounded,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
