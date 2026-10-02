import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../theme/tokens.dart';

/// Highlights a valid tracker destination while a card is being dragged.
class StageDropTarget extends StatelessWidget {
  const StageDropTarget({super.key, required this.child, required this.onDrop});
  final Widget child;
  final ValueChanged<ApplicationRecord> onDrop;
  @override
  Widget build(BuildContext context) => DragTarget<ApplicationRecord>(
    onAcceptWithDetails: (details) => onDrop(details.data),
    builder: (context, candidates, rejected) => AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : UITokens.quick,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.capsule),
        border: Border.all(
          width: 2,
          color: candidates.isEmpty
              ? Colors.transparent
              : AppColors.of(context).accent,
        ),
      ),
      child: child,
    ),
  );
}
