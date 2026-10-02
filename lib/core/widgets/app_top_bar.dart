import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/colors.dart';
import '../design/typography.dart';
import 'liquid_glass.dart';
import 'pressable.dart';

class SliverAppTopBar extends StatelessWidget {
  const SliverAppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showAvatar = true,
    this.avatarLetter = 'A',
    this.trailing,
    this.bottom,
    this.bottomHeight = 0,
    this.actions,
    this.expandedHeight = 90.0,
  });

  final String title;
  final String? subtitle;
  final bool showAvatar;
  final String avatarLetter;
  final Widget? trailing;
  final PreferredSizeWidget? bottom;
  final double bottomHeight;
  final List<Widget>? actions;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            (constraints.crossAxisExtent - 80 - (actions?.length ?? 0) * 48)
                .clamp(1.0, double.infinity);
        double measure(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: availableWidth);
          final height = painter.height;
          painter.dispose();
          return height;
        }

        final toolbarHeight =
            (MediaQuery.textScalerOf(context).scale(17) * 1.4 + 20).clamp(
              56.0,
              double.infinity,
            );
        final contentHeight =
            measure(title, AppTypography.largeTitle) +
            (subtitle == null
                ? 0
                : 2 + measure(subtitle!, AppTypography.subheadline)) +
            24;
        return SliverPersistentHeader(
          pinned: true,
          delegate: _AppTopBarDelegate(
            title: title,
            subtitle: subtitle,
            showAvatar: showAvatar,
            avatarLetter: avatarLetter,
            trailing: trailing,
            actions: actions,
            bottom: bottom,
            bottomHeight: bottomHeight,
            expandedHeight: contentHeight.clamp(
              expandedHeight,
              double.infinity,
            ),
            toolbarHeight: toolbarHeight,
            colors: colors,
            onAvatarTap: () => context.push('/profile'),
          ),
        );
      },
    );
  }
}

class _AppTopBarDelegate extends SliverPersistentHeaderDelegate {
  _AppTopBarDelegate({
    required this.title,
    this.subtitle,
    required this.showAvatar,
    required this.avatarLetter,
    this.trailing,
    this.actions,
    this.bottom,
    required this.bottomHeight,
    required this.expandedHeight,
    required this.toolbarHeight,
    required this.colors,
    required this.onAvatarTap,
  });

  final String title;
  final String? subtitle;
  final bool showAvatar;
  final String avatarLetter;
  final Widget? trailing;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double bottomHeight;
  final double expandedHeight;
  final double toolbarHeight;
  final AppColors colors;
  final VoidCallback onAvatarTap;

  @override
  double get minExtent => toolbarHeight + bottomHeight;

  @override
  double get maxExtent =>
      expandedHeight.clamp(toolbarHeight + 20, double.infinity) + bottomHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = ((shrinkOffset - 10) / (maxExtent - minExtent - 10)).clamp(
      0.0,
      1.0,
    );

    final avatarWidget = showAvatar
        ? Semantics(
            label: 'Open profile and settings',
            child: PressableScale(
              semanticLabel: 'Open profile and settings',
              onPressed: onAvatarTap,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          )
        : (trailing ?? const SizedBox(width: 44));

    return Stack(
      fit: StackFit.expand,
      children: [
        // Glass background only visible when collapsed
        if (progress > 0.05)
          Opacity(
            opacity: progress,
            child: const LiquidGlass(
              borderRadius: BorderRadius.zero,
              blurSigma: 20,
              padding: EdgeInsets.zero,
              child: SizedBox.expand(),
            ),
          ),

        // Collapsed centered title (17px SemiBold)
        Positioned(
          top: 0,
          left: 56,
          right: 56,
          height: toolbarHeight,
          child: Opacity(
            opacity: ((progress - 0.5) * 2).clamp(0.0, 1.0),
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        // Expanded Large 34px title
        Positioned(
          left: 16,
          right: 64 + (actions?.length ?? 0) * 48.0,
          bottom: bottomHeight + 12,
          child: Opacity(
            opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.largeTitle.copyWith(
                    color: colors.labelPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.subheadline.copyWith(
                      color: colors.labelSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Actions & Avatar
        Positioned(
          top: 6,
          right: 12,
          height: toolbarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [...?actions, avatarWidget],
          ),
        ),

        // Bottom widget (e.g. search bar or filters if pinned)
        if (bottom != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bottomHeight,
            child: bottom!,
          ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _AppTopBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        subtitle != oldDelegate.subtitle ||
        showAvatar != oldDelegate.showAvatar ||
        avatarLetter != oldDelegate.avatarLetter ||
        trailing != oldDelegate.trailing ||
        bottom != oldDelegate.bottom ||
        bottomHeight != oldDelegate.bottomHeight ||
        expandedHeight != oldDelegate.expandedHeight ||
        toolbarHeight != oldDelegate.toolbarHeight ||
        actions != oldDelegate.actions ||
        colors != oldDelegate.colors;
  }
}
