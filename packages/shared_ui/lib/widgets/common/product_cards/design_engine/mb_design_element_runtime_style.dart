import 'package:flutter/material.dart';
import 'package:shared_models/product_cards/design/mb_card_design_models.dart';

// MuthoBazar Design Element Runtime Style
// --------------------------------------
// Per-element visual styling for the new free-design product-card renderer.
//
// Stored format inside cardDesignJson:
//
// "elementStyles": {
//   "title": {
//     "fontSize": 18,
//     "fontWeight": "w900",
//     "textColorHex": "#FFFFFF"
//   },
//   "secondaryCta": {
//     "backgroundHex": "#FF6500",
//     "textColorHex": "#FFFFFF",
//     "borderRadius": 999,
//     "paddingX": 12,
//     "paddingY": 7
//   }
// }

class MBDesignElementRuntimeStyles {
  const MBDesignElementRuntimeStyles(this.styles);

  final Map<String, MBDesignElementRuntimeStyle> styles;

  factory MBDesignElementRuntimeStyles.fromConfig(MBCardDesignConfig config) {
    final raw = config.metadata['elementStyles'];

    if (raw is! Map) {
      return const MBDesignElementRuntimeStyles(
        <String, MBDesignElementRuntimeStyle>{},
      );
    }

    return MBDesignElementRuntimeStyles.fromMap(raw);
  }

  factory MBDesignElementRuntimeStyles.fromMap(Map raw) {
    final parsed = <String, MBDesignElementRuntimeStyle>{};

    for (final entry in raw.entries) {
      final key = entry.key.toString().trim();
      final value = entry.value;

      if (key.isEmpty || value is! Map) {
        continue;
      }

      parsed[key] = MBDesignElementRuntimeStyle.fromMap(value);
    }

    return MBDesignElementRuntimeStyles(parsed);
  }

  MBDesignElementRuntimeStyle? of(String elementId) {
    final normalized = elementId.trim();
    if (normalized.isEmpty) return null;

    final value = styles[normalized];
    if (value == null || value.isEmpty) return null;

    return value;
  }
}

class MBDesignElementRuntimeStyle {
  const MBDesignElementRuntimeStyle({
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.textAlign,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.ringColor,
    this.borderRadius,
    this.borderWidth,
    this.paddingX,
    this.paddingY,
    this.shadowOpacity,
    this.shadowBlur,
    this.shadowDy,
    this.ringWidth,
  });

  factory MBDesignElementRuntimeStyle.fromMap(Map raw) {
    return MBDesignElementRuntimeStyle(
      fontSize: _readDouble(raw['fontSize']),
      fontWeight: _readFontWeight(raw['fontWeight']),
      fontStyle: _readFontStyle(raw['fontStyle']),
      textAlign: _readTextAlign(raw['textAlign']),
      textColor: _readColor(raw['textColorHex'] ?? raw['colorHex']),
      backgroundColor: _readColor(raw['backgroundHex']),
      borderColor: _readColor(raw['borderHex']),
      shadowColor: _readColor(raw['shadowHex']),
      ringColor: _readColor(raw['ringHex']),
      borderRadius: _readDouble(raw['borderRadius']),
      borderWidth: _readDouble(raw['borderWidth']),
      paddingX: _readDouble(raw['paddingX']),
      paddingY: _readDouble(raw['paddingY']),
      shadowOpacity: _readDouble(raw['shadowOpacity']),
      shadowBlur: _readDouble(raw['shadowBlur']),
      shadowDy: _readDouble(raw['shadowDy']),
      ringWidth: _readDouble(raw['ringWidth']),
    );
  }

  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextAlign? textAlign;

  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final Color? ringColor;

  final double? borderRadius;
  final double? borderWidth;
  final double? paddingX;
  final double? paddingY;
  final double? shadowOpacity;
  final double? shadowBlur;
  final double? shadowDy;
  final double? ringWidth;

  bool get isEmpty {
    return fontSize == null &&
        fontWeight == null &&
        fontStyle == null &&
        textAlign == null &&
        textColor == null &&
        backgroundColor == null &&
        borderColor == null &&
        shadowColor == null &&
        ringColor == null &&
        borderRadius == null &&
        borderWidth == null &&
        paddingX == null &&
        paddingY == null &&
        shadowOpacity == null &&
        shadowBlur == null &&
        shadowDy == null &&
        ringWidth == null;
  }

  EdgeInsets? get padding {
    if (paddingX == null && paddingY == null) {
      return null;
    }

    return EdgeInsets.symmetric(
      horizontal: paddingX ?? 0,
      vertical: paddingY ?? 0,
    );
  }

  TextStyle mergeTextStyle(TextStyle base) {
    return base.copyWith(
      color: textColor ?? base.color,
      fontSize: fontSize ?? base.fontSize,
      fontWeight: fontWeight ?? base.fontWeight,
      fontStyle: fontStyle ?? base.fontStyle,
    );
  }

  List<BoxShadow>? boxShadow() {
    if (shadowBlur == null &&
        shadowDy == null &&
        shadowOpacity == null &&
        shadowColor == null) {
      return null;
    }

    final color = shadowColor ?? Colors.black;

    return [
      BoxShadow(
        color: color.withValues(alpha: shadowOpacity ?? 0.14),
        blurRadius: shadowBlur ?? 12,
        offset: Offset(0, shadowDy ?? 4),
      ),
    ];
  }

  static double? _readDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().trim());
  }

  static Color? _readColor(Object? value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;

    final normalized = raw.startsWith('#') ? raw.substring(1) : raw;
    if (normalized.length != 6 && normalized.length != 8) {
      return null;
    }

    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;

    if (normalized.length == 6) {
      return Color(0xFF000000 | parsed);
    }

    return Color(parsed);
  }

  static FontWeight? _readFontWeight(Object? value) {
    final text = value?.toString().toLowerCase().trim();

    switch (text) {
      case 'w300':
      case '300':
      case 'light':
        return FontWeight.w300;
      case 'w400':
      case '400':
      case 'normal':
        return FontWeight.w400;
      case 'w500':
      case '500':
      case 'medium':
        return FontWeight.w500;
      case 'w600':
      case '600':
      case 'semibold':
        return FontWeight.w600;
      case 'w700':
      case '700':
      case 'bold':
        return FontWeight.w700;
      case 'w800':
      case '800':
      case 'extra_bold':
        return FontWeight.w800;
      case 'w900':
      case '900':
      case 'black':
        return FontWeight.w900;
      default:
        return null;
    }
  }

  static FontStyle? _readFontStyle(Object? value) {
    final text = value?.toString().toLowerCase().trim();

    switch (text) {
      case 'italic':
        return FontStyle.italic;
      case 'normal':
        return FontStyle.normal;
      default:
        return null;
    }
  }

  static TextAlign? _readTextAlign(Object? value) {
    final text = value?.toString().toLowerCase().trim();

    switch (text) {
      case 'left':
      case 'start':
        return TextAlign.start;
      case 'right':
      case 'end':
        return TextAlign.end;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }
}

MBDesignElementRuntimeStyles mbResolveDesignElementRuntimeStyles(
  BuildContext context,
  MBCardDesignConfig config,
) {
  final scoped = MBDesignElementRuntimeStyleScope.maybeOf(context);
  return scoped ?? MBDesignElementRuntimeStyles.fromConfig(config);
}

class MBDesignElementRuntimeStyleScope extends InheritedWidget {
  const MBDesignElementRuntimeStyleScope({
    super.key,
    required this.styles,
    required super.child,
  });

  final MBDesignElementRuntimeStyles styles;

  static MBDesignElementRuntimeStyles? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MBDesignElementRuntimeStyleScope>();
    return scope?.styles;
  }

  @override
  bool updateShouldNotify(MBDesignElementRuntimeStyleScope oldWidget) {
    return styles != oldWidget.styles;
  }
}
