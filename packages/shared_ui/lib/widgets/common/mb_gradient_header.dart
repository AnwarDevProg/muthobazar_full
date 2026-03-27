import 'package:flutter/material.dart';
import '../../../theme/mb_colors.dart';
import '../../../theme/mb_gradients.dart';
import '../../../theme/mb_radius.dart';
import '../../../theme/mb_text_styles.dart';
import '../../responsive/mb_spacing.dart';


class MBGradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const MBGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.height = 180,
    this.margin,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.fromLTRB(
            MBSpacing.md,
            MBSpacing.lg,
            MBSpacing.md,
            MBSpacing.md,
          ),
      decoration: BoxDecoration(
        gradient: MBGradients.headerGradient,
        borderRadius: borderRadius ??
            const BorderRadius.only(
              bottomLeft: Radius.circular(MBRadius.xl),
              bottomRight: Radius.circular(MBRadius.xl),
            ),
        boxShadow: const [
          BoxShadow(
            color: MBColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: MBSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MBTextStyles.pageTitle.copyWith(
                      color: MBColors.textOnPrimary,
                      fontSize: 24,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: MBSpacing.xs),
                    Text(
                      subtitle!,
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textOnPrimary.withValues(alpha: 0.92),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: MBSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}











