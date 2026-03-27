import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class AuthSwitchLink extends StatelessWidget {
  final String prefixText;
  final String actionText;
  final VoidCallback onTap;

  const AuthSwitchLink({
    super.key,
    required this.prefixText,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: MBAppText.body(context).copyWith(
            color: MBColors.textSecondary,
          ),
          children: [
            TextSpan(text: prefixText),
            TextSpan(
              text: actionText,
              style: MBAppText.body(context).copyWith(
                color: MBColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}