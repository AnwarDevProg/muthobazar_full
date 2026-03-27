import 'package:flutter/material.dart';

import '../../../theme/mb_colors.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';


class MBTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;
  final EdgeInsetsGeometry? margin;

  const MBTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines,
        enabled: enabled,
        style: MBTextStyles.body.copyWith(
          color: MBColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintStyle: MBTextStyles.body.copyWith(
            color: MBColors.textMuted,
          ),
          labelStyle: MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
          filled: true,
          fillColor: MBColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MBRadius.md),
            borderSide: const BorderSide(color: MBColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MBRadius.md),
            borderSide: const BorderSide(color: MBColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MBRadius.md),
            borderSide: const BorderSide(
              color: MBColors.primaryOrange,
              width: 1.2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MBRadius.md),
            borderSide: const BorderSide(color: MBColors.border),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MBRadius.md),
            borderSide: const BorderSide(color: MBColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MBRadius.md),
            borderSide: const BorderSide(
              color: MBColors.error,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}











