import 'dart:convert';

import '../product_cards/config/mb_card_instance_config.dart';
import '../product_cards/config/mb_card_variant.dart';
import 'mb_product_purchase_option.dart';

// File: mb_product_variation.dart
// MB Product Variation Model
// --------------------------
// Defines a concrete sellable variation of a product.
//
// Phase 2 update:
// - Adds variation-level merchandising flags:
//   isFeatured, isFlashSale, isNewArrival, isBestSeller
// - Keeps all existing image / pricing / inventory / quantity behavior
// - Safe for old Firestore docs because new flags default to false

class MBProductVariation {
  final String id;
  final String sku;
  final String? barcode;
  final String titleEn;
  final String titleBn;
  final String shortDescriptionEn;
  final String shortDescriptionBn;

  // Legacy / compatibility image fields.
  final String imageUrl;
  final String imageStoragePath;

  // New variation image fields.
  final String fullImageUrl;
  final String fullImageStoragePath;
  final String thumbImageUrl;
  final String thumbImageStoragePath;
  final String originalImageUrl;
  final String originalImageStoragePath;

  final int? imageWidth;
  final int? imageHeight;
  final int? imageSizeBytes;

  final int? fullImageWidth;
  final int? fullImageHeight;
  final int? fullImageSizeBytes;

  final int? thumbImageWidth;
  final int? thumbImageHeight;
  final int? thumbImageSizeBytes;

  final int? originalImageWidth;
  final int? originalImageHeight;
  final int? originalImageSizeBytes;

  final String descriptionEn;
  final String descriptionBn;

  final double price;
  final double? salePrice;
  final double? costPrice;
  final DateTime? saleStartsAt;
  final DateTime? saleEndsAt;
  final String schedulePriceType;
  final double? estimatedSchedulePrice;

  final int stockQty;
  final int reservedQty;
  final String inventoryMode;
  final bool trackInventory;
  final bool supportsInstantOrder;
  final bool supportsScheduledOrder;
  final bool allowBackorder;
  final String? instantCutoffTime;
  final int todayInstantCap;
  final int todayInstantSold;
  final int maxScheduleQtyPerDay;
  final int minScheduleNoticeHours;
  final int reorderLevel;

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

  final List<MBProductPurchaseOption> purchaseOptions;

  final Map<String, String> attributeValues;
  final int sortOrder;
  final bool isDefault;
  final bool isEnabled;

  // Variation-level merchandising flags.
  final bool isFeatured;
  final bool isFlashSale;
  final bool isNewArrival;
  final bool isBestSeller;

  final DateTime? publishAt;
  final DateTime? unpublishAt;

  final int views;
  final int totalSold;
  final int addToCartCount;

  final String? cardLayoutType;
  final MBCardInstanceConfig? cardConfig;

  // Variation-level design-family card studio JSON.
  final String? cardDesignJson;

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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MBProductVariation({
    required this.id,
    this.sku = '',
    this.barcode,
    this.titleEn = '',
    this.titleBn = '',
    this.shortDescriptionEn = '',
    this.shortDescriptionBn = '',
    this.imageUrl = '',
    this.imageStoragePath = '',
    this.fullImageUrl = '',
    this.fullImageStoragePath = '',
    this.thumbImageUrl = '',
    this.thumbImageStoragePath = '',
    this.originalImageUrl = '',
    this.originalImageStoragePath = '',
    this.imageWidth,
    this.imageHeight,
    this.imageSizeBytes,
    this.fullImageWidth,
    this.fullImageHeight,
    this.fullImageSizeBytes,
    this.thumbImageWidth,
    this.thumbImageHeight,
    this.thumbImageSizeBytes,
    this.originalImageWidth,
    this.originalImageHeight,
    this.originalImageSizeBytes,
    this.descriptionEn = '',
    this.descriptionBn = '',
    this.price = 0.0,
    this.salePrice,
    this.costPrice,
    this.saleStartsAt,
    this.saleEndsAt,
    this.schedulePriceType = 'fixed',
    this.estimatedSchedulePrice,
    this.stockQty = 0,
    this.reservedQty = 0,
    this.inventoryMode = 'stocked',
    this.trackInventory = true,
    this.supportsInstantOrder = true,
    this.supportsScheduledOrder = false,
    this.allowBackorder = false,
    this.instantCutoffTime,
    this.todayInstantCap = 999999,
    this.todayInstantSold = 0,
    this.maxScheduleQtyPerDay = 999999,
    this.minScheduleNoticeHours = 0,
    this.reorderLevel = 0,
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
    this.purchaseOptions = const [],
    this.attributeValues = const {},
    this.sortOrder = 0,
    this.isDefault = false,
    this.isEnabled = true,
    this.isFeatured = false,
    this.isFlashSale = false,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.publishAt,
    this.unpublishAt,
    this.views = 0,
    this.totalSold = 0,
    this.addToCartCount = 0,
    this.cardLayoutType,
    this.cardConfig,
    this.cardDesignJson,
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
    this.createdAt,
    this.updatedAt,
  });

  static const MBProductVariation empty = MBProductVariation(id: '');

  bool get hasCardDesignJson {
    final value = cardDesignJson;
    return value != null && value.trim().isNotEmpty;
  }

  bool get hasPurchaseOptions => purchaseOptions.isNotEmpty;

  bool get usesEstimatedSchedulePrice =>
      schedulePriceType == 'estimated' || schedulePriceType == 'market';

  MBCardInstanceConfig? get effectiveCardConfig => cardConfig?.normalized();
  String? get effectiveCardVariantId => effectiveCardConfig?.variantId;
  String? get effectiveCardFamilyId => effectiveCardConfig?.familyId;

  MBProductVariation copyWith({
    String? id,
    String? sku,
    String? barcode,
    bool clearBarcode = false,
    String? titleEn,
    String? titleBn,
    String? shortDescriptionEn,
    String? shortDescriptionBn,
    String? imageUrl,
    String? imageStoragePath,
    String? fullImageUrl,
    String? fullImageStoragePath,
    String? thumbImageUrl,
    String? thumbImageStoragePath,
    String? originalImageUrl,
    String? originalImageStoragePath,
    int? imageWidth,
    bool clearImageWidth = false,
    int? imageHeight,
    bool clearImageHeight = false,
    int? imageSizeBytes,
    bool clearImageSizeBytes = false,
    int? fullImageWidth,
    bool clearFullImageWidth = false,
    int? fullImageHeight,
    bool clearFullImageHeight = false,
    int? fullImageSizeBytes,
    bool clearFullImageSizeBytes = false,
    int? thumbImageWidth,
    bool clearThumbImageWidth = false,
    int? thumbImageHeight,
    bool clearThumbImageHeight = false,
    int? thumbImageSizeBytes,
    bool clearThumbImageSizeBytes = false,
    int? originalImageWidth,
    bool clearOriginalImageWidth = false,
    int? originalImageHeight,
    bool clearOriginalImageHeight = false,
    int? originalImageSizeBytes,
    bool clearOriginalImageSizeBytes = false,
    String? descriptionEn,
    String? descriptionBn,
    double? price,
    double? salePrice,
    bool clearSalePrice = false,
    double? costPrice,
    bool clearCostPrice = false,
    DateTime? saleStartsAt,
    bool clearSaleStartsAt = false,
    DateTime? saleEndsAt,
    bool clearSaleEndsAt = false,
    String? schedulePriceType,
    double? estimatedSchedulePrice,
    bool clearEstimatedSchedulePrice = false,
    int? stockQty,
    int? reservedQty,
    String? inventoryMode,
    bool? trackInventory,
    bool? supportsInstantOrder,
    bool? supportsScheduledOrder,
    bool? allowBackorder,
    String? instantCutoffTime,
    bool clearInstantCutoffTime = false,
    int? todayInstantCap,
    int? todayInstantSold,
    int? maxScheduleQtyPerDay,
    int? minScheduleNoticeHours,
    int? reorderLevel,
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
    List<MBProductPurchaseOption>? purchaseOptions,
    Map<String, String>? attributeValues,
    int? sortOrder,
    bool? isDefault,
    bool? isEnabled,
    bool? isFeatured,
    bool? isFlashSale,
    bool? isNewArrival,
    bool? isBestSeller,
    DateTime? publishAt,
    bool clearPublishAt = false,
    DateTime? unpublishAt,
    bool clearUnpublishAt = false,
    int? views,
    int? totalSold,
    int? addToCartCount,
    String? cardLayoutType,
    bool clearCardLayoutType = false,
    MBCardInstanceConfig? cardConfig,
    bool clearCardConfig = false,
    String? cardDesignJson,
    bool clearCardDesignJson = false,
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
    bool clearCreatedAt = false,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return MBProductVariation(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      shortDescriptionEn: shortDescriptionEn ?? this.shortDescriptionEn,
      shortDescriptionBn: shortDescriptionBn ?? this.shortDescriptionBn,
      imageUrl: imageUrl ?? this.imageUrl,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      fullImageUrl: fullImageUrl ?? this.fullImageUrl,
      fullImageStoragePath: fullImageStoragePath ?? this.fullImageStoragePath,
      thumbImageUrl: thumbImageUrl ?? this.thumbImageUrl,
      thumbImageStoragePath:
      thumbImageStoragePath ?? this.thumbImageStoragePath,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      originalImageStoragePath:
      originalImageStoragePath ?? this.originalImageStoragePath,
      imageWidth: clearImageWidth ? null : (imageWidth ?? this.imageWidth),
      imageHeight: clearImageHeight ? null : (imageHeight ?? this.imageHeight),
      imageSizeBytes: clearImageSizeBytes
          ? null
          : (imageSizeBytes ?? this.imageSizeBytes),
      fullImageWidth: clearFullImageWidth
          ? null
          : (fullImageWidth ?? this.fullImageWidth),
      fullImageHeight: clearFullImageHeight
          ? null
          : (fullImageHeight ?? this.fullImageHeight),
      fullImageSizeBytes: clearFullImageSizeBytes
          ? null
          : (fullImageSizeBytes ?? this.fullImageSizeBytes),
      thumbImageWidth: clearThumbImageWidth
          ? null
          : (thumbImageWidth ?? this.thumbImageWidth),
      thumbImageHeight: clearThumbImageHeight
          ? null
          : (thumbImageHeight ?? this.thumbImageHeight),
      thumbImageSizeBytes: clearThumbImageSizeBytes
          ? null
          : (thumbImageSizeBytes ?? this.thumbImageSizeBytes),
      originalImageWidth: clearOriginalImageWidth
          ? null
          : (originalImageWidth ?? this.originalImageWidth),
      originalImageHeight: clearOriginalImageHeight
          ? null
          : (originalImageHeight ?? this.originalImageHeight),
      originalImageSizeBytes: clearOriginalImageSizeBytes
          ? null
          : (originalImageSizeBytes ?? this.originalImageSizeBytes),
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      price: price ?? this.price,
      salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
      costPrice: clearCostPrice ? null : (costPrice ?? this.costPrice),
      saleStartsAt:
      clearSaleStartsAt ? null : (saleStartsAt ?? this.saleStartsAt),
      saleEndsAt: clearSaleEndsAt ? null : (saleEndsAt ?? this.saleEndsAt),
      schedulePriceType: schedulePriceType ?? this.schedulePriceType,
      estimatedSchedulePrice: clearEstimatedSchedulePrice
          ? null
          : (estimatedSchedulePrice ?? this.estimatedSchedulePrice),
      stockQty: stockQty ?? this.stockQty,
      reservedQty: reservedQty ?? this.reservedQty,
      inventoryMode: inventoryMode ?? this.inventoryMode,
      trackInventory: trackInventory ?? this.trackInventory,
      supportsInstantOrder: supportsInstantOrder ?? this.supportsInstantOrder,
      supportsScheduledOrder:
      supportsScheduledOrder ?? this.supportsScheduledOrder,
      allowBackorder: allowBackorder ?? this.allowBackorder,
      instantCutoffTime: clearInstantCutoffTime
          ? null
          : (instantCutoffTime ?? this.instantCutoffTime),
      todayInstantCap: todayInstantCap ?? this.todayInstantCap,
      todayInstantSold: todayInstantSold ?? this.todayInstantSold,
      maxScheduleQtyPerDay:
      maxScheduleQtyPerDay ?? this.maxScheduleQtyPerDay,
      minScheduleNoticeHours:
      minScheduleNoticeHours ?? this.minScheduleNoticeHours,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      quantityType: quantityType ?? this.quantityType,
      quantityValue: quantityValue ?? this.quantityValue,
      toleranceType: toleranceType ?? this.toleranceType,
      tolerance: tolerance ?? this.tolerance,
      isToleranceActive: isToleranceActive ?? this.isToleranceActive,
      deliveryShift: deliveryShift ?? this.deliveryShift,
      minOrderQty:
      clearMinOrderQty ? null : (minOrderQty ?? this.minOrderQty),
      maxOrderQty:
      clearMaxOrderQty ? null : (maxOrderQty ?? this.maxOrderQty),
      stepQty: clearStepQty ? null : (stepQty ?? this.stepQty),
      unitLabelEn:
      clearUnitLabelEn ? null : (unitLabelEn ?? this.unitLabelEn),
      unitLabelBn:
      clearUnitLabelBn ? null : (unitLabelBn ?? this.unitLabelBn),
      purchaseOptions: purchaseOptions ?? this.purchaseOptions,
      attributeValues: attributeValues ?? this.attributeValues,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      isFeatured: isFeatured ?? this.isFeatured,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      publishAt: clearPublishAt ? null : (publishAt ?? this.publishAt),
      unpublishAt: clearUnpublishAt ? null : (unpublishAt ?? this.unpublishAt),
      views: views ?? this.views,
      totalSold: totalSold ?? this.totalSold,
      addToCartCount: addToCartCount ?? this.addToCartCount,
      cardLayoutType:
          clearCardLayoutType ? null : (cardLayoutType ?? this.cardLayoutType),
      cardConfig: clearCardConfig ? null : (cardConfig ?? this.cardConfig),
      cardDesignJson:
          clearCardDesignJson ? null : (cardDesignJson ?? this.cardDesignJson),
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
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  bool isSaleActiveAt(DateTime at) {
    final currentSalePrice = salePrice;
    if (currentSalePrice == null ||
        currentSalePrice <= 0 ||
        currentSalePrice >= price) {
      return false;
    }

    final startsAt = saleStartsAt;
    final endsAt = saleEndsAt;

    if (startsAt != null && at.isBefore(startsAt)) {
      return false;
    }

    if (endsAt != null && at.isAfter(endsAt)) {
      return false;
    }

    return true;
  }

  bool get isSaleActiveNow => isSaleActiveAt(DateTime.now());

  bool get hasDiscount => isSaleActiveNow;

  double get effectivePrice => effectivePriceAt(DateTime.now());

  double effectivePriceAt(DateTime at) {
    if (!isSaleActiveAt(at)) {
      return price;
    }

    return salePrice ?? price;
  }

  int get discountPercent {
    if (!hasDiscount || price <= 0 || salePrice == null) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  int get availableStock {
    final value = stockQty - reservedQty;
    return value < 0 ? 0 : value;
  }

  bool get inStock => allowBackorder || availableStock > 0;

  bool isPublishedAt(DateTime at) {
    if (!isEnabled || isDeleted) return false;
    if (publishAt != null && at.isBefore(publishAt!)) return false;
    if (unpublishAt != null && at.isAfter(unpublishAt!)) return false;
    return true;
  }

  bool get isPublishedNow => isPublishedAt(DateTime.now());

  String get effectiveFullImageUrl {
    if (fullImageUrl.trim().isNotEmpty) return fullImageUrl.trim();
    if (imageUrl.trim().isNotEmpty) return imageUrl.trim();
    if (originalImageUrl.trim().isNotEmpty) return originalImageUrl.trim();
    return '';
  }

  String get effectiveThumbImageUrl {
    if (thumbImageUrl.trim().isNotEmpty) return thumbImageUrl.trim();
    return effectiveFullImageUrl;
  }

  String get effectiveOriginalImageUrl {
    if (originalImageUrl.trim().isNotEmpty) return originalImageUrl.trim();
    return effectiveFullImageUrl;
  }

  String get effectiveFullImageStoragePath {
    if (fullImageStoragePath.trim().isNotEmpty) {
      return fullImageStoragePath.trim();
    }
    if (imageStoragePath.trim().isNotEmpty) return imageStoragePath.trim();
    if (originalImageStoragePath.trim().isNotEmpty) {
      return originalImageStoragePath.trim();
    }
    return '';
  }

  String get effectiveThumbImageStoragePath {
    if (thumbImageStoragePath.trim().isNotEmpty) {
      return thumbImageStoragePath.trim();
    }
    return effectiveFullImageStoragePath;
  }

  String get effectiveOriginalImageStoragePath {
    if (originalImageStoragePath.trim().isNotEmpty) {
      return originalImageStoragePath.trim();
    }
    return effectiveFullImageStoragePath;
  }

  int? get effectiveFullImageWidth =>
      fullImageWidth ?? imageWidth ?? originalImageWidth;
  int? get effectiveFullImageHeight =>
      fullImageHeight ?? imageHeight ?? originalImageHeight;
  int? get effectiveFullImageSizeBytes =>
      fullImageSizeBytes ?? imageSizeBytes ?? originalImageSizeBytes;

  int? get effectiveThumbImageWidth =>
      thumbImageWidth ?? effectiveFullImageWidth;
  int? get effectiveThumbImageHeight =>
      thumbImageHeight ?? effectiveFullImageHeight;
  int? get effectiveThumbImageSizeBytes =>
      thumbImageSizeBytes ?? effectiveFullImageSizeBytes;

  int? get effectiveOriginalImageWidth =>
      originalImageWidth ?? effectiveFullImageWidth;
  int? get effectiveOriginalImageHeight =>
      originalImageHeight ?? effectiveFullImageHeight;
  int? get effectiveOriginalImageSizeBytes =>
      originalImageSizeBytes ?? effectiveFullImageSizeBytes;

  String get previewImageUrl => effectiveThumbImageUrl;
  String get displayImageUrl => effectiveFullImageUrl;

  bool get hasImage => displayImageUrl.isNotEmpty;
  bool get hasSeparateThumbnail =>
      thumbImageUrl.trim().isNotEmpty && previewImageUrl != displayImageUrl;
  bool get hasOriginalImage => originalImageUrl.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'barcode': barcode,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'shortDescriptionEn': shortDescriptionEn,
      'shortDescriptionBn': shortDescriptionBn,
      'imageUrl': imageUrl.isNotEmpty ? imageUrl : effectiveFullImageUrl,
      'imageStoragePath': imageStoragePath.isNotEmpty
          ? imageStoragePath
          : effectiveFullImageStoragePath,
      'fullImageUrl':
      fullImageUrl.isNotEmpty ? fullImageUrl : effectiveFullImageUrl,
      'fullImageStoragePath': fullImageStoragePath.isNotEmpty
          ? fullImageStoragePath
          : effectiveFullImageStoragePath,
      'thumbImageUrl': thumbImageUrl.isNotEmpty ? thumbImageUrl : '',
      'thumbImageStoragePath':
      thumbImageStoragePath.isNotEmpty ? thumbImageStoragePath : '',
      'originalImageUrl': originalImageUrl.isNotEmpty ? originalImageUrl : '',
      'originalImageStoragePath':
      originalImageStoragePath.isNotEmpty ? originalImageStoragePath : '',
      'imageWidth': imageWidth ?? effectiveFullImageWidth,
      'imageHeight': imageHeight ?? effectiveFullImageHeight,
      'imageSizeBytes': imageSizeBytes ?? effectiveFullImageSizeBytes,
      'fullImageWidth': fullImageWidth ?? effectiveFullImageWidth,
      'fullImageHeight': fullImageHeight ?? effectiveFullImageHeight,
      'fullImageSizeBytes': fullImageSizeBytes ?? effectiveFullImageSizeBytes,
      'thumbImageWidth': thumbImageWidth,
      'thumbImageHeight': thumbImageHeight,
      'thumbImageSizeBytes': thumbImageSizeBytes,
      'originalImageWidth': originalImageWidth,
      'originalImageHeight': originalImageHeight,
      'originalImageSizeBytes': originalImageSizeBytes,
      'descriptionEn': descriptionEn,
      'descriptionBn': descriptionBn,
      'price': price,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'saleStartsAt': saleStartsAt?.toIso8601String(),
      'saleEndsAt': saleEndsAt?.toIso8601String(),
      'schedulePriceType': schedulePriceType,
      'estimatedSchedulePrice': estimatedSchedulePrice,
      'stockQty': stockQty,
      'reservedQty': reservedQty,
      'inventoryMode': inventoryMode,
      'trackInventory': trackInventory,
      'supportsInstantOrder': supportsInstantOrder,
      'supportsScheduledOrder': supportsScheduledOrder,
      'allowBackorder': allowBackorder,
      'instantCutoffTime': instantCutoffTime,
      'todayInstantCap': todayInstantCap,
      'todayInstantSold': todayInstantSold,
      'maxScheduleQtyPerDay': maxScheduleQtyPerDay,
      'minScheduleNoticeHours': minScheduleNoticeHours,
      'reorderLevel': reorderLevel,
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
      'purchaseOptions': purchaseOptions.map((option) => option.toMap()).toList(),
      'attributeValues': attributeValues,
      'sortOrder': sortOrder,
      'isDefault': isDefault,
      'isEnabled': isEnabled,
      'isFeatured': isFeatured,
      'isFlashSale': isFlashSale,
      'isNewArrival': isNewArrival,
      'isBestSeller': isBestSeller,
      'publishAt': publishAt?.toIso8601String(),
      'unpublishAt': unpublishAt?.toIso8601String(),
      'views': views,
      'totalSold': totalSold,
      'addToCartCount': addToCartCount,
      'cardLayoutType': _cardDesignLayoutTypeFromJson(cardDesignJson) ??
          cardConfig?.normalized().variantId ??
          cardLayoutType,
      if (!(cardDesignJson?.trim().isNotEmpty ?? false) && cardConfig != null)
        'cardConfig': cardConfig!.normalized().toMap(),
      if (cardDesignJson?.trim().isNotEmpty ?? false)
        'cardDesignJson': cardDesignJson!.trim(),
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBProductVariation.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return empty;

    final legacyImageUrl = _asString(map['imageUrl']);
    final legacyImageStoragePath = _asString(map['imageStoragePath']);
    final parsedFullImageUrl = _asString(map['fullImageUrl']);
    final parsedThumbImageUrl = _asString(map['thumbImageUrl']);
    final parsedOriginalImageUrl = _asString(map['originalImageUrl']);
    final parsedFullImageStoragePath = _asString(map['fullImageStoragePath']);
    final parsedThumbImageStoragePath =
    _asString(map['thumbImageStoragePath']);
    final parsedOriginalImageStoragePath =
    _asString(map['originalImageStoragePath']);
    final parsedCardDesignJson = _asNullableString(
      map['cardDesignJson'] ?? map['cardDesignJsonV1'],
    );
    final parsedCardConfig = _parseNullableCardConfig(
      map['cardConfig'],
      fallbackLayoutType: map['cardLayoutType'],
    );
    final parsedCardLayoutType = parsedCardConfig?.variantId ??
        _cardDesignLayoutTypeFromJson(parsedCardDesignJson) ??
        _normalizeCardLayoutType(map['cardLayoutType']);

    return MBProductVariation(
      id: _asString(map['id']),
      sku: _asString(map['sku']),
      barcode: _asNullableString(map['barcode']),
      titleEn: _asString(map['titleEn']),
      titleBn: _asString(map['titleBn']),
      shortDescriptionEn: _asString(map['shortDescriptionEn']),
      shortDescriptionBn: _asString(map['shortDescriptionBn']),
      imageUrl: legacyImageUrl.isNotEmpty ? legacyImageUrl : parsedFullImageUrl,
      imageStoragePath: legacyImageStoragePath.isNotEmpty
          ? legacyImageStoragePath
          : parsedFullImageStoragePath,
      fullImageUrl:
      parsedFullImageUrl.isNotEmpty ? parsedFullImageUrl : legacyImageUrl,
      fullImageStoragePath: parsedFullImageStoragePath.isNotEmpty
          ? parsedFullImageStoragePath
          : legacyImageStoragePath,
      thumbImageUrl: parsedThumbImageUrl,
      thumbImageStoragePath: parsedThumbImageStoragePath,
      originalImageUrl: parsedOriginalImageUrl,
      originalImageStoragePath: parsedOriginalImageStoragePath,
      imageWidth: _asNullableInt(map['imageWidth']),
      imageHeight: _asNullableInt(map['imageHeight']),
      imageSizeBytes: _asNullableInt(map['imageSizeBytes']),
      fullImageWidth:
      _asNullableInt(map['fullImageWidth']) ?? _asNullableInt(map['imageWidth']),
      fullImageHeight: _asNullableInt(map['fullImageHeight']) ??
          _asNullableInt(map['imageHeight']),
      fullImageSizeBytes: _asNullableInt(map['fullImageSizeBytes']) ??
          _asNullableInt(map['imageSizeBytes']),
      thumbImageWidth: _asNullableInt(map['thumbImageWidth']),
      thumbImageHeight: _asNullableInt(map['thumbImageHeight']),
      thumbImageSizeBytes: _asNullableInt(map['thumbImageSizeBytes']),
      originalImageWidth: _asNullableInt(map['originalImageWidth']),
      originalImageHeight: _asNullableInt(map['originalImageHeight']),
      originalImageSizeBytes: _asNullableInt(map['originalImageSizeBytes']),
      descriptionEn: _asString(map['descriptionEn']),
      descriptionBn: _asString(map['descriptionBn']),
      price: _asDouble(map['price'], fallback: 0.0),
      salePrice: _asNullableDouble(map['salePrice']),
      costPrice: _asNullableDouble(map['costPrice']),
      saleStartsAt: _asNullableDateTime(map['saleStartsAt']),
      saleEndsAt: _asNullableDateTime(map['saleEndsAt']),
      schedulePriceType: _asString(map['schedulePriceType'], fallback: 'fixed'),
      estimatedSchedulePrice: _asNullableDouble(map['estimatedSchedulePrice']),
      stockQty: _asInt(map['stockQty'], fallback: 0),
      reservedQty: _asInt(map['reservedQty'], fallback: 0),
      inventoryMode: _asString(map['inventoryMode'], fallback: 'stocked'),
      trackInventory: _asBool(map['trackInventory'], fallback: true),
      supportsInstantOrder:
      _asBool(map['supportsInstantOrder'], fallback: true),
      supportsScheduledOrder:
      _asBool(map['supportsScheduledOrder'], fallback: false),
      allowBackorder: _asBool(map['allowBackorder'], fallback: false),
      instantCutoffTime: _asNullableString(map['instantCutoffTime']),
      todayInstantCap: _asInt(map['todayInstantCap'], fallback: 999999),
      todayInstantSold: _asInt(map['todayInstantSold'], fallback: 0),
      maxScheduleQtyPerDay:
      _asInt(map['maxScheduleQtyPerDay'], fallback: 999999),
      minScheduleNoticeHours:
      _asInt(map['minScheduleNoticeHours'], fallback: 0),
      reorderLevel: _asInt(map['reorderLevel'], fallback: 0),
      quantityType: _asString(map['quantityType'], fallback: 'pcs'),
      quantityValue: _asDouble(map['quantityValue'], fallback: 0.0),
      toleranceType: _asString(map['toleranceType'], fallback: 'g'),
      tolerance: _asDouble(map['tolerance'], fallback: 0.0),
      isToleranceActive:
      _asBool(map['isToleranceActive'], fallback: false),
      deliveryShift: _asString(map['deliveryShift'], fallback: 'any'),
      minOrderQty: _asNullableDouble(map['minOrderQty']),
      maxOrderQty: _asNullableDouble(map['maxOrderQty']),
      stepQty: _asNullableDouble(map['stepQty']),
      unitLabelEn: _asNullableString(map['unitLabelEn']),
      unitLabelBn: _asNullableString(map['unitLabelBn']),
      purchaseOptions: _parsePurchaseOptions(map['purchaseOptions']),
      attributeValues: _asStringMap(map['attributeValues']),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      isDefault: _asBool(map['isDefault'], fallback: false),
      isEnabled: _asBool(map['isEnabled'], fallback: true),
      isFeatured: _asBool(map['isFeatured'], fallback: false),
      isFlashSale: _asBool(map['isFlashSale'], fallback: false),
      isNewArrival: _asBool(map['isNewArrival'], fallback: false),
      isBestSeller: _asBool(map['isBestSeller'], fallback: false),
      publishAt: _asNullableDateTime(map['publishAt']),
      unpublishAt: _asNullableDateTime(map['unpublishAt']),
      views: _asInt(map['views'], fallback: 0),
      totalSold: _asInt(map['totalSold'], fallback: 0),
      addToCartCount: _asInt(map['addToCartCount'], fallback: 0),
      cardLayoutType: parsedCardLayoutType,
      cardConfig: parsedCardConfig,
      cardDesignJson: parsedCardDesignJson,
      status: _asString(map['status'], fallback: 'active'),
      taxClassId: _asNullableString(map['taxClassId']),
      vatRate: _asNullableDouble(map['vatRate']),
      isTaxIncluded: _asBool(map['isTaxIncluded'], fallback: false),
      weightValue: _asNullableDouble(map['weightValue']),
      weightUnit: _asNullableString(map['weightUnit']),
      length: _asNullableDouble(map['length']),
      width: _asNullableDouble(map['width']),
      height: _asNullableDouble(map['height']),
      dimensionUnit: _asNullableString(map['dimensionUnit']),
      shippingClassId: _asNullableString(map['shippingClassId']),
      adminNote: _asNullableString(map['adminNote']),
      metadata: _asDynamicMap(map['metadata']),
      isDeleted: _asBool(map['isDeleted'], fallback: false),
      deletedAt: _asNullableDateTime(map['deletedAt']),
      deletedBy: _asNullableString(map['deletedBy']),
      deleteReason: _asNullableString(map['deleteReason']),
      createdBy: _asNullableString(map['createdBy']),
      updatedBy: _asNullableString(map['updatedBy']),
      createdAt: _asNullableDateTime(map['createdAt']),
      updatedAt: _asNullableDateTime(map['updatedAt']),
    );
  }

  factory MBProductVariation.fromLegacyMap(Map<dynamic, dynamic>? map) {
    if (map == null) return empty;

    final dynamic rawAttributeValues =
        map['AttributeValues'] ?? map['AttributeValue'] ?? const {};
    final legacyImage = _asString(map['Image']);

    return MBProductVariation(
      id: _asString(map['Id']),
      sku: _asString(map['SKU']),
      barcode: _asNullableString(map['Barcode']),
      titleEn: _asString(map['Title']),
      titleBn: '',
      shortDescriptionEn: '',
      shortDescriptionBn: '',
      imageUrl: legacyImage,
      fullImageUrl: legacyImage,
      descriptionEn: _asString(map['Description']),
      descriptionBn: '',
      price: _asDouble(map['Price'], fallback: 0.0),
      salePrice: _asNullableDouble(map['SalePrice']),
      costPrice: _asNullableDouble(map['CostPrice']),
      saleStartsAt: null,
      saleEndsAt: null,
      schedulePriceType: 'fixed',
      estimatedSchedulePrice: null,
      stockQty: _asInt(map['Stock'], fallback: 0),
      reservedQty: _asInt(map['ReservedQty'], fallback: 0),
      inventoryMode: 'stocked',
      trackInventory: true,
      supportsInstantOrder: true,
      supportsScheduledOrder: false,
      allowBackorder: false,
      instantCutoffTime: null,
      todayInstantCap: 999999,
      todayInstantSold: 0,
      maxScheduleQtyPerDay: 999999,
      minScheduleNoticeHours: 0,
      reorderLevel: 0,
      quantityType: 'pcs',
      quantityValue: 0.0,
      toleranceType: 'g',
      tolerance: 0.0,
      isToleranceActive: false,
      deliveryShift: 'any',
      minOrderQty: null,
      maxOrderQty: null,
      stepQty: null,
      unitLabelEn: null,
      unitLabelBn: null,
      purchaseOptions: const [],
      attributeValues: _asStringMap(rawAttributeValues),
      sortOrder: 0,
      isDefault: false,
      isEnabled: true,
      isFeatured: false,
      isFlashSale: false,
      isNewArrival: false,
      isBestSeller: false,
      publishAt: null,
      unpublishAt: null,
      views: 0,
      totalSold: 0,
      addToCartCount: 0,
      cardLayoutType: null,
      cardConfig: null,
      cardDesignJson: null,
      status: 'active',
      taxClassId: null,
      vatRate: null,
      isTaxIncluded: false,
      weightValue: null,
      weightUnit: null,
      length: null,
      width: null,
      height: null,
      dimensionUnit: null,
      shippingClassId: null,
      adminNote: null,
      metadata: const {},
      isDeleted: false,
      deletedAt: null,
      deletedBy: null,
      deleteReason: null,
      createdBy: null,
      updatedBy: null,
      createdAt: null,
      updatedAt: null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductVariation.fromJson(String source) =>
      MBProductVariation.fromMap(json.decode(source) as Map<dynamic, dynamic>);
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final parsed = value.toString().trim();
  return parsed.isEmpty ? fallback : parsed;
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

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
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

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final parsed = value.toString().trim();
  return parsed.isEmpty ? null : parsed;
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

MBCardInstanceConfig? _parseNullableCardConfig(
  dynamic rawConfig, {
  required dynamic fallbackLayoutType,
}) {
  if (rawConfig is Map) {
    return MBCardInstanceConfig.fromMap(
      Map<String, dynamic>.from(rawConfig),
    ).normalized();
  }

  final normalizedFallback = _normalizeCardLayoutType(fallbackLayoutType);
  if (normalizedFallback == null) return null;
  return _cardConfigFromLayoutType(normalizedFallback);
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

String? _normalizeCardLayoutType(dynamic value) {
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  if (normalized.isEmpty) return null;

  for (final variant in MBCardVariant.values) {
    if (variant.id.toLowerCase() == normalized) {
      return variant.id;
    }
  }

  return null;
}

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
    // Invalid JSON still means this variation is using the advanced design slot.
  }

  return 'advanced_v3';
}

Map<String, dynamic> _asDynamicMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};

  return value.map(
    (key, item) => MapEntry(key.toString(), item),
  );
}

Map<String, String> _asStringMap(dynamic value) {
  if (value is Map) {
    return value.map(
          (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
    );
  }
  return const {};
}
