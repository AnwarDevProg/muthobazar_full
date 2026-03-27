import 'package:flutter/material.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_text_styles.dart';
import '../../responsive/mb_spacing.dart';


class MBSectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTapAction;
  final EdgeInsetsGeometry? margin;

  const MBSectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onTapAction,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          const EdgeInsets.only(
            top: MBSpacing.sm,
            bottom: MBSpacing.sm,
          ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: MBTextStyles.sectionTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionText != null && actionText!.trim().isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTapAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                child: Text(
                  actionText!,
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}











