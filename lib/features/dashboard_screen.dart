import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final counts = stageCounts(state.applications);
    final submitted = state.applications
        .where((a) => a.stage != ApplicationStage.saved)
        .length;
    final followUps =
        state.applications.where((a) => a.followUpAt != null).toList()
          ..sort((a, b) => a.followUpAt!.compareTo(b.followUpAt!));
    final content = <Widget>[
      const PageTitle(
        'Dashboard',
        subtitle: 'A live view of your demo workspace',
      ),
      const SizedBox(height: 20),
      if (state.applications.isEmpty && state.matches.isEmpty)
        EmptyState(
          icon: Icons.space_dashboard_outlined,
          title: 'No activity to summarize',
          message: 'Track a role or run a demo match to populate this view.',
          action: FilledButton(
            onPressed: () => context.go('/discover'),
            child: const Text('Browse roles'),
          ),
        )
      else ...[
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 600
                ? (constraints.maxWidth - 24) / 3
                : (constraints.maxWidth - 12) / 2;
            final stats = [
              ('Tracked', state.applications.length),
              ('Submitted', submitted),
              ('Interviews', counts[ApplicationStage.interview]!),
              ('Offers', counts[ApplicationStage.offer]!),
              ('Saved matches', state.matches.length),
            ];
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: stats
                  .map(
                    (s) => SizedBox(
                      width: width,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${s.$2}',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                              ),
                              Text(s.$1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 26),
        Text(
          'Application stages',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ...ApplicationStage.values.map(
          (s) => _StageBar(
            label: s.label,
            value: counts[s]!,
            total: state.applications.length,
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent matches',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/match'),
              child: const Text('Run another'),
            ),
          ],
        ),
        if (state.matches.isEmpty)
          const Text('No match results saved yet.')
        else
          ...state.matches
              .take(3)
              .map(
                (m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('${m.overall}')),
                  title: Text(m.jobLabel),
                  subtitle: Text('Demo analysis • ${shortDate(m.createdAt)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/matches/${m.id}'),
                ),
              ),
        const SizedBox(height: 18),
        Text(
          'Upcoming follow-ups',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (followUps.isEmpty)
          const Text('No follow-up dates set.')
        else
          ...followUps
              .take(4)
              .map(
                (a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text('${a.role} • ${a.company}'),
                  subtitle: Text(shortDate(a.followUpAt!)),
                  onTap: () => context.push('/applications/${a.id}'),
                ),
              ),
      ],
    ];
    return SafeArea(
      bottom: false,
      child: ScenarioState(
        scenario: state.scenario,
        onRetry: () => ref
            .read(appControllerProvider.notifier)
            .setScenario(DemoScenario.normal),
        normal: ListView(
          key: const PageStorageKey('dashboard-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 116),
          children: content,
        ),
      ),
    );
  }
}

class _StageBar extends StatelessWidget {
  const _StageBar({
    required this.label,
    required this.value,
    required this.total,
  });
  final String label;
  final int value, total;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(
      label: '$label, $value applications',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('$value'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: total == 0 ? 0 : value / total,
            minHeight: 9,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    ),
  );
}
