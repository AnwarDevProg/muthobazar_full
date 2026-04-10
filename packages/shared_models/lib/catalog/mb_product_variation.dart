import 'dart:convert';

// File: mb_product_variation.dart
// MB Product Variation Model
// --------------------------
// Defines a concrete sellable variation of a product.
// Examples:
// - Size M / Color Red
// - 500g pack
// - Boneless cut

class MBProductVariation {
  final String id;
  final String sku;
  final String? barcode;
  final String titleEn;
  final String titleBn;
  final String imageUrl;
  final String descriptionEn;
  final String descriptionBn;
  final double price;
  final double? salePrice;
  final double? costPrice;
  final int stockQty;
  final int reservedQty;
  final bool trackInventory;
  final bool allowBackorder;
  final Map<String, String> attributeValues;
  final int sortOrder;
  final bool isDefault;
  final bool isEnabled;

  const MBProductVariation({
    required this.id,
    this.sku = '',
    this.barcode,
    this.titleEn = '',
    this.titleBn = '',
    this.imageUrl = '',
    this.descriptionEn = '',
    this.descriptionBn = '',
    this.price = 0.0,
    this.salePrice,
    this.costPrice,
    this.stockQty = 0,
    this.reservedQty = 0,
    this.trackInventory = true,
    this.allowBackorder = false,
    this.attributeValues = const {},
    this.sortOrder = 0,
    this.isDefault = false,
    this.isEnabled = true,
  });

  static const MBProductVariation empty = MBProductVariation(id: '');

  MBProductVariation copyWith({
    String? id,
    String? sku,
    String? barcode,
    bool clearBarcode = false,
    String? titleEn,
    String? titleBn,
    String? imageUrl,
    String? descriptionEn,
    String? descriptionBn,
    double? price,
    double? salePrice,
    bool clearSalePrice = false,
    double? costPrice,
    bool clearCostPrice = false,
    int? stockQty,
    int? reservedQty,
    bool? trackInventory,
    bool? allowBackorder,
    Map<String, String>? attributeValues,
    int? sortOrder,
    bool? isDefault,
    bool? isEnabled,
  }) {
    return MBProductVariation(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      imageUrl: imageUrl ?? this.imageUrl,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      price: price ?? this.price,
      salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
      costPrice: clearCostPrice ? null : (costPrice ?? this.costPrice),
      stockQty: stockQty ?? this.stockQty,
      reservedQty: reservedQty ?? this.reservedQty,
      trackInventory: trackInventory ?? this.trackInventory,
      allowBackorder: allowBackorder ?? this.allowBackorder,
      attributeValues: attributeValues ?? this.attributeValues,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  bool get hasDiscount => salePrice != null && salePrice! > 0 && salePrice! < price;

  double get effectivePrice => hasDiscount ? salePrice! : price;

  int get discountPercent {
    if (!hasDiscount || price <= 0) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  int get availableStock {
    final value = stockQty - reservedQty;
    return value < 0 ? 0 : value;
  }

  bool get inStock => allowBackorder || availableStock > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'barcode': barcode,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'imageUrl': imageUrl,
      'descriptionEn': descriptionEn,
      'descriptionBn': descriptionBn,
      'price': price,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'stockQty': stockQty,
      'reservedQty': reservedQty,
      'trackInventory': trackInventory,
      'allowBackorder': allowBackorder,
      'attributeValues': attributeValues,
      'sortOrder': sortOrder,
      'isDefault': isDefault,
      'isEnabled': isEnabled,
    };
  }

  factory MBProductVariation.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBProductVariation(
      id: (map['id'] ?? '').toString(),
      sku: (map['sku'] ?? '').toString(),
      barcode: map['barcode']?.toString(),
      titleEn: (map['titleEn'] ?? '').toString(),
      titleBn: (map['titleBn'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      descriptionEn: (map['descriptionEn'] ?? '').toString(),
      descriptionBn: (map['descriptionBn'] ?? '').toString(),
      price: _asDouble(map['price'], fallback: 0.0),
      salePrice: _asNullableDouble(map['salePrice']),
      costPrice: _asNullableDouble(map['costPrice']),
      stockQty: _asInt(map['stockQty'], fallback: 0),
      reservedQty: _asInt(map['reservedQty'], fallback: 0),
      trackInventory: _asBool(map['trackInventory'], fallback: true),
      allowBackorder: _asBool(map['allowBackorder'], fallback: false),
      attributeValues: _asStringMap(map['attributeValues']),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      isDefault: _asBool(map['isDefault'], fallback: false),
      isEnabled: _asBool(map['isEnabled'], fallback: true),
    );
  }

  factory MBProductVariation.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    final dynamic rawAttributeValues =
        map['AttributeValues'] ?? map['AttributeValue'] ?? const {};

    return MBProductVariation(
      id: (map['Id'] ?? '').toString(),
      sku: (map['SKU'] ?? '').toString(),
      barcode: map['Barcode']?.toString(),
      titleEn: (map['Title'] ?? '').toString(),
      titleBn: '',
      imageUrl: (map['Image'] ?? '').toString(),
      descriptionEn: (map['Description'] ?? '').toString(),
      descriptionBn: '',
      price: _asDouble(map['Price'], fallback: 0.0),
      salePrice: _asNullableDouble(map['SalePrice']),
      costPrice: _asNullableDouble(map['CostPrice']),
      stockQty: _asInt(map['Stock'], fallback: 0),
      reservedQty: _asInt(map['ReservedQty'], fallback: 0),
      trackInventory: true,
      allowBackorder: false,
      attributeValues: _asStringMap(rawAttributeValues),
      sortOrder: 0,
      isDefault: false,
      isEnabled: true,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductVariation.fromJson(String source) =>
      MBProductVariation.fromMap(json.decode(source) as Map<String, dynamic>);
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
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

Map<String, String> _asStringMap(dynamic value) {
  if (value is Map<String, String>) return value;
  if (value is Map) {
    return value.map(
          (key, item) => MapEntry(key.toString(), item.toString()),
    );
  }
  return const {};
}