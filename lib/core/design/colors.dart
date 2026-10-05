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
    this.diffAddedText = const Color(0xFF15803D),
    this.diffAddedBg = const Color(0xFFDCFCE7),
    this.diffPrunedText = const Color(0xFFB91C1C),
    this.diffPrunedBg = const Color(0xFFFEE2E2),
    this.hairlineBorder = const Color(0x14000000),
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
  final Color diffAddedText;
  final Color diffAddedBg;
  final Color diffPrunedText;
  final Color diffPrunedBg;
  final Color hairlineBorder;
  Color get borderSubtle => hairlineBorder;

  static const light = AppColors(
    background: Color(0xFFF8FAFC), // Slate 50 Light Canvas
    secondaryBackground: Color(0xFFFFFFFF), // Elevated surface
    surface: Color(0xFFFFFFFF), // Pure White surface #FFFFFF
    elevatedSurface: Color(0xFFFFFFFF),
    paleIndigoSurface: Color(0xFFF1F5F9), // Slate 100 accent surface
    glassSurface: Color(0xFFFFFFFF), // Flat opaque hex surface
    glassBorder: Color(0x14000000), // Hairline border rgba(0, 0, 0, 0.08)
    glassHighlight: Colors.transparent,
    primary: Color(0xFF0369A1), // Ocean Blue (#0369A1 for WCAG AA 5.9:1 white-text compliance)
    secondary: Color(0xFF0D9488), // Precision Teal
    accent: Color(0xFF0369A1), // WCAG 4.5:1 compliant Ocean Blue on white surface
    labelPrimary: Color(0xFF08090C), // Slate 950 / True Obsidian text
    labelSecondary: Color(0xFF475569), // Slate 600 (7.57:1 contrast on white)
    labelTertiary: Color(0xFF64748B), // Slate 500
    separator: Color(0x14000000), // Hairline border rgba(0, 0, 0, 0.08)
    success: Color(0xFF15803D), // Text: #15803D
    warning: Color(0xFFB45309), // Text: #B45309
    error: Color(0xFFB91C1C), // Text: #B91C1C
    info: Color(0xFF0284C7),
    diffAddedText: Color(0xFF15803D), // #15803D
    diffAddedBg: Color(0xFFDCFCE7), // #DCFCE7
    diffPrunedText: Color(0xFFB91C1C), // #B91C1C
    diffPrunedBg: Color(0xFFFEE2E2), // #FEE2E2
    hairlineBorder: Color(0x14000000), // rgba(0, 0, 0, 0.08)
  );

  static const dark = AppColors(
    background: Color(0xFF08090C), // True Obsidian Dark Canvas #08090C
    secondaryBackground: Color(0xFF111318), // Graphite Elevated Surface #111318
    surface: Color(0xFF111318), // Graphite Surface #111318
    elevatedSurface: Color(0xFF181B22), // Elevated Graphite
    paleIndigoSurface: Color(0xFF181B22),
    glassSurface: Color(0xFF111318), // Flat opaque hex surface
    glassBorder: Color(0x14FFFFFF), // Hairline border rgba(255, 255, 255, 0.08)
    glassHighlight: Color(0x24FFFFFF), // Specular border rgba(255, 255, 255, 0.14)
    primary: Color(0xFF0369A1), // Ocean Blue (#0369A1 for WCAG AA 5.9:1 white-text compliance)
    secondary: Color(0xFF0D9488), // Precision Teal
    accent: Color(0xFF38BDF8), // WCAG 4.5:1 compliant light blue on dark graphite
    labelPrimary: Color(0xFFF8FAFC), // Slate 50
    labelSecondary: Color(0xFF94A3B8), // Slate 400
    labelTertiary: Color(0xFF64748B), // Slate 500
    separator: Color(0x14FFFFFF), // Hairline border rgba(255, 255, 255, 0.08)
    success: Color(0xFF15803D),
    warning: Color(0xFFB45309),
    error: Color(0xFFB91C1C),
    info: Color(0xFF38BDF8),
    diffAddedText: Color(0xFF4ADE80), // Added text dark
    diffAddedBg: Color(0xFF14532D), // Surface: #14532D
    diffPrunedText: Color(0xFFF87171), // Pruned text dark
    diffPrunedBg: Color(0xFF7F1D1D), // Surface: #7F1D1D
    hairlineBorder: Color(0x14FFFFFF), // rgba(255, 255, 255, 0.08)
  );

  static const lightHighContrast = AppColors(
    background: Color(0xFFF1F5F9),
    secondaryBackground: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    elevatedSurface: Color(0xFFFFFFFF),
    paleIndigoSurface: Color(0xFFE2E8F0),
    glassSurface: Color(0xFFFFFFFF),
    glassBorder: Color(0xFF000000),
    glassHighlight: Colors.transparent,
    primary: Color(0xFF0369A1), // High contrast oceanic cyan (5.9:1 with white)
    secondary: Color(0xFF0369A1),
    accent: Color(0xFF0369A1), // 5.9:1 contrast with surface
    labelPrimary: Color(0xFF000000),
    labelSecondary: Color(0xFF334155),
    labelTertiary: Color(0xFF475569),
    separator: Color(0xFF94A3B8),
    success: Color(0xFF047857),
    warning: Color(0xFFB45309),
    error: Color(0xFFB91C1C),
    info: Color(0xFF0284C7),
    diffAddedText: Color(0xFF15803D),
    diffAddedBg: Color(0xFFDCFCE7),
    diffPrunedText: Color(0xFFB91C1C),
    diffPrunedBg: Color(0xFFFEE2E2),
    hairlineBorder: Color(0xFF000000),
  );

  static const darkHighContrast = AppColors(
    background: Color(0xFF000000),
    secondaryBackground: Color(0xFF0A0B0E),
    surface: Color(0xFF0A0B0E),
    elevatedSurface: Color(0xFF12141A),
    paleIndigoSurface: Color(0xFF1A1F2C),
    glassSurface: Color(0xFF0A0B0E),
    glassBorder: Color(0xFFFFFFFF),
    glassHighlight: Colors.transparent,
    primary: Color(0xFF0369A1), // High contrast oceanic cyan (5.9:1 with white)
    secondary: Color(0xFF7DD3FC),
    accent: Color(0xFF38BDF8),
    labelPrimary: Color(0xFFFFFFFF),
    labelSecondary: Color(0xFFE2E8F0),
    labelTertiary: Color(0xFFCBD5E1),
    separator: Color(0xFF64748B),
    success: Color(0xFF34D399),
    warning: Color(0xFFFCD34D),
    error: Color(0xFFFCA5A5),
    info: Color(0xFF38BDF8),
    diffAddedText: Color(0xFF86EFAC),
    diffAddedBg: Color(0xFF14532D),
    diffPrunedText: Color(0xFFFCA5A5),
    diffPrunedBg: Color(0xFF7F1D1D),
    hairlineBorder: Color(0xFFFFFFFF),
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
        primary: const Color(0xFF0369A1),
        accent: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
        paleIndigoSurface: isDark ? const Color(0xFF0C2D48) : const Color(0xFFE0F2FE),
      ) as AppColors,
      AppAccentColor.emerald => base.copyWith(
        primary: const Color(0xFF10B981),
        accent: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
        paleIndigoSurface: isDark ? const Color(0xFF063726) : const Color(0xFFD1FAE5),
      ) as AppColors,
      AppAccentColor.violet => base.copyWith(
        primary: const Color(0xFF7C3AED),
        accent: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
        paleIndigoSurface: isDark ? const Color(0xFF281845) : const Color(0xFFEDE9FE),
      ) as AppColors,
      AppAccentColor.coral => base.copyWith(
        primary: const Color(0xFFF43F5E),
        accent: isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
        paleIndigoSurface: isDark ? const Color(0xFF431219) : const Color(0xFFFFE4E6),
      ) as AppColors,
      AppAccentColor.indigo => base.copyWith(
        primary: const Color(0xFF4F46E5),
        accent: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
        paleIndigoSurface: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
      ) as AppColors,
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
    Color? diffAddedText,
    Color? diffAddedBg,
    Color? diffPrunedText,
    Color? diffPrunedBg,
    Color? hairlineBorder,
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
      diffAddedText: diffAddedText ?? this.diffAddedText,
      diffAddedBg: diffAddedBg ?? this.diffAddedBg,
      diffPrunedText: diffPrunedText ?? this.diffPrunedText,
      diffPrunedBg: diffPrunedBg ?? this.diffPrunedBg,
      hairlineBorder: hairlineBorder ?? this.hairlineBorder,
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
      diffAddedText: Color.lerp(diffAddedText, other.diffAddedText, t)!,
      diffAddedBg: Color.lerp(diffAddedBg, other.diffAddedBg, t)!,
      diffPrunedText: Color.lerp(diffPrunedText, other.diffPrunedText, t)!,
      diffPrunedBg: Color.lerp(diffPrunedBg, other.diffPrunedBg, t)!,
      hairlineBorder: Color.lerp(hairlineBorder, other.hairlineBorder, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors => AppColors.of(this);
}
