import 'dart:async';
import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';

enum AppToastType {
  info,
  success,
  warning,
  error,
}

/// Floating toast with automatic dismissal at 2 seconds.
class AppToast {
  const AppToast._();

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    IconData? icon,
    Duration duration = AppMotion.toastDuration,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        icon: icon,
        duration: duration,
        onDismissed: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.type,
    this.icon,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final AppToastType type;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.quick,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.curveStandard,
      reverseCurve: AppMotion.curveExit,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(_fade);

    _controller.forward();

    _timer = Timer(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final media = MediaQuery.of(context);

    Color fg;
    IconData defaultIcon;

    switch (widget.type) {
      case AppToastType.success:
        fg = colors.diffAddedText;
        defaultIcon = Icons.check_circle_outline_rounded;
      case AppToastType.warning:
        fg = colors.warning;
        defaultIcon = Icons.warning_amber_rounded;
      case AppToastType.error:
        fg = colors.error;
        defaultIcon = Icons.error_outline_rounded;
      case AppToastType.info:
        fg = colors.accent;
        defaultIcon = Icons.info_outline_rounded;
    }

    final displayIcon = widget.icon ?? defaultIcon;

    return Positioned(
      bottom: media.padding.bottom + 84.0,
      left: AppSpacing.s16,
      right: AppSpacing.s16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s12,
                ),
                decoration: BoxDecoration(
                  color: colors.elevatedSurface,
                  borderRadius: AppRadius.capsuleRadius,
                  border: Border.all(
                    color: colors.hairlineBorder,
                    width: AppRadius.hairline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(displayIcon, size: 18, color: fg),
                    const SizedBox(width: AppSpacing.s8),
                    Flexible(
                      child: Text(
                        widget.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: colors.labelPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
