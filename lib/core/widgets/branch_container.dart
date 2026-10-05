import 'package:flutter/material.dart';

class BranchContainer extends StatelessWidget {
  const BranchContainer({
    super.key,
    required this.index,
    required this.children,
  });
  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IndexedStack(
      index: index,
      children: [
        for (var i = 0; i < children.length; i++)
          AnimatedOpacity(
            key: ValueKey('branch_$i'),
            opacity: i == index ? 1.0 : 0.0,
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: children[i],
          ),
      ],
    );
  }
}

