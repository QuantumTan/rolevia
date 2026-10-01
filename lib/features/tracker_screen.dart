import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/fixtures.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});
  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen>
    with AutomaticKeepAliveClientMixin {
  bool board = true;
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    return SafeArea(
      bottom: false,
      child: ScenarioState(
        scenario: state.scenario,
        onRetry: () => ref
            .read(appControllerProvider.notifier)
            .setScenario(DemoScenario.normal),
        empty: const EmptyState(
          icon: Icons.view_kanban_outlined,
          title: 'No tracked applications',
          message: 'Add a role to build your application pipeline.',
        ),
        normal: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Column(
                children: [
                  const PageTitle(
                    'Tracker',
                    subtitle: 'Application stages and follow-ups',
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.view_kanban_outlined),
                        label: Text('Board'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.list),
                        label: Text('List'),
                      ),
                    ],
                    selected: {board},
                    showSelectedIcon: false,
                    onSelectionChanged: (v) => setState(() => board = v.first),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.applications.isEmpty
                  ? EmptyState(
                      icon: Icons.add_task,
                      title: 'Your tracker is empty',
                      message:
                          'Add an application or track one from a job detail.',
                      action: FilledButton(
                        onPressed: () => showAddApplicationSheet(context, ref),
                        child: const Text('Add application'),
                      ),
                    )
                  : board
                  ? _Board(applications: state.applications)
                  : ListView.builder(
                      key: const PageStorageKey('tracker-list'),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 116),
                      itemCount: state.applications.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ApplicationCard(value: state.applications[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.applications});
  final List<ApplicationRecord> applications;
  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const PageStorageKey('tracker-board'),
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 116),
    itemCount: ApplicationStage.values.length,
    separatorBuilder: (_, _) => const SizedBox(width: 12),
    itemBuilder: (_, i) {
      final stage = ApplicationStage.values[i];
      final values = applications.where((a) => a.stage == stage).toList();
      return SizedBox(
        width: (MediaQuery.sizeOf(context).width * .78).clamp(270, 340),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${stage.label}  ${values.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: values.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          'No roles in ${stage.label.toLowerCase()}.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: values.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, x) => ApplicationCard(value: values[x]),
                    ),
            ),
          ],
        ),
      );
    },
  );
}

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.value});
  final ApplicationRecord value;
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final overdue =
        value.followUpAt != null &&
        value.followUpAt!.isBefore(
          DateTime(today.year, today.month, today.day),
        );
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/applications/${value.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value.role, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(value.company),
              const SizedBox(height: 9),
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 17,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      value.location,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (value.followUpAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        overdue
                            ? Icons.notification_important_outlined
                            : Icons.event_outlined,
                        size: 17,
                        color: overdue
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${overdue ? 'Overdue' : 'Follow up'} ${shortDate(value.followUpAt!)}',
                        style: TextStyle(
                          color: overdue
                              ? Theme.of(context).colorScheme.error
                              : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showAddApplicationSheet(
  BuildContext outerContext,
  WidgetRef ref,
) async {
  final company = TextEditingController(),
      role = TextEditingController(),
      location = TextEditingController(),
      link = TextEditingController(),
      notes = TextEditingController();
  String? jobId;
  bool existing = true;
  var stage = ApplicationStage.saved;
  var appliedAt = DateTime.now();
  DateTime? followUp;
  await showModalBottomSheet(
    context: outerContext,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheet) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add application',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Existing job')),
                    ButtonSegment(value: false, label: Text('Enter manually')),
                  ],
                  selected: {existing},
                  showSelectedIcon: false,
                  onSelectionChanged: (v) => setSheet(() => existing = v.first),
                ),
                const SizedBox(height: 14),
                if (existing)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Job'),
                    items: seedJobs
                        .map(
                          (j) => DropdownMenuItem(
                            value: j.id,
                            child: Text(
                              '${j.role} • ${j.company}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => jobId = v,
                  )
                else ...[
                  TextField(
                    controller: company,
                    decoration: const InputDecoration(labelText: 'Company'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: link,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Application link (optional)',
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final chosen = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now(),
                      initialDate: appliedAt,
                    );
                    if (chosen != null) setSheet(() => appliedAt = chosen);
                  },
                  icon: const Icon(Icons.today_outlined),
                  label: Text('Application date ${shortDate(appliedAt)}'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ApplicationStage>(
                  initialValue: stage,
                  decoration: const InputDecoration(labelText: 'Stage'),
                  items: ApplicationStage.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      )
                      .toList(),
                  onChanged: (v) => stage = v!,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final chosen = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 1),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: DateTime.now().add(const Duration(days: 3)),
                    );
                    if (chosen != null) setSheet(() => followUp = chosen);
                  },
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    followUp == null
                        ? 'Set follow-up date'
                        : 'Follow up ${shortDate(followUp!)}',
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () {
                    if (existing) {
                      if (jobId == null) {
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(content: Text('Choose a job first.')),
                        );
                        return;
                      }
                      final job = seedJobs.firstWhere((j) => j.id == jobId);
                      final before = ref
                          .read(appControllerProvider)
                          .applications
                          .length;
                      final item = ref
                          .read(appControllerProvider.notifier)
                          .trackJob(job);
                      Navigator.pop(context);
                      final duplicate =
                          before ==
                          ref.read(appControllerProvider).applications.length;
                      if (!duplicate) {
                        ref
                            .read(appControllerProvider.notifier)
                            .updateApplication(
                              item.copyWith(
                                stage: stage,
                                appliedAt: appliedAt,
                                followUpAt: followUp,
                              ),
                            );
                      }
                      ScaffoldMessenger.of(outerContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            duplicate
                                ? 'That job is already tracked. Opening the existing record.'
                                : 'Application added to ${stage.label}.',
                          ),
                        ),
                      );
                      if (duplicate) {
                        outerContext.push('/applications/${item.id}');
                      }
                    } else {
                      if (company.text.trim().isEmpty ||
                          role.text.trim().isEmpty ||
                          location.text.trim().isEmpty) {
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Company, role, and location are required.',
                            ),
                          ),
                        );
                        return;
                      }
                      ref
                          .read(appControllerProvider.notifier)
                          .addApplication(
                            ApplicationRecord(
                              id: 'a${DateTime.now().microsecondsSinceEpoch}',
                              company: company.text.trim(),
                              role: role.text.trim(),
                              location: location.text.trim(),
                              appliedAt: appliedAt,
                              stage: stage,
                              link: link.text.trim(),
                              notes: notes.text.trim().isEmpty
                                  ? []
                                  : [notes.text.trim()],
                              followUpAt: followUp,
                            ),
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save application'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  company.dispose();
  role.dispose();
  location.dispose();
  link.dispose();
  notes.dispose();
}
