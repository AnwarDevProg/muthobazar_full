import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_defaults.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_cta_element.dart
//
// Purpose:
// Primary CTA element.

class MBDesignCtaElement extends StatelessWidget {
  const MBDesignCtaElement({
    super.key,
    required this.text,
    this.element,
    this.onTap,
  });

  final String text;
  final MBCardElementConfig? element;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!(element?.visible ?? true)) {
      return const SizedBox.shrink();
    }

    final label = text.trim().isEmpty ? 'Buy' : text.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: MBDesignCardDefaults.orangeGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: MBDesignCardDefaults.orange.withValues(alpha: 0.24),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
