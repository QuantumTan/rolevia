import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';

/// Short platform-aware transitions for pushed routes.
CustomTransitionPage<void> appPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : UITokens.transition,
  reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : UITokens.transition,
  transitionsBuilder: (context, animation, secondary, child) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondary,
        linearTransition: false,
        child: child,
      );
    }
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);
