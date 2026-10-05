// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/design/colors.dart';

void main() {
  test('check all app colors', () {
    double ratio(Color a, Color b) {
      final first = a.computeLuminance();
      final second = b.computeLuminance();
      return first > second
          ? (first + 0.05) / (second + 0.05)
          : (second + 0.05) / (first + 0.05);
    }

    final palettes = {
      'light': AppColors.light,
      'dark': AppColors.dark,
      'lightHighContrast': AppColors.lightHighContrast,
      'darkHighContrast': AppColors.darkHighContrast,
    };

    palettes.forEach((name, colors) {
      for (final surface in [colors.surface, colors.elevatedSurface]) {
        print('$name surface: $surface');
        print('  labelPrimary (${colors.labelPrimary}): ${ratio(colors.labelPrimary, surface)}');
        print('  labelSecondary (${colors.labelSecondary}): ${ratio(colors.labelSecondary, surface)}');
        print('  accent (${colors.accent}): ${ratio(colors.accent, surface)}');
      }
      print('  white on primary (${colors.primary}): ${ratio(Colors.white, colors.primary)}');
    });
  });
}
