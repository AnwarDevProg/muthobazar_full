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
//
// Layout height rule:
// Parent layouts such as Home/category/search should resolve card height from:
// cardConfig.settings.layout
// -> variant/family defaults
// -> safe system fallback.
//
// Width / height aspectRatio example:
// available card width = 170
// aspectRatio = 0.50
// preferred height = 170 / 0.50 = 340

class MBCardLayoutSettings {
  const MBCardLayoutSettings({
    this.footprint,
    this.aspectRatio,
    this.preferredAspectRatio,
    this.preferredHeight,
    this.minHeight,
    this.maxHeight,
    this.canShrink,
    this.canExpand,
    this.maxShrinkPercent,
    this.maxExpandPercent,
    this.contentAlignment,
    this.imagePosition,
    this.pricePosition,
    this.ctaPosition,
    this.sectionGap,
  });

  factory MBCardLayoutSettings.fromMap(Map map) {
    return MBCardLayoutSettings(
      footprint: _readNullableString(map['footprint']),
      aspectRatio: _readNullableDouble(
        map['aspectRatio'] ?? map['aspect_ratio'],
      ),
      preferredAspectRatio: _readNullableDouble(
        map['preferredAspectRatio'] ?? map['preferred_aspect_ratio'],
      ),
      preferredHeight: _readNullableDouble(
        map['preferredHeight'] ??
            map['preferred_height'] ??
            map['height'] ??
            map['slotHeight'] ??
            map['slot_height'],
      ),
      minHeight: _readNullableDouble(
        map['minHeight'] ??
            map['min_height'] ??
            map['minimumHeight'] ??
            map['minimum_height'],
      ),
      maxHeight: _readNullableDouble(
        map['maxHeight'] ??
            map['max_height'] ??
            map['maximumHeight'] ??
            map['maximum_height'],
      ),
      canShrink: _readNullableBool(
        map['canShrink'] ?? map['can_shrink'],
      ),
      canExpand: _readNullableBool(
        map['canExpand'] ?? map['can_expand'],
      ),
      maxShrinkPercent: _readNullableDouble(
        map['maxShrinkPercent'] ?? map['max_shrink_percent'],
      ),
      maxExpandPercent: _readNullableDouble(
        map['maxExpandPercent'] ?? map['max_expand_percent'],
      ),
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
      sectionGap: _readNullableDouble(
        map['sectionGap'] ?? map['section_gap'],
      ),
    );
  }

  // Useful until full variant registry stores this centrally.
  factory MBCardLayoutSettings.variantDefaults({
    required String familyId,
    required String variantId,
  }) {
    final family = familyId.trim().toLowerCase();
    final variant = variantId.trim().toLowerCase();

    if (variant == 'compact01') {
      return const MBCardLayoutSettings(
        footprint: 'half',
        aspectRatio: 0.58,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 7,
        maxExpandPercent: 12,
      );
    }

    if (variant == 'compact02') {
      return const MBCardLayoutSettings(
        footprint: 'half',
        aspectRatio: 0.42,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 6,
        maxExpandPercent: 12,
      );
    }

    if (variant == 'compact05') {
      return const MBCardLayoutSettings(
        footprint: 'half',
        aspectRatio: 0.44,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 6,
        maxExpandPercent: 12,
      );
    }

    if (family == 'premium' || variant.startsWith('premium')) {
      return const MBCardLayoutSettings(
        footprint: 'half',
        aspectRatio: 0.46,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 6,
        maxExpandPercent: 10,
      );
    }

    if (family == 'flash_sale' || variant.startsWith('flash')) {
      return const MBCardLayoutSettings(
        footprint: 'half',
        aspectRatio: 0.50,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 7,
        maxExpandPercent: 10,
      );
    }

    if (family == 'price' || variant.startsWith('price')) {
      return const MBCardLayoutSettings(
        footprint: 'half',
        aspectRatio: 0.50,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 7,
        maxExpandPercent: 10,
      );
    }

    if (family == 'horizontal' || variant.startsWith('horizontal')) {
      return const MBCardLayoutSettings(
        footprint: 'full',
        aspectRatio: 1.70,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 6,
        maxExpandPercent: 10,
      );
    }

    if (family == 'wide' || variant.startsWith('wide')) {
      return const MBCardLayoutSettings(
        footprint: 'full',
        aspectRatio: 0.86,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 6,
        maxExpandPercent: 10,
      );
    }

    if (family == 'promo' || variant.startsWith('promo')) {
      return const MBCardLayoutSettings(
        footprint: 'full',
        aspectRatio: 1.05,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 6,
        maxExpandPercent: 10,
      );
    }

    if (family == 'featured' || variant.startsWith('featured')) {
      return const MBCardLayoutSettings(
        footprint: 'full',
        aspectRatio: 0.95,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 5,
        maxExpandPercent: 8,
      );
    }

    return const MBCardLayoutSettings(
      aspectRatio: 0.58,
      canShrink: true,
      canExpand: true,
      maxShrinkPercent: 7,
      maxExpandPercent: 12,
    );
  }

  final String? footprint;

  // Width / height.
  final double? aspectRatio;
  final double? preferredAspectRatio;

  // Exact slot-height controls.
  final double? preferredHeight;
  final double? minHeight;
  final double? maxHeight;

  // Elastic behavior for row pairing and gap filler logic.
  final bool? canShrink;
  final bool? canExpand;
  final double? maxShrinkPercent;
  final double? maxExpandPercent;

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
    Object? preferredAspectRatio = _sentinel,
    Object? preferredHeight = _sentinel,
    Object? minHeight = _sentinel,
    Object? maxHeight = _sentinel,
    Object? canShrink = _sentinel,
    Object? canExpand = _sentinel,
    Object? maxShrinkPercent = _sentinel,
    Object? maxExpandPercent = _sentinel,
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
      preferredAspectRatio: identical(preferredAspectRatio, _sentinel)
          ? this.preferredAspectRatio
          : _readNullableDouble(preferredAspectRatio),
      preferredHeight: identical(preferredHeight, _sentinel)
          ? this.preferredHeight
          : _readNullableDouble(preferredHeight),
      minHeight: identical(minHeight, _sentinel)
          ? this.minHeight
          : _readNullableDouble(minHeight),
      maxHeight: identical(maxHeight, _sentinel)
          ? this.maxHeight
          : _readNullableDouble(maxHeight),
      canShrink: identical(canShrink, _sentinel)
          ? this.canShrink
          : _readNullableBool(canShrink),
      canExpand: identical(canExpand, _sentinel)
          ? this.canExpand
          : _readNullableBool(canExpand),
      maxShrinkPercent: identical(maxShrinkPercent, _sentinel)
          ? this.maxShrinkPercent
          : _readNullableDouble(maxShrinkPercent),
      maxExpandPercent: identical(maxExpandPercent, _sentinel)
          ? this.maxExpandPercent
          : _readNullableDouble(maxExpandPercent),
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

  MBCardLayoutSettings mergeMissing(MBCardLayoutSettings fallback) {
    return MBCardLayoutSettings(
      footprint: footprint ?? fallback.footprint,
      aspectRatio: aspectRatio ?? fallback.aspectRatio,
      preferredAspectRatio: preferredAspectRatio ?? fallback.preferredAspectRatio,
      preferredHeight: preferredHeight ?? fallback.preferredHeight,
      minHeight: minHeight ?? fallback.minHeight,
      maxHeight: maxHeight ?? fallback.maxHeight,
      canShrink: canShrink ?? fallback.canShrink,
      canExpand: canExpand ?? fallback.canExpand,
      maxShrinkPercent: maxShrinkPercent ?? fallback.maxShrinkPercent,
      maxExpandPercent: maxExpandPercent ?? fallback.maxExpandPercent,
      contentAlignment: contentAlignment ?? fallback.contentAlignment,
      imagePosition: imagePosition ?? fallback.imagePosition,
      pricePosition: pricePosition ?? fallback.pricePosition,
      ctaPosition: ctaPosition ?? fallback.ctaPosition,
      sectionGap: sectionGap ?? fallback.sectionGap,
    );
  }

  Map<String, Object?> toMap() {
    return _cleanMap({
      'footprint': footprint,
      'aspectRatio': aspectRatio,
      'preferredAspectRatio': preferredAspectRatio,
      'preferredHeight': preferredHeight,
      'minHeight': minHeight,
      'maxHeight': maxHeight,
      'canShrink': canShrink,
      'canExpand': canExpand,
      'maxShrinkPercent': maxShrinkPercent,
      'maxExpandPercent': maxExpandPercent,
      'contentAlignment': contentAlignment,
      'imagePosition': imagePosition,
      'pricePosition': pricePosition,
      'ctaPosition': ctaPosition,
      'sectionGap': sectionGap,
    });
  }

  @override
  String toString() {
    return 'MBCardLayoutSettings(${toMap()})';
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
