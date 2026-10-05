import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';

/// Filter chip with chevron icon, active state, and active count badge.
/// Meets 44px minimum tap target.
class AppFilterChip extends StatefulWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeCount = 0,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final int activeCount;
  final Widget? icon;

  @override
  State<AppFilterChip> createState() => _AppFilterChipState();
}

class _AppFilterChipState extends State<AppFilterChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final borderColor = widget.isActive
        ? colors.accent
        : colors.hairlineBorder;
    final bgColor = widget.isActive
        ? (isDark ? colors.accent.withValues(alpha: 0.15) : colors.paleIndigoSurface)
        : colors.surface;
    final textColor = widget.isActive ? colors.accent : colors.labelPrimary;

    final scale = (reduceMotion || !_pressed) ? 1.0 : AppMotion.pressScale;

    return Semantics(
      button: true,
      selected: widget.isActive,
      label: widget.activeCount > 0
          ? '${widget.label}, ${widget.activeCount} selected'
          : widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          AppMotion.segmentedControlOrChip();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: scale,
          duration: reduceMotion ? Duration.zero : AppMotion.instant,
          curve: AppMotion.curveStandard,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.capsuleRadius,
              border: Border.all(
                color: borderColor,
                width: widget.isActive ? 1.0 : AppRadius.hairline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: AppSpacing.s4),
                ],
                Text(
                  widget.label,
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (widget.activeCount > 0) ...[
                  const SizedBox(width: AppSpacing.s4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: AppRadius.capsuleRadius,
                    ),
                    child: Text(
                      '${widget.activeCount}',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? colors.background : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: AppSpacing.s4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AppStatusType {
  neutral,
  applied,
  interviewing,
  offered,
  rejected,
}

/// Status chip with semantic contrast-verified colors and capsule shape.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.status = AppStatusType.neutral,
    this.customColor,
    this.customBgColor,
  });

  final String label;
  final AppStatusType status;
  final Color? customColor;
  final Color? customBgColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color fg;
    Color bg;

    if (customColor != null && customBgColor != null) {
      fg = customColor!;
      bg = customBgColor!;
    } else {
      switch (status) {
        case AppStatusType.offered:
          fg = colors.diffAddedText;
          bg = colors.diffAddedBg;
        case AppStatusType.interviewing:
          fg = colors.warning;
          bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        case AppStatusType.rejected:
          fg = colors.diffPrunedText;
          bg = colors.diffPrunedBg;
        case AppStatusType.applied:
          fg = colors.accent;
          bg = isDark ? const Color(0xFF0C2D48) : const Color(0xFFE0F2FE);
        case AppStatusType.neutral:
          fg = colors.labelSecondary;
          bg = isDark ? colors.elevatedSurface : const Color(0xFFF1F5F9);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.capsuleRadius,
        border: Border.all(
          color: colors.hairlineBorder,
          width: AppRadius.hairline,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum AppSkillMatchType {
  matched,
  missing,
  neutral,
}

/// Skill chip displaying required/matched skill with subtle high-contrast styling.
class AppSkillChip extends StatelessWidget {
  const AppSkillChip({
    super.key,
    required this.label,
    this.matchType = AppSkillMatchType.neutral,
    this.yearsExperience,
    this.onTap,
  });

  final String label;
  final AppSkillMatchType matchType;
  final double? yearsExperience;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color fg;
    Color bg;
    IconData? icon;

    switch (matchType) {
      case AppSkillMatchType.matched:
        fg = colors.diffAddedText;
        bg = colors.diffAddedBg;
        icon = Icons.check_rounded;
      case AppSkillMatchType.missing:
        fg = colors.diffPrunedText;
        bg = colors.diffPrunedBg;
        icon = Icons.close_rounded;
      case AppSkillMatchType.neutral:
        fg = colors.labelPrimary;
        bg = isDark ? colors.elevatedSurface : const Color(0xFFF1F5F9);
        icon = null;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: AppSpacing.s4),
        ],
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: fg,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (yearsExperience != null) ...[
          const SizedBox(width: AppSpacing.s4),
          Text(
            '${yearsExperience!.toStringAsFixed(yearsExperience! % 1 == 0 ? 0 : 1)}y',
            style: AppTypography.caption.copyWith(
              color: fg.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );

    final chipBox = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.capsuleRadius,
        border: Border.all(
          color: colors.hairlineBorder,
          width: AppRadius.hairline,
        ),
      ),
      child: content,
    );

    if (onTap == null) return chipBox;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppMotion.segmentedControlOrChip();
          onTap!();
        },
        child: chipBox,
      ),
    );
  }
}
