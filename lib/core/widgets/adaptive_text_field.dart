import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/radius.dart';
import '../design/spacing.dart';

/// Adaptive text field and search field with iOS inset styling and M3 support.
class AdaptiveTextField extends StatefulWidget {
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.showClearButton = false,
    this.onClear,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;
  final bool showClearButton;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  @override
  State<AdaptiveTextField> createState() => _AdaptiveTextFieldState();
}

class _AdaptiveTextFieldState extends State<AdaptiveTextField> {
  late TextEditingController _effectiveController;
  late FocusNode _effectiveFocusNode;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _effectiveController =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _showClear = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (_showClear != hasText) {
      setState(() => _showClear = hasText);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    } else {
      _effectiveController.removeListener(_onTextChanged);
    }
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget? suffix = widget.suffixIcon;
    if (widget.showClearButton && _showClear) {
      suffix = IconButton(
        icon: const Icon(Icons.cancel, size: 18),
        color: colors.labelTertiary,
        splashRadius: 18,
        tooltip: 'Clear text',
        onPressed: () {
          _effectiveController.clear();
          widget.onChanged?.call('');
          widget.onClear?.call();
        },
      );
    }

    final fieldBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final borderSide = BorderSide(
      color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB),
      width: 0.8,
    );
    final focusBorderSide = BorderSide(color: colors.primary, width: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xxs),
            child: Text(
              widget.labelText!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.labelSecondary,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
        TextFormField(
          controller: _effectiveController,
          focusNode: _effectiveFocusNode,
          autofocus: widget.autofocus,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          style: TextStyle(
            fontSize: 16,
            color: colors.labelPrimary,
            letterSpacing: -0.2,
          ),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 15,
              color: colors.labelTertiary,
              letterSpacing: -0.2,
            ),
            helperText: widget.helperText,
            helperStyle: TextStyle(fontSize: 12, color: colors.labelSecondary),
            errorText: widget.errorText,
            filled: true,
            fillColor: fieldBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    child: IconTheme(
                      data: IconThemeData(
                        color: colors.labelTertiary,
                        size: 20,
                      ),
                      child: widget.prefixIcon!,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: borderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: borderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: focusBorderSide,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colors.error, width: 1),
            ),
          ),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
        ),
      ],
    );
  }
}
