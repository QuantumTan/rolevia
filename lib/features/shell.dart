import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/icons.dart';
import '../core/design/radius.dart';
import '../core/widgets/adaptive_navigation_bar.dart';
import '../state/app_state.dart';
import '../core/services/interview_reminders.dart';
import '../core/widgets/adaptive_toast.dart';
import 'tracker_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int get index => widget.navigationShell.currentIndex;
  bool _isMinimized = false;
  bool _userScrolling = false;
  double _scrollTravel = 0;
  late int _lastIndex = index;
  final Set<String> _shownReminders = {};

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastIndex != index) {
      _lastIndex = index;
      _isMinimized = false;
      _userScrolling = false;
      _scrollTravel = 0;
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is UserScrollNotification) {
      _userScrolling = notification.direction != ScrollDirection.idle;
      _scrollTravel = 0;
    }
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels <= 16) {
        if (_isMinimized) setState(() => _isMinimized = false);
        _scrollTravel = 0;
      } else if (_userScrolling || notification.dragDetails != null) {
        final delta = notification.scrollDelta ?? 0;
        if (delta.sign != _scrollTravel.sign) _scrollTravel = 0;
        _scrollTravel += delta;
        if (_scrollTravel > 24 &&
            notification.metrics.pixels > 64 &&
            !_isMinimized) {
          setState(() => _isMinimized = true);
        } else if (_scrollTravel < -24 && _isMinimized) {
          setState(() => _isMinimized = false);
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(interviewRemindersProvider, (_, event) {
      event.whenData((record) {
        final key = '${record.id}:${record.interviewAt}';
        if (_shownReminders.add(key) && mounted) {
          showGlassToast(
            context,
            'Upcoming interview: ${record.role} at ${record.company}',
            icon: Icons.event_outlined,
          );
        }
      });
    });
    final state = ref.watch(appControllerProvider);
    final colors = AppColors.of(context);
    final size = MediaQuery.sizeOf(context);
    final useRail = size.width >= 720 && size.height >= 560;

    return Scaffold(
      extendBody: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showRail = useRail && constraints.maxWidth >= 720;
          return Row(
            children: [
              if (showRail)
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
              if (showRail) VerticalDivider(width: 1, color: colors.separator),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScroll,
                      child: widget.navigationShell,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          useRail || MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : AdaptiveNavigationBar(
              selectedIndex: index,
              isMinimized: _isMinimized,
              solid:
                  state.profile.reduceTransparency ||
                  MediaQuery.highContrastOf(context),
              destinations: destinations,
              onDestinationSelected: _selectDestination,
            ),
      floatingActionButton: index == 1
          ? Padding(
              padding: EdgeInsets.only(bottom: useRail ? 0 : 72),
              child: FloatingActionButton(
                tooltip: 'Add an application',
                onPressed: () => showAddApplicationSheet(context, ref),
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.add_rounded),
              ),
            )
          : null,
    );
  }

  void _selectDestination(int value) {
    setState(() {
      _isMinimized = false;
      _scrollTravel = 0;
      _userScrolling = false;
    });
    widget.navigationShell.goBranch(value);
  }

  static const destinations = [
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.discover,
      label: 'Discover',
    ),
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.tracker,
      label: 'Tracker',
    ),
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.document,
      label: 'Vault',
    ),
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.dashboard,
      label: 'Dashboard',
    ),
  ];
}
