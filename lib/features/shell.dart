import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets.dart';
import '../state/app_state.dart';
import 'dashboard_screen.dart';
import 'discover_screen.dart';
import 'match_screen.dart';
import 'tracker_screen.dart';
import 'vault_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.initialIndex});
  final int initialIndex;
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late int index = widget.initialIndex;
  static const paths = [
    '/discover',
    '/vault',
    '/match',
    '/tracker',
    '/dashboard',
  ];
  static const screens = [
    DiscoverScreen(),
    VaultScreen(),
    MatchScreen(),
    TrackerScreen(),
    DashboardScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: GlassSurface(
          solid:
              state.profile.reduceTransparency ||
              MediaQuery.highContrastOf(context),
          radius: 28,
          child: NavigationBar(
            selectedIndex: index,
            backgroundColor: Colors.transparent,
            labelBehavior:
                MediaQuery.textScalerOf(context).scale(12) > 18 ||
                    MediaQuery.sizeOf(context).width < 360
                ? NavigationDestinationLabelBehavior.alwaysHide
                : NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.travel_explore_outlined),
                selectedIcon: Icon(Icons.travel_explore),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_copy_outlined),
                selectedIcon: Icon(Icons.folder_copy),
                label: 'Vault',
              ),
              NavigationDestination(
                icon: Icon(Icons.compare_arrows),
                label: 'Match',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_kanban_outlined),
                selectedIcon: Icon(Icons.view_kanban),
                label: 'Tracker',
              ),
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Dashboard',
              ),
            ],
            onDestinationSelected: (value) {
              setState(() => index = value);
              context.replace(paths[value]);
            },
          ),
        ),
      ),
      floatingActionButton: index == 3
          ? FloatingActionButton(
              tooltip: 'Add application',
              onPressed: () => showAddApplicationSheet(context, ref),
              child: const Icon(Icons.add),
            )
          : kDebugMode
          ? FloatingActionButton.small(
              tooltip: 'Demo state selector',
              onPressed: () => _scenarios(context),
              child: const Icon(Icons.science_outlined),
            )
          : null,
    );
  }

  void _scenarios(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debug demo scenario',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              ...DemoScenario.values.map(
                (s) => ListTile(
                  title: Text(s.name),
                  onTap: () {
                    ref.read(appControllerProvider.notifier).setScenario(s);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
