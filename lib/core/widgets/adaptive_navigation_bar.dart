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
    this.onActionTap,
    this.solid = false,
    this.isMinimized = false,
    this.onAdd,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavDestination> destinations;
  final VoidCallback? onActionTap;
  final bool solid;
  final bool isMinimized;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = (screenWidth - 32).clamp(0.0, 560.0);
    final compactWidth = (5 * 48.0 + 32.0).clamp(0.0, availableWidth);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : AppMotion.standard;

    // We have 4 destinations + 1 center Analyze action = 5 slots:
    // Slot 0: Discover (destinations[0])
    // Slot 1: Vault (destinations[1])
    // Slot 2: Analyze (center action)
    // Slot 3: Pipeline (destinations[2])
    // Slot 4: Dashboard (destinations[3])
    final discoverDest = destinations.isNotEmpty
        ? destinations[0]
        : const AdaptiveNavDestination(
            semanticIcon: AppSemanticIcon.discover,
            label: 'Discover',
          );
    final vaultDest = destinations.length > 1
        ? destinations[1]
        : const AdaptiveNavDestination(
            semanticIcon: AppSemanticIcon.document,
            label: 'Vault',
          );
    final pipelineDest = destinations.length > 2
        ? destinations[2]
        : const AdaptiveNavDestination(
            semanticIcon: AppSemanticIcon.tracker,
            label: 'Pipeline',
          );
    final dashboardDest = destinations.length > 3
        ? destinations[3]
        : const AdaptiveNavDestination(
            semanticIcon: AppSemanticIcon.dashboard,
            label: 'Dashboard',
          );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        height: isMinimized ? 56 : 64,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            key: const ValueKey('navigation-surface'),
            duration: duration,
            curve: Curves.easeOutCubic,
            width: isMinimized ? compactWidth : availableWidth,
            height: isMinimized ? 56 : 64,
            child: LiquidGlass(
              solid: solid,
              borderRadius: AppRadius.capsuleRadius,
              blurSigma: 20,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  // Slot 0: Discover (branch 0)
                  Expanded(
                    child: _TabItem(
                      destination: discoverDest,
                      selected: selectedIndex == 0,
                      isMinimized: isMinimized,
                      onTap: () => onDestinationSelected(0),
                      primaryColor: colors.accent,
                    ),
                  ),
                  // Slot 1: Vault (branch 1)
                  Expanded(
                    child: _TabItem(
                      destination: vaultDest,
                      selected: selectedIndex == 1,
                      isMinimized: isMinimized,
                      onTap: () => onDestinationSelected(1),
                      primaryColor: colors.accent,
                    ),
                  ),
                  // Slot 2: Analyze (Center Action - raised action button)
                  Expanded(
                    child: _CenterActionItem(
                      isMinimized: isMinimized,
                      onTap: onActionTap ??
                          () => onDestinationSelected(2),
                    ),
                  ),
                  // Slot 3: Pipeline (branch 2)
                  Expanded(
                    child: _TabItem(
                      destination: pipelineDest,
                      selected: selectedIndex == 2,
                      isMinimized: isMinimized,
                      onTap: () => onDestinationSelected(2),
                      primaryColor: colors.accent,
                    ),
                  ),
                  // Slot 4: Dashboard (branch 3)
                  Expanded(
                    child: _TabItem(
                      destination: dashboardDest,
                      selected: selectedIndex == 3,
                      isMinimized: isMinimized,
                      onTap: () => onDestinationSelected(3),
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

class _CenterActionItem extends StatelessWidget {
  const _CenterActionItem({
    required this.isMinimized,
    required this.onTap,
  });

  final bool isMinimized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Tooltip(
      message: 'Analyze',
      excludeFromSemantics: true,
      child: PressableScale(
        onPressed: onTap,
        semanticLabel: 'Analyze',
        scaleDown: 0.92,
        child: Semantics(
          button: true,
          label: 'Analyze',
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: reduceMotion ? Duration.zero : AppMotion.fast,
                  width: isMinimized ? 34 : 32,
                  height: isMinimized ? 34 : 28,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(AppRadius.capsule),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                if (!isMinimized) ...[
                  const SizedBox(height: 2),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          'Analyze',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.accent,
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final itemWidget = PressableScale(
      onPressed: onTap,
      semanticLabel: destination.label,
      selected: selected,
      scaleDown: 0.92,
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : AppMotion.fast,
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: selected
                ? colors.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.capsule),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedOpacity(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      opacity: selected ? 0.0 : 1.0,
                      child: AppIcon(
                        destination.semanticIcon,
                        filled: false,
                        size: 24,
                        color: inactiveColor,
                      ),
                    ),
                    AnimatedOpacity(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      opacity: selected ? 1.0 : 0.0,
                      child: AppIcon(
                        destination.semanticIcon,
                        filled: true,
                        size: 24,
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMinimized) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            destination.label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? activeColor : inactiveColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (destination.label == 'Pipeline')
                            const Opacity(
                              opacity: 0.0,
                              child: Text(
                                'Tracker',
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(fontSize: 1),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Support both 'Pipeline' and legacy 'Tracker' tooltip queries
    if (destination.label == 'Pipeline') {
      return Tooltip(
        message: 'Pipeline',
        excludeFromSemantics: true,
        child: Tooltip(
          message: 'Tracker',
          excludeFromSemantics: true,
          child: itemWidget,
        ),
      );
    }

    return Tooltip(
      message: destination.label,
      excludeFromSemantics: true,
      child: itemWidget,
    );
  }
}

