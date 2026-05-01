import 'dart:convert';

import '../product_cards/config/mb_card_family.dart';
import '../product_cards/config/mb_card_instance_config.dart';
import '../product_cards/config/mb_card_variant.dart';
import 'mb_product_attribute.dart';
import 'mb_product_media.dart';
import 'mb_product_purchase_option.dart';
import 'mb_product_variation.dart';

// File: mb_product.dart
// MB Product Model
// ----------------
// Root product aggregate used by admin, customer, and backend logic.
//
// Card persistence upgrade:
// - cardLayoutType is kept for backward compatibility.
// - cardConfig is the new source for exact product-card variant and settings.
// - Existing legacy values are migrated safely in memory:
//   standard -> compact01
//   compact  -> compact01
//   deal     -> promo01
//   featured -> featured01
// - New variant ids like compact01, price01, wide01, promo01, flash01, etc.
//   are preserved instead of being normalized back to standard.

class MBProduct {
  final String id;
  final String slug;
  final String? productCode;
  final String? sku;
  final String? barcode;

  final String titleEn;
  final String titleBn;
  final String shortDescriptionEn;
  final String shortDescriptionBn;
  final String descriptionEn;
  final String descriptionBn;

  final String thumbnailUrl;
  final List<String> imageUrls;
  final List<MBProductMedia> mediaItems;

  final double price;
  final double? salePrice;
  final double? costPrice;
  final DateTime? saleStartsAt;
  final DateTime? saleEndsAt;

  final int stockQty;
  final String inventoryMode;
  final bool trackInventory;
  final bool supportsInstantOrder;
  final bool supportsScheduledOrder;
  final int regularStockQty;
  final int reservedInstantQty;
  final int reservedQty;
  final int todayInstantCap;
  final int todayInstantSold;
  final int maxScheduleQtyPerDay;
  final String schedulePriceType;
  final double? estimatedSchedulePrice;
  final String? instantCutoffTime;
  final int minScheduleNoticeHours;
  final int reorderLevel;
  final bool allowBackorder;

  final String? categoryId;
  final String? categoryNameEn;
  final String? categoryNameBn;
  final String? categorySlug;

  final String? brandId;
  final String? brandNameEn;
  final String? brandNameBn;
  final String? brandSlug;

  final String productType;
  final List<String> tags;
  final List<String> keywords;
  final List<MBProductAttribute> attributes;
  final List<MBProductVariation> variations;
  final List<MBProductPurchaseOption> purchaseOptions;

  /// Legacy card field.
  ///
  /// New saves should store the exact variant id, for example compact01,
  /// price01, wide01, promo01, or flash01. Old values are still accepted.
  final String cardLayoutType;

  /// New persisted card configuration.
  ///
  /// This stores the card family, exact variant, optional preset, and all
  /// per-product card setting overrides.
  final MBCardInstanceConfig cardConfig;
  /// New design-family card studio JSON.
  ///
  /// This is the first persistence bridge for the free-design renderer.
  /// It stores the exported design-state JSON from MBCardDesignStudio.
  /// The old cardConfig remains untouched for legacy/variant fallback.
  final String? cardDesignJson;

  bool get hasCardDesignJson {
    final value = cardDesignJson;
    return value != null && value.trim().isNotEmpty;
  }

  final bool isFeatured;
  final bool isFlashSale;
  final bool isEnabled;
  final bool isNewArrival;
  final bool isBestSeller;
  final int sortOrder;
  final DateTime? publishAt;
  final DateTime? unpublishAt;

  final int views;
  final int totalSold;
  final int addToCartCount;

  final String quantityType;
  final double quantityValue;
  final String toleranceType;
  final double tolerance;
  final bool isToleranceActive;
  final String deliveryShift;
  final double? minOrderQty;
  final double? maxOrderQty;
  final double? stepQty;
  final String? unitLabelEn;
  final String? unitLabelBn;

  final String status;
  final String? taxClassId;
  final double? vatRate;
  final bool isTaxIncluded;
  final double? weightValue;
  final String? weightUnit;
  final double? length;
  final double? width;
  final double? height;
  final String? dimensionUnit;
  final String? shippingClassId;
  final String? adminNote;
  final Map<String, dynamic> metadata;

  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? deleteReason;

  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MBProduct({
    required this.id,
    this.slug = '',
    this.productCode,
    this.sku,
    this.barcode,
    required this.titleEn,
    required this.titleBn,
    this.shortDescriptionEn = '',
    this.shortDescriptionBn = '',
    this.descriptionEn = '',
    this.descriptionBn = '',
    this.thumbnailUrl = '',
    this.imageUrls = const [],
    this.mediaItems = const [],
    this.price = 0.0,
    this.salePrice,
    this.costPrice,
    this.saleStartsAt,
    this.saleEndsAt,
    this.stockQty = 0,
    this.inventoryMode = 'stocked',
    this.trackInventory = true,
    this.supportsInstantOrder = true,
    this.supportsScheduledOrder = false,
    this.regularStockQty = 0,
    this.reservedInstantQty = 0,
    this.reservedQty = 0,
    this.todayInstantCap = 999999,
    this.todayInstantSold = 0,
    this.maxScheduleQtyPerDay = 999999,
    this.schedulePriceType = 'fixed',
    this.estimatedSchedulePrice,
    this.instantCutoffTime,
    this.minScheduleNoticeHours = 0,
    this.reorderLevel = 0,
    this.allowBackorder = false,
    this.categoryId,
    this.categoryNameEn,
    this.categoryNameBn,
    this.categorySlug,
    this.brandId,
    this.brandNameEn,
    this.brandNameBn,
    this.brandSlug,
    this.productType = 'simple',
    this.tags = const [],
    this.keywords = const [],
    this.attributes = const [],
    this.variations = const [],
    this.purchaseOptions = const [],
    this.cardLayoutType = 'compact01',
    this.cardConfig = _defaultCardConfig,
    this.cardDesignJson,
    this.isFeatured = false,
    this.isFlashSale = false,
    this.isEnabled = true,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.sortOrder = 0,
    this.publishAt,
    this.unpublishAt,
    this.views = 0,
    this.totalSold = 0,
    this.addToCartCount = 0,
    this.quantityType = 'pcs',
    this.quantityValue = 0.0,
    this.toleranceType = 'g',
    this.tolerance = 0.0,
    this.isToleranceActive = false,
    this.deliveryShift = 'any',
    this.minOrderQty,
    this.maxOrderQty,
    this.stepQty,
    this.unitLabelEn,
    this.unitLabelBn,
    this.status = 'active',
    this.taxClassId,
    this.vatRate,
    this.isTaxIncluded = false,
    this.weightValue,
    this.weightUnit,
    this.length,
    this.width,
    this.height,
    this.dimensionUnit,
    this.shippingClassId,
    this.adminNote,
    this.metadata = const {},
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.deleteReason,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MBProduct.empty() => MBProduct(
    id: '',
    titleEn: '',
    titleBn: '',
    cardLayoutType: _defaultCardConfig.variantId,
    cardConfig: _defaultCardConfig,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  bool get hasDiscount {
    final currentSalePrice = salePrice;
    if (currentSalePrice == null) return false;
    if (currentSalePrice <= 0) return false;
    if (currentSalePrice >= price) return false;

    final now = DateTime.now();
    if (saleStartsAt != null && now.isBefore(saleStartsAt!)) return false;
    if (saleEndsAt != null && now.isAfter(saleEndsAt!)) return false;

    return true;
  }

  double get effectivePrice => hasDiscount ? salePrice! : price;

  int get discountPercent {
    if (!hasDiscount || price <= 0) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  bool get hasAttributes => attributes.isNotEmpty;
  bool get hasVariations => variations.isNotEmpty;
  bool get hasPurchaseOptions => purchaseOptions.isNotEmpty;
  bool get hasMedia =>
      mediaItems.isNotEmpty || thumbnailUrl.isNotEmpty || imageUrls.isNotEmpty;

  bool get isVariableProduct => productType == 'variable';
  bool get canInstantOrder => isEnabled && !isDeleted && supportsInstantOrder;
  bool get canScheduledOrder => isEnabled && !isDeleted && supportsScheduledOrder;
  bool get usesEstimatedSchedulePrice =>
      schedulePriceType == 'estimated' || schedulePriceType == 'market';

  MBCardInstanceConfig get effectiveCardConfig {
    return cardConfig.normalized();
  }

  String get normalizedCardLayoutType => effectiveCardConfig.variantId;
  String get effectiveCardVariantId => effectiveCardConfig.variantId;
  String get effectiveCardFamilyId => effectiveCardConfig.familyId;

  bool get usesCompactCardLayout =>
      effectiveCardConfig.family == MBCardFamily.compact;

  bool get usesDealCardLayout =>
      _isLegacyDealLayout(cardLayoutType) ||
          effectiveCardConfig.family == MBCardFamily.promo;

  bool get usesFeaturedCardLayout =>
      effectiveCardConfig.family == MBCardFamily.featured;

  int get instantAvailableFromStock {
    final value = regularStockQty - reservedInstantQty;
    return value < 0 ? 0 : value;
  }

  int get instantAvailableToday {
    final capLeft = todayInstantCap - todayInstantSold;
    final stockLeft = instantAvailableFromStock;

    switch (inventoryMode) {
      case 'stocked':
        return allowBackorder ? 999999 : stockLeft;
      case 'hybrid_fresh':
        if (allowBackorder) return capLeft < 0 ? 0 : capLeft;
        final result = capLeft < stockLeft ? capLeft : stockLeft;
        return result < 0 ? 0 : result;
      case 'untracked':
        return 999999;
      case 'schedule_only':
      default:
        return 0;
    }
  }

  bool get inStock {
    if (allowBackorder) return true;

    if (isVariableProduct) {
      return variations.any(
            (variation) => variation.inStock && variation.isPublishedNow,
      );
    }

    return instantAvailableToday > 0;
  }

  bool get isSaleActive => hasDiscount;

  bool get isPublishedNow {
    final now = DateTime.now();
    if (!isEnabled || isDeleted) return false;
    if (publishAt != null && now.isBefore(publishAt!)) return false;
    if (unpublishAt != null && now.isAfter(unpublishAt!)) return false;
    return true;
  }

  List<MBProductMedia> get enabledMediaItems => mediaItems.where((item) => item.isEnabled).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  String get resolvedThumbnailUrl {
    if (thumbnailUrl.trim().isNotEmpty) return thumbnailUrl;

    for (final item in enabledMediaItems) {
      if (item.role == 'thumbnail' || item.isPrimary) {
        if (item.url.trim().isNotEmpty) return item.url;
      }
    }

    for (final item in enabledMediaItems) {
      if (item.url.trim().isNotEmpty) return item.url;
    }

    if (imageUrls.isNotEmpty) return imageUrls.first.toString();
    return '';
  }

  List<String> get resolvedImageUrls {
    if (imageUrls.isNotEmpty) return imageUrls;

    final urls = <String>[];
    for (final item in enabledMediaItems) {
      if (item.type == 'image' && item.url.trim().isNotEmpty) {
        urls.add(item.url);
      }
    }

    return urls;
  }

  MBProduct copyWith({
    String? id,
    String? slug,
    String? productCode,
    bool clearProductCode = false,
    String? sku,
    bool clearSku = false,
    String? barcode,
    bool clearBarcode = false,
    String? titleEn,
    String? titleBn,
    String? shortDescriptionEn,
    String? shortDescriptionBn,
    String? descriptionEn,
    String? descriptionBn,
    String? thumbnailUrl,
    List<String>? imageUrls,
    List<MBProductMedia>? mediaItems,
    double? price,
    double? salePrice,
    bool clearSalePrice = false,
    double? costPrice,
    bool clearCostPrice = false,
    DateTime? saleStartsAt,
    bool clearSaleStartsAt = false,
    DateTime? saleEndsAt,
    bool clearSaleEndsAt = false,
    int? stockQty,
    String? inventoryMode,
    bool? trackInventory,
    bool? supportsInstantOrder,
    bool? supportsScheduledOrder,
    int? regularStockQty,
    int? reservedInstantQty,
    int? reservedQty,
    int? todayInstantCap,
    int? todayInstantSold,
    int? maxScheduleQtyPerDay,
    String? schedulePriceType,
    double? estimatedSchedulePrice,
    bool clearEstimatedSchedulePrice = false,
    String? instantCutoffTime,
    bool clearInstantCutoffTime = false,
    int? minScheduleNoticeHours,
    int? reorderLevel,
    bool? allowBackorder,
    String? categoryId,
    bool clearCategoryId = false,
    String? categoryNameEn,
    bool clearCategoryNameEn = false,
    String? categoryNameBn,
    bool clearCategoryNameBn = false,
    String? categorySlug,
    bool clearCategorySlug = false,
    String? brandId,
    bool clearBrandId = false,
    String? brandNameEn,
    bool clearBrandNameEn = false,
    String? brandNameBn,
    bool clearBrandNameBn = false,
    String? brandSlug,
    bool clearBrandSlug = false,
    String? productType,
    List<String>? tags,
    List<String>? keywords,
    List<MBProductAttribute>? attributes,
    List<MBProductVariation>? variations,
    List<MBProductPurchaseOption>? purchaseOptions,
    String? cardLayoutType,
    MBCardInstanceConfig? cardConfig,
    String? cardDesignJson,
    bool clearCardDesignJson = false,
    bool? isFeatured,
    bool? isFlashSale,
    bool? isEnabled,
    bool? isNewArrival,
    bool? isBestSeller,
    int? sortOrder,
    DateTime? publishAt,
    bool clearPublishAt = false,
    DateTime? unpublishAt,
    bool clearUnpublishAt = false,
    int? views,
    int? totalSold,
    int? addToCartCount,
    String? quantityType,
    double? quantityValue,
    String? toleranceType,
    double? tolerance,
    bool? isToleranceActive,
    String? deliveryShift,
    double? minOrderQty,
    bool clearMinOrderQty = false,
    double? maxOrderQty,
    bool clearMaxOrderQty = false,
    double? stepQty,
    bool clearStepQty = false,
    String? unitLabelEn,
    bool clearUnitLabelEn = false,
    String? unitLabelBn,
    bool clearUnitLabelBn = false,
    String? status,
    String? taxClassId,
    bool clearTaxClassId = false,
    double? vatRate,
    bool clearVatRate = false,
    bool? isTaxIncluded,
    double? weightValue,
    bool clearWeightValue = false,
    String? weightUnit,
    bool clearWeightUnit = false,
    double? length,
    bool clearLength = false,
    double? width,
    bool clearWidth = false,
    double? height,
    bool clearHeight = false,
    String? dimensionUnit,
    bool clearDimensionUnit = false,
    String? shippingClassId,
    bool clearShippingClassId = false,
    String? adminNote,
    bool clearAdminNote = false,
    Map<String, dynamic>? metadata,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    String? deletedBy,
    bool clearDeletedBy = false,
    String? deleteReason,
    bool clearDeleteReason = false,
    String? createdBy,
    bool clearCreatedBy = false,
    String? updatedBy,
    bool clearUpdatedBy = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextCardLayoutType = _normalizeCardLayoutType(
      cardLayoutType ?? this.cardLayoutType,
    );

    final nextCardConfig = cardConfig ??
        (cardLayoutType == null
            ? this.cardConfig
            : _cardConfigFromLayoutType(nextCardLayoutType));

    return MBProduct(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      productCode: clearProductCode ? null : (productCode ?? this.productCode),
      sku: clearSku ? null : (sku ?? this.sku),
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      shortDescriptionEn: shortDescriptionEn ?? this.shortDescriptionEn,
      shortDescriptionBn: shortDescriptionBn ?? this.shortDescriptionBn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      mediaItems: mediaItems ?? this.mediaItems,
      price: price ?? this.price,
      salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
      costPrice: clearCostPrice ? null : (costPrice ?? this.costPrice),
      saleStartsAt:
      clearSaleStartsAt ? null : (saleStartsAt ?? this.saleStartsAt),
      saleEndsAt: clearSaleEndsAt ? null : (saleEndsAt ?? this.saleEndsAt),
      stockQty: stockQty ?? this.stockQty,
      inventoryMode: inventoryMode ?? this.inventoryMode,
      trackInventory: trackInventory ?? this.trackInventory,
      supportsInstantOrder: supportsInstantOrder ?? this.supportsInstantOrder,
      supportsScheduledOrder:
      supportsScheduledOrder ?? this.supportsScheduledOrder,
      regularStockQty: regularStockQty ?? this.regularStockQty,
      reservedInstantQty: reservedInstantQty ?? this.reservedInstantQty,
      reservedQty: reservedQty ?? this.reservedQty,
      todayInstantCap: todayInstantCap ?? this.todayInstantCap,
      todayInstantSold: todayInstantSold ?? this.todayInstantSold,
      maxScheduleQtyPerDay:
      maxScheduleQtyPerDay ?? this.maxScheduleQtyPerDay,
      schedulePriceType: schedulePriceType ?? this.schedulePriceType,
      estimatedSchedulePrice: clearEstimatedSchedulePrice
          ? null
          : (estimatedSchedulePrice ?? this.estimatedSchedulePrice),
      instantCutoffTime:
      clearInstantCutoffTime ? null : (instantCutoffTime ?? this.instantCutoffTime),
      minScheduleNoticeHours:
      minScheduleNoticeHours ?? this.minScheduleNoticeHours,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      allowBackorder: allowBackorder ?? this.allowBackorder,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      categoryNameEn:
      clearCategoryNameEn ? null : (categoryNameEn ?? this.categoryNameEn),
      categoryNameBn:
      clearCategoryNameBn ? null : (categoryNameBn ?? this.categoryNameBn),
      categorySlug:
      clearCategorySlug ? null : (categorySlug ?? this.categorySlug),
      brandId: clearBrandId ? null : (brandId ?? this.brandId),
      brandNameEn:
      clearBrandNameEn ? null : (brandNameEn ?? this.brandNameEn),
      brandNameBn:
      clearBrandNameBn ? null : (brandNameBn ?? this.brandNameBn),
      brandSlug: clearBrandSlug ? null : (brandSlug ?? this.brandSlug),
      productType: productType ?? this.productType,
      tags: tags ?? this.tags,
      keywords: keywords ?? this.keywords,
      attributes: attributes ?? this.attributes,
      variations: variations ?? this.variations,
      purchaseOptions: purchaseOptions ?? this.purchaseOptions,
      cardLayoutType: nextCardConfig.normalized().variantId,
      cardConfig: nextCardConfig.normalized(),
      cardDesignJson: clearCardDesignJson
          ? null
          : (cardDesignJson ?? this.cardDesignJson),
      isFeatured: isFeatured ?? this.isFeatured,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      isEnabled: isEnabled ?? this.isEnabled,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      sortOrder: sortOrder ?? this.sortOrder,
      publishAt: clearPublishAt ? null : (publishAt ?? this.publishAt),
      unpublishAt: clearUnpublishAt ? null : (unpublishAt ?? this.unpublishAt),
      views: views ?? this.views,
      totalSold: totalSold ?? this.totalSold,
      addToCartCount: addToCartCount ?? this.addToCartCount,
      quantityType: quantityType ?? this.quantityType,
      quantityValue: quantityValue ?? this.quantityValue,
      toleranceType: toleranceType ?? this.toleranceType,
      tolerance: tolerance ?? this.tolerance,
      isToleranceActive: isToleranceActive ?? this.isToleranceActive,
      deliveryShift: deliveryShift ?? this.deliveryShift,
      minOrderQty: clearMinOrderQty ? null : (minOrderQty ?? this.minOrderQty),
      maxOrderQty: clearMaxOrderQty ? null : (maxOrderQty ?? this.maxOrderQty),
      stepQty: clearStepQty ? null : (stepQty ?? this.stepQty),
      unitLabelEn: clearUnitLabelEn ? null : (unitLabelEn ?? this.unitLabelEn),
      unitLabelBn: clearUnitLabelBn ? null : (unitLabelBn ?? this.unitLabelBn),
      status: status ?? this.status,
      taxClassId: clearTaxClassId ? null : (taxClassId ?? this.taxClassId),
      vatRate: clearVatRate ? null : (vatRate ?? this.vatRate),
      isTaxIncluded: isTaxIncluded ?? this.isTaxIncluded,
      weightValue: clearWeightValue ? null : (weightValue ?? this.weightValue),
      weightUnit: clearWeightUnit ? null : (weightUnit ?? this.weightUnit),
      length: clearLength ? null : (length ?? this.length),
      width: clearWidth ? null : (width ?? this.width),
      height: clearHeight ? null : (height ?? this.height),
      dimensionUnit:
          clearDimensionUnit ? null : (dimensionUnit ?? this.dimensionUnit),
      shippingClassId:
          clearShippingClassId ? null : (shippingClassId ?? this.shippingClassId),
      adminNote: clearAdminNote ? null : (adminNote ?? this.adminNote),
      metadata: metadata ?? this.metadata,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      deletedBy: clearDeletedBy ? null : (deletedBy ?? this.deletedBy),
      deleteReason:
      clearDeleteReason ? null : (deleteReason ?? this.deleteReason),
      createdBy: clearCreatedBy ? null : (createdBy ?? this.createdBy),
      updatedBy: clearUpdatedBy ? null : (updatedBy ?? this.updatedBy),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final normalizedConfig = effectiveCardConfig.normalized();

    return {
      'id': id,
      'slug': slug,
      'productCode': productCode,
      'sku': sku,
      'barcode': barcode,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'shortDescriptionEn': shortDescriptionEn,
      'shortDescriptionBn': shortDescriptionBn,
      'descriptionEn': descriptionEn,
      'descriptionBn': descriptionBn,
      'thumbnailUrl': thumbnailUrl,
      'imageUrls': imageUrls,
      'mediaItems': mediaItems.map((e) => e.toMap()).toList(),
      'price': price,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'saleStartsAt': saleStartsAt?.toIso8601String(),
      'saleEndsAt': saleEndsAt?.toIso8601String(),
      'stockQty': stockQty,
      'inventoryMode': inventoryMode,
      'trackInventory': trackInventory,
      'supportsInstantOrder': supportsInstantOrder,
      'supportsScheduledOrder': supportsScheduledOrder,
      'regularStockQty': regularStockQty,
      'reservedInstantQty': reservedInstantQty,
      'reservedQty': reservedQty,
      'todayInstantCap': todayInstantCap,
      'todayInstantSold': todayInstantSold,
      'maxScheduleQtyPerDay': maxScheduleQtyPerDay,
      'schedulePriceType': schedulePriceType,
      'estimatedSchedulePrice': estimatedSchedulePrice,
      'instantCutoffTime': instantCutoffTime,
      'minScheduleNoticeHours': minScheduleNoticeHours,
      'reorderLevel': reorderLevel,
      'allowBackorder': allowBackorder,
      'categoryId': categoryId,
      'categoryNameEn': categoryNameEn,
      'categoryNameBn': categoryNameBn,
      'categorySlug': categorySlug,
      'brandId': brandId,
      'brandNameEn': brandNameEn,
      'brandNameBn': brandNameBn,
      'brandSlug': brandSlug,
      'productType': productType,
      'tags': tags,
      'keywords': keywords,
      'attributes': attributes.map((e) => e.toMap()).toList(),
      'variations': variations.map((e) => e.toMap()).toList(),
      'purchaseOptions': purchaseOptions.map((e) => e.toMap()).toList(),
      'cardLayoutType': _cardDesignLayoutTypeFromJson(cardDesignJson) ?? normalizedConfig.variantId,
      if (!(cardDesignJson?.trim().isNotEmpty ?? false))
        'cardConfig': normalizedConfig.toMap(),
      if (cardDesignJson?.trim().isNotEmpty ?? false)
        'cardDesignJson': cardDesignJson!.trim(),
      'isFeatured': isFeatured,
      'isFlashSale': isFlashSale,
      'isEnabled': isEnabled,
      'isNewArrival': isNewArrival,
      'isBestSeller': isBestSeller,
      'sortOrder': sortOrder,
      'publishAt': publishAt?.toIso8601String(),
      'unpublishAt': unpublishAt?.toIso8601String(),
      'views': views,
      'totalSold': totalSold,
      'addToCartCount': addToCartCount,
      'quantityType': quantityType,
      'quantityValue': quantityValue,
      'toleranceType': toleranceType,
      'tolerance': tolerance,
      'isToleranceActive': isToleranceActive,
      'deliveryShift': deliveryShift,
      'minOrderQty': minOrderQty,
      'maxOrderQty': maxOrderQty,
      'stepQty': stepQty,
      'unitLabelEn': unitLabelEn,
      'unitLabelBn': unitLabelBn,
      'status': status,
      'taxClassId': taxClassId,
      'vatRate': vatRate,
      'isTaxIncluded': isTaxIncluded,
      'weightValue': weightValue,
      'weightUnit': weightUnit,
      'length': length,
      'width': width,
      'height': height,
      'dimensionUnit': dimensionUnit,
      'shippingClassId': shippingClassId,
      'adminNote': adminNote,
      'metadata': metadata,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
      'deleteReason': deleteReason,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MBProduct.fromMap(Map? map) {
    if (map == null) return MBProduct.empty();

    final thumbnailUrl = (map['thumbnailUrl'] ?? '').toString();
    final imageUrls = _asStringList(map['imageUrls']);
    final mediaItems = _parseMediaItems(
      map['mediaItems'],
      thumbnailUrl: thumbnailUrl,
      imageUrls: imageUrls,
    );

    final cardConfig = _parseCardConfig(
      map['cardConfig'],
      fallbackLayoutType: map['cardLayoutType'],
    ).normalized();

    return MBProduct(
      id: (map['id'] ?? '').toString(),
      slug: (map['slug'] ?? '').toString(),
      productCode: map['productCode']?.toString(),
      sku: map['sku']?.toString(),
      barcode: map['barcode']?.toString(),
      titleEn: (map['titleEn'] ?? '').toString(),
      titleBn: (map['titleBn'] ?? '').toString(),
      shortDescriptionEn: (map['shortDescriptionEn'] ?? '').toString(),
      shortDescriptionBn: (map['shortDescriptionBn'] ?? '').toString(),
      descriptionEn: (map['descriptionEn'] ?? '').toString(),
      descriptionBn: (map['descriptionBn'] ?? '').toString(),
      thumbnailUrl: thumbnailUrl,
      imageUrls: imageUrls,
      mediaItems: mediaItems,
      price: _asDouble(map['price'], fallback: 0.0),
      salePrice: _asNullableDouble(map['salePrice']),
      costPrice: _asNullableDouble(map['costPrice']),
      saleStartsAt: _asNullableDateTime(map['saleStartsAt']),
      saleEndsAt: _asNullableDateTime(map['saleEndsAt']),
      stockQty: _asInt(map['stockQty'], fallback: 0),
      inventoryMode: (map['inventoryMode'] ?? 'stocked').toString(),
      trackInventory: _asBool(map['trackInventory'], fallback: true),
      supportsInstantOrder: _asBool(map['supportsInstantOrder'], fallback: true),
      supportsScheduledOrder: _asBool(
        map['supportsScheduledOrder'],
        fallback: false,
      ),
      regularStockQty: _asInt(
        map['regularStockQty'] ?? map['stockQty'],
        fallback: 0,
      ),
      reservedInstantQty: _asInt(map['reservedInstantQty'], fallback: 0),
      reservedQty: _asInt(
        map['reservedQty'] ?? map['reservedInstantQty'],
        fallback: 0,
      ),
      todayInstantCap: _asInt(map['todayInstantCap'], fallback: 999999),
      todayInstantSold: _asInt(map['todayInstantSold'], fallback: 0),
      maxScheduleQtyPerDay: _asInt(
        map['maxScheduleQtyPerDay'],
        fallback: 999999,
      ),
      schedulePriceType: (map['schedulePriceType'] ?? 'fixed').toString(),
      estimatedSchedulePrice: _asNullableDouble(map['estimatedSchedulePrice']),
      instantCutoffTime: map['instantCutoffTime']?.toString(),
      minScheduleNoticeHours:
      _asInt(map['minScheduleNoticeHours'], fallback: 0),
      reorderLevel: _asInt(map['reorderLevel'], fallback: 0),
      allowBackorder: _asBool(map['allowBackorder'], fallback: false),
      categoryId: map['categoryId']?.toString(),
      categoryNameEn: map['categoryNameEn']?.toString(),
      categoryNameBn: map['categoryNameBn']?.toString(),
      categorySlug: map['categorySlug']?.toString(),
      brandId: map['brandId']?.toString(),
      brandNameEn: map['brandNameEn']?.toString(),
      brandNameBn: map['brandNameBn']?.toString(),
      brandSlug: map['brandSlug']?.toString(),
      productType: (map['productType'] ?? 'simple').toString(),
      tags: _asStringList(map['tags']),
      keywords: _asStringList(map['keywords']),
      attributes: _parseAttributes(map['attributes']),
      variations: _parseVariations(map['variations']),
      purchaseOptions: _parsePurchaseOptions(map['purchaseOptions']),
      cardLayoutType: cardConfig.variantId,
      cardConfig: cardConfig,
      cardDesignJson: _asNullableString(
        map['cardDesignJson'] ?? map['cardDesignJsonV1'],
      ),
      isFeatured: _asBool(map['isFeatured'], fallback: false),
      isFlashSale: _asBool(map['isFlashSale'], fallback: false),
      isEnabled: _asBool(map['isEnabled'], fallback: true),
      isNewArrival: _asBool(map['isNewArrival'], fallback: false),
      isBestSeller: _asBool(map['isBestSeller'], fallback: false),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      publishAt: _asNullableDateTime(map['publishAt']),
      unpublishAt: _asNullableDateTime(map['unpublishAt']),
      views: _asInt(map['views'], fallback: 0),
      totalSold: _asInt(map['totalSold'], fallback: 0),
      addToCartCount: _asInt(map['addToCartCount'], fallback: 0),
      quantityType: (map['quantityType'] ?? 'pcs').toString(),
      quantityValue: _asDouble(map['quantityValue'], fallback: 0.0),
      toleranceType: (map['toleranceType'] ?? 'g').toString(),
      tolerance: _asDouble(map['tolerance'], fallback: 0.0),
      isToleranceActive: _asBool(map['isToleranceActive'], fallback: false),
      deliveryShift: (map['deliveryShift'] ?? 'any').toString(),
      minOrderQty: _asNullableDouble(map['minOrderQty']),
      maxOrderQty: _asNullableDouble(map['maxOrderQty']),
      stepQty: _asNullableDouble(map['stepQty']),
      unitLabelEn: map['unitLabelEn']?.toString(),
      unitLabelBn: map['unitLabelBn']?.toString(),
      status: (map['status'] ?? 'active').toString(),
      taxClassId: map['taxClassId']?.toString(),
      vatRate: _asNullableDouble(map['vatRate']),
      isTaxIncluded: _asBool(map['isTaxIncluded'], fallback: false),
      weightValue: _asNullableDouble(map['weightValue']),
      weightUnit: map['weightUnit']?.toString(),
      length: _asNullableDouble(map['length']),
      width: _asNullableDouble(map['width']),
      height: _asNullableDouble(map['height']),
      dimensionUnit: map['dimensionUnit']?.toString(),
      shippingClassId: map['shippingClassId']?.toString(),
      adminNote: map['adminNote']?.toString(),
      metadata: _asDynamicMap(map['metadata']),
      isDeleted: _asBool(map['isDeleted'], fallback: false),
      deletedAt: _asNullableDateTime(map['deletedAt']),
      deletedBy: map['deletedBy']?.toString(),
      deleteReason: map['deleteReason']?.toString(),
      createdBy: map['createdBy']?.toString(),
      updatedBy: map['updatedBy']?.toString(),
      createdAt: _asNullableDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _asNullableDateTime(map['updatedAt']) ?? DateTime.now(),
    );
  }

  factory MBProduct.fromJson(String source) {
    final decoded = json.decode(source);
    if (decoded is Map) {
      return MBProduct.fromMap(Map<String, dynamic>.from(decoded));
    }
    return MBProduct.empty();
  }

  String toJson() => json.encode(toMap());
}

const MBCardInstanceConfig _defaultCardConfig = MBCardInstanceConfig(
  family: MBCardFamily.compact,
  variant: MBCardVariant.compact01,
);

String? _cardDesignLayoutTypeFromJson(String? source) {
  final text = source?.trim();
  if (text == null || text.isEmpty) return null;
  try {
    final decoded = json.decode(text);
    if (decoded is Map) {
      final templateId = decoded['templateId']?.toString().trim() ?? '';
      if (templateId.isNotEmpty) return templateId;
      final designFamilyId = decoded['designFamilyId']?.toString().trim() ?? '';
      if (designFamilyId.isNotEmpty) return designFamilyId;
    }
  } catch (_) {
    // Invalid JSON still means this product is using the advanced design slot.
  }
  return 'advanced_v3';
}
String? _asNullableString(dynamic value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
List<String> _asStringList(dynamic value) {
  if (value is! List) return const <String>[];

  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<MBProductMedia> _parseMediaItems(
    dynamic rawMedia, {
      required String thumbnailUrl,
      required List<String> imageUrls,
    }) {
  final items = <MBProductMedia>[];

  if (rawMedia is List) {
    for (final item in rawMedia) {
      if (item is Map) {
        items.add(MBProductMedia.fromMap(Map<String, dynamic>.from(item)));
      }
    }
  }

  if (items.isNotEmpty) return items;

  final fallback = <MBProductMedia>[];
  final cleanThumbnailUrl = thumbnailUrl.trim();

  if (cleanThumbnailUrl.isNotEmpty) {
    fallback.add(
      MBProductMedia.fromLegacyUrl(
        cleanThumbnailUrl,
        id: 'thumbnail',
        role: 'thumbnail',
        sortOrder: 0,
        isPrimary: true,
      ),
    );
  }

  for (var index = 0; index < imageUrls.length; index++) {
    final url = imageUrls[index].toString().trim();
    if (url.isEmpty) continue;
    if (url == cleanThumbnailUrl) continue;

    fallback.add(
      MBProductMedia.fromLegacyUrl(
        url,
        id: 'gallery_$index',
        role: 'gallery',
        sortOrder: index + 1,
      ),
    );
  }

  return fallback;
}

List<MBProductAttribute> _parseAttributes(dynamic rawAttributes) {
  if (rawAttributes is! List) return const <MBProductAttribute>[];

  final items = <MBProductAttribute>[];
  for (final item in rawAttributes) {
    if (item is Map) {
      items.add(MBProductAttribute.fromMap(Map<String, dynamic>.from(item)));
    }
  }

  return items;
}

List<MBProductVariation> _parseVariations(dynamic rawVariations) {
  if (rawVariations is! List) return const <MBProductVariation>[];

  final items = <MBProductVariation>[];
  for (final item in rawVariations) {
    if (item is Map) {
      items.add(MBProductVariation.fromMap(Map<String, dynamic>.from(item)));
    }
  }

  return items;
}

List<MBProductPurchaseOption> _parsePurchaseOptions(dynamic rawOptions) {
  if (rawOptions is! List) return const <MBProductPurchaseOption>[];

  final items = <MBProductPurchaseOption>[];
  for (final item in rawOptions) {
    if (item is Map) {
      items.add(
        MBProductPurchaseOption.fromMap(Map<String, dynamic>.from(item)),
      );
    }
  }

  return items;
}

MBCardInstanceConfig _parseCardConfig(
    dynamic rawConfig, {
      required dynamic fallbackLayoutType,
    }) {
  if (rawConfig is Map) {
    return MBCardInstanceConfig.fromMap(
      Map<String, dynamic>.from(rawConfig),
    ).normalized();
  }

  return _cardConfigFromLayoutType(fallbackLayoutType);
}

MBCardInstanceConfig _cardConfigFromLayoutType(dynamic value) {
  final variant = MBCardVariantHelper.parse(
    _normalizeCardLayoutType(value),
    fallback: MBCardVariant.compact01,
  );

  return MBCardInstanceConfig(
    family: variant.family,
    variant: variant,
  );
}

String _normalizeCardLayoutType(dynamic value) {
  final normalized = value?.toString().trim().toLowerCase() ?? '';

  if (normalized.isEmpty) {
    return MBCardVariant.compact01.id;
  }

  for (final variant in MBCardVariant.values) {
    if (variant.id.toLowerCase() == normalized) {
      return variant.id;
    }
  }

  // New design only: no old layout aliases are accepted here.
  // Invalid values safely fall back to the default new variant.
  return MBCardVariant.compact01.id;
}

bool _isLegacyDealLayout(dynamic value) => false;

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  return double.tryParse(text);
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}


Map<String, dynamic> _asDynamicMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};

  return value.map(
    (key, item) => MapEntry(key.toString(), item),
  );
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

DateTime? _asNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  try {
    final dynamic dynamicValue = value;
    final dynamic converted = dynamicValue.toDate();
    if (converted is DateTime) return converted;
  } catch (_) {
    // Ignore non-Firestore timestamp-like values.
  }

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}

