import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/icons.dart';
import '../core/widgets/adaptive_navigation_bar.dart';
import '../state/app_state.dart';
import '../core/services/interview_reminders.dart';
import '../core/widgets/adaptive_toast.dart';
import 'package:flutter/services.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/typography.dart';
import '../core/widgets/pressable.dart';

final scrollToTopIndexProvider = StateProvider<int?>((ref) => null);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int get index => widget.navigationShell.currentIndex;
  bool _isMinimized = false;
  bool _userScrolling = false;
  double _scrollTravel = 0;
  late int _lastIndex = index;
  final Set<String> _shownReminders = {};
  String? _detectedJobPostText;
  String? _lastDismissedClipboardText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text != null &&
          text.isNotEmpty &&
          text != _lastDismissedClipboardText &&
          text != _detectedJobPostText) {
        final isJobUrl =
            text.startsWith('http://') || text.startsWith('https://');
        final isLongText = text.length > 150;
        if (isJobUrl || isLongText) {
          if (mounted) {
            setState(() {
              _detectedJobPostText = text;
            });
          }
        }
      }
    } catch (_) {
      // Clipboard access might be denied
    }
  }

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
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Tooltip(
                        message: 'Analyze',
                        child: PressableScale(
                          onPressed: _openMatchStudio,
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: colors.accent,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.capsule),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.document_scanner_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                if (constraints.maxWidth >= 1100) ...[
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Analyze',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                          label: destination.label == 'Pipeline'
                              ? const Stack(
                                  children: [
                                    Text('Pipeline'),
                                    Opacity(
                                      opacity: 0.0,
                                      child: Text(
                                        'Tracker',
                                        style: TextStyle(fontSize: 1),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(destination.label),
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
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: _onScroll,
                          child: widget.navigationShell,
                        ),
                        // Clipboard detected job post floating chip
                        if (_detectedJobPostText != null)
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: useRail ? 24 : 80,
                            child: Center(
                              child: _ClipboardHintChip(
                                onPaste: () {
                                  final text = _detectedJobPostText!;
                                  setState(() => _detectedJobPostText = null);
                                  context.push(
                                    '/match',
                                    extra: {
                                      'text': text,
                                      'source': 'Clipboard',
                                    },
                                  );
                                },
                                onDismiss: () {
                                  setState(() {
                                    _lastDismissedClipboardText =
                                        _detectedJobPostText;
                                    _detectedJobPostText = null;
                                  });
                                },
                              ),
                            ),
                          ),
                      ],
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
              onActionTap: _openMatchStudio,
            ),
    );
  }

  void _openMatchStudio() {
    AppMotion.selectionHaptic();
    context.push('/match');
  }

  void _selectDestination(int value) {
    if (index == value) {
      // Tapping the active tab scrolls to top or pops to root
      AppMotion.selectionHaptic();
      final primary = PrimaryScrollController.maybeOf(context);
      if (primary != null && primary.hasClients) {
        primary.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
      ref.read(scrollToTopIndexProvider.notifier).state = value;
      return;
    }

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
      semanticIcon: AppSemanticIcon.document,
      label: 'Vault',
    ),
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.tracker,
      label: 'Pipeline',
    ),
    AdaptiveNavDestination(
      semanticIcon: AppSemanticIcon.dashboard,
      label: 'Dashboard',
    ),
  ];
}

class _ClipboardHintChip extends StatelessWidget {
  const _ClipboardHintChip({
    required this.onPaste,
    required this.onDismiss,
  });

  final VoidCallback onPaste;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppRadius.capsule),
          border: Border.all(
            color: colors.hairlineBorder,
            width: AppRadius.hairline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onPaste,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.content_paste_go_rounded,
                    size: 16,
                    color: colors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Paste detected job post',
                    style: AppTypography.caption.copyWith(
                      color: colors.labelPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: colors.labelTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

