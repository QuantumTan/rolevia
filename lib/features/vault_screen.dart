import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/brand.dart';
import '../models/models.dart';
import '../shared/widgets.dart';
import '../state/app_state.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});
  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen>
    with AutomaticKeepAliveClientMixin {
  bool picking = false;
  @override
  bool get wantKeepAlive => true;
  Future<void> _pick() async {
    setState(() => picking = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'docx'],
      );
      if (!mounted) return;
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File selection canceled.')),
        );
        return;
      }
      final size = file.lengthSync() ?? await file.length() ?? 0;
      if (!mounted) return;
      if (size > Brand.maxResumeBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose a PDF or DOCX smaller than 10 MB.'),
          ),
        );
        return;
      }
      final ext = (file.extension ?? '').toUpperCase();
      if (ext != 'PDF' && ext != 'DOCX') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only PDF and DOCX files are supported.'),
          ),
        );
        return;
      }
      ref
          .read(appControllerProvider.notifier)
          .addResume(
            ResumeVersion(
              id: 'r${DateTime.now().microsecondsSinceEpoch}',
              title: file.name.replaceFirst(RegExp(r'\.[^.]+$'), ''),
              filename: file.name,
              fileType: ext,
              addedAt: DateTime.now(),
              isSample: false,
            ),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Resume metadata added. The file was not uploaded or parsed.',
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The file picker could not open. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

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
        empty: EmptyState(
          icon: Icons.description_outlined,
          title: 'No resumes in the vault',
          message: 'Add a PDF or DOCX. This demo stores metadata only.',
          action: FilledButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.add),
            label: const Text('Add resume'),
          ),
        ),
        normal: ListView(
          key: const PageStorageKey('vault-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 116),
          children: [
            PageTitle(
              'Vault',
              subtitle: 'Resume versions and sample previews',
              trailing: IconButton.filled(
                tooltip: 'Add resume',
                onPressed: picking ? null : _pick,
                icon: picking
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selected files stay on this device as metadata. Parsing and secure upload are not connected.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            if (state.resumes.isEmpty)
              EmptyState(
                icon: Icons.description_outlined,
                title: 'No resumes yet',
                message: 'Add a PDF or DOCX to begin.',
                action: FilledButton(
                  onPressed: _pick,
                  child: const Text('Choose a file'),
                ),
              )
            else
              ...state.resumes.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ResumeCard(
                    resume: r,
                    isDefault: r.id == state.defaultResumeId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ResumeCard extends ConsumerWidget {
  const ResumeCard({super.key, required this.resume, required this.isDefault});
  final ResumeVersion resume;
  final bool isDefault;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/resumes/${resume.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                resume.fileType,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          resume.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 7),
                        const Chip(
                          label: Text('Default'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    resume.filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Added ${shortDate(resume.addedAt)}${resume.isSample ? '  •  Sample preview' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Resume actions',
              onSelected: (v) => _action(context, ref, v),
              itemBuilder: (_) => [
                if (!isDefault)
                  const PopupMenuItem(
                    value: 'default',
                    child: Text('Make default'),
                  ),
                const PopupMenuItem(value: 'rename', child: Text('Rename')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  Future<void> _action(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final controller = ref.read(appControllerProvider.notifier);
    if (value == 'default') controller.setDefaultResume(resume.id);
    if (value == 'rename') {
      final text = TextEditingController(text: resume.title);
      final title = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rename resume'),
          content: TextField(
            controller: text,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, text.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      text.dispose();
      if (!context.mounted) return;
      if (title != null && title.isNotEmpty) {
        controller.renameResume(resume.id, title);
      }
    }
    if (value == 'delete' &&
        await confirmAction(
          context,
          title: 'Delete resume?',
          message: 'The original file is not stored. This removes its demo metadata and updates the default selection.',
        )) {
      controller.deleteResume(resume.id);
    }
  }
}
