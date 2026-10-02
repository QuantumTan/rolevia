import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design/colors.dart';

/// Platform-adaptive switch using CupertinoSwitch on iOS and Material switch on Android.
class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return CupertinoSwitch(
        value: value,
        activeTrackColor: colors.primary,
        onChanged: onChanged,
      );
    }

    return Switch(
      value: value,
      activeTrackColor: colors.primary,
      onChanged: onChanged,
    );
  }
}
