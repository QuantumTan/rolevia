import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/theme.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final cupertino = FontLoader('CupertinoIcons')
      ..addFont(
        rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      );
    await cupertino.load();
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('ScoreRing, MatchBadge, CompanyAvatar golden in $brightness', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 700));
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.binding.setSurfaceSize(null);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(brightness),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ScoreRing
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ScoreRing(85, size: 72),
                        ScoreRing(62, size: 72),
                        ScoreRing(35, size: 72),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // MatchBadge
                    const Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        MatchBadge(85),
                        MatchBadge(62),
                        MatchBadge(45),
                        MatchBadge(85, compact: true),
                        MatchBadge(85, showVerdict: true),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // CompanyAvatar
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CompanyAvatar('Northwind Digital', size: 48),
                        CompanyAvatar('Kapitan Tech', size: 48),
                        CompanyAvatar('Bayani Connect', size: 48),
                        CompanyAvatar('', size: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Settle animations
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('core_widgets_${brightness.name}.png'),
      );
    });
  }
}
