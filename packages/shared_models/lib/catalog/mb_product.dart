import 'dart:convert';

import 'mb_product_attribute.dart';
import 'mb_product_purchase_option.dart';
import 'mb_product_variation.dart';

// MB Product Model (Final - Admin + Hybrid Inventory Ready)
// ---------------------------------------------------------
// Supports:
// - bilingual product data
// - attributes
// - variations
// - purchase options
// - hybrid inventory logic
// - admin create/update with copyWith
// - Firestore serialization

class MBProduct {
  final String id;
  final String? productCode;
  final String? sku;

  final String titleEn;
  final String titleBn;

  final String shortDescriptionEn;
  final String shortDescriptionBn;

  final String descriptionEn;
  final String descriptionBn;

  final String thumbnailUrl;
  final List<String> imageUrls;

  final double price;
  final double? salePrice;

  // Legacy compatibility field
  final int stockQty;

  // Hybrid inventory fields
  final String inventoryMode; // stocked | hybrid_fresh | schedule_only | untracked
  final bool trackInventory;

  final bool supportsInstantOrder;
  final bool supportsScheduledOrder;

  final int regularStockQty;
  final int reservedInstantQty;

  final int todayInstantCap;
  final int todayInstantSold;

  final int maxScheduleQtyPerDay;

  final String schedulePriceType; // fixed | estimated | market
  final double? estimatedSchedulePrice;

  final String? instantCutoffTime;
  final int minScheduleNoticeHours;

  final String? categoryId;
  final String? brandId;

  final String productType;

  final List<String> tags;
  final List<String> keywords;

  final List<MBProductAttribute> attributes;
  final List<MBProductVariation> variations;
  final List<MBProductPurchaseOption> purchaseOptions;

  final bool isFeatured;
  final bool isFlashSale;
  final bool isEnabled;
  final bool isNewArrival;
  final bool isBestSeller;

  final int views;
  final int totalSold;
  final int addToCartCount;

  final String quantityType;
  final double quantityValue;
  final String toleranceType;
  final double tolerance;
  final bool isToleranceActive;

  final String deliveryShift;

  final DateTime? saleEndsAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MBProduct({
    required this.id,
    this.productCode,
    this.sku,
    required this.titleEn,
    required this.titleBn,
    this.shortDescriptionEn = '',
    this.shortDescriptionBn = '',
    this.descriptionEn = '',
    this.descriptionBn = '',
    this.thumbnailUrl = '',
    this.imageUrls = const [],
    this.price = 0.0,
    this.salePrice,
    this.stockQty = 0,
    this.inventoryMode = 'stocked',
    this.trackInventory = true,
    this.supportsInstantOrder = true,
    this.supportsScheduledOrder = false,
    this.regularStockQty = 0,
    this.reservedInstantQty = 0,
    this.todayInstantCap = 999999,
    this.todayInstantSold = 0,
    this.maxScheduleQtyPerDay = 999999,
    this.schedulePriceType = 'fixed',
    this.estimatedSchedulePrice,
    this.instantCutoffTime,
    this.minScheduleNoticeHours = 0,
    this.categoryId,
    this.brandId,
    this.productType = 'simple',
    this.tags = const [],
    this.keywords = const [],
    this.attributes = const [],
    this.variations = const [],
    this.purchaseOptions = const [],
    this.isFeatured = false,
    this.isFlashSale = false,
    this.isEnabled = true,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.views = 0,
    this.totalSold = 0,
    this.addToCartCount = 0,
    this.quantityType = 'pcs',
    this.quantityValue = 0.0,
    this.toleranceType = 'g',
    this.tolerance = 0.0,
    this.isToleranceActive = false,
    this.deliveryShift = 'any',
    this.saleEndsAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MBProduct.empty() => MBProduct(
    id: '',
    titleEn: '',
    titleBn: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // --------------------------------------------------
  // Helpers
  // --------------------------------------------------

  bool get hasDiscount =>
      salePrice != null && salePrice! > 0 && salePrice! < price;

  double get effectivePrice => hasDiscount ? salePrice! : price;

  int get discountPercent {
    if (!hasDiscount || price <= 0) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  bool get hasAttributes => attributes.isNotEmpty;

  bool get hasVariations => variations.isNotEmpty;

  bool get hasPurchaseOptions => purchaseOptions.isNotEmpty;

  bool get isVariableProduct => productType == 'variable';

  bool get canInstantOrder => isEnabled && supportsInstantOrder;

  bool get canScheduledOrder => isEnabled && supportsScheduledOrder;

  bool get usesEstimatedSchedulePrice =>
      schedulePriceType == 'estimated' || schedulePriceType == 'market';

  int get instantAvailableFromStock {
    final value = regularStockQty - reservedInstantQty;
    return value < 0 ? 0 : value;
  }

  int get instantAvailableToday {
    final capLeft = todayInstantCap - todayInstantSold;
    final stockLeft = instantAvailableFromStock;

    switch (inventoryMode) {
      case 'stocked':
        return stockLeft;
      case 'hybrid_fresh':
        final result = capLeft < stockLeft ? capLeft : stockLeft;
        return result < 0 ? 0 : result;
      case 'untracked':
        return 999999;
      case 'schedule_only':
      default:
        return 0;
    }
  }

  bool get inStock => instantAvailableToday > 0;

  bool get isSaleActive {
    if (saleEndsAt == null) return hasDiscount;
    return DateTime.now().isBefore(saleEndsAt!);
  }

  // --------------------------------------------------
  // copyWith
  // --------------------------------------------------

  MBProduct copyWith({
    String? id,
    String? productCode,
    bool clearProductCode = false,
    String? sku,
    bool clearSku = false,
    String? titleEn,
    String? titleBn,
    String? shortDescriptionEn,
    String? shortDescriptionBn,
    String? descriptionEn,
    String? descriptionBn,
    String? thumbnailUrl,
    List<String>? imageUrls,
    double? price,
    double? salePrice,
    bool clearSalePrice = false,
    int? stockQty,
    String? inventoryMode,
    bool? trackInventory,
    bool? supportsInstantOrder,
    bool? supportsScheduledOrder,
    int? regularStockQty,
    int? reservedInstantQty,
    int? todayInstantCap,
    int? todayInstantSold,
    int? maxScheduleQtyPerDay,
    String? schedulePriceType,
    double? estimatedSchedulePrice,
    bool clearEstimatedSchedulePrice = false,
    String? instantCutoffTime,
    bool clearInstantCutoffTime = false,
    int? minScheduleNoticeHours,
    String? categoryId,
    bool clearCategoryId = false,
    String? brandId,
    bool clearBrandId = false,
    String? productType,
    List<String>? tags,
    List<String>? keywords,
    List<MBProductAttribute>? attributes,
    List<MBProductVariation>? variations,
    List<MBProductPurchaseOption>? purchaseOptions,
    bool? isFeatured,
    bool? isFlashSale,
    bool? isEnabled,
    bool? isNewArrival,
    bool? isBestSeller,
    int? views,
    int? totalSold,
    int? addToCartCount,
    String? quantityType,
    double? quantityValue,
    String? toleranceType,
    double? tolerance,
    bool? isToleranceActive,
    String? deliveryShift,
    DateTime? saleEndsAt,
    bool clearSaleEndsAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MBProduct(
      id: id ?? this.id,
      productCode: clearProductCode ? null : (productCode ?? this.productCode),
      sku: clearSku ? null : (sku ?? this.sku),
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      shortDescriptionEn: shortDescriptionEn ?? this.shortDescriptionEn,
      shortDescriptionBn: shortDescriptionBn ?? this.shortDescriptionBn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
      stockQty: stockQty ?? this.stockQty,
      inventoryMode: inventoryMode ?? this.inventoryMode,
      trackInventory: trackInventory ?? this.trackInventory,
      supportsInstantOrder: supportsInstantOrder ?? this.supportsInstantOrder,
      supportsScheduledOrder:
      supportsScheduledOrder ?? this.supportsScheduledOrder,
      regularStockQty: regularStockQty ?? this.regularStockQty,
      reservedInstantQty: reservedInstantQty ?? this.reservedInstantQty,
      todayInstantCap: todayInstantCap ?? this.todayInstantCap,
      todayInstantSold: todayInstantSold ?? this.todayInstantSold,
      maxScheduleQtyPerDay:
      maxScheduleQtyPerDay ?? this.maxScheduleQtyPerDay,
      schedulePriceType: schedulePriceType ?? this.schedulePriceType,
      estimatedSchedulePrice: clearEstimatedSchedulePrice
          ? null
          : (estimatedSchedulePrice ?? this.estimatedSchedulePrice),
      instantCutoffTime: clearInstantCutoffTime
          ? null
          : (instantCutoffTime ?? this.instantCutoffTime),
      minScheduleNoticeHours:
      minScheduleNoticeHours ?? this.minScheduleNoticeHours,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      brandId: clearBrandId ? null : (brandId ?? this.brandId),
      productType: productType ?? this.productType,
      tags: tags ?? this.tags,
      keywords: keywords ?? this.keywords,
      attributes: attributes ?? this.attributes,
      variations: variations ?? this.variations,
      purchaseOptions: purchaseOptions ?? this.purchaseOptions,
      isFeatured: isFeatured ?? this.isFeatured,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      isEnabled: isEnabled ?? this.isEnabled,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      views: views ?? this.views,
      totalSold: totalSold ?? this.totalSold,
      addToCartCount: addToCartCount ?? this.addToCartCount,
      quantityType: quantityType ?? this.quantityType,
      quantityValue: quantityValue ?? this.quantityValue,
      toleranceType: toleranceType ?? this.toleranceType,
      tolerance: tolerance ?? this.tolerance,
      isToleranceActive: isToleranceActive ?? this.isToleranceActive,
      deliveryShift: deliveryShift ?? this.deliveryShift,
      saleEndsAt: clearSaleEndsAt ? null : (saleEndsAt ?? this.saleEndsAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // --------------------------------------------------
  // Serialization
  // --------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productCode': productCode,
      'sku': sku,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'shortDescriptionEn': shortDescriptionEn,
      'shortDescriptionBn': shortDescriptionBn,
      'descriptionEn': descriptionEn,
      'descriptionBn': descriptionBn,
      'thumbnailUrl': thumbnailUrl,
      'imageUrls': imageUrls,
      'price': price,
      'salePrice': salePrice,
      'stockQty': stockQty,
      'inventoryMode': inventoryMode,
      'trackInventory': trackInventory,
      'supportsInstantOrder': supportsInstantOrder,
      'supportsScheduledOrder': supportsScheduledOrder,
      'regularStockQty': regularStockQty,
      'reservedInstantQty': reservedInstantQty,
      'todayInstantCap': todayInstantCap,
      'todayInstantSold': todayInstantSold,
      'maxScheduleQtyPerDay': maxScheduleQtyPerDay,
      'schedulePriceType': schedulePriceType,
      'estimatedSchedulePrice': estimatedSchedulePrice,
      'instantCutoffTime': instantCutoffTime,
      'minScheduleNoticeHours': minScheduleNoticeHours,
      'categoryId': categoryId,
      'brandId': brandId,
      'productType': productType,
      'tags': tags,
      'keywords': keywords,
      'attributes': attributes.map((e) => e.toMap()).toList(),
      'variations': variations.map((e) => e.toMap()).toList(),
      'purchaseOptions': purchaseOptions.map((e) => e.toMap()).toList(),
      'isFeatured': isFeatured,
      'isFlashSale': isFlashSale,
      'isEnabled': isEnabled,
      'isNewArrival': isNewArrival,
      'isBestSeller': isBestSeller,
      'views': views,
      'totalSold': totalSold,
      'addToCartCount': addToCartCount,
      'quantityType': quantityType,
      'quantityValue': quantityValue,
      'toleranceType': toleranceType,
      'tolerance': tolerance,
      'isToleranceActive': isToleranceActive,
      'deliveryShift': deliveryShift,
      'saleEndsAt': saleEndsAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MBProduct.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBProduct.empty();

    return MBProduct(
      id: (map['id'] ?? '').toString(),
      productCode: map['productCode']?.toString(),
      sku: map['sku']?.toString(),
      titleEn: (map['titleEn'] ?? '').toString(),
      titleBn: (map['titleBn'] ?? '').toString(),
      shortDescriptionEn: (map['shortDescriptionEn'] ?? '').toString(),
      shortDescriptionBn: (map['shortDescriptionBn'] ?? '').toString(),
      descriptionEn: (map['descriptionEn'] ?? '').toString(),
      descriptionBn: (map['descriptionBn'] ?? '').toString(),
      thumbnailUrl: (map['thumbnailUrl'] ?? '').toString(),
      imageUrls: List<String>.from(map['imageUrls'] ?? const []),
      price: ((map['price'] ?? 0) as num).toDouble(),
      salePrice: map['salePrice'] == null
          ? null
          : ((map['salePrice'] as num).toDouble()),
      stockQty: (map['stockQty'] ?? 0) is int
          ? (map['stockQty'] ?? 0) as int
          : int.tryParse((map['stockQty'] ?? '0').toString()) ?? 0,
      inventoryMode: (map['inventoryMode'] ?? 'stocked').toString(),
      trackInventory: map['trackInventory'] ?? true,
      supportsInstantOrder: map['supportsInstantOrder'] ?? true,
      supportsScheduledOrder: map['supportsScheduledOrder'] ?? false,
      regularStockQty: (map['regularStockQty'] ?? map['stockQty'] ?? 0) is int
          ? (map['regularStockQty'] ?? map['stockQty'] ?? 0) as int
          : int.tryParse(
          (map['regularStockQty'] ?? map['stockQty'] ?? '0')
              .toString()) ??
          0,
      reservedInstantQty: (map['reservedInstantQty'] ?? 0) is int
          ? (map['reservedInstantQty'] ?? 0) as int
          : int.tryParse((map['reservedInstantQty'] ?? '0').toString()) ?? 0,
      todayInstantCap: (map['todayInstantCap'] ?? 999999) is int
          ? (map['todayInstantCap'] ?? 999999) as int
          : int.tryParse((map['todayInstantCap'] ?? '999999').toString()) ??
          999999,
      todayInstantSold: (map['todayInstantSold'] ?? 0) is int
          ? (map['todayInstantSold'] ?? 0) as int
          : int.tryParse((map['todayInstantSold'] ?? '0').toString()) ?? 0,
      maxScheduleQtyPerDay: (map['maxScheduleQtyPerDay'] ?? 999999) is int
          ? (map['maxScheduleQtyPerDay'] ?? 999999) as int
          : int.tryParse(
          (map['maxScheduleQtyPerDay'] ?? '999999').toString()) ??
          999999,
      schedulePriceType: (map['schedulePriceType'] ?? 'fixed').toString(),
      estimatedSchedulePrice: map['estimatedSchedulePrice'] == null
          ? null
          : ((map['estimatedSchedulePrice'] as num).toDouble()),
      instantCutoffTime: map['instantCutoffTime']?.toString(),
      minScheduleNoticeHours: (map['minScheduleNoticeHours'] ?? 0) is int
          ? (map['minScheduleNoticeHours'] ?? 0) as int
          : int.tryParse((map['minScheduleNoticeHours'] ?? '0').toString()) ??
          0,
      categoryId: map['categoryId']?.toString(),
      brandId: map['brandId']?.toString(),
      productType: (map['productType'] ?? 'simple').toString(),
      tags: List<String>.from(map['tags'] ?? const []),
      keywords: List<String>.from(map['keywords'] ?? const []),
      attributes: (map['attributes'] as List<dynamic>? ?? const [])
          .map((e) => MBProductAttribute.fromMap(e as Map<String, dynamic>))
          .toList(),
      variations: (map['variations'] as List<dynamic>? ?? const [])
          .map((e) => MBProductVariation.fromMap(e as Map<String, dynamic>))
          .toList(),
      purchaseOptions: (map['purchaseOptions'] as List<dynamic>? ?? const [])
          .map((e) => MBProductPurchaseOption.fromMap(e as Map<String, dynamic>))
          .toList(),
      isFeatured: map['isFeatured'] ?? false,
      isFlashSale: map['isFlashSale'] ?? false,
      isEnabled: map['isEnabled'] ?? true,
      isNewArrival: map['isNewArrival'] ?? false,
      isBestSeller: map['isBestSeller'] ?? false,
      views: (map['views'] ?? 0) is int
          ? (map['views'] ?? 0) as int
          : int.tryParse((map['views'] ?? '0').toString()) ?? 0,
      totalSold: (map['totalSold'] ?? 0) is int
          ? (map['totalSold'] ?? 0) as int
          : int.tryParse((map['totalSold'] ?? '0').toString()) ?? 0,
      addToCartCount: (map['addToCartCount'] ?? 0) is int
          ? (map['addToCartCount'] ?? 0) as int
          : int.tryParse((map['addToCartCount'] ?? '0').toString()) ?? 0,
      quantityType: (map['quantityType'] ?? 'pcs').toString(),
      quantityValue: ((map['quantityValue'] ?? 0) as num).toDouble(),
      toleranceType: (map['toleranceType'] ?? 'g').toString(),
      tolerance: ((map['tolerance'] ?? 0) as num).toDouble(),
      isToleranceActive: map['isToleranceActive'] ?? false,
      deliveryShift: (map['deliveryShift'] ?? 'any').toString(),
      saleEndsAt: map['saleEndsAt'] == null
          ? null
          : DateTime.tryParse(map['saleEndsAt'].toString()),
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
      updatedAt: map['updatedAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProduct.fromJson(String source) =>
      MBProduct.fromMap(json.decode(source) as Map<String, dynamic>);
}