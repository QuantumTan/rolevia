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
ThemeData appTheme(
  Brightness brightness, {
  bool reduceTransparency = false,
  AppAccentColor accentColor = AppAccentColor.indigo,
}) {
  final isDark = brightness == Brightness.dark;
  var colors = isDark ? AppColors.dark : AppColors.light;
  if (accentColor != AppAccentColor.indigo) {
    colors = AppColors.withAccent(colors, accentColor);
  }

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: colors.accent,
    onPrimary: isDark ? colors.background : Colors.white,
    secondary: colors.secondary,
    onSecondary: Colors.white,
    error: colors.error,
    onError: Colors.white,
    surface: colors.surface,
    onSurface: colors.labelPrimary,
    onSurfaceVariant: colors.labelSecondary,
    outline: colors.separator,
    outlineVariant: colors.separator.withValues(alpha: 0.5),
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
    splashFactory: NoSplash.splashFactory, // Cupertino-like calm interaction
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
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide.none,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB),
          width: 0.8,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB),
          width: 0.8,
        ),
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
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 48),
        foregroundColor: colors.labelPrimary,
        side: BorderSide(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFD1D5DB),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
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
          BorderSide(
            color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFF2F2F7),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.labelPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide.none,
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
      barBackgroundColor: colors.glassSurface,
      scaffoldBackgroundColor: colors.background,
    ),
  );
}
