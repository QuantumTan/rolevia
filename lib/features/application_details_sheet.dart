import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_dialog.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/adaptive_text_field.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/company_avatar.dart';
import '../core/widgets/match_badge.dart';
import '../models/models.dart';
import '../state/app_state.dart';

Future<void> showApplicationDetailsSheet(
  BuildContext context,
  ApplicationRecord record,
) async {
  await showAdaptiveSheet<void>(
    context: context,
    title: 'Application details',
    headerBuilder: (_, close) =>
        _ApplicationHeader(record: record, close: close),
    builder: (_) => ApplicationDetailsBody(record: record),
  );
}

class _ApplicationHeader extends StatelessWidget {
  const _ApplicationHeader({required this.record, required this.close});
  final ApplicationRecord record;
  final Widget close;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CompanyAvatar(record.company, size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.role,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title2.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${record.company} · ${record.location}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.footnote.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ],
          ),
        ),
        close,
      ],
    );
  }
}

/// Owns the field until the route's exit animation actually unmounts it.
class ApplicationDetailsBody extends ConsumerStatefulWidget {
  const ApplicationDetailsBody({super.key, required this.record});
  final ApplicationRecord record;
  @override
  ConsumerState<ApplicationDetailsBody> createState() =>
      _ApplicationDetailsBodyState();
}

class _ApplicationDetailsBodyState
    extends ConsumerState<ApplicationDetailsBody> {
  late final TextEditingController _notes;
  late final AppController _app;
  final _notesFocus = FocusNode();
  final _notesKey = GlobalKey();
  Timer? _debounce;
  Timer? _savedTimer;
  bool _dirty = false;
  bool _saved = false;
  bool _deleted = false;
  bool _revealing = false;
  bool _revealAgain = false;
  double _keyboardInset = 0;

  @override
  void initState() {
    super.initState();
    _app = ref.read(appControllerProvider.notifier);
    _notes = TextEditingController(text: widget.record.notes.join('\n'));
    _notesFocus.addListener(_focusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    if (_keyboardInset != inset) {
      _keyboardInset = inset;
      if (_notesFocus.hasFocus && inset > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _revealNotes());
      }
    }
  }

  void _focusChanged() {
    if (_notesFocus.hasFocus) _revealNotes();
  }

  Future<void> _revealNotes() async {
    if (!mounted || !_notesFocus.hasFocus) return;
    if (_revealing) {
      _revealAgain = true;
      return;
    }
    _revealing = true;
    final scope = AdaptiveSheetScope.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    await scope.expand();
    if (mounted && _notesFocus.hasFocus && _notesKey.currentContext != null) {
      await Scrollable.ensureVisible(
        _notesKey.currentContext!,
        alignment: 1,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    _revealing = false;
    if (_revealAgain) {
      _revealAgain = false;
      _revealNotes();
    }
  }

  ApplicationRecord? get _record => ref
      .read(appControllerProvider)
      .applications
      .where((item) => item.id == widget.record.id)
      .firstOrNull;

  void _flushNotes({bool feedback = false}) {
    _debounce?.cancel();
    if (!_dirty || _deleted) return;
    final record = _record;
    if (record == null) return;
    final text = _notes.text.trim();
    _dirty = false;
    _app.updateApplication(
      record.copyWith(notes: text.isEmpty ? const [] : text.split('\n')),
    );
    if (feedback && mounted) {
      setState(() => _saved = true);
      _savedTimer?.cancel();
      _savedTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _saved = false);
      });
    }
  }

  void _notesChanged(String value) {
    _dirty = true;
    _savedTimer?.cancel();
    if (_saved) setState(() => _saved = false);
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _flushNotes(feedback: true),
    );
  }

  Future<void> _changeDate(ApplicationRecord record) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: record.appliedAt,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (!mounted || date == null) return;
    final current = _record;
    if (current != null) {
      _app.updateApplication(current.copyWith(appliedAt: date));
    }
  }

  Future<void> _openLink(Uri link) async {
    try {
      if (await launchUrl(link, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // A missing browser handler should leave the application sheet intact.
    }
    if (mounted) showGlassToast(context, 'Could not open the job link');
  }

  Future<void> _delete() async {
    final confirmed = await showAdaptiveConfirmDialog(
      context,
      title: 'Delete this application?',
      message: "This can't be undone.",
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );
    if (!mounted || !confirmed) return;
    _deleted = true;
    _debounce?.cancel();
    _app.deleteApplication(widget.record.id);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _savedTimer?.cancel();
    _notesFocus.removeListener(_focusChanged);
    _notesFocus.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final record =
        state.applications.where((a) => a.id == widget.record.id).firstOrNull ??
        widget.record;
    final analyses =
        record.jobId == null
              ? <MatchResult>[]
              : state.matches.where((m) => m.jobId == record.jobId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final analysis = analyses.firstOrNull;
    final badgeScore = int.tryParse(
      RegExp(r'^(\d{1,3})%').firstMatch(record.matchBadge ?? '')?.group(1) ??
          '',
    );
    final link = Uri.tryParse(record.link);
    final hasLink =
        link != null &&
        ['https', 'http'].contains(link.scheme) &&
        link.host.isNotEmpty;
    final colors = AppColors.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _flushNotes();
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: badgeScore != null
                      ? MatchBadge(badgeScore)
                      : Text(
                          record.matchBadge ?? 'Not analyzed',
                          style: AppTypography.footnote.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                ),
                TextButton(
                  onPressed: analysis == null
                      ? null
                      : () {
                          _flushNotes();
                          final router = GoRouter.of(context);
                          Navigator.pop(context);
                          router.push('/matches/${analysis.id}');
                        },
                  child: const Text('View analysis'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Status',
              style: AppTypography.headline.copyWith(
                color: colors.labelPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              key: const ValueKey('application-status-control'),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final stage in ApplicationStage.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        shape: const StadiumBorder(),
                        label: Text(stage.label),
                        selected: stage == record.stage,
                        selectedColor: colors.primary,
                        labelStyle: AppTypography.footnote.copyWith(
                          color: stage == record.stage
                              ? Colors.white
                              : colors.labelPrimary,
                        ),
                        checkmarkColor: Colors.white,
                        onSelected: (_) {
                          AppMotion.selectionHaptic();
                          final current = _record;
                          if (current != null) {
                            _app.updateApplication(
                              current.copyWith(stage: stage),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AdaptiveCard(
              padding: const EdgeInsets.all(16),
              color: colors.elevatedSurface,
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Applied date',
                    value: _date(record.appliedAt),
                    onTap: () => _changeDate(record),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Resume used',
                    value: analysis?.resumeTitle ?? 'Not recorded',
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Job link',
                    value: hasLink
                        ? link.host.replaceFirst(RegExp(r'^www\.'), '')
                        : 'Not recorded',
                    onTap: hasLink ? () => _openLink(link) : null,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Location', value: record.location),
                ],
              ),
            ),
            if (analysis != null) ...[
              const SizedBox(height: 8),
              Text(
                'Resume from the latest saved analysis',
                style: AppTypography.caption.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Column(
              key: _notesKey,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notes',
                      style: AppTypography.headline.copyWith(
                        color: colors.labelPrimary,
                      ),
                    ),
                    Semantics(
                      liveRegion: true,
                      child: AnimatedOpacity(
                        opacity: _saved ? 1 : 0,
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        child: ExcludeSemantics(
                          excluding: !_saved,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: colors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Saved',
                                key: const ValueKey('notes-saved'),
                                style: AppTypography.footnote.copyWith(
                                  color: colors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AdaptiveTextField(
                  key: const ValueKey('application-notes'),
                  controller: _notes,
                  focusNode: _notesFocus,
                  hintText: 'Add interview details or a follow-up reminder',
                  minLines: 4,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  onChanged: _notesChanged,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(
                foregroundColor: colors.error,
                alignment: Alignment.centerLeft,
                minimumSize: const Size(44, 44),
              ),
              child: const Text('Delete application'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.footnote.copyWith(
              color: colors.labelSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.callout.copyWith(
              color: onTap == null ? colors.labelPrimary : colors.accent,
            ),
          ),
        ),
      ],
    );
    return onTap == null
        ? row
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: row,
            ),
          );
  }
}

String _date(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}
