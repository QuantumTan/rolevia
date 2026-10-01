import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/brand.dart';
import '../data/fixtures.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});
  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen>
    with AutomaticKeepAliveClientMixin {
  bool pastedMode = false, analyzing = false;
  int step = 0;
  final pasted = TextEditingController();
  String? error;
  @override
  bool get wantKeepAlive => true;
  @override
  void dispose() {
    pasted.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final state = ref.read(appControllerProvider);
    final message = validateMatch(
      resumeId: state.selectedMatchResumeId ?? state.defaultResumeId,
      jobId: state.selectedMatchJobId,
      pasted: pasted.text,
      pastedMode: pastedMode,
    );
    if (message != null) {
      setState(() => error = message);
      return;
    }
    setState(() {
      analyzing = true;
      error = null;
      step = 0;
    });
    for (var i = 0; i < 3; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      setState(() => step = i + 1);
    }
    final result = ref
        .read(appControllerProvider.notifier)
        .analyze(
          resumeId: state.selectedMatchResumeId ?? state.defaultResumeId!,
          jobId: pastedMode ? null : state.selectedMatchJobId,
          pasted: pasted.text,
        );
    if (mounted) {
      setState(() => analyzing = false);
      context.push('/matches/${result.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(appControllerProvider);
    final resumeId = state.selectedMatchResumeId ?? state.defaultResumeId;
    return SafeArea(
      bottom: false,
      child: ScenarioState(
        scenario: state.scenario,
        onRetry: () => ref
            .read(appControllerProvider.notifier)
            .setScenario(DemoScenario.normal),
        normal: ListView(
          key: const PageStorageKey('match-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 116),
          children: [
            PageTitle(
              Brand.appName,
              subtitle: 'Compare inputs with deterministic demo fixtures',
              trailing: Semantics(
                label: 'Open profile and settings',
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    child: Text(
                      state.profile.name.isEmpty
                          ? '?'
                          : state.profile.name[0].toUpperCase(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text('1. Resume', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            if (state.resumes.isEmpty)
              EmptyState(
                icon: Icons.description_outlined,
                title: 'A resume is required',
                message: 'Add resume metadata in Vault, then return here.',
                action: FilledButton(
                  onPressed: () => context.go('/vault'),
                  child: const Text('Open Vault'),
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: resumeId,
                decoration: const InputDecoration(labelText: 'Resume version'),
                items: state.resumes
                    .map(
                      (r) =>
                          DropdownMenuItem(value: r.id, child: Text(r.title)),
                    )
                    .toList(),
                onChanged: (v) => ref
                    .read(appControllerProvider.notifier)
                    .selectMatchInputs(resumeId: v),
              ),
            const SizedBox(height: 24),
            Text('2. Role', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Saved job'),
                  icon: Icon(Icons.work_outline),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Paste text'),
                  icon: Icon(Icons.content_paste),
                ),
              ],
              selected: {pastedMode},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setState(() {
                pastedMode = v.first;
                error = null;
              }),
            ),
            const SizedBox(height: 12),
            if (pastedMode)
              TextField(
                controller: pasted,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Job description',
                  hintText:
                      'Paste the responsibilities and qualifications here',
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: state.selectedMatchJobId,
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
                onChanged: (v) => ref
                    .read(appControllerProvider.notifier)
                    .selectMatchInputs(jobId: v),
              ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (analyzing)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const LinearProgressIndicator(),
                      const SizedBox(height: 14),
                      Text(
                        [
                          'Preparing inputs...',
                          'Comparing skills...',
                          'Assembling guidance...',
                          'Finishing demo result...',
                        ][step],
                      ),
                    ],
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: state.resumes.isEmpty ? null : _analyze,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Analyze demo match'),
              ),
            const SizedBox(height: 14),
            Text(
              'Demo analysis only. No document is parsed or sent to AI. Scores are illustrative guidance, not hiring probabilities or verified ATS measurements.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
