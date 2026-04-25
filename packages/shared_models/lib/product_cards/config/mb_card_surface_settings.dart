// MuthoBazar Product Card Design System
// File: mb_card_surface_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_surface_settings.dart
//
// Purpose:
// Defines card surface-level visual settings. This model keeps all fields safe
// for persistence and supports optional future styling without changing product
// documents again.
//
// Empty/missing Firestore values are accepted through fromMap fallbacks.
// Token fields are stable string ids; shared_ui resolves actual Color/Gradient.

class MBCardSurfaceSettings {
  const MBCardSurfaceSettings({
    this.backgroundColorToken,
    this.backgroundGradientToken,
    this.borderRadius = 16,
    this.cornerStyle = 'rounded',
    this.elevationLevel = 1,
    this.useGlassEffect = false,
    this.use3DEffect = false,
    this.threeDDepth = 0,
    this.paddingScale = 1,
    this.showShadow = true,
    this.shadowStyleToken,
    this.surfaceOpacity = 1,
    this.borderClipBehavior = 'anti_alias',
  });

  factory MBCardSurfaceSettings.fromMap(Map map) {
    return MBCardSurfaceSettings(
      backgroundColorToken: _readNullableString(
        map['backgroundColorToken'] ?? map['background_color_token'],
      ),
      backgroundGradientToken: _readNullableString(
        map['backgroundGradientToken'] ??
            map['background_gradient_token'] ??
            map['gradientToken'] ??
            map['gradient_token'],
      ),
      borderRadius: _readDouble(map['borderRadius'] ?? map['border_radius'], 16),
      cornerStyle: _readString(map['cornerStyle'] ?? map['corner_style'], 'rounded'),
      elevationLevel: _readDouble(map['elevationLevel'] ?? map['elevation_level'], 1),
      useGlassEffect: _readBool(map['useGlassEffect'] ?? map['use_glass_effect'], false),
      use3DEffect: _readBool(map['use3DEffect'] ?? map['use_3d_effect'], false),
      threeDDepth: _readDouble(map['threeDDepth'] ?? map['three_d_depth'], 0),
      paddingScale: _readDouble(map['paddingScale'] ?? map['padding_scale'], 1),
      showShadow: _readBool(map['showShadow'] ?? map['show_shadow'], true),
      shadowStyleToken: _readNullableString(
        map['shadowStyleToken'] ?? map['shadow_style_token'],
      ),
      surfaceOpacity: _readDouble(map['surfaceOpacity'] ?? map['surface_opacity'], 1),
      borderClipBehavior: _readString(
        map['borderClipBehavior'] ?? map['border_clip_behavior'],
        'anti_alias',
      ),
    );
  }

  final String? backgroundColorToken;
  final String? backgroundGradientToken;
  final double borderRadius;
  final String cornerStyle;
  final double elevationLevel;
  final bool useGlassEffect;
  final bool use3DEffect;
  final double threeDDepth;
  final double paddingScale;
  final bool showShadow;
  final String? shadowStyleToken;
  final double surfaceOpacity;
  final String borderClipBehavior;

  String? get gradientToken => backgroundGradientToken;

  bool get hasBackgroundColorToken =>
      backgroundColorToken != null && backgroundColorToken!.trim().isNotEmpty;
  bool get hasBackgroundGradientToken =>
      backgroundGradientToken != null && backgroundGradientToken!.trim().isNotEmpty;
  bool get hasSurfaceToken => hasBackgroundColorToken || hasBackgroundGradientToken;
  bool get hasDepthEffect => elevationLevel > 0 || use3DEffect || threeDDepth > 0;
  bool get isSquareCorner => cornerStyle.trim().toLowerCase() == 'square';
  bool get isRoundedCorner => cornerStyle.trim().toLowerCase() == 'rounded';

  MBCardSurfaceSettings copyWith({
    Object? backgroundColorToken = _sentinel,
    Object? backgroundGradientToken = _sentinel,
    double? borderRadius,
    String? cornerStyle,
    double? elevationLevel,
    bool? useGlassEffect,
    bool? use3DEffect,
    double? threeDDepth,
    double? paddingScale,
    bool? showShadow,
    Object? shadowStyleToken = _sentinel,
    double? surfaceOpacity,
    String? borderClipBehavior,
  }) {
    return MBCardSurfaceSettings(
      backgroundColorToken: identical(backgroundColorToken, _sentinel)
          ? this.backgroundColorToken
          : _normalizeNullableString(backgroundColorToken as String?),
      backgroundGradientToken: identical(backgroundGradientToken, _sentinel)
          ? this.backgroundGradientToken
          : _normalizeNullableString(backgroundGradientToken as String?),
      borderRadius: borderRadius ?? this.borderRadius,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      elevationLevel: elevationLevel ?? this.elevationLevel,
      useGlassEffect: useGlassEffect ?? this.useGlassEffect,
      use3DEffect: use3DEffect ?? this.use3DEffect,
      threeDDepth: threeDDepth ?? this.threeDDepth,
      paddingScale: paddingScale ?? this.paddingScale,
      showShadow: showShadow ?? this.showShadow,
      shadowStyleToken: identical(shadowStyleToken, _sentinel)
          ? this.shadowStyleToken
          : _normalizeNullableString(shadowStyleToken as String?),
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      borderClipBehavior: borderClipBehavior ?? this.borderClipBehavior,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'backgroundColorToken': _normalizeNullableString(backgroundColorToken),
      'backgroundGradientToken': _normalizeNullableString(backgroundGradientToken),
      'borderRadius': borderRadius,
      'cornerStyle': cornerStyle,
      'elevationLevel': elevationLevel,
      'useGlassEffect': useGlassEffect,
      'use3DEffect': use3DEffect,
      'threeDDepth': threeDDepth,
      'paddingScale': paddingScale,
      'showShadow': showShadow,
      'shadowStyleToken': _normalizeNullableString(shadowStyleToken),
      'surfaceOpacity': surfaceOpacity,
      'borderClipBehavior': borderClipBehavior,
    };
  }

  static const Object _sentinel = Object();
}


String? _readNullableString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

String _readString(Object? value, String fallback) {
  return _readNullableString(value) ?? fallback;
}

bool _readBool(Object? value, bool fallback) {
  if (value == null) return fallback;
  if (value is bool) return value;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return fallback;
}

int _readInt(Object? value, int fallback) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? fallback;
}

double _readDouble(Object? value, double fallback) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? fallback;
}

String? _normalizeNullableString(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
