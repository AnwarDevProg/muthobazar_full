import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_defaults.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_text_element.dart
//
// Purpose:
// Basic text element for title/subtitle/price labels.

class MBDesignTextElement extends StatelessWidget {
  const MBDesignTextElement({
    super.key,
    required this.text,
    this.element,
    this.defaultStyle,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final MBCardElementConfig? element;
  final TextStyle? defaultStyle;
  final int maxLines;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    if (!isVisible || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: _style(),
    );
  }

  bool get isVisible => element?.visible ?? true;

  TextStyle _style() {
    final style = element?.style;
    final base = defaultStyle ??
        const TextStyle(
          color: MBDesignCardDefaults.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.1,
        );

    return base.copyWith(
      fontSize: style?.fontSize ?? base.fontSize,
      color: _colorFromToken(style?.colorToken) ?? base.color,
      fontWeight: _fontWeight(style?.fontWeight) ?? base.fontWeight,
      fontStyle: _fontStyle(style?.fontStyle) ?? base.fontStyle,
    );
  }

  Color? _colorFromToken(String? token) {
    switch (token) {
      case 'text_inverse':
        return Colors.white;
      case 'text_orange':
        return MBDesignCardDefaults.orange;
      case 'text_muted':
        return MBDesignCardDefaults.textMuted;
      case 'text_secondary':
        return MBDesignCardDefaults.textSecondary;
      case 'text_primary':
        return MBDesignCardDefaults.textPrimary;
      default:
        return null;
    }
  }

  FontWeight? _fontWeight(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'w400':
      case 'normal':
        return FontWeight.w400;
      case 'w500':
      case 'medium':
        return FontWeight.w500;
      case 'w600':
      case 'semibold':
        return FontWeight.w600;
      case 'w700':
      case 'bold':
        return FontWeight.w700;
      case 'w800':
      case 'extra_bold':
        return FontWeight.w800;
      case 'w900':
      case 'black':
        return FontWeight.w900;
      default:
        return null;
    }
  }

  FontStyle? _fontStyle(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'italic':
        return FontStyle.italic;
      case 'normal':
        return FontStyle.normal;
      default:
        return null;
    }
  }
}
