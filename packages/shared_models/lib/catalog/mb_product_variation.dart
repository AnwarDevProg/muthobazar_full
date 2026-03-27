import 'dart:convert';

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
  final String imageUrl;
  final String descriptionEn;
  final String descriptionBn;
  final double price;
  final double? salePrice;
  final int stockQty;
  final Map<String, String> attributeValues;
  final bool isEnabled;

  const MBProductVariation({
    required this.id,
    this.sku = '',
    this.imageUrl = '',
    this.descriptionEn = '',
    this.descriptionBn = '',
    this.price = 0.0,
    this.salePrice,
    this.stockQty = 0,
    this.attributeValues = const {},
    this.isEnabled = true,
  });

  static const MBProductVariation empty = MBProductVariation(id: '');

  MBProductVariation copyWith({
    String? id,
    String? sku,
    String? imageUrl,
    String? descriptionEn,
    String? descriptionBn,
    double? price,
    double? salePrice,
    bool clearSalePrice = false,
    int? stockQty,
    Map<String, String>? attributeValues,
    bool? isEnabled,
  }) {
    return MBProductVariation(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      imageUrl: imageUrl ?? this.imageUrl,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      price: price ?? this.price,
      salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
      stockQty: stockQty ?? this.stockQty,
      attributeValues: attributeValues ?? this.attributeValues,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  bool get hasDiscount => salePrice != null && salePrice! > 0 && salePrice! < price;

  double get effectivePrice => hasDiscount ? salePrice! : price;

  int get discountPercent {
    if (!hasDiscount || price <= 0) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'imageUrl': imageUrl,
      'descriptionEn': descriptionEn,
      'descriptionBn': descriptionBn,
      'price': price,
      'salePrice': salePrice,
      'stockQty': stockQty,
      'attributeValues': attributeValues,
      'isEnabled': isEnabled,
    };
  }

  factory MBProductVariation.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBProductVariation(
      id: (map['id'] ?? '').toString(),
      sku: (map['sku'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      descriptionEn: (map['descriptionEn'] ?? '').toString(),
      descriptionBn: (map['descriptionBn'] ?? '').toString(),
      price: ((map['price'] ?? 0) as num).toDouble(),
      salePrice: map['salePrice'] == null ? null : ((map['salePrice'] as num).toDouble()),
      stockQty: (map['stockQty'] ?? 0) is int
          ? (map['stockQty'] ?? 0) as int
          : int.tryParse((map['stockQty'] ?? '0').toString()) ?? 0,
      attributeValues: Map<String, String>.from(map['attributeValues'] ?? const {}),
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  // Legacy compatibility from old ProductVariationModelV2
  factory MBProductVariation.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    final dynamic rawAttributeValues =
        map['AttributeValues'] ?? map['AttributeValue'] ?? const {};

    return MBProductVariation(
      id: (map['Id'] ?? '').toString(),
      sku: (map['SKU'] ?? '').toString(),
      imageUrl: (map['Image'] ?? '').toString(),
      descriptionEn: (map['Description'] ?? '').toString(),
      descriptionBn: '',
      price: ((map['Price'] ?? 0) as num).toDouble(),
      salePrice: map['SalePrice'] == null
          ? null
          : ((map['SalePrice'] as num).toDouble() == 0
          ? null
          : (map['SalePrice'] as num).toDouble()),
      stockQty: (map['Stock'] ?? 0) is int
          ? (map['Stock'] ?? 0) as int
          : int.tryParse((map['Stock'] ?? '0').toString()) ?? 0,
      attributeValues: Map<String, String>.from(rawAttributeValues),
      isEnabled: true,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductVariation.fromJson(String source) =>
      MBProductVariation.fromMap(json.decode(source) as Map<String, dynamic>);
}












