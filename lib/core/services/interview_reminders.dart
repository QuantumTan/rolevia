import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';

/// Reschedules foreground reminders whenever a saved appointment changes.
final interviewRemindersProvider = StreamProvider<ApplicationRecord>((ref) {
  final records = ref.watch(
    appControllerProvider.select((s) => s.applications),
  );
  final output = StreamController<ApplicationRecord>();
  final timers = <Timer>[];
  final now = DateTime.now();
  for (final record in records) {
    final interview = record.interviewAt;
    if (interview == null ||
        !interview.isAfter(now) ||
        record.stage == ApplicationStage.rejected) {
      continue;
    }
    final due = interview.subtract(const Duration(minutes: 30));
    timers.add(
      Timer(due.isAfter(now) ? due.difference(now) : Duration.zero, () {
        if (!output.isClosed) output.add(record);
      }),
    );
  }
  ref.onDispose(() {
    for (final timer in timers) {
      timer.cancel();
    }
    output.close();
  });
  return output.stream;
});
