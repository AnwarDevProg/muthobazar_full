import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';


class AuthGetOtpButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AuthGetOtpButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MBSpacing.buttonHeight(context),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: MBColors.primaryOrange.withValues(alpha: 0.06),
          side: BorderSide(
            color: MBColors.primaryOrange.withValues(alpha: 0.35),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: MBAppText.button(context).copyWith(
            color: MBColors.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}