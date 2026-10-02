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
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavDestination> destinations;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final labelScale = MediaQuery.textScalerOf(context).scale(11) / 11;
    final targetHeight = 42.0 + 26.0 * labelScale;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Align(
        heightFactor: 1,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: (screenWidth - 24).clamp(0.0, 560.0),
          height: targetHeight,
          child: LiquidGlass(
            solid: solid,
            borderRadius: AppRadius.capsuleRadius,
            blurSigma: 20,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: labelScale > 1.3
                    ? (screenWidth - 40)
                          .clamp(0.0, 544.0)
                          .clamp(
                            64.0 * labelScale * destinations.length,
                            double.infinity,
                          )
                    : (screenWidth - 40).clamp(0.0, 544.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < destinations.length; i++)
                      Expanded(
                        child: _TabItem(
                          destination: destinations[i],
                          selected: i == selectedIndex,
                          onTap: () {
                            AppMotion.selectionHaptic();
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
  });

  final AdaptiveNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = primaryColor;
    final colors = AppColors.of(context);
    final inactiveColor = colors.labelSecondary;

    return PressableScale(
      onPressed: onTap,
      semanticLabel: destination.label,
      selected: selected,
      scaleDown: 0.92,
      child: Semantics(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
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
                size: 22,
                color: selected ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  destination.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? activeColor : inactiveColor,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
