import 'package:flutter/material.dart';

import '../../../theme/mb_colors.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';

class MBSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? margin;
  final bool isLoading;
  final bool expand;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const MBSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 52,
    this.prefixIcon,
    this.margin,
    this.isLoading = false,
    this.expand = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
    this.padding,
  });

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(MBRadius.md);
    final effectiveForeground = foregroundColor ?? MBColors.primaryOrange;

    final child = isLoading
        ? SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveForeground),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          prefixIcon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: textStyle ??
              MBTextStyles.bodyMedium.copyWith(
                color: effectiveForeground,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );

    return Container(
      margin: margin,
      width: expand ? double.infinity : null,
      height: height,
      child: Opacity(
        opacity: _isEnabled ? 1 : 0.70,
        child: OutlinedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor ?? MBColors.surface,
            foregroundColor: effectiveForeground,
            padding: padding,
            side: BorderSide(
              color: borderColor ?? MBColors.primaryOrange,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: radius,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}











