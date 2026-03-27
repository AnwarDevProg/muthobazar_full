import 'package:flutter/material.dart';

import '../../../theme/mb_gradients.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';

class MBPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final bool isLoading;
  final bool expand;
  final Widget? prefixIcon;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const MBPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 52,
    this.isLoading = false,
    this.expand = true,
    this.prefixIcon,
    this.gradient,
    this.borderRadius,
    this.textStyle,
    this.padding,
  });

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(MBRadius.md);

    final buttonChild = isLoading
        ? const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
          style: textStyle ?? MBTextStyles.button,
        ),
      ],
    );

    final button = SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: Opacity(
        opacity: _isEnabled ? 1 : 0.65,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient ?? MBGradients.primaryGradient,
            borderRadius: radius,
          ),
          child: ElevatedButton(
            onPressed: _isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: Colors.white,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
              ),
            ),
            child: buttonChild,
          ),
        ),
      ),
    );

    return button;
  }
}











