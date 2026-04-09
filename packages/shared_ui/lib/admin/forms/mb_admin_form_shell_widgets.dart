import 'package:flutter/material.dart';

import '../../responsive/mb_spacing.dart';
import '../../theme/mb_colors.dart';
import '../../theme/mb_radius.dart';
import '../../theme/mb_text_styles.dart';

// Reusable admin form shell widgets for category, brand, and future admin forms.

class MBAdminFormSectionCard extends StatelessWidget {
  const MBAdminFormSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.padding,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MBTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xs),
          Text(
            subtitle,
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          child,
        ],
      ),
    );
  }
}

class MBAdminFormErrorBanner extends StatelessWidget {
  const MBAdminFormErrorBanner({
    super.key,
    required this.message,
    this.margin,
  });

  final String message;
  final EdgeInsetsGeometry? margin;

  String _cleanMessage(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.startsWith('Exception: ')) {
      return trimmed.replaceFirst('Exception: ', '').trim();
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final String safeMessage = _cleanMessage(message);

    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.only(bottom: MBSpacing.lg),
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.error.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: MBColors.error,
          ),
          MBSpacing.w(MBSpacing.sm),
          Expanded(
            child: Text(
              safeMessage,
              style: MBTextStyles.body.copyWith(
                color: MBColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MBAdminImagePreviewBox extends StatelessWidget {
  const MBAdminImagePreviewBox({
    super.key,
    required this.child,
    this.aspectRatio = 1,
    this.isBusy = false,
    this.busyLabel,
  });

  final Widget child;
  final double aspectRatio;
  final bool isBusy;
  final String? busyLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(MBRadius.lg),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: child,
          ),
        ),
        if (isBusy)
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(MBRadius.lg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if ((busyLabel ?? '').trim().isNotEmpty) ...[
                    MBSpacing.h(MBSpacing.sm),
                    Text(
                      busyLabel!.trim(),
                      style: MBTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class MBAdminEmptyImageBox extends StatelessWidget {
  const MBAdminEmptyImageBox({
    super.key,
    required this.icon,
    required this.text,
    this.aspectRatio = 1,
  });

  final IconData icon;
  final String text;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.90),
        ),
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(MBSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: MBColors.textMuted,
                ),
                MBSpacing.h(MBSpacing.sm),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MBAdminInfoRow extends StatelessWidget {
  const MBAdminInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 96,
  });

  final String label;
  final String value;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final String safeValue = value.trim().isEmpty ? '—' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: MBSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          Expanded(
            child: SelectableText(
              safeValue,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MBAdminFormActionFooter extends StatelessWidget {
  const MBAdminFormActionFooter({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.onCancelTap,
    this.isPrimaryEnabled = true,
    this.cancelLabel = 'Cancel',
    this.padding,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onCancelTap;
  final bool isPrimaryEnabled;
  final String cancelLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(MBSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancelTap,
              child: Text(cancelLabel),
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: FilledButton(
              onPressed: isPrimaryEnabled ? onPrimaryTap : null,
              child: Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}
