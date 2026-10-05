import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import 'app_card.dart';

/// Draggable modal bottom sheet container:
/// - Top border radius 28 logical px
/// - Centered grabber 36x5 logical px
/// - Snap points 0.55 and 0.95
/// - Explicitly NO size/expand buttons
/// - Hairline border and specular top highlight
class BottomSheetScaffold extends StatefulWidget {
  const BottomSheetScaffold({
    super.key,
    required this.body,
    this.title,
    this.headerLeading,
    this.headerTrailing,
    this.bottomBar,
    this.initialChildSize = 0.55,
    this.minChildSize = 0.35,
    this.maxChildSize = 0.95,
  });

  final Widget body;
  final String? title;
  final Widget? headerLeading;
  final Widget? headerTrailing;
  final Widget? bottomBar;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    String? title,
    bool isDismissible = true,
  }) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      sheetAnimationStyle: reduceMotion
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: AppMotion.standard,
              reverseDuration: AppMotion.quick,
            ),
      builder: (sheetContext) => BottomSheetScaffold(
        title: title,
        headerTrailing: IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: () => Navigator.of(sheetContext).pop(),
          tooltip: 'Close',
        ),
        body: builder(sheetContext),
      ),
    );
  }

  @override
  State<BottomSheetScaffold> createState() => _BottomSheetScaffoldState();
}

class _BottomSheetScaffoldState extends State<BottomSheetScaffold> {
  final DraggableScrollableController _controller = DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final media = MediaQuery.of(context);

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: true,
      snapSizes: [widget.initialChildSize, widget.maxChildSize],
      builder: (context, scrollController) {
        Widget content = Column(
          children: [
            // Grabber 36x5
            Semantics(
              label: 'Drag handle to resize or dismiss sheet',
              child: SizedBox(
                height: 24,
                width: double.infinity,
                child: Center(
                  child: Container(
                    width: AppRadius.grabberWidth,
                    height: AppRadius.grabberHeight,
                    decoration: BoxDecoration(
                      color: colors.labelTertiary.withValues(alpha: 0.5),
                      borderRadius: AppRadius.grabberRadius,
                    ),
                  ),
                ),
              ),
            ),

            // Header row (if title, leading, or trailing provided)
            if (widget.title != null ||
                widget.headerLeading != null ||
                widget.headerTrailing != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s4,
                  AppSpacing.s16,
                  AppSpacing.s8,
                ),
                child: Row(
                  children: [
                    if (widget.headerLeading != null) ...[
                      widget.headerLeading!,
                      const SizedBox(width: AppSpacing.s8),
                    ],
                    Expanded(
                      child: widget.title != null
                          ? Text(
                              widget.title!,
                              style: AppTypography.headline.copyWith(
                                color: colors.labelPrimary,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (widget.headerTrailing != null) widget.headerTrailing!,
                  ],
                ),
              ),

            Divider(
              height: 1,
              thickness: 0.5,
              color: colors.hairlineBorder,
            ),

            // Scrollable Body
            Expanded(
              child: PrimaryScrollController(
                controller: scrollController,
                child: widget.body,
              ),
            ),

            // Bottom bar if provided
            if (widget.bottomBar != null) ...[
              Divider(
                height: 1,
                thickness: 0.5,
                color: colors.hairlineBorder,
              ),
              widget.bottomBar!,
            ],
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.sheetRadius,
            border: Border.all(
              color: colors.hairlineBorder,
              width: AppRadius.hairline,
            ),
          ),
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: colors.glassHighlight.a > 0
              ? CustomPaint(
                  foregroundPainter: SpecularTopBorderPainter(
                    highlightColor: colors.glassHighlight,
                    borderRadius: AppRadius.sheetRadius,
                  ),
                  child: content,
                )
              : content,
        );
      },
    );
  }
}
