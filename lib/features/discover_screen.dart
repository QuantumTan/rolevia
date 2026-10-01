import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/fixtures.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});
  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with AutomaticKeepAliveClientMixin {
  String query = '', location = '';
  bool savedOnly = false, salarySort = false;
  int minimumSalary = 0;
  Set<WorkMode> modes = {};
  Set<EmploymentType> types = {};
  Timer? debounce;
  @override
  bool get wantKeepAlive => true;
  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final jobs = filterJobs(
      jobs: seedJobs,
      query: query,
      location: location,
      modes: modes,
      types: types,
      minimumSalary: minimumSalary,
      savedOnly: savedOnly,
      savedIds: state.savedJobIds,
      salaryDescending: salarySort,
    );
    return SafeArea(
      bottom: false,
      child: ScenarioState(
        scenario: state.scenario,
        onRetry: () => ref
            .read(appControllerProvider.notifier)
            .setScenario(DemoScenario.normal),
        empty: const EmptyState(
          icon: Icons.work_off_outlined,
          title: 'No demo jobs',
          message: 'Return the debug scenario to normal to restore the seeded roles.',
        ),
        normal: CustomScrollView(
          key: const PageStorageKey('discover-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
              sliver: SliverToBoxAdapter(
                child: PageTitle(
                  'Discover',
                  subtitle: 'Software and IT roles across the Philippines',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Role, company, or skill',
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () => setState(() => query = ''),
                                icon: const Icon(Icons.close),
                              ),
                      ),
                      onChanged: (value) {
                        debounce?.cancel();
                        debounce = Timer(const Duration(milliseconds: 300), () {
                          if (mounted) setState(() => query = value);
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('All')),
                            ButtonSegment(value: true, label: Text('Saved')),
                          ],
                          selected: {savedOnly},
                          onSelectionChanged: (v) =>
                              setState(() => savedOnly = v.first),
                          showSelectedIcon: false,
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Filter jobs',
                          onPressed: () => _filters(context),
                          icon: Badge(
                            isLabelVisible:
                                modes.isNotEmpty ||
                                types.isNotEmpty ||
                                location.isNotEmpty ||
                                minimumSalary > 0,
                            child: const Icon(Icons.tune),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (jobs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off,
                  title: 'No matching roles',
                  message: 'Try fewer filters or a broader search.',
                  action: FilledButton.tonal(
                    onPressed: () => setState(() {
                      query = '';
                      location = '';
                      modes = {};
                      types = {};
                      minimumSalary = 0;
                    }),
                    child: const Text('Reset search'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 116),
                sliver: SliverList.separated(
                  itemCount: jobs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => JobCard(
                    job: jobs[i],
                    saved: state.savedJobIds.contains(jobs[i].id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _filters(BuildContext context) async {
    var draftModes = {...modes};
    var draftTypes = {...types};
    var draftLocation = location;
    var draftSalary = minimumSalary;
    var draftSort = salarySort;
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
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
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Filter roles',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Location contains',
                    ),
                    onChanged: (v) => draftLocation = v,
                    controller: TextEditingController(text: draftLocation),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Work arrangement',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children: WorkMode.values
                        .map(
                          (v) => FilterChip(
                            label: Text(v.label),
                            selected: draftModes.contains(v),
                            onSelected: (x) => setSheet(
                              () =>
                                  x ? draftModes.add(v) : draftModes.remove(v),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Employment type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children: EmploymentType.values
                        .map(
                          (v) => FilterChip(
                            label: Text(v.label),
                            selected: draftTypes.contains(v),
                            onSelected: (x) => setSheet(
                              () =>
                                  x ? draftTypes.add(v) : draftTypes.remove(v),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: draftSalary,
                    decoration: const InputDecoration(
                      labelText: 'Minimum salary',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Any salary')),
                      DropdownMenuItem(
                        value: 60000,
                        child: Text('PHP 60k+ / month'),
                      ),
                      DropdownMenuItem(
                        value: 100000,
                        child: Text('PHP 100k+ / month'),
                      ),
                    ],
                    onChanged: (v) => draftSalary = v!,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: draftSort,
                    title: const Text('Sort by highest salary'),
                    onChanged: (v) => setSheet(() => draftSort = v),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            modes = {};
                            types = {};
                            location = '';
                            minimumSalary = 0;
                            salarySort = false;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            modes = draftModes;
                            types = draftTypes;
                            location = draftLocation;
                            minimumSalary = draftSalary;
                            salarySort = draftSort;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply filters'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JobCard extends ConsumerWidget {
  const JobCard({super.key, required this.job, required this.saved});
  final Job job;
  final bool saved;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/jobs/${job.id}'),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.role,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: saved ? 'Remove saved job' : 'Save job',
                  onPressed: () => ref
                      .read(appControllerProvider.notifier)
                      .toggleSaved(job.id),
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${job.location}  •  ${job.mode.label}  •  ${job.type.label}'),
            const SizedBox(height: 7),
            Text(
              job.salaryLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SkillWrap(job.skills.take(3).toList()),
            const SizedBox(height: 10),
            Text(
              job.postedDays == 1
                  ? 'Posted yesterday'
                  : 'Posted ${job.postedDays} days ago',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}
