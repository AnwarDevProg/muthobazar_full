import 'dart:convert';

// MB Product Attribute Model
// --------------------------
// Bilingual attribute definition for products.
// Examples:
// - Size -> S, M, L
// - Color -> Red, Blue
// - Weight -> 500g, 1kg

class MBProductAttribute {
  final String nameEn;
  final String nameBn;
  final List<String> values;
  final int sortOrder;
  final bool isVisible;

  const MBProductAttribute({
    required this.nameEn,
    required this.nameBn,
    this.values = const [],
    this.sortOrder = 0,
    this.isVisible = true,
  });

  static const MBProductAttribute empty = MBProductAttribute(
    nameEn: '',
    nameBn: '',
  );

  MBProductAttribute copyWith({
    String? nameEn,
    String? nameBn,
    List<String>? values,
    int? sortOrder,
    bool? isVisible,
  }) {
    return MBProductAttribute(
      nameEn: nameEn ?? this.nameEn,
      nameBn: nameBn ?? this.nameBn,
      values: values ?? this.values,
      sortOrder: sortOrder ?? this.sortOrder,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameEn': nameEn,
      'nameBn': nameBn,
      'values': values,
      'sortOrder': sortOrder,
      'isVisible': isVisible,
    };
  }

  factory MBProductAttribute.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBProductAttribute(
      nameEn: (map['nameEn'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      values: List<String>.from(map['values'] ?? const []),
      sortOrder: (map['sortOrder'] ?? 0) is int
          ? (map['sortOrder'] ?? 0) as int
          : int.tryParse((map['sortOrder'] ?? '0').toString()) ?? 0,
      isVisible: map['isVisible'] ?? true,
    );
  }

  // Legacy compatibility from old ProductAttributeModelV2
  factory MBProductAttribute.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBProductAttribute(
      nameEn: (map['Name'] ?? '').toString(),
      nameBn: '',
      values: List<String>.from(map['Values'] ?? const []),
      sortOrder: 0,
      isVisible: true,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductAttribute.fromJson(String source) =>
      MBProductAttribute.fromMap(json.decode(source) as Map<String, dynamic>);
}












