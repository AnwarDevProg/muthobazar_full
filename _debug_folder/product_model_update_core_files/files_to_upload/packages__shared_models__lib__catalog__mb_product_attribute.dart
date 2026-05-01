import 'dart:convert';

import 'mb_product_attribute_value.dart';

// MB Product Attribute Model
// --------------------------
// Defines an attribute group for a product.
// Examples:
// - Size
// - Color
// - Weight
// - Cut Type

class MBProductAttribute {
  final String id;
  final String nameEn;
  final String nameBn;
  final String code;
  final List<MBProductAttributeValue> values;
  final int sortOrder;
  final bool isVisible;
  final bool useForVariation;
  final bool isRequired;
  final String displayType;

  const MBProductAttribute({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    this.code = '',
    this.values = const [],
    this.sortOrder = 0,
    this.isVisible = true,
    this.useForVariation = false,
    this.isRequired = false,
    this.displayType = 'text',
  });

  static const MBProductAttribute empty = MBProductAttribute(
    id: '',
    nameEn: '',
    nameBn: '',
  );

  MBProductAttribute copyWith({
    String? id,
    String? nameEn,
    String? nameBn,
    String? code,
    List<MBProductAttributeValue>? values,
    int? sortOrder,
    bool? isVisible,
    bool? useForVariation,
    bool? isRequired,
    String? displayType,
  }) {
    return MBProductAttribute(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameBn: nameBn ?? this.nameBn,
      code: code ?? this.code,
      values: values ?? this.values,
      sortOrder: sortOrder ?? this.sortOrder,
      isVisible: isVisible ?? this.isVisible,
      useForVariation: useForVariation ?? this.useForVariation,
      isRequired: isRequired ?? this.isRequired,
      displayType: displayType ?? this.displayType,
    );
  }

  bool get hasValues => values.isNotEmpty;

  bool get isColorType => displayType == 'color';

  bool get isImageType => displayType == 'image';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameBn': nameBn,
      'code': code,
      'values': values.map((e) => e.toMap()).toList(),
      'sortOrder': sortOrder,
      'isVisible': isVisible,
      'useForVariation': useForVariation,
      'isRequired': isRequired,
      'displayType': displayType,
    };
  }

  factory MBProductAttribute.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    final rawValues = map['values'];

    return MBProductAttribute(
      id: (map['id'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      values: _parseAttributeValues(rawValues),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      isVisible: _asBool(map['isVisible'], fallback: true),
      useForVariation: _asBool(map['useForVariation'], fallback: false),
      isRequired: _asBool(map['isRequired'], fallback: false),
      displayType: (map['displayType'] ?? 'text').toString(),
    );
  }

  // Legacy compatibility from old ProductAttributeModelV2.
  // Supports shapes like:
  // {
  //   'Name': 'Size',
  //   'Values': ['S', 'M', 'L']
  // }
  factory MBProductAttribute.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    final rawValues = map['Values'] ?? const [];
    final name = (map['Name'] ?? '').toString();

    return MBProductAttribute(
      id: name,
      nameEn: name,
      nameBn: '',
      code: '',
      values: _parseAttributeValues(rawValues),
      sortOrder: 0,
      isVisible: true,
      useForVariation: false,
      isRequired: false,
      displayType: 'text',
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductAttribute.fromJson(String source) =>
      MBProductAttribute.fromMap(json.decode(source) as Map<String, dynamic>);
}

List<MBProductAttributeValue> _parseAttributeValues(dynamic rawValues) {
  if (rawValues is! List) return const [];

  final results = <MBProductAttributeValue>[];

  for (var i = 0; i < rawValues.length; i++) {
    final item = rawValues[i];

    if (item is Map<String, dynamic>) {
      results.add(MBProductAttributeValue.fromMap(item));
      continue;
    }

    if (item is Map) {
      results.add(
        MBProductAttributeValue.fromMap(Map<String, dynamic>.from(item)),
      );
      continue;
    }

    if (item is String) {
      results.add(
        MBProductAttributeValue.fromLegacyString(item, sortOrder: i),
      );
    }
  }

  return results;
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