import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_defaults.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_badge_element.dart
//
// Purpose:
// Small badge/chip element for savings, discounts, labels.

class MBDesignBadgeElement extends StatelessWidget {
  const MBDesignBadgeElement({
    super.key,
    required this.text,
    this.element,
  });

  final String text;
  final MBCardElementConfig? element;

  @override
  Widget build(BuildContext context) {
    if (!(element?.visible ?? true) || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: MBDesignCardDefaults.orange.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: MBDesignCardDefaults.orangeDark,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
