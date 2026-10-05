import 'package:flutter/material.dart';

import '../models/models.dart';
import 'theme/tokens.dart';

export 'design/colors.dart';
export 'design/custom_icons.dart';
export 'design/icons.dart';
export 'design/motion.dart';
export 'design/radius.dart';
export 'design/spacing.dart';
export 'design/typography.dart';
export 'theme/theme_persistence.dart';
export 'theme/tokens.dart';

// Shared widgets
export 'widgets/app_button.dart';
export 'widgets/app_card.dart';
export 'widgets/app_scaffold.dart';
export 'widgets/bottom_sheet_scaffold.dart';
export 'widgets/chips.dart';
export 'widgets/company_avatar.dart';
export 'widgets/diff_span.dart';
export 'widgets/empty_state.dart';
export 'widgets/error_state.dart';
export 'widgets/floating_nav.dart';
export 'widgets/grid_background.dart';
export 'widgets/match_badge.dart';
export 'widgets/mono_text.dart';
export 'widgets/monoline_illustration.dart';
export 'widgets/offline_banner.dart';
export 'widgets/score_ring.dart';
export 'widgets/section_header.dart';
export 'widgets/segmented_control.dart';
export 'widgets/skeleton.dart';
export 'widgets/stat_tile.dart';
export 'widgets/tactile_card.dart';
export 'widgets/toast.dart';
export 'widgets/top_bar.dart';

// Backward compatibility widgets
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

/// Central theme factory:
/// - All ThemeData objects are cached static finals per (brightness x accent),
///   NEVER built inside build().
/// - Guaranteed zero jank theme switching within strict performance budget.
abstract final class AppThemeSingletons {
  // Precomputed static final instances for all 10 combinations (2 brightness x 5 accents)
  static final ThemeData lightOcean = _buildTheme(Brightness.light, accentColor: AppAccentColor.ocean);
  static final ThemeData lightEmerald = _buildTheme(Brightness.light, accentColor: AppAccentColor.emerald);
  static final ThemeData lightViolet = _buildTheme(Brightness.light, accentColor: AppAccentColor.violet);
  static final ThemeData lightCoral = _buildTheme(Brightness.light, accentColor: AppAccentColor.coral);
  static final ThemeData lightIndigo = _buildTheme(Brightness.light, accentColor: AppAccentColor.indigo);

  static final ThemeData darkOcean = _buildTheme(Brightness.dark, accentColor: AppAccentColor.ocean);
  static final ThemeData darkEmerald = _buildTheme(Brightness.dark, accentColor: AppAccentColor.emerald);
  static final ThemeData darkViolet = _buildTheme(Brightness.dark, accentColor: AppAccentColor.violet);
  static final ThemeData darkCoral = _buildTheme(Brightness.dark, accentColor: AppAccentColor.coral);
  static final ThemeData darkIndigo = _buildTheme(Brightness.dark, accentColor: AppAccentColor.indigo);

  // Cached table containing precomputed instances
  static final Map<String, ThemeData> _cache = {
    'light_false_ocean': lightOcean,
    'light_false_emerald': lightEmerald,
    'light_false_violet': lightViolet,
    'light_false_coral': lightCoral,
    'light_false_indigo': lightIndigo,
    'dark_false_ocean': darkOcean,
    'dark_false_emerald': darkEmerald,
    'dark_false_violet': darkViolet,
    'dark_false_coral': darkCoral,
    'dark_false_indigo': darkIndigo,
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

/// Resolves immutable static ThemeData singleton for the given parameters.
ThemeData appTheme(
  Brightness brightness, {
  bool reduceTransparency = false,
  AppAccentColor accentColor = AppAccentColor.ocean,
}) =>
    AppThemeSingletons.resolve(
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
    outlineVariant: colors.hairlineBorder,
  );

  final textTheme = AppTypography.createTextTheme(colors.labelPrimary);

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.platformFontFamily,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.background,
    textTheme: textTheme,
    extensions: [
      colors,
      SurfacePreferences(solid: reduceTransparency),
    ],
    dividerTheme: DividerThemeData(
      color: colors.hairlineBorder,
      thickness: AppRadius.hairline,
      space: 1.0,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.title.copyWith(
        color: colors.labelPrimary,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: colors.labelPrimary, size: 22),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(
          color: colors.hairlineBorder,
          width: AppRadius.hairline,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetRadius,
      ),
    ),
  );
}
