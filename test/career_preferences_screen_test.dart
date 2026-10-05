import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/features/career_preferences_screen.dart';


void main() {
  testWidgets('CareerPreferencesScreen renders and selects target roles', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CareerPreferencesScreen(isOnboarding: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personalize Your Discovery'), findsOneWidget);
    expect(find.text('Target Roles'), findsOneWidget);
    expect(find.text('Preferred Work Mode'), findsOneWidget);
    expect(find.text('Preferred Location'), findsOneWidget);

    // Tap on a role chip
    final frontendFinder = find.text('Frontend Developer');
    expect(frontendFinder, findsOneWidget);
    await tester.tap(frontendFinder);
    await tester.pumpAndSettle();

    // Verify Save button is visible
    expect(find.text('Save & Personalize Feed'), findsOneWidget);
  });
}
