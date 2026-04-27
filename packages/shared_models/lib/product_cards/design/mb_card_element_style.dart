// Generic style overrides for an element.
// Renderer decides which fields are supported by each element/template.

class MBCardElementStyle {
  const MBCardElementStyle({
    this.colorToken,
    this.backgroundColorToken,
    this.gradientToken,
    this.borderColorToken,
    this.shadowToken,
    this.textStyleToken,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.borderRadius,
    this.borderWidth,
    this.opacity,
    this.rotation,
    this.paddingScale,
    this.spacingScale,
    this.effectPreset,
    this.extra = const <String, Object?>{},
  });

  factory MBCardElementStyle.fromMap(Map map) {
    return MBCardElementStyle(
      colorToken: _stringOrNull(map['colorToken'] ?? map['color_token']),
      backgroundColorToken: _stringOrNull(map['backgroundColorToken'] ?? map['background_color_token']),
      gradientToken: _stringOrNull(map['gradientToken'] ?? map['gradient_token']),
      borderColorToken: _stringOrNull(map['borderColorToken'] ?? map['border_color_token']),
      shadowToken: _stringOrNull(map['shadowToken'] ?? map['shadow_token']),
      textStyleToken: _stringOrNull(map['textStyleToken'] ?? map['text_style_token']),
      fontSize: _double(map['fontSize'] ?? map['font_size']),
      fontWeight: _stringOrNull(map['fontWeight'] ?? map['font_weight']),
      fontStyle: _stringOrNull(map['fontStyle'] ?? map['font_style']),
      borderRadius: _double(map['borderRadius'] ?? map['border_radius']),
      borderWidth: _double(map['borderWidth'] ?? map['border_width']),
      opacity: _double(map['opacity']),
      rotation: _double(map['rotation']),
      paddingScale: _double(map['paddingScale'] ?? map['padding_scale']),
      spacingScale: _double(map['spacingScale'] ?? map['spacing_scale']),
      effectPreset: _stringOrNull(map['effectPreset'] ?? map['effect_preset']),
      extra: _objectMap(map['extra']),
    );
  }

  final String? colorToken;
  final String? backgroundColorToken;
  final String? gradientToken;
  final String? borderColorToken;
  final String? shadowToken;
  final String? textStyleToken;
  final double? fontSize;
  final String? fontWeight;
  final String? fontStyle;
  final double? borderRadius;
  final double? borderWidth;
  final double? opacity;
  final double? rotation;
  final double? paddingScale;
  final double? spacingScale;
  final String? effectPreset;
  final Map<String, Object?> extra;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() => _cleanMap({
        'colorToken': colorToken,
        'backgroundColorToken': backgroundColorToken,
        'gradientToken': gradientToken,
        'borderColorToken': borderColorToken,
        'shadowToken': shadowToken,
        'textStyleToken': textStyleToken,
        'fontSize': fontSize,
        'fontWeight': fontWeight,
        'fontStyle': fontStyle,
        'borderRadius': borderRadius,
        'borderWidth': borderWidth,
        'opacity': opacity,
        'rotation': rotation,
        'paddingScale': paddingScale,
        'spacingScale': spacingScale,
        'effectPreset': effectPreset,
        if (extra.isNotEmpty) 'extra': extra,
      });
}

String? _stringOrNull(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

double? _double(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is Map<String, Object?>) return Map<String, Object?>.from(value);
  if (value is Map) return value.map((key, val) => MapEntry(key.toString(), val));
  return const <String, Object?>{};
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(map.entries.where((entry) {
    final value = entry.value;
    if (value == null) return false;
    if (value is String && value.isEmpty) return false;
    if (value is Iterable && value.isEmpty) return false;
    if (value is Map && value.isEmpty) return false;
    return true;
  }));
}
