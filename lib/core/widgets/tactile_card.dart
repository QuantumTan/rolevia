import 'package:flutter/material.dart';

import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import 'app_card.dart';

/// Tactile card with tactile spring press feedback:
/// scales down to 0.98 on down, returns with spring physics on release.
/// Fully respects reduce motion and accessibility semantics.
class TactileCard extends StatefulWidget {
  const TactileCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = AppSpacing.edgeInsetsCard,
    this.margin,
    this.borderRadius,
    this.color,
    this.showBorder = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool showBorder;
  final String? semanticLabel;

  @override
  State<TactileCard> createState() => _TactileCardState();
}

class _TactileCardState extends State<TactileCard> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  void _handleTapCancel() {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    AppMotion.selectionHaptic();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isInteractive = widget.onTap != null || widget.onLongPress != null;
    final scale = (!isInteractive || reduceMotion || !_pressed)
        ? 1.0
        : AppMotion.pressScale;

    Widget card = AppCard(
      padding: widget.padding,
      margin: widget.margin,
      borderRadius: widget.borderRadius ?? AppRadius.cardRadius,
      color: widget.color,
      showBorder: widget.showBorder,
      child: widget.child,
    );

    if (!isInteractive) {
      return card;
    }

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: true,
      onTap: _handleTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: scale,
          duration: reduceMotion ? Duration.zero : AppMotion.instant,
          curve: AppMotion.curveStandard,
          child: card,
        ),
      ),
    );
  }
}
