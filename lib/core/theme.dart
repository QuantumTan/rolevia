import 'package:flutter/material.dart';

const indigo = Color(0xFF3F51B5);

ThemeData appTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: indigo,
    brightness: brightness,
    surface: dark ? const Color(0xFF1C1C1E) : Colors.white,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? Colors.black : const Color(0xFFF5F5F5),
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.1,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.35),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.4),
    ),
    cardTheme: CardThemeData(
      color: dark ? const Color(0xFF1C1C1E) : Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: dark ? const Color(0xFF343438) : const Color(0xFFE3E3E8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1C1C1E) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: dark ? const Color(0xFF45454A) : const Color(0xFFD5D5DB),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 50),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 50),
        shape: const StadiumBorder(),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(
        color: dark ? const Color(0xFF45454A) : const Color(0xFFD5D5DB),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: indigo.withValues(alpha: .14),
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 11,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
    ),
  );
}
