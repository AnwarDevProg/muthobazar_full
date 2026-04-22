// MuthoBazar Product Card Design System
// File: mb_card_media_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_media_settings.dart
//
// Purpose:
// Defines the media/image presentation settings used by the product card system.
//
// Media settings represent:
// - how the product image should fit inside the card
// - image corner radius
// - optional image overlay opacity
// - whether image shadow should be shown
// - optional image frame style token/preset
// - overall image emphasis level
//
// Important:
// - This model is serializable and safe for persistence.
// - Style/token fields are stored as stable string ids, not concrete BoxFit,
//   border, frame, or shader objects. UI resolution must happen later in
//   shared_ui.
// - This model controls media presentation intent only. Exact rendering belongs
//   to the resolver and widget layer.

class MBCardMediaSettings {
  const MBCardMediaSettings({
    this.imageFitMode = 'cover',
    this.imageCornerRadius = 14,
    this.imageOverlayOpacity = 0,
    this.showImageShadow = false,
    this.imageFrameStyle,
    this.imageEmphasis = 1,
  });

  factory MBCardMediaSettings.fromMap(Map<String, dynamic> map) {
    return MBCardMediaSettings(
      imageFitMode: _readString(
        map['imageFitMode'] ?? map['image_fit_mode'],
        'cover',
      ),
      imageCornerRadius: _readDouble(
        map['imageCornerRadius'] ?? map['image_corner_radius'],
        14,
      ),
      imageOverlayOpacity: _readDouble(
        map['imageOverlayOpacity'] ?? map['image_overlay_opacity'],
        0,
      ),
      showImageShadow: _readBool(
        map['showImageShadow'] ?? map['show_image_shadow'],
        false,
      ),
      imageFrameStyle: _readNullableString(
        map['imageFrameStyle'] ?? map['image_frame_style'],
      ),
      imageEmphasis: _readDouble(
        map['imageEmphasis'] ?? map['image_emphasis'],
        1,
      ),
    );
  }

  final String imageFitMode;
  final double imageCornerRadius;
  final double imageOverlayOpacity;
  final bool showImageShadow;
  final String? imageFrameStyle;
  final double imageEmphasis;

  bool get hasImageFrameStyle =>
      imageFrameStyle != null && imageFrameStyle!.trim().isNotEmpty;

  bool get hasOverlay => imageOverlayOpacity > 0;

  bool get hasStrongEmphasis => imageEmphasis > 1;

  bool get isCoverMode => imageFitMode.trim().toLowerCase() == 'cover';

  bool get isContainMode => imageFitMode.trim().toLowerCase() == 'contain';

  bool get isFillMode => imageFitMode.trim().toLowerCase() == 'fill';

  MBCardMediaSettings copyWith({
    String? imageFitMode,
    double? imageCornerRadius,
    double? imageOverlayOpacity,
    bool? showImageShadow,
    Object? imageFrameStyle = _sentinel,
    double? imageEmphasis,
  }) {
    return MBCardMediaSettings(
      imageFitMode: imageFitMode ?? this.imageFitMode,
      imageCornerRadius: imageCornerRadius ?? this.imageCornerRadius,
      imageOverlayOpacity: imageOverlayOpacity ?? this.imageOverlayOpacity,
      showImageShadow: showImageShadow ?? this.showImageShadow,
      imageFrameStyle: identical(imageFrameStyle, _sentinel)
          ? this.imageFrameStyle
          : _normalizeNullableString(imageFrameStyle as String?),
      imageEmphasis: imageEmphasis ?? this.imageEmphasis,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imageFitMode': imageFitMode,
      'imageCornerRadius': imageCornerRadius,
      'imageOverlayOpacity': imageOverlayOpacity,
      'showImageShadow': showImageShadow,
      'imageFrameStyle': _normalizeNullableString(imageFrameStyle),
      'imageEmphasis': imageEmphasis,
    };
  }

  @override
  String toString() {
    return 'MBCardMediaSettings('
        'imageFitMode: $imageFitMode, '
        'imageCornerRadius: $imageCornerRadius, '
        'imageOverlayOpacity: $imageOverlayOpacity, '
        'showImageShadow: $showImageShadow, '
        'imageFrameStyle: $imageFrameStyle, '
        'imageEmphasis: $imageEmphasis'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardMediaSettings &&
        other.imageFitMode == imageFitMode &&
        other.imageCornerRadius == imageCornerRadius &&
        other.imageOverlayOpacity == imageOverlayOpacity &&
        other.showImageShadow == showImageShadow &&
        other.imageFrameStyle == imageFrameStyle &&
        other.imageEmphasis == imageEmphasis;
  }

  @override
  int get hashCode {
    return Object.hash(
      imageFitMode,
      imageCornerRadius,
      imageOverlayOpacity,
      showImageShadow,
      imageFrameStyle,
      imageEmphasis,
    );
  }

  static const Object _sentinel = Object();

  static String _readString(Object? value, String fallback) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return fallback;
    }
    return normalized;
  }

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
