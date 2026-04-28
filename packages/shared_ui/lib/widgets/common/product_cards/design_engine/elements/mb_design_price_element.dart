import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_defaults.dart';
import '../mb_design_element_runtime_style.dart';
import 'mb_design_text_element.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_price_element.dart
//
// Purpose:
// First-pass final/original price renderer.

class MBDesignPriceElement extends StatelessWidget {
  const MBDesignPriceElement({
    super.key,
    required this.finalPriceText,
    this.originalPriceText,
    this.finalPriceElement,
    this.originalPriceElement,
    this.finalPriceColor,
    this.originalPriceColor,
    this.finalPriceStyle,
    this.originalPriceStyle,
  });

  final String finalPriceText;
  final String? originalPriceText;
  final MBCardElementConfig? finalPriceElement;
  final MBCardElementConfig? originalPriceElement;

  final Color? finalPriceColor;
  final Color? originalPriceColor;
  final MBDesignElementRuntimeStyle? finalPriceStyle;
  final MBDesignElementRuntimeStyle? originalPriceStyle;

  @override
  Widget build(BuildContext context) {
    if (!(finalPriceElement?.visible ?? true)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MBDesignTextElement(
          text: finalPriceText,
          element: finalPriceElement,
          runtimeStyle: finalPriceStyle,
          defaultStyle: TextStyle(
            color: finalPriceColor ?? MBDesignCardDefaults.orangeDark,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        if ((originalPriceElement?.visible ?? true) &&
            originalPriceText != null &&
            originalPriceText!.trim().isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(
            originalPriceText!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: originalPriceStyle?.mergeTextStyle(
                  TextStyle(
                    color:
                        originalPriceColor ?? MBDesignCardDefaults.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                    height: 1.1,
                  ),
                ) ??
                TextStyle(
                  color: originalPriceColor ?? MBDesignCardDefaults.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.lineThrough,
                  height: 1.1,
                ),
          ),
        ],
      ],
    );
  }
}
