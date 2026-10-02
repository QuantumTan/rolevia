import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/motion.dart';
import '../theme/tokens.dart';
import 'adaptive_button.dart';
import 'adaptive_toast.dart';

/// Clipboard action with in-place confirmation and no repeated async requests.
class CopyButton extends StatefulWidget {
  const CopyButton(this.text, {super.key});
  final String text;
  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool copied = false;
  bool busy = false;
  Timer? reset;
  @override
  void dispose() {
    reset?.cancel();
    super.dispose();
  }

  Future<void> copy() async {
    setState(() => busy = true);
    try {
      await Clipboard.setData(ClipboardData(text: widget.text));
      if (!mounted) return;
      AppMotion.successHaptic();
      setState(() {
        busy = false;
        copied = true;
      });
      reset?.cancel();
      reset = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => copied = false);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => busy = false);
      showGlassToast(
        context,
        'Could not copy. Try again.',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AdaptiveButton.tertiary(
      onPressed: busy ? null : copy,
      isLoading: busy,
      icon: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : UITokens.selection,
        child: Icon(
          copied ? Icons.check_rounded : Icons.copy_rounded,
          key: ValueKey(copied),
          size: 18,
          color: AppColors.of(context).accent,
        ),
      ),
      label: copied ? 'Copied' : 'Copy',
    ),
  );
}
