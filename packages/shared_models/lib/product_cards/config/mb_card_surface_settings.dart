// MuthoBazar Product Card Design System
// File: mb_card_surface_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_surface_settings.dart
//
// Purpose:
// Defines the surface-level styling settings used by the product card system.
//
// Surface settings represent:
// - base background token selection
// - optional gradient token selection
// - corner radius
// - elevation depth
// - optional glass effect
// - optional 3D effect intent
// - spacing/padding scale
//
// Important:
// - This model is serializable and safe for persistence.
// - Token fields are stored as stable string ids, not concrete Color or Gradient
//   values. UI resolution must happen later in shared_ui.
// - This model does not perform rendering or token resolution.

class MBCardSurfaceSettings {
  const MBCardSurfaceSettings({
    this.backgroundColorToken,
    this.backgroundGradientToken,
    this.borderRadius = 16,
    this.elevationLevel = 1,
    this.useGlassEffect = false,
    this.use3DEffect = false,
    this.threeDDepth = 0,
    this.paddingScale = 1,
  });

  factory MBCardSurfaceSettings.fromMap(Map<String, dynamic> map) {
    return MBCardSurfaceSettings(
      backgroundColorToken: _readNullableString(
        map['backgroundColorToken'] ?? map['background_color_token'],
      ),
      backgroundGradientToken: _readNullableString(
        map['backgroundGradientToken'] ?? map['background_gradient_token'],
      ),
      borderRadius: _readDouble(map['borderRadius'] ?? map['border_radius'], 16),
      elevationLevel: _readDouble(
        map['elevationLevel'] ?? map['elevation_level'],
        1,
      ),
      useGlassEffect: _readBool(
        map['useGlassEffect'] ?? map['use_glass_effect'],
        false,
      ),
      use3DEffect: _readBool(
        map['use3DEffect'] ?? map['use_3d_effect'],
        false,
      ),
      threeDDepth: _readDouble(map['threeDDepth'] ?? map['three_d_depth'], 0),
      paddingScale: _readDouble(map['paddingScale'] ?? map['padding_scale'], 1),
    );
  }

  final String? backgroundColorToken;
  final String? backgroundGradientToken;
  final double borderRadius;
  final double elevationLevel;
  final bool useGlassEffect;
  final bool use3DEffect;
  final double threeDDepth;
  final double paddingScale;

  bool get hasBackgroundColorToken =>
      backgroundColorToken != null && backgroundColorToken!.trim().isNotEmpty;

  bool get hasBackgroundGradientToken =>
      backgroundGradientToken != null &&
          backgroundGradientToken!.trim().isNotEmpty;

  bool get hasSurfaceToken => hasBackgroundColorToken || hasBackgroundGradientToken;

  bool get hasDepthEffect => elevationLevel > 0 || use3DEffect || threeDDepth > 0;

  MBCardSurfaceSettings copyWith({
    Object? backgroundColorToken = _sentinel,
    Object? backgroundGradientToken = _sentinel,
    double? borderRadius,
    double? elevationLevel,
    bool? useGlassEffect,
    bool? use3DEffect,
    double? threeDDepth,
    double? paddingScale,
  }) {
    return MBCardSurfaceSettings(
      backgroundColorToken: identical(backgroundColorToken, _sentinel)
          ? this.backgroundColorToken
          : _normalizeNullableString(backgroundColorToken as String?),
      backgroundGradientToken: identical(backgroundGradientToken, _sentinel)
          ? this.backgroundGradientToken
          : _normalizeNullableString(backgroundGradientToken as String?),
      borderRadius: borderRadius ?? this.borderRadius,
      elevationLevel: elevationLevel ?? this.elevationLevel,
      useGlassEffect: useGlassEffect ?? this.useGlassEffect,
      use3DEffect: use3DEffect ?? this.use3DEffect,
      threeDDepth: threeDDepth ?? this.threeDDepth,
      paddingScale: paddingScale ?? this.paddingScale,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'backgroundColorToken': _normalizeNullableString(backgroundColorToken),
      'backgroundGradientToken':
      _normalizeNullableString(backgroundGradientToken),
      'borderRadius': borderRadius,
      'elevationLevel': elevationLevel,
      'useGlassEffect': useGlassEffect,
      'use3DEffect': use3DEffect,
      'threeDDepth': threeDDepth,
      'paddingScale': paddingScale,
    };
  }

  @override
  String toString() {
    return 'MBCardSurfaceSettings('
        'backgroundColorToken: $backgroundColorToken, '
        'backgroundGradientToken: $backgroundGradientToken, '
        'borderRadius: $borderRadius, '
        'elevationLevel: $elevationLevel, '
        'useGlassEffect: $useGlassEffect, '
        'use3DEffect: $use3DEffect, '
        'threeDDepth: $threeDDepth, '
        'paddingScale: $paddingScale'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardSurfaceSettings &&
        other.backgroundColorToken == backgroundColorToken &&
        other.backgroundGradientToken == backgroundGradientToken &&
        other.borderRadius == borderRadius &&
        other.elevationLevel == elevationLevel &&
        other.useGlassEffect == useGlassEffect &&
        other.use3DEffect == use3DEffect &&
        other.threeDDepth == threeDDepth &&
        other.paddingScale == paddingScale;
  }

  @override
  int get hashCode {
    return Object.hash(
      backgroundColorToken,
      backgroundGradientToken,
      borderRadius,
      elevationLevel,
      useGlassEffect,
      use3DEffect,
      threeDDepth,
      paddingScale,
    );
  }

  static const Object _sentinel = Object();

  static String? _readNullableString(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String? _normalizeNullableString(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static bool _readBool(Object? value, bool fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is bool) {
      return value;
    }

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    return fallback;
  }

  static double _readDouble(Object? value, double fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().trim()) ?? fallback;
  }
}
