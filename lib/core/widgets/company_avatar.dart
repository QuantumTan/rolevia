import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/typography.dart';

/// Company avatar displaying monogram tile, company logo URL, or briefcase icon if name is empty.
/// Uses one neutral, high-contrast monogram treatment across every company.
/// Avatar tile radius is 10 logical px.
class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar(this.name, {super.key, this.logoUrl, this.size = 44.0});

  final String name;
  final String? logoUrl;
  final double size;

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

    final bgColor = isDark ? const Color(0xFF1E232E) : const Color(0xFFE8ECF2);
    final fgColor = isDark ? const Color(0xFFF5F6F8) : const Color(0xFF172033);

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
    final fontSize = (size * (inits.length > 1 ? 0.38 : 0.46)).clamp(
      10.0,
      24.0,
    );

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
