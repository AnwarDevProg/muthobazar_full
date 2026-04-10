import 'dart:convert';

// File: mb_product_attribute_value.dart
// MB Product Attribute Value Model
// --------------------------------
// Rich attribute value object for product attributes.
// Examples:
// - Color: Red / Blue with optional color hex or swatch image
// - Size: S / M / L
// - Weight: 500g / 1kg

class MBProductAttributeValue {
  final String id;
  final String labelEn;
  final String labelBn;
  final String value;
  final String? colorHex;
  final String? imageUrl;
  final int sortOrder;
  final bool isEnabled;

  const MBProductAttributeValue({
    required this.id,
    required this.labelEn,
    required this.labelBn,
    required this.value,
    this.colorHex,
    this.imageUrl,
    this.sortOrder = 0,
    this.isEnabled = true,
  });

  static const MBProductAttributeValue empty = MBProductAttributeValue(
    id: '',
    labelEn: '',
    labelBn: '',
    value: '',
  );

  MBProductAttributeValue copyWith({
    String? id,
    String? labelEn,
    String? labelBn,
    String? value,
    String? colorHex,
    bool clearColorHex = false,
    String? imageUrl,
    bool clearImageUrl = false,
    int? sortOrder,
    bool? isEnabled,
  }) {
    return MBProductAttributeValue(
      id: id ?? this.id,
      labelEn: labelEn ?? this.labelEn,
      labelBn: labelBn ?? this.labelBn,
      value: value ?? this.value,
      colorHex: clearColorHex ? null : (colorHex ?? this.colorHex),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  bool get hasColor => (colorHex ?? '').trim().isNotEmpty;

  bool get hasImage => (imageUrl ?? '').trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'labelEn': labelEn,
      'labelBn': labelBn,
      'value': value,
      'colorHex': colorHex,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isEnabled': isEnabled,
    };
  }

  factory MBProductAttributeValue.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBProductAttributeValue(
      id: (map['id'] ?? '').toString(),
      labelEn: (map['labelEn'] ?? '').toString(),
      labelBn: (map['labelBn'] ?? '').toString(),
      value: (map['value'] ?? '').toString(),
      colorHex: map['colorHex']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      isEnabled: _asBool(map['isEnabled'], fallback: true),
    );
  }

  factory MBProductAttributeValue.fromLegacyString(
      String rawValue, {
        int sortOrder = 0,
      }) {
    final trimmed = rawValue.trim();
    return MBProductAttributeValue(
      id: trimmed,
      labelEn: trimmed,
      labelBn: '',
      value: trimmed,
      sortOrder: sortOrder,
      isEnabled: true,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductAttributeValue.fromJson(String source) =>
      MBProductAttributeValue.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return fallback;
}