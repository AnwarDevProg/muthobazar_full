import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_defaults.dart';
import '../mb_design_element_runtime_style.dart';

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
    this.runtimeStyle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final String text;
  final MBCardElementConfig? element;
  final MBDesignElementRuntimeStyle? runtimeStyle;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    if (!(element?.visible ?? true) || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveBackground =
        runtimeStyle?.backgroundColor ?? backgroundColor ?? Colors.white;
    final effectiveTextColor =
        runtimeStyle?.textColor ?? textColor ?? MBDesignCardDefaults.orangeDark;
    final effectiveBorder = runtimeStyle?.borderColor ??
        borderColor ??
        MBDesignCardDefaults.orange.withValues(alpha: 0.18);
    final radius = runtimeStyle?.borderRadius ?? 999.0;
    final padding = runtimeStyle?.padding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: runtimeStyle?.boxShadow() ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
        border: Border.all(
          color: effectiveBorder,
          width: runtimeStyle?.borderWidth ?? 1,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: runtimeStyle?.mergeTextStyle(
              TextStyle(
                color: effectiveTextColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ) ??
            TextStyle(
              color: effectiveTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
      ),
    );
  }
}
