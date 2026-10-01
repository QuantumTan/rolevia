import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/fixtures.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: IconButton.filledTonal(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      title: Text(title),
      actions: actions,
    ),
    body: SafeArea(child: child),
  );
}

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = seedJobs.firstWhere((j) => j.id == id);
    final saved = ref.watch(
      appControllerProvider.select((s) => s.savedJobIds.contains(id)),
    );
    return DetailScaffold(
      title: 'Job details',
      actions: [
        IconButton(
          tooltip: saved ? 'Remove saved job' : 'Save job',
          onPressed: () =>
              ref.read(appControllerProvider.notifier).toggleSaved(id),
          icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          Text(job.role, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 5),
          Text(job.company, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Text('${job.location}  •  ${job.mode.label}  •  ${job.type.label}'),
          const SizedBox(height: 5),
          Text(
            job.salaryLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SkillWrap(job.skills),
          const SizedBox(height: 24),
          _section(context, 'Overview', [job.overview]),
          _section(context, 'Responsibilities', job.responsibilities),
          _section(context, 'Qualifications', job.qualifications),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              ref.read(appControllerProvider.notifier).selectForMatch(job.id);
              context.go('/match');
            },
            child: const Text('Match my resume'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              final before = ref
                  .read(appControllerProvider)
                  .applications
                  .length;
              final item = ref
                  .read(appControllerProvider.notifier)
                  .trackJob(job);
              final duplicate =
                  before == ref.read(appControllerProvider).applications.length;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    duplicate
                        ? 'Already tracked. Opening the existing application.'
                        : 'Added to Tracker as Saved.',
                  ),
                ),
              );
              if (duplicate) context.push('/applications/${item.id}');
            },
            child: const Text('Track application'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Demo only. External applications are not connected.',
                ),
              ),
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('External application demo'),
          ),
        ],
      ),
    );
  }
}

Widget _section(BuildContext context, String title, List<String> values) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 9),
        ...values.map(
          (v) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (values.length > 1)
                  const Padding(
                    padding: EdgeInsets.only(top: 8, right: 9),
                    child: CircleAvatar(radius: 2.5),
                  ),
                Expanded(
                  child: Text(v, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class ResumeDetailScreen extends ConsumerWidget {
  const ResumeDetailScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(
      appControllerProvider.select(
        (s) => s.resumes.where((r) => r.id == id).firstOrNull,
      ),
    );
    if (resume == null) {
      return const DetailScaffold(
        title: 'Resume',
        child: EmptyState(
          icon: Icons.description_outlined,
          title: 'Resume removed',
          message: 'Return to Vault to choose another version.',
        ),
      );
    }
    return DetailScaffold(
      title: resume.title,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(resume.filename, style: Theme.of(context).textTheme.titleMedium),
          Text('${resume.fileType} • Added ${shortDate(resume.addedAt)}'),
          const SizedBox(height: 22),
          if (!resume.isSample)
            const EmptyState(
              icon: Icons.preview_outlined,
              title: 'Preview unavailable in demo',
              message: 'Only metadata was saved. The original document was not uploaded, parsed, or stored.',
            )
          else ...[
            _section(context, 'Sample summary', [resume.summary!]),
            _section(context, 'Sample experience', resume.experience),
            Text(
              'Sample skills',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            SkillWrap(resume.skills),
            const SizedBox(height: 22),
            _section(context, 'Sample education', [resume.education]),
            Text(
              'This structured preview is seeded sample content. It was not extracted from a real file.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class MatchResultScreen extends ConsumerWidget {
  const MatchResultScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(
      appControllerProvider.select(
        (s) => s.matches.where((m) => m.id == id).firstOrNull,
      ),
    );
    if (result == null) {
      return const DetailScaffold(
        title: 'Demo analysis',
        child: ErrorPanel(onRetry: _noop),
      );
    }
    return DetailScaffold(
      title: 'Demo analysis',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ScoreRing(result.overall),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.jobLabel,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Illustrative fit score, not a hiring probability',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Score components',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          ...result.components.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(width: 110, child: Text(e.key)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: e.value / 100,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${e.value}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Matched skills',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 9),
          SkillWrap(result.matched),
          const SizedBox(height: 20),
          Text(
            'Missing skills',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 9),
          SkillWrap(result.missing),
          const SizedBox(height: 22),
          _section(context, 'Strengths', result.strengths),
          _section(context, 'Gaps to address', result.gaps),
          Text(
            'Suggested bullet revisions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          ...result.suggestions.map(
            (s) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(s.original),
                    const Divider(height: 24),
                    Text(
                      'Suggested',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(s.suggested),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Copy suggested bullet',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: s.suggested));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Suggested bullet copied.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Adapt every suggestion truthfully. Never add achievements or qualifications you do not have.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          if (result.jobId != null)
            FilledButton(
              onPressed: () {
                final job = seedJobs.firstWhere((j) => j.id == result.jobId);
                ref.read(appControllerProvider.notifier).trackJob(job);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Role is now available in Tracker.'),
                  ),
                );
              },
              child: const Text('Add related job to Tracker'),
            ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go('/match'),
            child: const Text('Run another match'),
          ),
          const SizedBox(height: 18),
          const Text(
            'No document was parsed or sent to AI. This result comes from deterministic mock fixtures.',
          ),
        ],
      ),
    );
  }
}

void _noop() {}

class ApplicationDetailScreen extends ConsumerWidget {
  const ApplicationDetailScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(
      appControllerProvider.select(
        (s) => s.applications.where((a) => a.id == id).firstOrNull,
      ),
    );
    if (item == null) {
      return const DetailScaffold(
        title: 'Application',
        child: EmptyState(
          icon: Icons.delete_outline,
          title: 'Application removed',
          message: 'Return to Tracker to view current records.',
        ),
      );
    }
    return DetailScaffold(
      title: 'Application',
      actions: [
        PopupMenuButton<ApplicationStage>(
          tooltip: 'Move application stage',
          icon: const Icon(Icons.move_down),
          onSelected: (s) => ref
              .read(appControllerProvider.notifier)
              .updateApplication(item.copyWith(stage: s)),
          itemBuilder: (_) => ApplicationStage.values
              .map(
                (s) =>
                    PopupMenuItem(value: s, child: Text('Move to ${s.label}')),
              )
              .toList(),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(item.role, style: Theme.of(context).textTheme.displaySmall),
          Text(item.company, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text('${item.location} • ${item.stage.label}'),
          Text('Added ${shortDate(item.appliedAt)}'),
          if (item.followUpAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Follow up ${shortDate(item.followUpAt!)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          const SizedBox(height: 24),
          Text('Notes', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (item.notes.isEmpty)
            const Text('No notes yet.')
          else
            ...item.notes.indexed.map(
              (n) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notes),
                title: Text(n.$2),
                subtitle: Text('Note ${n.$1 + 1}'),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () async {
              final c = TextEditingController();
              final note = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add dated note'),
                  content: TextField(
                    controller: c,
                    autofocus: true,
                    minLines: 2,
                    maxLines: 5,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, c.text.trim()),
                      child: const Text('Add note'),
                    ),
                  ],
                ),
              );
              c.dispose();
              if (note != null && note.isNotEmpty) {
                ref
                    .read(appControllerProvider.notifier)
                    .updateApplication(
                      item.copyWith(
                        notes: [
                          ...item.notes,
                          '${shortDate(DateTime.now())}: $note',
                        ],
                      ),
                    );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add note'),
          ),
          const SizedBox(height: 26),
          FilledButton.tonal(
            onPressed: () => _editApplication(context, ref, item),
            child: const Text('Edit details'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              if (await confirmAction(
                context,
                title: 'Delete application?',
                message: 'This removes the application and its notes from local demo storage.',
              )) {
                ref.read(appControllerProvider.notifier).deleteApplication(id);
                if (context.mounted) context.go('/tracker');
              }
            },
            child: const Text('Delete application'),
          ),
        ],
      ),
    );
  }
}

Future<void> _editApplication(
  BuildContext context,
  WidgetRef ref,
  ApplicationRecord item,
) async {
  final company = TextEditingController(text: item.company);
  final role = TextEditingController(text: item.role);
  final location = TextEditingController(text: item.location);
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(sheet).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ref
                  .read(appControllerProvider.notifier)
                  .updateApplication(
                    item.copyWith(
                      company: company.text.trim(),
                      role: role.text.trim(),
                      location: location.text.trim(),
                    ),
                  );
              Navigator.pop(sheet);
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    ),
  );
  company.dispose();
  role.dispose();
  location.dispose();
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final name = TextEditingController(),
      headline = TextEditingController(),
      location = TextEditingController(),
      roles = TextEditingController();
  bool seeded = false;
  @override
  void dispose() {
    name.dispose();
    headline.dispose();
    location.dispose();
    roles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appControllerProvider.select((s) => s.profile));
    if (!seeded) {
      name.text = profile.name;
      headline.text = profile.headline;
      location.text = profile.location;
      roles.text = profile.targetRoles.join(', ');
      seeded = true;
    }
    return DetailScaffold(
      title: 'Profile & settings',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Demo profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: headline,
            decoration: const InputDecoration(labelText: 'Headline'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: location,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: roles,
            decoration: const InputDecoration(
              labelText: 'Target roles',
              helperText: 'Separate roles with commas',
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () {
              ref
                  .read(appControllerProvider.notifier)
                  .updateProfile(
                    profile.copyWith(
                      name: name.text.trim(),
                      headline: headline.text.trim(),
                      location: location.text.trim(),
                      targetRoles: roles.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo profile saved.')),
              );
            },
            child: const Text('Save profile'),
          ),
          const SizedBox(height: 28),
          Text('Appearance', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          SegmentedButton<AppTheme>(
            segments: AppTheme.values
                .map((t) => ButtonSegment(value: t, label: Text(t.label)))
                .toList(),
            selected: {profile.theme},
            onSelectionChanged: (v) => ref
                .read(appControllerProvider.notifier)
                .updateProfile(profile.copyWith(theme: v.first)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduce transparency'),
            subtitle: const Text('Makes glass navigation and controls solid'),
            value: profile.reduceTransparency,
            onChanged: (v) => ref
                .read(appControllerProvider.notifier)
                .updateProfile(profile.copyWith(reduceTransparency: v)),
          ),
          const SizedBox(height: 22),
          Text(
            'About this demo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Authentication, AI analysis, document parsing, external applications, and notifications are simulated or intentionally disconnected. Local preferences are demo storage, not secure document storage.',
          ),
          const SizedBox(height: 22),
          OutlinedButton(
            onPressed: () async {
              if (await confirmAction(
                context,
                title: 'Reset demo data?',
                message: 'This restores all seeded jobs, resumes, applications, matches, and settings.',
                confirmLabel: 'Reset',
              )) {
                await ref.read(appControllerProvider.notifier).reset();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo fixtures restored.')),
                  );
                }
              }
            },
            child: const Text('Reset demo data'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              ref.read(appControllerProvider.notifier).signOut();
              context.go('/entry');
            },
            child: const Text('Sign out of demo'),
          ),
        ],
      ),
    );
  }
}
