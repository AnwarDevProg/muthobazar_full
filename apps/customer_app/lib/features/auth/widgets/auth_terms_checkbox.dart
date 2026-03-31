import 'package:customer_app/features/auth/constants/auth_legal_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';
import 'legal_document_sheet.dart';

class AuthTermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AuthTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Checkbox(
            value: value,
            onChanged: (bool? newValue) {
              onChanged(newValue ?? false);
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RichText(
              text: TextSpan(
                style: MBAppText.body(context).copyWith(
                  color: MBColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: MBAppText.body(context).copyWith(
                      color: MBColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        showLegalDocumentSheet(
                          context: context,
                          title: 'Terms & Conditions',
                          content: AuthLegalText.terms,
                        );
                      },
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: MBAppText.body(context).copyWith(
                      color: MBColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        showLegalDocumentSheet(
                          context: context,
                          title: 'Privacy Policy',
                          content: AuthLegalText.privacy,
                        );
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}