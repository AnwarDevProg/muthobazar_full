// MB Section Header
// -----------------
// Reusable header for sections like
// "Featured Products", "Categories", etc.

import 'package:flutter/material.dart';
import '../../responsive/mb_spacing.dart';
import '../../typography/mb_app_text.dart';
import '../../../theme/mb_colors.dart';

class MBSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  const MBSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: MBSpacing.pageHorizontal(context),
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: MBAppText.sectionTitle(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    actionText!,
                    style: MBAppText.body(context).copyWith(
                      color: MBColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  MBSpacing.w(MBSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: MBColors.primaryOrange,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}











