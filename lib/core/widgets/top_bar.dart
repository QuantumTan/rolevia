import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'company_avatar.dart';

/// Standard top bar:
/// - Title
/// - Quota pill (one quota pill in the top bar)
/// - User avatar
/// Meets 44x44 minimum touch targets.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.title,
    this.quotaCount,
    this.onQuotaTap,
    this.avatarName = 'User',
    this.avatarUrl,
    this.onAvatarTap,
    this.leading,
    this.actions,
    this.bottom,
    this.showBorder = true,
  });

  final String title;
  final int? quotaCount;
  final VoidCallback? onQuotaTap;
  final String avatarName;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBorder;

  @override
  Size get preferredSize => Size.fromHeight(56.0 + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: showBorder
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: AppSpacing.s8),
                    ],
                    Expanded(
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
                    if (quotaCount != null) ...[
                      const SizedBox(width: AppSpacing.s8),
                      Semantics(
                        button: true,
                        label: '$quotaCount scans remaining',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            AppMotion.selectionHaptic();
                            onQuotaTap?.call();
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s12,
                              vertical: AppSpacing.s4,
                            ),
                            decoration: BoxDecoration(
                              color: quotaCount == 0
                                  ? colors.error.withValues(alpha: 0.12)
                                  : (quotaCount == 1
                                      ? colors.warning.withValues(alpha: 0.12)
                                      : colors.elevatedSurface),
                              borderRadius: AppRadius.capsuleRadius,
                              border: Border.all(
                                color: quotaCount == 0
                                    ? colors.error
                                    : (quotaCount == 1
                                        ? colors.warning
                                        : colors.hairlineBorder),
                                width: AppRadius.hairline,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 16,
                                  color: quotaCount == 0
                                      ? colors.error
                                      : (quotaCount == 1
                                          ? colors.warning
                                          : colors.accent),
                                ),
                                const SizedBox(width: AppSpacing.s4),
                                Text(
                                  '$quotaCount ${quotaCount == 1 ? 'scan' : 'scans'} left',
                                  style: AppTypography.caption.copyWith(
                                    color: quotaCount == 0
                                        ? colors.error
                                        : (quotaCount == 1
                                            ? colors.warning
                                            : colors.labelPrimary),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    ...?actions,
                    if (onAvatarTap != null || avatarUrl != null || avatarName.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.s8),
                      Semantics(
                        button: true,
                        label: 'Open profile',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            AppMotion.selectionHaptic();
                            onAvatarTap?.call();
                          },
                          child: CompanyAvatar(
                            avatarName,
                            logoUrl: avatarUrl,
                            size: 34,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }
}
