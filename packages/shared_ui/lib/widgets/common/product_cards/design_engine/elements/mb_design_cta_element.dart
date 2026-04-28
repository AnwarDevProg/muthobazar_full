import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_defaults.dart';
import '../mb_design_element_runtime_style.dart';

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
    this.runtimeStyle,
    this.onTap,
    this.gradient,
    this.textColor,
    this.shadowColor,
  });

  final String text;
  final MBCardElementConfig? element;
  final MBDesignElementRuntimeStyle? runtimeStyle;
  final VoidCallback? onTap;

  final Gradient? gradient;
  final Color? textColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    if (!(element?.visible ?? true)) {
      return const SizedBox.shrink();
    }

    final label = text.trim().isEmpty ? 'Buy' : text.trim();
    final effectiveGradient = runtimeStyle?.backgroundColor == null
        ? (gradient ?? MBDesignCardDefaults.orangeGradient)
        : null;
    final effectiveTextColor =
        runtimeStyle?.textColor ?? textColor ?? Colors.white;
    final effectiveShadowColor =
        shadowColor ?? MBDesignCardDefaults.orange.withValues(alpha: 0.24);
    final radius = runtimeStyle?.borderRadius ?? 999.0;
    final padding = runtimeStyle?.padding ??
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: runtimeStyle?.backgroundColor,
            gradient: effectiveGradient,
            borderRadius: BorderRadius.circular(radius),
            border: runtimeStyle?.borderColor == null
                ? null
                : Border.all(
                    color: runtimeStyle!.borderColor!,
                    width: runtimeStyle?.borderWidth ?? 1,
                  ),
            boxShadow: runtimeStyle?.boxShadow() ??
                [
                  BoxShadow(
                    color: effectiveShadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: runtimeStyle?.mergeTextStyle(
                  TextStyle(
                    color: effectiveTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ) ??
                TextStyle(
                  color: effectiveTextColor,
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
