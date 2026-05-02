import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import 'mb_design_card_context.dart';
import 'templates/hero_poster_circle_diagonal_v1.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_card_renderer.dart
//
// Purpose:
// New design-family product card renderer.
//
// Design phase rule:
// - This renderer does not use the old cardConfig fallback.
// - It renders from MBCardDesignConfig only.
// - Unsupported template ids show a clear development placeholder.

class MBDesignCardRenderer extends StatelessWidget {
  const MBDesignCardRenderer({
    super.key,
    required this.product,
    required this.config,
    this.onTap,
    this.onPrimaryCtaTap,
    this.onSecondaryCtaTap,
    this.currencySymbol = '৳',
  });

  final MBProduct product;
  final MBCardDesignConfig config;

  final VoidCallback? onTap;
  final VoidCallback? onPrimaryCtaTap;
  final VoidCallback? onSecondaryCtaTap;

  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final cardContext = MBDesignCardContext(
      product: product,
      config: config,
      onTap: onTap,
      onPrimaryCtaTap: onPrimaryCtaTap,
      onSecondaryCtaTap: onSecondaryCtaTap,
      currencySymbol: currencySymbol,
    );

    switch (config.templateId) {
      case MBCardDesignRegistry.heroPosterCircleDiagonalV1:
        return MBHeroPosterCircleDiagonalV1(
          contextData: cardContext,
        );

      default:
        return _UnsupportedDesignTemplate(
          templateId: config.templateId,
          familyId: config.designFamilyId,
        );
    }
  }
}

class _UnsupportedDesignTemplate extends StatelessWidget {
  const _UnsupportedDesignTemplate({
    required this.templateId,
    required this.familyId,
  });

  final String templateId;
  final String familyId;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF8A00).withValues(alpha: 0.24),
        ),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF2E2A27),
          fontSize: 12,
          height: 1.35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unsupported design template',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text('familyId: $familyId'),
            Text('templateId: $templateId'),
          ],
        ),
      ),
    );
  }
}
