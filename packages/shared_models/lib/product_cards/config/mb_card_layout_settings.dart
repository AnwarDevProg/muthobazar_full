// MuthoBazar Product Card Design System
// File: mb_card_layout_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_layout_settings.dart
//
// Purpose:
// Defines optional layout tuning hints for product-card variants.
//
// Important:
// - Variant structure should stay mostly fixed.
// - These values are optional hints for variants that explicitly support them.
// - null means "not overridden"; empty map means "no custom layout settings".

class MBCardLayoutSettings {
  const MBCardLayoutSettings({
    this.footprint,
    this.aspectRatio,
    this.minHeight,
    this.maxHeight,
    this.contentAlignment,
    this.imagePosition,
    this.pricePosition,
    this.ctaPosition,
    this.sectionGap,
  });

  factory MBCardLayoutSettings.fromMap(Map map) {
    return MBCardLayoutSettings(
      footprint: _readNullableString(map['footprint']),
      aspectRatio: _readNullableDouble(map['aspectRatio'] ?? map['aspect_ratio']),
      minHeight: _readNullableDouble(map['minHeight'] ?? map['min_height']),
      maxHeight: _readNullableDouble(map['maxHeight'] ?? map['max_height']),
      contentAlignment: _readNullableString(
        map['contentAlignment'] ?? map['content_alignment'],
      ),
      imagePosition: _readNullableString(
        map['imagePosition'] ?? map['image_position'],
      ),
      pricePosition: _readNullableString(
        map['pricePosition'] ?? map['price_position'],
      ),
      ctaPosition: _readNullableString(
        map['ctaPosition'] ?? map['cta_position'],
      ),
      sectionGap: _readNullableDouble(map['sectionGap'] ?? map['section_gap']),
    );
  }

  final String? footprint;
  final double? aspectRatio;
  final double? minHeight;
  final double? maxHeight;
  final String? contentAlignment;
  final String? imagePosition;
  final String? pricePosition;
  final String? ctaPosition;
  final double? sectionGap;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  MBCardLayoutSettings copyWith({
    Object? footprint = _sentinel,
    Object? aspectRatio = _sentinel,
    Object? minHeight = _sentinel,
    Object? maxHeight = _sentinel,
    Object? contentAlignment = _sentinel,
    Object? imagePosition = _sentinel,
    Object? pricePosition = _sentinel,
    Object? ctaPosition = _sentinel,
    Object? sectionGap = _sentinel,
  }) {
    return MBCardLayoutSettings(
      footprint: identical(footprint, _sentinel)
          ? this.footprint
          : _readNullableString(footprint),
      aspectRatio: identical(aspectRatio, _sentinel)
          ? this.aspectRatio
          : _readNullableDouble(aspectRatio),
      minHeight: identical(minHeight, _sentinel)
          ? this.minHeight
          : _readNullableDouble(minHeight),
      maxHeight: identical(maxHeight, _sentinel)
          ? this.maxHeight
          : _readNullableDouble(maxHeight),
      contentAlignment: identical(contentAlignment, _sentinel)
          ? this.contentAlignment
          : _readNullableString(contentAlignment),
      imagePosition: identical(imagePosition, _sentinel)
          ? this.imagePosition
          : _readNullableString(imagePosition),
      pricePosition: identical(pricePosition, _sentinel)
          ? this.pricePosition
          : _readNullableString(pricePosition),
      ctaPosition: identical(ctaPosition, _sentinel)
          ? this.ctaPosition
          : _readNullableString(ctaPosition),
      sectionGap: identical(sectionGap, _sentinel)
          ? this.sectionGap
          : _readNullableDouble(sectionGap),
    );
  }

  Map<String, Object?> toMap() {
    return _cleanMap({
      'footprint': footprint,
      'aspectRatio': aspectRatio,
      'minHeight': minHeight,
      'maxHeight': maxHeight,
      'contentAlignment': contentAlignment,
      'imagePosition': imagePosition,
      'pricePosition': pricePosition,
      'ctaPosition': ctaPosition,
      'sectionGap': sectionGap,
    });
  }

  static const Object _sentinel = Object();
}


String? _readNullableString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

bool? _readNullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

double? _readNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(
    map.entries.where((entry) => entry.value != null),
  );
}
