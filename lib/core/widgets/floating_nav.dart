import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'app_card.dart';

class FloatingNavItem {
  const FloatingNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Floating capsule navigation bar:
/// - Active accent tint
/// - Tab icon fill transition
/// - Tactile spring press feedback
/// - 44x44 minimum touch targets
/// - Hairline border and specular top highlight
class FloatingNav extends StatelessWidget {
  const FloatingNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final media = MediaQuery.of(context);

    Widget navContent = Container(
      constraints: const BoxConstraints(maxWidth: 440),
      height: 60.0,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.capsuleRadius,
        border: Border.all(
          color: colors.hairlineBorder,
          width: AppRadius.hairline,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: _NavTabItem(
              item: item,
              isSelected: isSelected,
              onTap: () {
                if (!isSelected) {
                  AppMotion.segmentedControlOrChip();
                  onTap(index);
                }
              },
            ),
          );
        }),
      ),
    );

    if (colors.glassHighlight.a > 0) {
      navContent = CustomPaint(
        foregroundPainter: SpecularTopBorderPainter(
          highlightColor: colors.glassHighlight,
          borderRadius: AppRadius.capsuleRadius,
          strokeWidth: AppRadius.hairline,
        ),
        child: navContent,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        0,
        AppSpacing.s16,
        media.padding.bottom > 0 ? media.padding.bottom : AppSpacing.s16,
      ),
      child: navContent,
    );
  }
}

class _NavTabItem extends StatefulWidget {
  const _NavTabItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavTabItem> createState() => _NavTabItemState();
}

class _NavTabItemState extends State<_NavTabItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final color = widget.isSelected ? colors.accent : colors.labelSecondary;
    final scale = (reduceMotion || !_pressed) ? 1.0 : AppMotion.pressScale;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: reduceMotion ? Duration.zero : AppMotion.instant,
          curve: AppMotion.curveStandard,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : AppMotion.quick,
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: Icon(
                  widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                  key: ValueKey('${widget.item.label}_${widget.isSelected}'),
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
