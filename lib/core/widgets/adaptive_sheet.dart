import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/typography.dart';
import 'liquid_glass.dart';

typedef SheetHeaderBuilder = Widget Function(
  BuildContext context,
  Widget close,
);

/// One draggable route and one scroll position, shared by header and body.
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  String? title,
  SheetHeaderBuilder? headerBuilder,
  bool useRootNavigator = true,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    sheetAnimationStyle: reduceMotion
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            curve: AppMotion.springCurve,
            reverseCurve: AppMotion.curveExit,
            duration: AppMotion.sheet,
            reverseDuration: AppMotion.standard,
          ),
    builder: (_) => _AdaptiveSheetContent(
      title: title,
      headerBuilder: headerBuilder,
      builder: builder,
    ),
  );
}

/// Keyboard and assistive resize operations use the same sheet controller.
class AdaptiveSheetScope extends InheritedWidget {
  const AdaptiveSheetScope({
    super.key,
    required super.child,
    required this.expand,
    required this.collapse,
  });
  final Future<void> Function() expand;
  final Future<void> Function() collapse;
  static AdaptiveSheetScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveSheetScope>()!;
  @override
  bool updateShouldNotify(AdaptiveSheetScope oldWidget) => false;
}

class _AdaptiveSheetContent extends StatefulWidget {
  const _AdaptiveSheetContent({
    this.title,
    this.headerBuilder,
    required this.builder,
  });
  final String? title;
  final SheetHeaderBuilder? headerBuilder;
  final Widget Function(BuildContext) builder;
  @override
  State<_AdaptiveSheetContent> createState() => _AdaptiveSheetContentState();
}

class _AdaptiveSheetContentState extends State<_AdaptiveSheetContent>
    with SingleTickerProviderStateMixin {
  final _controller = DraggableScrollableController();
  late final AnimationController _hint = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  static final _hinted = <String?>{};
  double _collapsed = 0.45;
  double? _parentHeight;
  double? _lastSnap;
  bool _closing = false;
  Animation<double>? _entryAnimation;
  VelocityTracker? _velocity;
  double? _dragStartSize;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_extentChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && _hinted.add(widget.title)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _entryAnimation = ModalRoute.of(context)?.animation;
        if (_entryAnimation == null ||
            _entryAnimation!.status == AnimationStatus.completed) {
          _hint.forward();
        } else {
          _entryAnimation!.addStatusListener(_afterEntry);
        }
      });
    }
  }

  void _afterEntry(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _entryAnimation?.removeStatusListener(_afterEntry);
    if (mounted) _hint.forward();
  }

  void _extentChanged() {
    if (!_controller.isAttached || _closing) return;
    final size = _controller.size;
    if (size <= 0.001) {
      _closing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          Navigator.pop(context);
        }
      });
      return;
    }
    final snap = (size - _collapsed).abs() < 0.001
        ? _collapsed
        : (size - 0.90).abs() < 0.001
        ? 0.90
        : null;
    if (snap != null && snap != _lastSnap) AppMotion.lightHaptic();
    _lastSnap = snap;
  }

  Future<void> _resize(double size) async {
    if (!_controller.isAttached || _closing) return;
    if ((_controller.size - size).abs() < 0.001) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpTo(size);
    } else {
      await _controller.animateTo(
        size,
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.2, 0.9, 0.25, 1),
      );
    }
  }

  void _settle(PointerUpEvent event) {
    _velocity?.addPosition(event.timeStamp, event.position);
    final velocity = _velocity?.getVelocity().pixelsPerSecond.dy ?? 0;
    final start = _dragStartSize;
    _velocity = null;
    _dragStartSize = null;
    if (!_controller.isAttached || start == null || _dragDistance.abs() < 8) {
      return;
    }
    final size = _controller.size;
    if ((start - size).abs() < 0.001) return;
    final maxExtent = math.max(0.90, _collapsed);
    final double target;
    if (velocity > 1200) {
      target = 0;
    } else if (velocity < -600) {
      target = maxExtent;
    } else if (velocity > 600) {
      target = start > _collapsed + 0.05 ? _collapsed : 0.0;
    } else if (_dragDistance < 0) {
      target = maxExtent;
    } else {
      if (start > _collapsed + 0.05) {
        target = size < _collapsed * 0.5 ? 0.0 : _collapsed;
      } else {
        target = 0.0;
      }
    }
    // Let Scrollable end its drag before replacing its ballistic settle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_closing) _resize(target);
    });
  }

  @override
  void dispose() {
    _entryAnimation?.removeStatusListener(_afterEntry);
    _controller.removeListener(_extentChanged);
    _controller.dispose();
    _hint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final colors = AppColors.of(context);
    final reduceMotion = media.disableAnimations;
    final titleScale = media.textScaler.scale(22);
    final headerHeight = widget.headerBuilder == null
        ? math.max(44.0, media.textScaler.scale(17) * 1.35 * 2) + 68
        : math.max(
                48.0,
                titleScale * 1.28 * 2 + media.textScaler.scale(13) * 1.35 + 4,
              ) +
              76;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wasCollapsed =
            _controller.isAttached &&
            (_controller.size - _collapsed).abs() < 0.002;
        final rotated =
            _parentHeight != null && _parentHeight != constraints.maxHeight;
        _parentHeight = constraints.maxHeight;
        // Preview at 45%; preserve a 360px minimum floor on compact viewports.
        final minDetentRatio = (360 / constraints.maxHeight).clamp(0.0, 1.0);
        final maxExtent = math.max(0.90, minDetentRatio).clamp(0.90, 1.0);
        _collapsed = math
            .max(0.45, minDetentRatio)
            .clamp(0.45, maxExtent);
        final snapSizes = _collapsed < maxExtent ? [_collapsed, maxExtent] : [maxExtent];
        if (rotated && wasCollapsed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _controller.isAttached && !_closing) {
              _controller.jumpTo(_collapsed);
            }
          });
        }
        return DraggableScrollableSheet(
          key: const ValueKey('adaptive-draggable-sheet'),
          controller: _controller,
          initialChildSize: _collapsed,
          minChildSize: 0,
          maxChildSize: maxExtent,
          snap: true,
          snapSizes: snapSizes,
          snapAnimationDuration: Duration(milliseconds: reduceMotion ? 1 : 300),
          shouldCloseOnMinExtent: false,
          expand: false,
          builder: (context, scrollController) => AdaptiveSheetScope(
            expand: () => _resize(maxExtent),
            collapse: () => _resize(_collapsed),
            child: ClipRRect(
              borderRadius: AppRadius.sheetRadius,
              child: ColoredBox(
                color: colors.surface,
                child: Padding(
                  padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
                  child: Listener(
                    onPointerDown: (event) {
                      _velocity = VelocityTracker.withKind(event.kind)
                        ..addPosition(event.timeStamp, event.position);
                      _dragStartSize = _controller.isAttached
                          ? _controller.size
                          : null;
                      _dragDistance = 0;
                    },
                    onPointerMove: (event) {
                      _velocity?.addPosition(event.timeStamp, event.position);
                      _dragDistance += event.delta.dy;
                    },
                    onPointerUp: _settle,
                    onPointerCancel: (_) {
                      _velocity = null;
                      _dragStartSize = null;
                    },
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: PointerDeviceKind.values.toSet(),
                      ),
                      child: CustomScrollView(
                        key: const ValueKey('adaptive-sheet-scroll'),
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SheetHeader(
                              extent: headerHeight,
                              child: LiquidGlass(
                                borderRadius: AppRadius.sheetRadius,
                                showShadow: false,
                                child: Column(
                                  children: [
                                    Semantics(
                                      label: 'Resize sheet',
                                      customSemanticsActions: {
                                        const CustomSemanticsAction(
                                          label: 'Expand',
                                        ): () =>
                                            _resize(maxExtent),
                                        const CustomSemanticsAction(
                                          label: 'Collapse',
                                        ): () =>
                                            _resize(_collapsed),
                                      },
                                      child: SizedBox(
                                        key: const ValueKey('sheet-grabber'),
                                        height: 44,
                                        width: double.infinity,
                                        child: ColoredBox(
                                          color: Colors.transparent,
                                          child: AnimatedBuilder(
                                            animation: _hint,
                                            builder: (_, child) =>
                                                Transform.translate(
                                                  offset: Offset(
                                                    0,
                                                    reduceMotion
                                                        ? 0
                                                        : -4 *
                                                              math.sin(
                                                                math.pi *
                                                                    _hint.value,
                                                              ),
                                                  ),
                                                  child: child,
                                                ),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Container(
                                                  width: 36,
                                                  height: 5,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        colors.labelSecondary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          3,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          24,
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            final close = IconButton(
                                              tooltip: 'Close dialog',
                                              constraints: const BoxConstraints(
                                                minWidth: 44,
                                                minHeight: 44,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              icon: const Icon(
                                                Icons.close_rounded,
                                              ),
                                            );
                                            return widget.headerBuilder?.call(
                                                  context,
                                                  close,
                                                ) ??
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        widget.title ?? '',
                                                        style: AppTypography
                                                            .headline
                                                            .copyWith(
                                                              color: colors
                                                                  .labelPrimary,
                                                            ),
                                                      ),
                                                    ),
                                                    close,
                                                  ],
                                                );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(
                              bottom: math.max(16, media.padding.bottom),
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Builder(builder: widget.builder),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetHeader extends SliverPersistentHeaderDelegate {
  const _SheetHeader({required this.extent, required this.child});
  final double extent;
  final Widget child;
  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(_SheetHeader oldDelegate) =>
      extent != oldDelegate.extent || child != oldDelegate.child;
}
