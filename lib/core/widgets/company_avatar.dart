import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Stable local initials; no network request or real company logo.
class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar(this.name, {super.key, this.size = 44});
  final String name;
  final double size;
  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    return words.isEmpty
        ? '?'
        : words
              .take(2)
              .map((w) => String.fromCharCode(w.runes.first))
              .join()
              .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hash = name.runes.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    final colors = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = [
      colors.paleIndigoSurface,
      dark ? colors.elevatedSurface : const Color(0xFFC5CAE9),
      dark ? const Color(0xFF352B15) : const Color(0xFFFFF8E1),
    ][hash % 3];
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          initials,
          style: AppTypography.headline.copyWith(color: colors.labelPrimary),
        ),
      ),
    );
  }
}
