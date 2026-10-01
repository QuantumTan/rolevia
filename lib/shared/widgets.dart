import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/models.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 24,
    this.solid = false,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool solid;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: solid
            ? (dark ? const Color(0xFF1C1C1E) : Colors.white)
            : (dark
                  ? const Color(0xFF1C1C1E).withValues(alpha: .88)
                  : Colors.white.withValues(alpha: .82)),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: .16) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .3 : .09),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: solid
          ? content
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: content,
            ),
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.displaySmall),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({
    super.key,
    required this.onRetry,
    this.message = 'The demo could not load this view.',
  });
  final VoidCallback onRetry;
  final String message;
  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.error_outline,
    title: 'Something went wrong',
    message: message,
    action: FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
  );
}

class SkillWrap extends StatelessWidget {
  const SkillWrap(this.values, {super.key});
  final List<String> values;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 7,
    runSpacing: 7,
    children: values
        .map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact))
        .toList(),
  );
}

class ScoreRing extends StatelessWidget {
  const ScoreRing(this.score, {super.key, this.size = 96});
  final int score;
  final double size;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: score / 100),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 700),
    builder: (context, value, _) => SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
            strokeCap: StrokeCap.round,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          Center(
            child: Text(
              '${(value * 100).round()}',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ),
  );
}

class ScenarioState extends StatelessWidget {
  const ScenarioState({
    super.key,
    required this.scenario,
    required this.normal,
    required this.onRetry,
    this.empty,
  });
  final dynamic scenario;
  final Widget normal;
  final Widget? empty;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) =>
      switch (scenario.toString().split('.').last) {
        'loading' => const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading demo data...'),
              ],
            ),
          ),
        ),
        'error' => ErrorPanel(onRetry: onRetry),
        'empty' =>
          empty ??
              const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'Nothing here yet',
                message: 'Change the demo scenario or add an item to continue.',
              ),
        _ => normal,
      };
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ) ??
    false;

String shortDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
String stageLabel(ApplicationStage value) => value.label;
