import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/colors.dart';
import '../design/icons.dart';
import '../design/motion.dart';
import 'liquid_glass.dart';
import 'pressable.dart';

/// Platform-adaptive Scaffold with iOS large title navigation bar support
/// and Liquid Glass frosted effects.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBody = false,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final canPop = Navigator.canPop(context);

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && showBackButton && canPop) {
      effectiveLeading = Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Tooltip(
          message: 'Back',
          child: Semantics(
            label: 'Back',
            child: PressableScale(
              onPressed: () {
                AppMotion.lightHaptic();
                context.pop();
              },
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  AppSemanticIcon.back,
                  size: 20,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    PreferredSizeWidget? appBar;
    if (title != null) {
      appBar = PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: LiquidGlass(
          solid: false,
          radius: 0,
          blurSigma: 20,
          showBorder: false,
          showShadow: false,
          child: AppBar(
            leading: effectiveLeading,
            title: Text(
              title!,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.labelPrimary,
                letterSpacing: -0.3,
              ),
            ),
            centerTitle: isIOS,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: actions,
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: extendBody,
      backgroundColor: colors.background,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
