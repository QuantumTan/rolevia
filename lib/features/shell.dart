import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/icons.dart';
import '../core/widgets/adaptive_navigation_bar.dart';
import '../state/app_state.dart';
import 'tracker_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int get index => widget.navigationShell.currentIndex;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= 720;
          return Row(
            children: [
              if (useRail)
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 1100,
                    minExtendedWidth: 200,
                    labelType: constraints.maxWidth >= 1100
                        ? null
                        : NavigationRailLabelType.all,
                    selectedIndex: index,
                    onDestinationSelected: _selectDestination,
                    backgroundColor: colors.surface,
                    indicatorColor: colors.paleIndigoSurface,
                    destinations: [
                      for (final destination in destinations)
                        NavigationRailDestination(
                          icon: AppIcon(
                            destination.semanticIcon,
                            color: colors.labelSecondary,
                          ),
                          selectedIcon: AppIcon(
                            destination.semanticIcon,
                            filled: true,
                            color: colors.accent,
                          ),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                ),
              if (useRail) VerticalDivider(width: 1, color: colors.separator),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: widget.navigationShell,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          MediaQuery.sizeOf(context).width >= 720 ||
              MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : AdaptiveNavigationBar(
              selectedIndex: index,
              solid:
                  state.profile.reduceTransparency ||
                  MediaQuery.highContrastOf(context),
              destinations: destinations,
              onDestinationSelected: _selectDestination,
            ),
      floatingActionButton: index == 3
          ? FloatingActionButton(
              tooltip: 'Add an application',
              onPressed: () => showAddApplicationSheet(context, ref),
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  void _selectDestination(int value) {
    widget.navigationShell.goBranch(value);
  }

  static const destinations = [
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.discover,
      label: 'Discover',
    ),
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.document,
      label: 'Vault',
    ),
    AdaptiveNavDestination(semanticIcon: AppSemanticIcon.match, label: 'Match'),
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.tracker,
      label: 'Tracker',
    ),
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.dashboard,
      label: 'Dashboard',
    ),
  ];
}
