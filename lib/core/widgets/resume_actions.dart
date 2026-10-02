import 'package:flutter/material.dart';

import '../design/colors.dart';

/// Resume actions remain available through a menu and directional swipes.
class ResumeActions extends StatelessWidget {
  const ResumeActions({
    super.key,
    required this.id,
    required this.child,
    required this.onActivate,
    required this.onRemove,
    required this.canRemove,
  });

  final String id;
  final Widget child;
  final VoidCallback onActivate;
  final Future<void> Function() onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Dismissible(
      key: ValueKey('resume-actions-$id'),
      direction: canRemove
          ? DismissDirection.horizontal
          : DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onActivate();
        } else {
          await onRemove();
        }
        // The controller owns removal; keep this transient swipe reversible.
        return false;
      },
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.all(24),
        color: colors.paleIndigoSurface,
        child: Icon(Icons.check_circle_outline, color: colors.accent),
      ),
      secondaryBackground: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.all(24),
        color: colors.error.withValues(alpha: 0.12),
        child: Icon(Icons.delete_outline, color: colors.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: PopupMenuButton<String>(
              tooltip: 'Resume options',
              onSelected: (value) async {
                if (value == 'active') {
                  onActivate();
                } else {
                  await onRemove();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'active', child: Text('Set active')),
                if (canRemove)
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Delete resume'),
                  ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
