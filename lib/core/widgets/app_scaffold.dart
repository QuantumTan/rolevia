import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'company_avatar.dart';

/// Screen scaffold featuring:
/// - Collapsing large title into inline title on scroll
/// - Top bar actions and quota pill
/// - Optional floating navigation or bottom bar
/// - Platform safe areas and theme canvas background
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.quotaCount,
    this.onQuotaTap,
    this.avatarName,
    this.avatarUrl,
    this.onAvatarTap,
    this.actions,
    this.floatingBottomBar,
    this.slivers,
    this.scrollController,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final int? quotaCount;
  final VoidCallback? onQuotaTap;
  final String? avatarName;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actions;
  final Widget? floatingBottomBar;
  final List<Widget>? slivers;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _CollapsibleHeaderDelegate(
                  title: title,
                  subtitle: subtitle,
                  quotaCount: quotaCount,
                  onQuotaTap: onQuotaTap,
                  avatarName: avatarName,
                  avatarUrl: avatarUrl,
                  onAvatarTap: onAvatarTap,
                  actions: actions,
                  colors: colors,
                ),
              ),
              ...?slivers,
              SliverToBoxAdapter(child: body),
              // Extra scroll padding so content is never covered by floating bottom bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: floatingBottomBar != null ? 88.0 : AppSpacing.s24,
                ),
              ),
            ],
          ),
          if (floatingBottomBar != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: floatingBottomBar!,
            ),
        ],
      ),
    );
  }
}

class _CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CollapsibleHeaderDelegate({
    required this.title,
    this.subtitle,
    this.quotaCount,
    this.onQuotaTap,
    this.avatarName,
    this.avatarUrl,
    this.onAvatarTap,
    this.actions,
    required this.colors,
  });

  final String title;
  final String? subtitle;
  final int? quotaCount;
  final VoidCallback? onQuotaTap;
  final String? avatarName;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actions;
  final AppColors colors;

  @override
  double get minExtent => 60.0;

  @override
  double get maxExtent => subtitle != null ? 120.0 : 100.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: progress > 0.3
            ? Border(
                bottom: BorderSide(
                  color: colors.hairlineBorder,
                  width: AppRadius.hairline,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Collapsed inline title (appears as progress increases)
            Positioned(
              left: AppSpacing.s16,
              right: 120,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: (progress * 1.5 - 0.5).clamp(0.0, 1.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Expanded large title
            Positioned(
              left: AppSpacing.s16,
              bottom: AppSpacing.s12,
              child: Opacity(
                opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.display.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: colors.labelSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Top right actions: Quota pill, avatar, or extra actions
            Positioned(
              top: 0,
              right: AppSpacing.s16,
              bottom: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (quotaCount != null) ...[
                      GestureDetector(
                        onTap: onQuotaTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.elevatedSurface,
                            borderRadius: AppRadius.capsuleRadius,
                            border: Border.all(
                              color: colors.hairlineBorder,
                              width: AppRadius.hairline,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: colors.accent),
                              const SizedBox(width: 4),
                              Text(
                                '$quotaCount',
                                style: AppTypography.caption.copyWith(
                                  color: colors.labelPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                    ],
                    ...?actions,
                    if (onAvatarTap != null || avatarName != null) ...[
                      const SizedBox(width: AppSpacing.s8),
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: CompanyAvatar(
                          avatarName ?? 'User',
                          logoUrl: avatarUrl,
                          size: 32,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CollapsibleHeaderDelegate oldDelegate) =>
      oldDelegate.title != title ||
      oldDelegate.subtitle != subtitle ||
      oldDelegate.quotaCount != quotaCount ||
      oldDelegate.avatarName != avatarName ||
      oldDelegate.colors != colors;
}
