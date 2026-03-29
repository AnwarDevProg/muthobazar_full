import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminFeaturePlaceholderPage extends StatelessWidget {
  const AdminFeaturePlaceholderPage({
    super.key,
    required this.title,
    this.description,
  });

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(MBSpacing.xl),
          child: MBCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: MBColors.primaryOrange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(MBRadius.xl),
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 34,
                    color: MBColors.primaryOrange,
                  ),
                ),
                MBSpacing.h(MBSpacing.lg),
                Text(
                  title,
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                MBSpacing.h(MBSpacing.sm),
                Text(
                  description ?? 'This feature is still not activated.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}