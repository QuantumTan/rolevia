import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/typography.dart';

/// Company avatar displaying monogram tile, company logo URL, or briefcase icon if name is empty.
/// Uses a fixed palette of 8 deterministic tonal colors that pass 4.5:1 contrast in light and dark mode.
/// Avatar tile radius is 10 logical px.
class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar(
    this.name, {
    super.key,
    this.logoUrl,
    this.size = 44.0,
  });

  final String name;
  final String? logoUrl;
  final double size;

  static const List<({Color lightBg, Color lightText, Color darkBg, Color darkText})>
      _palette = [
    // 0: Slate
    (
      lightBg: Color(0xFFE2E8F0),
      lightText: Color(0xFF0F172A),
      darkBg: Color(0xFF1E293B),
      darkText: Color(0xFFF8FAFC),
    ),
    // 1: Ocean
    (
      lightBg: Color(0xFFE0F2FE),
      lightText: Color(0xFF0369A1),
      darkBg: Color(0xFF0C2D48),
      darkText: Color(0xFFBAE6FD),
    ),
    // 2: Emerald
    (
      lightBg: Color(0xFFD1FAE5),
      lightText: Color(0xFF065F46),
      darkBg: Color(0xFF064E3B),
      darkText: Color(0xFFA7F3D0),
    ),
    // 3: Indigo
    (
      lightBg: Color(0xFFE0E7FF),
      lightText: Color(0xFF3730A3),
      darkBg: Color(0xFF1E1B4B),
      darkText: Color(0xFFC7D2FE),
    ),
    // 4: Violet
    (
      lightBg: Color(0xFFEDE9FE),
      lightText: Color(0xFF5B21B6),
      darkBg: Color(0xFF2E1065),
      darkText: Color(0xFFDDD6FE),
    ),
    // 5: Amber
    (
      lightBg: Color(0xFFFEF3C7),
      lightText: Color(0xFF92400E),
      darkBg: Color(0xFF451A03),
      darkText: Color(0xFFFDE68A),
    ),
    // 6: Rose
    (
      lightBg: Color(0xFFFFE4E6),
      lightText: Color(0xFF9F1239),
      darkBg: Color(0xFF4C0519),
      darkText: Color(0xFFFECDD3),
    ),
    // 7: Teal
    (
      lightBg: Color(0xFFCCFBF1),
      lightText: Color(0xFF115E59),
      darkBg: Color(0xFF134E4A),
      darkText: Color(0xFF99F6E4),
    ),
  ];

  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return words
        .take(2)
        .map((w) => String.fromCharCode(w.runes.first))
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleanName = name.trim();
    final cleanLogo = logoUrl?.trim();

    final hash = cleanName.runes.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    final entry = _palette[hash % _palette.length];
    final bgColor = isDark ? entry.darkBg : entry.lightBg;
    final fgColor = isDark ? entry.darkText : entry.lightText;

    final borderRadius = BorderRadius.circular(AppRadius.avatarTile);

    Widget child;

    if (cleanLogo != null && cleanLogo.isNotEmpty) {
      child = Image.network(
        cleanLogo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(cleanName, fgColor),
      );
    } else {
      child = _buildFallback(cleanName, fgColor);
    }

    return Semantics(
      label: cleanName.isNotEmpty ? '$cleanName avatar' : 'Company avatar',
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: AppColors.of(context).hairlineBorder,
            width: 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildFallback(String cleanName, Color fgColor) {
    if (cleanName.isEmpty) {
      return Icon(
        Icons.business_center_outlined,
        size: size * 0.48,
        color: fgColor,
      );
    }
    final inits = initials;
    final fontSize = (size * (inits.length > 1 ? 0.38 : 0.46)).clamp(10.0, 24.0);

    return Text(
      inits,
      style: AppTypography.headline.copyWith(
        color: fgColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        height: 1.0,
      ),
    );
  }
}
