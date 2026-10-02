import 'package:flutter/material.dart';

export '../design/colors.dart';
export '../design/typography.dart';
export '../design/spacing.dart';
export '../design/radius.dart';

/// Surface preferences shared by navigation, sheets and transient feedback.
class SurfacePreferences extends ThemeExtension<SurfacePreferences> {
  const SurfacePreferences({this.solid = false});
  final bool solid;

  @override
  SurfacePreferences copyWith({bool? solid}) =>
      SurfacePreferences(solid: solid ?? this.solid);

  @override
  SurfacePreferences lerp(covariant SurfacePreferences? other, double t) =>
      t < 0.5 ? this : other ?? this;
}

class UITokens {
  const UITokens._();
  static const amber = Color(0xFFFFB300);
  static const cardRadius = 16.0;
  static const sheetRadius = 28.0;
  static const screenMargin = 16.0;
  static const quick = Duration(milliseconds: 100);
  static const selection = Duration(milliseconds: 200);
  static const transition = Duration(milliseconds: 300);
  static const score = Duration(milliseconds: 800);
}
