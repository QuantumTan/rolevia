import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import 'theme/tokens.dart';

export 'design/colors.dart';
export 'design/icons.dart';
export 'design/motion.dart';
export 'design/radius.dart';
export 'design/spacing.dart';
export 'design/typography.dart';
export 'widgets/adaptive_button.dart';
export 'widgets/adaptive_card.dart';
export 'widgets/adaptive_dialog.dart';
export 'widgets/adaptive_navigation_bar.dart';
export 'widgets/adaptive_scaffold.dart';
export 'widgets/adaptive_sheet.dart';
export 'widgets/adaptive_switch.dart';
export 'widgets/adaptive_text_field.dart';
export 'widgets/liquid_glass.dart';
export 'widgets/pressable.dart';
export 'widgets/skeleton.dart';

/// Central theme factory combining Apple Human Interface Guidelines
/// and refined Material 3 platform adaptation.
abstract final class AppThemeSingletons {
  static final ThemeData light = _buildTheme(Brightness.light);
  static final ThemeData dark = _buildTheme(Brightness.dark);

  static final Map<String, ThemeData> _cache = {
    'light_false_ocean': light,
    'dark_false_ocean': dark,
  };

  static ThemeData resolve(
    Brightness brightness, {
    bool reduceTransparency = false,
    AppAccentColor accentColor = AppAccentColor.ocean,
  }) {
    final key = '${brightness.name}_${reduceTransparency}_${accentColor.name}';
    return _cache.putIfAbsent(
      key,
      () => _buildTheme(
        brightness,
        reduceTransparency: reduceTransparency,
        accentColor: accentColor,
      ),
    );
  }
}

/// Central theme factory using static immutable singletons
/// to guarantee zero-jank theme switching within strict 8-16ms budget.
ThemeData appTheme(
  Brightness brightness, {
  bool reduceTransparency = false,
  AppAccentColor accentColor = AppAccentColor.ocean,
}) => AppThemeSingletons.resolve(
  brightness,
  reduceTransparency: reduceTransparency,
  accentColor: accentColor,
);

ThemeData _buildTheme(
  Brightness brightness, {
  bool reduceTransparency = false,
  AppAccentColor accentColor = AppAccentColor.ocean,
}) {
  final isDark = brightness == Brightness.dark;
  final baseColors = isDark ? AppColors.dark : AppColors.light;
  final colors = AppColors.withAccent(baseColors, accentColor);

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: colors.primary,
    onPrimary: isDark ? colors.background : Colors.white,
    secondary: colors.secondary,
    onSecondary: Colors.white,
    error: colors.error,
    onError: Colors.white,
    surface: colors.surface,
    onSurface: colors.labelPrimary,
    onSurfaceVariant: colors.labelSecondary,
    outline: colors.separator,
    outlineVariant: colors.hairlineBorder,
  );

  final textTheme = AppTypography.createTextTheme(colors.labelPrimary);

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.background,
    textTheme: textTheme,
    extensions: [
      colors,
      SurfacePreferences(solid: reduceTransparency),
    ],
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: colors.labelPrimary,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: colors.accent),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.hairlineBorder, width: 1.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.hairlineBorder, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.hairlineBorder, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 48),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 48),
        foregroundColor: colors.labelPrimary,
        side: BorderSide(color: colors.hairlineBorder, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: colors.hairlineBorder, width: 1.0),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.paleIndigoSurface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.labelPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: colors.hairlineBorder, width: 1.0),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.elevatedSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colors.hairlineBorder, width: 1.0),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: colors.primary.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 11,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: s.contains(WidgetState.selected)
              ? colors.primary
              : colors.labelSecondary,
        ),
      ),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: colors.accent,
      barBackgroundColor: colors.surface,
      scaffoldBackgroundColor: colors.background,
    ),
  );
}
