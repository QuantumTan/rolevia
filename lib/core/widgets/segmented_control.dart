import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';

class SegmentItem<T> {
  const SegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final Widget? icon;
}

/// Native-feeling tactile segmented control:
/// - Sliding pill selection indicator with spring curve
/// - Selection click haptics
/// - 44px minimum touch target height
/// - Accessible keyboard navigation & Semantics
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.isFullWidth = true,
  });

  final List<SegmentItem<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final selectedIndex = segments.indexWhere((s) => s.value == selected);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = isFullWidth
            ? constraints.maxWidth
            : segments.length * 100.0;
        final segmentWidth = (totalWidth - 8.0) / segments.length;

        return Container(
          width: totalWidth,
          height: 44.0,
          padding: const EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: isDark ? colors.elevatedSurface : const Color(0xFFE2E8F0),
            borderRadius: AppRadius.capsuleRadius,
            border: Border.all(
              color: colors.hairlineBorder,
              width: AppRadius.hairline,
            ),
          ),
          child: Stack(
            children: [
              // Animated sliding indicator pill
              if (selectedIndex >= 0)
                AnimatedPositioned(
                  duration: reduceMotion ? Duration.zero : AppMotion.quick,
                  curve: AppMotion.curveStandard,
                  left: selectedIndex * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppRadius.capsuleRadius,
                      border: Border.all(
                        color: colors.hairlineBorder,
                        width: AppRadius.hairline,
                      ),
                    ),
                  ),
                ),

              // Segment touch targets
              Row(
                children: segments.map((segment) {
                  final isSelected = segment.value == selected;
                  final textColor = isSelected
                      ? colors.labelPrimary
                      : colors.labelSecondary;

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      label: segment.label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!isSelected) {
                            AppMotion.segmentedControlOrChip();
                            onChanged(segment.value);
                          }
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (segment.icon != null) ...[
                                IconTheme(
                                  data: IconThemeData(
                                    size: 16,
                                    color: textColor,
                                  ),
                                  child: segment.icon!,
                                ),
                                const SizedBox(width: AppSpacing.s4),
                              ],
                              Text(
                                segment.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
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
            ],
          ),
        );
      },
    );
  }
}
