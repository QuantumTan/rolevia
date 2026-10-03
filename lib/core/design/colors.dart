import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Semantic color tokens following modern Apple Human Interface Guidelines,
/// Liquid Glass principles, and Material 3 Expressive styling.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.secondaryBackground,
    required this.surface,
    required this.elevatedSurface,
    required this.paleIndigoSurface,
    required this.glassSurface,
    required this.glassBorder,
    required this.glassHighlight,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.labelPrimary,
    required this.labelSecondary,
    required this.labelTertiary,
    required this.separator,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  final Color background;
  final Color secondaryBackground;
  final Color surface;
  final Color elevatedSurface;
  final Color paleIndigoSurface;
  final Color glassSurface;
  final Color glassBorder;
  final Color glassHighlight;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color labelPrimary;
  final Color labelSecondary;
  final Color labelTertiary;
  final Color separator;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  static const light = AppColors(
    background: Color(0xFFF5F5F7),
    secondaryBackground: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    elevatedSurface: Color(0xFFFFFFFF),
    paleIndigoSurface: Color(0xFFE8EAF6),
    glassSurface: Color(0xB3FFFFFF), // 70% white
    glassBorder: Color(0x99FFFFFF), // 60% inner stroke
    glassHighlight: Color(0x99FFFFFF),
    primary: Color(0xFF3F51B5), // Indigo
    secondary: Color(0xFF5C6BC0),
    accent: Color(0xFF3F51B5),
    labelPrimary: Color(0xFF1C1C1E),
    labelSecondary: Color(0xFF6B6B70),
    labelTertiary: Color(0xFF6B6B70),
    separator: Color(0xFFE5E5EA),
    success: Color(0xFF2E7D32),
    warning: Color(0xFF8A5C13),
    error: Color(0xFFC62828),
    info: Color(0xFF1976D2),
  );

  static const dark = AppColors(
    background: Color(0xFF000000),
    secondaryBackground: Color(0xFF1C1C1E),
    surface: Color(0xFF1C1C1E),
    elevatedSurface: Color(0xFF2C2C2E),
    paleIndigoSurface: Color(0xFF202230),
    glassSurface: Color(0x991C1C1E), // 60% #1C1C1E
    glassBorder: Color(0x1FFFFFFF), // 12% white inner stroke
    glassHighlight: Color(0x2EFFFFFF),
    primary: Color(0xFF3F51B5), // Action fill remains #3F51B5
    secondary: Color(0xFF7986CB),
    accent: Color(0xFFA5B0F5),
    labelPrimary: Color(0xFFFFFFFF),
    labelSecondary: Color(0xFFA1A1A6),
    labelTertiary: Color(0xFFA1A1A6),
    separator: Color(0xFF2C2C2E),
    success: Color(0xFF9ED5AB),
    warning: Color(0xFFE8C578),
    error: Color(0xFFF3A6A1),
    info: Color(0xFF7986CB),
  );

  static const lightHighContrast = AppColors(
    background: Color(0xFFE5E5EA),
    secondaryBackground: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    elevatedSurface: Color(0xFFFFFFFF),
    paleIndigoSurface: Color(0xFFD8DBEA),
    glassSurface: Color(0xFFFFFFFF),
    glassBorder: Color(0xFF000000),
    glassHighlight: Colors.transparent,
    primary: Color(0xFF283593),
    secondary: Color(0xFF303F9F),
    accent: Color(0xFF283593),
    labelPrimary: Color(0xFF000000),
    labelSecondary: Color(0xFF374151),
    labelTertiary: Color(0xFF4B5563),
    separator: Color(0xFF9CA3AF),
    success: Color(0xFF1B5E20),
    warning: Color(0xFF6D4C00),
    error: Color(0xFFB71C1C),
    info: Color(0xFF0D47A1),
  );

  static const darkHighContrast = AppColors(
    background: Color(0xFF000000),
    secondaryBackground: Color(0xFF121214),
    surface: Color(0xFF121214),
    elevatedSurface: Color(0xFF1E1E22),
    paleIndigoSurface: Color(0xFF252636),
    glassSurface: Color(0xFF121214),
    glassBorder: Color(0xFFFFFFFF),
    glassHighlight: Colors.transparent,
    primary: Color(0xFF283593),
    secondary: Color(0xFFC5CAE9),
    accent: Color(0xFF9FA8DA),
    labelPrimary: Color(0xFFFFFFFF),
    labelSecondary: Color(0xFFD1D5DB),
    labelTertiary: Color(0xFF9CA3AF),
    separator: Color(0xFF52525B),
    success: Color(0xFFA5D6A7),
    warning: Color(0xFFFFE082),
    error: Color(0xFFEF9A9A),
    info: Color(0xFF90CAF9),
  );

  static AppColors of(BuildContext context) {
    if (MediaQuery.highContrastOf(context)) {
      return Theme.of(context).brightness == Brightness.dark
          ? darkHighContrast
          : lightHighContrast;
    }
    final theme = Theme.of(context).extension<AppColors>();
    if (theme != null) return theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighContrast = MediaQuery.highContrastOf(context);
    if (isHighContrast) {
      return isDark ? darkHighContrast : lightHighContrast;
    }
    return isDark ? dark : light;
  }

  static AppColors withAccent(AppColors base, AppAccentColor accent) {
    final isDark = base.background == dark.background ||
        base.background == darkHighContrast.background;
    return switch (accent) {
      AppAccentColor.ocean => base.copyWith(
        primary: const Color(0xFF0284C7),
        accent: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
        paleIndigoSurface: isDark ? const Color(0xFF0C2D48) : const Color(0xFFE0F2FE),
      ) as AppColors,
      AppAccentColor.emerald => base.copyWith(
        primary: const Color(0xFF059669),
        accent: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
        paleIndigoSurface: isDark ? const Color(0xFF063726) : const Color(0xFFD1FAE5),
      ) as AppColors,
      AppAccentColor.violet => base.copyWith(
        primary: const Color(0xFF7C3AED),
        accent: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
        paleIndigoSurface: isDark ? const Color(0xFF281845) : const Color(0xFFEDE9FE),
      ) as AppColors,
      AppAccentColor.coral => base.copyWith(
        primary: const Color(0xFFE11D48),
        accent: isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
        paleIndigoSurface: isDark ? const Color(0xFF431219) : const Color(0xFFFFE4E6),
      ) as AppColors,
      AppAccentColor.indigo => base,
    };
  }

  @override
  ThemeExtension<AppColors> copyWith({
    Color? background,
    Color? secondaryBackground,
    Color? surface,
    Color? elevatedSurface,
    Color? paleIndigoSurface,
    Color? glassSurface,
    Color? glassBorder,
    Color? glassHighlight,
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? labelPrimary,
    Color? labelSecondary,
    Color? labelTertiary,
    Color? separator,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColors(
      background: background ?? this.background,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      paleIndigoSurface: paleIndigoSurface ?? this.paleIndigoSurface,
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      labelPrimary: labelPrimary ?? this.labelPrimary,
      labelSecondary: labelSecondary ?? this.labelSecondary,
      labelTertiary: labelTertiary ?? this.labelTertiary,
      separator: separator ?? this.separator,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      secondaryBackground: Color.lerp(
        secondaryBackground,
        other.secondaryBackground,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      paleIndigoSurface: Color.lerp(
        paleIndigoSurface,
        other.paleIndigoSurface,
        t,
      )!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassHighlight: Color.lerp(glassHighlight, other.glassHighlight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      labelPrimary: Color.lerp(labelPrimary, other.labelPrimary, t)!,
      labelSecondary: Color.lerp(labelSecondary, other.labelSecondary, t)!,
      labelTertiary: Color.lerp(labelTertiary, other.labelTertiary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors => AppColors.of(this);
}
