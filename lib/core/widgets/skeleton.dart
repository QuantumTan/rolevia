import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';

/// Shimmering/pulsing placeholder box for fluid skeleton loading
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.sm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = Tween<double>(
      begin: 0.35,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

/// Skeleton representing a job or card item preventing layout shift
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.edgeInsetsCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          width: 0.8,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 180, height: 20),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonBox(width: 120, height: 14),
                  ],
                ),
              ),
              SkeletonBox(width: 28, height: 28, radius: 14),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: 220, height: 13),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 150, height: 15),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SkeletonBox(width: 70, height: 24, radius: 12),
              SizedBox(width: AppSpacing.xs),
              SkeletonBox(width: 60, height: 24, radius: 12),
              SizedBox(width: AppSpacing.xs),
              SkeletonBox(width: 80, height: 24, radius: 12),
            ],
          ),
        ],
      ),
    );
  }
}
