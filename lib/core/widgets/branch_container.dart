import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Fades tabs while keeping every branch navigator and scroll position alive.
class BranchContainer extends StatelessWidget {
  const BranchContainer({
    super.key,
    required this.index,
    required this.children,
  });
  final int index;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      for (var i = 0; i < children.length; i++)
        _BranchVisibility(
          visible: i == index,
          child: ExcludeSemantics(
            excluding: i != index,
            child: TickerMode(
              enabled: i == index,
              child: IgnorePointer(ignoring: i != index, child: children[i]),
            ),
          ),
        ),
    ],
  );
}

class _BranchVisibility extends StatefulWidget {
  const _BranchVisibility({required this.visible, required this.child});
  final bool visible;
  final Widget child;
  @override
  State<_BranchVisibility> createState() => _BranchVisibilityState();
}

class _BranchVisibilityState extends State<_BranchVisibility> {
  late bool hidden = !widget.visible;
  @override
  void didUpdateWidget(_BranchVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) hidden = false;
  }

  @override
  Widget build(BuildContext context) => Offstage(
    offstage: hidden && !widget.visible,
    child: AnimatedOpacity(
      opacity: widget.visible ? 1 : 0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : UITokens.selection,
      onEnd: () {
        if (!widget.visible && mounted) setState(() => hidden = true);
      },
      child: widget.child,
    ),
  );
}
