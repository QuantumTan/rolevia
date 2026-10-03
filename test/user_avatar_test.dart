import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/widgets/user_avatar.dart';
import 'package:rolevia/models/models.dart';

void main() {
  group('ProfileSettings avatar and initial resolution', () {
    test('initialLetter derives first letter from non-empty name', () {
      const profile = ProfileSettings(name: 'Quantum Tan');
      expect(profile.initialLetter, equals('Q'));
    });

    test('initialLetter falls back to email initial when name is blank', () {
      const profile = ProfileSettings(name: '', email: 'developer@example.com');
      expect(profile.initialLetter, equals('D'));
    });

    test('initialLetter defaults to U when both name and email are blank', () {
      const profile = ProfileSettings(name: '', email: '');
      expect(profile.initialLetter, equals('U'));
    });

    test('displayName returns name when present', () {
      const profile = ProfileSettings(name: 'Sarah Connor', email: 's@example.com');
      expect(profile.displayName, equals('Sarah Connor'));
    });

    test('displayName formats email handle when name is blank', () {
      const profile = ProfileSettings(name: '', email: 'quantumtan@example.com');
      expect(profile.displayName, equals('Quantumtan'));
    });

    test('displayName falls back to Job Seeker when both are blank', () {
      const profile = ProfileSettings(name: '', email: '');
      expect(profile.displayName, equals('Job Seeker'));
    });
  });

  group('UserAvatar Widget', () {
    testWidgets('renders fallback letter text when no avatarUrl is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              initial: 'Q',
              size: 40,
            ),
          ),
        ),
      );

      expect(find.text('Q'), findsOneWidget);
    });

    testWidgets('renders camera edit badge when showEditBadge is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              initial: 'T',
              size: 56,
              showEditBadge: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    });

    testWidgets('triggers onTap callback when pressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              initial: 'T',
              size: 40,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UserAvatar));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
