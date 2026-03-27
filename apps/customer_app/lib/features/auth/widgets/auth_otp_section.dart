import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';
import 'otp_input.dart';

class AuthOtpSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool visible;
  final String? helperText;

  const AuthOtpSection({
    super.key,
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.onChanged,
    this.visible = true,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: MBAppText.label(context).copyWith(
            color: MBColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        MBSpacing.h(MBSpacing.xs),
        OtpInput(
          controller: controller,
          focusNode: focusNode,
          errorText: errorText,
          onChanged: onChanged,
          animateHighlight: visible,
        ),
        if (helperText != null && helperText!.trim().isNotEmpty) ...[
          MBSpacing.h(MBSpacing.xs),
          Text(
            helperText!,
            style: MBAppText.bodySmall(context).copyWith(
              color: MBColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(fade),
            child: child,
          ),
        );
      },
      child: visible
          ? KeyedSubtree(
        key: const ValueKey('otp-visible'),
        child: content,
      )
          : const SizedBox(
        key: ValueKey('otp-hidden'),
      ),
    );
  }
}