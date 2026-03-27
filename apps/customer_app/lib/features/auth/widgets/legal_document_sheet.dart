// Legal Document Sheet
// --------------------
// Bottom sheet used for Terms & Conditions and Privacy Policy.

import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

Future<void> showLegalDocumentSheet({
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;

      return Container(
        height: screenHeight * 0.8,
        decoration: const BoxDecoration(
          color: MBColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MBRadius.xl),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: MBSpacing.sm),

            /// Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MBColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: MBSpacing.md),

            /// Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MBSpacing.lg),
              child: Text(
                title,
                style: MBAppText.headline3(context),
              ),
            ),

            const SizedBox(height: MBSpacing.md),

            /// Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: MBSpacing.lg,
                ),
                child: Text(
                  content,
                  style: MBAppText.body(context).copyWith(
                    color: MBColors.textPrimary,
                    height: 1.55,
                  ),
                ),
              ),
            ),

            const SizedBox(height: MBSpacing.md),

            /// OK button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MBSpacing.lg,
                0,
                MBSpacing.lg,
                MBSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MBColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MBRadius.md),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: MBAppText.button(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}