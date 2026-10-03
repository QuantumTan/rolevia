import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/services/job_text_cleaner.dart';
import 'package:rolevia/core/theme.dart';
import 'package:rolevia/core/widgets/job_description_view.dart';

void main() {
  testWidgets('long descriptions expand and collapse without losing text', (
    tester,
  ) async {
    final source = [
      'Responsibilities',
      for (var index = 1; index <= 12; index++)
        '- Responsibility $index has enough detail to wrap on a phone screen',
    ].join('\n');

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            child: JobDescriptionView(result: JobTextCleaner.clean(source)),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('job-description-collapsed')), findsOneWidget);
    expect(find.text('Show more'), findsOneWidget);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('job-description-expanded')), findsOneWidget);
    expect(find.textContaining('Responsibility 12'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('job-description-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('job-description-collapsed')), findsOneWidget);
  });

  testWidgets('truncated descriptions show an explicit warning', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.light),
        home: Scaffold(
          body: JobDescriptionView(
            result: JobTextCleaner.clean('Short provider snippet...See more'),
          ),
        ),
      ),
    );

    expect(
      find.text(
        'This looks cut off. Paste the full job description for a more accurate result.',
      ),
      findsOneWidget,
    );
  });
}
