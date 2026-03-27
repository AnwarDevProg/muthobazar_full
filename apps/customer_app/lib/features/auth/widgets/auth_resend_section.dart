import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class AuthResendSection extends StatelessWidget {
  final bool isOtpSent;
  final bool showResendButton;
  final int resendTimeoutSeconds;
  final VoidCallback onResend;

  const AuthResendSection({
    super.key,
    required this.isOtpSent,
    required this.showResendButton,
    required this.resendTimeoutSeconds,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOtpSent) {
      return const SizedBox.shrink();
    }

    return Center(
      child: showResendButton
          ? TextButton(
        onPressed: onResend,
        child: Text(
          'Resend OTP',
          style: MBAppText.body(context).copyWith(
            color: MBColors.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : Text(
        'Resend in $resendTimeoutSeconds seconds',
        style: MBAppText.bodySmall(context).copyWith(
          color: MBColors.textSecondary,
        ),
      ),
    );
  }
}