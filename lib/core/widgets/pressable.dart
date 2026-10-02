import 'package:flutter/material.dart';

import '../design/motion.dart';

/// Tactile pressable container with subtle iOS-style spring scale feedback
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleDown = 0.97,
    this.enabled = true,
    this.haptic = true,
    this.semanticLabel,
    this.selected,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double scaleDown;
  final bool enabled;
  final bool haptic;
  final String? semanticLabel;
  final bool? selected;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  bool _focused = false;

  void _activate() {
    if (!widget.enabled || widget.onPressed == null) return;
    if (widget.haptic) AppMotion.selectionHaptic();
    widget.onPressed!();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.onPressed == null) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.onPressed == null) return;
    setState(() => _pressed = false);
    _activate();
  }

  void _handleTapCancel() {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final targetScale = (!widget.enabled || disableAnimations || !_pressed)
        ? 1.0
        : widget.scaleDown;

    final interactive = widget.enabled && widget.onPressed != null;
    final gesture = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTapDown: interactive ? _handleTapDown : null,
      onTapUp: interactive ? _handleTapUp : null,
      onTapCancel: interactive ? _handleTapCancel : null,
      child: AnimatedScale(
        scale: targetScale,
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 100),
        curve: AppMotion.springCurve,
        child: widget.child,
      ),
    );
    return Semantics(
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      selected: widget.selected,
      button: true,
      enabled: interactive,
      onTap: interactive ? _activate : null,
      child: FocusableActionDetector(
        enabled: interactive,
        mouseCursor: interactive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: _focused
                  ? Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 3,
                    )
                  : null,
            ),
            child: gesture,
          ),
        ),
      ),
    );
  }
}
