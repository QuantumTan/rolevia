import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/icons.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import 'liquid_glass.dart';
import 'pressable.dart';

class AdaptiveNavDestination {
  const AdaptiveNavDestination({
    required this.semanticIcon,
    required this.label,
  });

  final AppSemanticIcon semanticIcon;
  final String label;
}

class AdaptiveNavigationBar extends StatelessWidget {
  const AdaptiveNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.solid = false,
    this.isMinimized = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavDestination> destinations;
  final bool solid;
  final bool isMinimized;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final labelScale = MediaQuery.textScalerOf(context).scale(11) / 11;
    final targetHeight = 42.0 + 26.0 * labelScale;
    final availableWidth = (screenWidth - 32).clamp(0.0, 560.0);
    final compactWidth = (destinations.length * 52.0 + 16).clamp(
      0.0,
      availableWidth,
    );
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.standard;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        height: targetHeight,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            key: const ValueKey('navigation-surface'),
            duration: duration,
            curve: Curves.easeOutCubic,
            width: isMinimized ? compactWidth : availableWidth,
            height: isMinimized ? 56 : targetHeight,
            child: LiquidGlass(
              solid: solid,
              borderRadius: AppRadius.capsuleRadius,
              blurSigma: 20,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < destinations.length; i++)
                    Expanded(
                      child: _TabItem(
                        destination: destinations[i],
                        selected: i == selectedIndex,
                        isMinimized: isMinimized,
                        onTap: () {
                          onDestinationSelected(i);
                        },
                        primaryColor: colors.accent,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
    required this.isMinimized,
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isMinimized;

  @override
  Widget build(BuildContext context) {
    final activeColor = primaryColor;
    final colors = AppColors.of(context);
    final inactiveColor = colors.labelSecondary;

    return Tooltip(
      message: destination.label,
      excludeFromSemantics: true,
      child: PressableScale(
        onPressed: onTap,
        semanticLabel: destination.label,
        selected: selected,
        scaleDown: 0.92,
        child: Semantics(
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppMotion.fast,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            decoration: BoxDecoration(
              color: selected ? colors.paleIndigoSurface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.capsule),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  destination.semanticIcon,
                  filled: selected,
                  size: isMinimized ? 24 : 22,
                  color: selected ? activeColor : inactiveColor,
                ),
                if (!isMinimized) ...[
                  const SizedBox(height: 2),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          destination.label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected ? activeColor : inactiveColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
