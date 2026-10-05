import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/theme.dart';
import 'package:rolevia/data/workspace_repository.dart';
import 'package:rolevia/features/detail_screens.dart';
import 'package:rolevia/models/models.dart';
import 'package:rolevia/state/app_state.dart';

import 'fixtures.dart';

class _CustomizationTestRepository implements WorkspaceRepository {
  _CustomizationTestRepository(this.value);
  Map<String, dynamic>? value;

  @override
  Future<Map<String, dynamic>?> read() async => value;

  @override
  Future<void> write(Map<String, dynamic> data) async {
    value = data;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

void main() {
  group('ProfileSettings Customization Serialization', () {
    test('defaults are sane and backward-compatible', () {
      const profile = ProfileSettings();
      expect(profile.bio, isEmpty);
      expect(profile.headline, isEmpty);
      expect(profile.primarySkills, isEmpty);
      expect(profile.experienceLevel, ExperienceLevel.mid);
      expect(profile.expectedSalary, isNull);
      expect(profile.accentColor, AppAccentColor.ocean);
      expect(profile.hapticFeedback, isTrue);
      expect(profile.defaultTab, 'match');
      expect(profile.theme, AppTheme.system);
    });

    test('serializes and deserializes all customization fields', () {
      final original = const ProfileSettings().copyWith(
        name: 'Jordan Santos',
        headline: 'Lead Mobile Architect',
        bio: 'Designing responsive and accessible cross-platform apps.',
        experienceLevel: ExperienceLevel.lead,
        expectedSalary: 120000,
        primarySkills: ['Flutter', 'Dart', 'GraphQL', 'Firebase'],
        accentColor: AppAccentColor.ocean,
        hapticFeedback: false,
        defaultTab: 'discover',
        theme: AppTheme.dark,
        reduceTransparency: true,
      );

      final json = original.toJson();
      final restored = ProfileSettings.fromJson(json);

      expect(restored.name, 'Jordan Santos');
      expect(restored.headline, 'Lead Mobile Architect');
      expect(restored.bio, 'Designing responsive and accessible cross-platform apps.');
      expect(restored.experienceLevel, ExperienceLevel.lead);
      expect(restored.expectedSalary, 120000);
      expect(restored.primarySkills, ['Flutter', 'Dart', 'GraphQL', 'Firebase']);
      expect(restored.accentColor, AppAccentColor.ocean);
      expect(restored.hapticFeedback, isFalse);
      expect(restored.defaultTab, 'discover');
      expect(restored.theme, AppTheme.dark);
      expect(restored.reduceTransparency, isTrue);
    });
  });

  group('Accent Theme Tinting', () {
    test('AppColors.withAccent applies distinct colors for all accents', () {
      final baseLight = AppColors.light;
      for (final accent in AppAccentColor.values) {
        final colored = AppColors.withAccent(baseLight, accent);
        if (accent == AppAccentColor.ocean) {
          expect(colored.primary, baseLight.primary);
        } else {
          expect(colored.primary, isNot(baseLight.primary));
        }
      }
    });

    test('appTheme receives accentColor and modifies color scheme', () {
      final indigoTheme = appTheme(Brightness.light, accentColor: AppAccentColor.indigo);
      final emeraldTheme = appTheme(Brightness.light, accentColor: AppAccentColor.emerald);

      expect(indigoTheme.colorScheme.primary, const Color(0xFF4F46E5));
      expect(emeraldTheme.colorScheme.primary, const Color(0xFF10B981));
    });
  });

  group('Haptic Feedback Control', () {
    test('AppMotion.hapticsEnabled controls tactile trigger', () {
      AppMotion.hapticsEnabled = false;
      AppMotion.selectionHaptic();
      AppMotion.lightHaptic();
      AppMotion.mediumHaptic();

      AppMotion.hapticsEnabled = true;
      AppMotion.selectionHaptic();
      expect(AppMotion.hapticsEnabled, isTrue);
    });
  });

  group('ProfileScreen Customization UI', () {
    testWidgets('renders professional profile, seniority chips, and theme options', (
      tester,
    ) async {
      final snapshot = fixtureSnapshot()
        ..addAll({'onboardingComplete': true, 'authenticated': true});
      final profile = const ProfileSettings(
        name: 'Jordan',
        headline: 'Software Engineer',
        bio: 'Tech enthusiast',
        primarySkills: ['Flutter', 'Dart'],
        expectedSalary: 75000,
        experienceLevel: ExperienceLevel.senior,
        accentColor: AppAccentColor.emerald,
      );
      snapshot['profile'] = profile.toJson();
      final repo = _CustomizationTestRepository(snapshot);

      await tester.binding.setSurfaceSize(const Size(800, 2000));
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.binding.setSurfaceSize(null);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            theme: appTheme(Brightness.light, accentColor: profile.accentColor),
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify name, headline, bio
      expect(find.text('Jordan'), findsOneWidget);
      expect(find.text('Software Engineer'), findsOneWidget);
      expect(find.text('Tech enthusiast'), findsOneWidget);

      // Verify Professional Profile section
      expect(find.text('Professional Profile'), findsOneWidget);
      expect(find.text('Seniority & Experience'), findsOneWidget);
      expect(find.text('Senior'), findsOneWidget);

      // Verify Desired Monthly Salary
      expect(find.text('PHP 75000 / month'), findsOneWidget);

      // Verify Skills
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Add skill'), findsOneWidget);

      // Verify Appearance & Accent Tint
      expect(find.text('Appearance & Theme'), findsOneWidget);
      expect(find.text('Signature Accent Tint'), findsOneWidget);
      expect(find.text('Emerald'), findsOneWidget);
      expect(find.text('Ocean Blue'), findsOneWidget);
      expect(find.text('Sunset Coral'), findsOneWidget);

      // Verify System & Experience section
      expect(find.text('System & Experience'), findsOneWidget);
      expect(find.text('Haptic feedback'), findsOneWidget);
      expect(find.text('Default Start Screen'), findsOneWidget);
    });
  });
}
