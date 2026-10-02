import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/typography.dart';
import 'liquid_glass.dart';
import 'pressable.dart';

/// Shows an adaptive modal bottom sheet following Job Matcher Liquid Glass specifications:
/// - 28px top corner radius
/// - Grabber: 36 x 5px, centered, 8px from top
/// - Glass header, solid body
/// - Close button with 44px minimum touch target
/// - Medium (56%) / Large (89%) detents with segmented toggle
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  String? title,
  bool isScrollControlled = true,
  bool openLarge = true,
  bool showDetents = true,
}) {
  final colors = AppColors.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: isDark ? Colors.black54 : Colors.black38,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) {
      return _AdaptiveSheetContent(
        title: title,
        initialLarge: openLarge,
        showDetents: showDetents,
        colors: colors,
        builder: builder,
      );
    },
  );
}

class _AdaptiveSheetContent extends StatefulWidget {
  const _AdaptiveSheetContent({
    this.title,
    required this.initialLarge,
    required this.showDetents,
    required this.colors,
    required this.builder,
  });

  final String? title;
  final bool initialLarge;
  final bool showDetents;
  final AppColors colors;
  final Widget Function(BuildContext) builder;

  @override
  State<_AdaptiveSheetContent> createState() => _AdaptiveSheetContentState();
}

class _AdaptiveSheetContentState extends State<_AdaptiveSheetContent> {
  late bool isLarge = widget.initialLarge;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height;
    final bottomInset = mediaQuery.viewInsets.bottom;

    // Medium: approximately 56% of available screen height
    // Large: approximately 89%
    final targetHeight = isLarge
        ? availableHeight * 0.89
        : availableHeight * 0.56;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      height: targetHeight + bottomInset,
      decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: AppRadius.sheetRadius,
      ),
      child: Column(
        children: [
          // Glass header with grabber, title, detents, and close button
          LiquidGlass(
            borderRadius: AppRadius.sheetRadius,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 36x5 Grabber, 8px from top
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: widget.colors.separator,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        widget.title ?? '',
                        style: AppTypography.headline.copyWith(
                          color: widget.colors.labelPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Medium / Large segmented toggle
                    if (widget.showDetents) ...[
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: widget.colors.paleIndigoSurface,
                          borderRadius: BorderRadius.circular(
                            AppRadius.capsule,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PressableScale(
                              onPressed: () => setState(() => isLarge = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: !isLarge
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.capsule,
                                  ),
                                ),
                                child: Text(
                                  'Med',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: !isLarge
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: !isLarge
                                        ? widget.colors.primary
                                        : widget.colors.labelSecondary,
                                  ),
                                ),
                              ),
                            ),
                            PressableScale(
                              onPressed: () => setState(() => isLarge = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isLarge
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.capsule,
                                  ),
                                ),
                                child: Text(
                                  'Large',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isLarge
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isLarge
                                        ? widget.colors.primary
                                        : widget.colors.labelSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Close button with minimum 44x44 touch target
                    PressableScale(
                      semanticLabel: 'Close dialog',
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: widget.colors.paleIndigoSurface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: widget.colors.labelPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Solid body scrolling independently
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: math.max(16.0, bottomInset + 16),
              ),
              child: widget.builder(context),
            ),
          ),
        ],
      ),
    );
  }
}
