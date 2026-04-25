// MuthoBazar Product Card Design System
// File: mb_card_media_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_media_settings.dart
//
// Purpose:
// Defines product image/media presentation settings.

class MBCardMediaSettings {
  const MBCardMediaSettings({
    this.imageFitMode = 'cover',
    this.imageShape = 'rounded',
    this.imageCornerRadius = 14,
    this.imageOverlayOpacity = 0,
    this.showImageShadow = false,
    this.imageFrameStyle,
    this.imageBackgroundToken,
    this.imageEmphasis = 1,
    this.imageSizeRatio,
    this.imageTopRatio,
    this.imageLeftRatio,
    this.imageRingThickness,
    this.showImageFrame = false,
    this.enableImageZoom = false,
  });

  factory MBCardMediaSettings.fromMap(Map map) {
    return MBCardMediaSettings(
      imageFitMode: _readString(map['imageFitMode'] ?? map['image_fit_mode'], 'cover'),
      imageShape: _readString(map['imageShape'] ?? map['image_shape'], 'rounded'),
      imageCornerRadius: _readDouble(map['imageCornerRadius'] ?? map['image_corner_radius'], 14),
      imageOverlayOpacity: _readDouble(map['imageOverlayOpacity'] ?? map['image_overlay_opacity'], 0),
      showImageShadow: _readBool(map['showImageShadow'] ?? map['show_image_shadow'], false),
      imageFrameStyle: _readNullableString(map['imageFrameStyle'] ?? map['image_frame_style']),
      imageBackgroundToken: _readNullableString(map['imageBackgroundToken'] ?? map['image_background_token']),
      imageEmphasis: _readDouble(map['imageEmphasis'] ?? map['image_emphasis'], 1),
      imageSizeRatio: _readNullableDouble(map['imageSizeRatio'] ?? map['image_size_ratio']),
      imageTopRatio: _readNullableDouble(map['imageTopRatio'] ?? map['image_top_ratio']),
      imageLeftRatio: _readNullableDouble(map['imageLeftRatio'] ?? map['image_left_ratio']),
      imageRingThickness: _readNullableDouble(map['imageRingThickness'] ?? map['image_ring_thickness']),
      showImageFrame: _readBool(map['showImageFrame'] ?? map['show_image_frame'], false),
      enableImageZoom: _readBool(map['enableImageZoom'] ?? map['enable_image_zoom'], false),
    );
  }

  final String imageFitMode;
  final String imageShape;
  final double imageCornerRadius;
  final double imageOverlayOpacity;
  final bool showImageShadow;
  final String? imageFrameStyle;
  final String? imageBackgroundToken;
  final double imageEmphasis;
  final double? imageSizeRatio;
  final double? imageTopRatio;
  final double? imageLeftRatio;
  final double? imageRingThickness;
  final bool showImageFrame;
  final bool enableImageZoom;

  bool get hasImageFrameStyle => imageFrameStyle != null && imageFrameStyle!.trim().isNotEmpty;
  bool get hasOverlay => imageOverlayOpacity > 0;
  bool get hasStrongEmphasis => imageEmphasis > 1;
  bool get isCoverMode => imageFitMode.trim().toLowerCase() == 'cover';
  bool get isContainMode => imageFitMode.trim().toLowerCase() == 'contain';
  bool get isFillMode => imageFitMode.trim().toLowerCase() == 'fill';
  bool get isCircleShape => imageShape.trim().toLowerCase() == 'circle';

  MBCardMediaSettings copyWith({
    String? imageFitMode,
    String? imageShape,
    double? imageCornerRadius,
    double? imageOverlayOpacity,
    bool? showImageShadow,
    Object? imageFrameStyle = _sentinel,
    Object? imageBackgroundToken = _sentinel,
    double? imageEmphasis,
    Object? imageSizeRatio = _sentinel,
    Object? imageTopRatio = _sentinel,
    Object? imageLeftRatio = _sentinel,
    Object? imageRingThickness = _sentinel,
    bool? showImageFrame,
    bool? enableImageZoom,
  }) {
    return MBCardMediaSettings(
      imageFitMode: imageFitMode ?? this.imageFitMode,
      imageShape: imageShape ?? this.imageShape,
      imageCornerRadius: imageCornerRadius ?? this.imageCornerRadius,
      imageOverlayOpacity: imageOverlayOpacity ?? this.imageOverlayOpacity,
      showImageShadow: showImageShadow ?? this.showImageShadow,
      imageFrameStyle: identical(imageFrameStyle, _sentinel)
          ? this.imageFrameStyle
          : _normalizeNullableString(imageFrameStyle as String?),
      imageBackgroundToken: identical(imageBackgroundToken, _sentinel)
          ? this.imageBackgroundToken
          : _normalizeNullableString(imageBackgroundToken as String?),
      imageEmphasis: imageEmphasis ?? this.imageEmphasis,
      imageSizeRatio: identical(imageSizeRatio, _sentinel)
          ? this.imageSizeRatio
          : _readNullableDouble(imageSizeRatio),
      imageTopRatio: identical(imageTopRatio, _sentinel)
          ? this.imageTopRatio
          : _readNullableDouble(imageTopRatio),
      imageLeftRatio: identical(imageLeftRatio, _sentinel)
          ? this.imageLeftRatio
          : _readNullableDouble(imageLeftRatio),
      imageRingThickness: identical(imageRingThickness, _sentinel)
          ? this.imageRingThickness
          : _readNullableDouble(imageRingThickness),
      showImageFrame: showImageFrame ?? this.showImageFrame,
      enableImageZoom: enableImageZoom ?? this.enableImageZoom,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'imageFitMode': imageFitMode,
      'imageShape': imageShape,
      'imageCornerRadius': imageCornerRadius,
      'imageOverlayOpacity': imageOverlayOpacity,
      'showImageShadow': showImageShadow,
      'imageFrameStyle': _normalizeNullableString(imageFrameStyle),
      'imageBackgroundToken': _normalizeNullableString(imageBackgroundToken),
      'imageEmphasis': imageEmphasis,
      'imageSizeRatio': imageSizeRatio,
      'imageTopRatio': imageTopRatio,
      'imageLeftRatio': imageLeftRatio,
      'imageRingThickness': imageRingThickness,
      'showImageFrame': showImageFrame,
      'enableImageZoom': enableImageZoom,
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


double? _readNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}
