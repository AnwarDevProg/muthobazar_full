// File: mb_advanced_binding_registry.dart
//
// MuthoBazar Advanced Studio Binding Registry
// -------------------------------------------
// Patch 12.6: Full model binding registry + runtime preview context alignment.
//
// Purpose:
// - Keep every Studio V3 binding path in one discoverable registry.
// - Group bindings by source model: product, brand, category, variation,
//   purchase option, product attribute, attribute value, attribute preset,
//   static/action/timer/card.
// - Give the drawer, preview resolver, runtime renderer, and future inspectors
//   a shared list of supported bindings.
// - Keep saved V3 JSON clean: nodes store binding keys, not resolved values.

class MBAdvancedBindingGroupId {
  const MBAdvancedBindingGroupId._();

  static const String card = 'card';
  static const String product = 'product';
  static const String brand = 'brand';
  static const String category = 'category';
  static const String variation = 'variation';
  static const String purchaseOption = 'purchaseOption';
  static const String productAttribute = 'productAttribute';
  static const String attributeValue = 'attributeValue';
  static const String attributePreset = 'attributePreset';
  static const String staticValue = 'static';
  static const String action = 'action';
  static const String timer = 'timer';
}

class MBAdvancedBindingValueType {
  const MBAdvancedBindingValueType._();

  static const String text = 'text';
  static const String number = 'number';
  static const String currency = 'currency';
  static const String imageUrl = 'imageUrl';
  static const String color = 'color';
  static const String bool = 'bool';
  static const String action = 'action';
}

class MBAdvancedBindingKey {
  const MBAdvancedBindingKey._();

  static const String cardSurface = 'card.surface';

  static const String productId = 'product.id';
  static const String productSlug = 'product.slug';
  static const String productTitleEn = 'product.titleEn';
  static const String productTitleBn = 'product.titleBn';
  static const String productNameEn = 'product.nameEn';
  static const String productNameBn = 'product.nameBn';
  static const String productSku = 'product.sku';
  static const String productType = 'product.productType';
  static const String productShortDescriptionEn = 'product.shortDescriptionEn';
  static const String productShortDescriptionBn = 'product.shortDescriptionBn';
  static const String productDescriptionEn = 'product.descriptionEn';
  static const String productDescriptionBn = 'product.descriptionBn';
  static const String productThumbnailUrl = 'product.thumbnailUrl';
  static const String productImageUrl = 'product.imageUrl';
  static const String productFirstImageUrl = 'product.imageUrls.first';
  static const String productFinalPrice = 'product.finalPrice';
  static const String productSalePrice = 'product.salePrice';
  static const String productPrice = 'product.price';
  static const String productOriginalPrice = 'product.originalPrice';
  static const String productMrp = 'product.mrp';
  static const String productCostPrice = 'product.costPrice';
  static const String productDiscountPercent = 'product.discountPercent';
  static const String productBrandName = 'product.brandName';
  static const String productBrandNameEn = 'product.brandNameEn';
  static const String productBrandNameBn = 'product.brandNameBn';
  static const String productCategoryName = 'product.categoryName';
  static const String productCategoryNameEn = 'product.categoryNameEn';
  static const String productCategoryNameBn = 'product.categoryNameBn';
  static const String productUnitLabelEn = 'product.unitLabelEn';
  static const String productUnitLabelBn = 'product.unitLabelBn';
  static const String productQuantityValue = 'product.quantityValue';
  static const String productQuantityType = 'product.quantityType';
  static const String productStockQty = 'product.stockQty';
  static const String productStockText = 'product.stockText';
  static const String productDeliveryHint = 'product.deliveryHint';
  static const String productRating = 'product.rating';
  static const String productReviewCount = 'product.reviewCount';
  static const String productIsFeatured = 'product.isFeatured';
  static const String productIsFlashSale = 'product.isFlashSale';
  static const String productIsNewArrival = 'product.isNewArrival';
  static const String productIsBestSeller = 'product.isBestSeller';

  static const String brandNameEn = 'brand.nameEn';
  static const String brandNameBn = 'brand.nameBn';
  static const String brandLogoUrl = 'brand.logoUrl';
  static const String brandSlug = 'brand.slug';

  static const String categoryNameEn = 'category.nameEn';
  static const String categoryNameBn = 'category.nameBn';
  static const String categoryImageUrl = 'category.imageUrl';
  static const String categoryIconUrl = 'category.iconUrl';
  static const String categorySlug = 'category.slug';

  static const String variationTitleEn = 'variation.titleEn';
  static const String variationTitleBn = 'variation.titleBn';
  static const String variationNameEn = 'variation.nameEn';
  static const String variationNameBn = 'variation.nameBn';
  static const String variationSku = 'variation.sku';
  static const String variationThumbnailUrl = 'variation.thumbnailUrl';
  static const String variationFirstImageUrl = 'variation.imageUrls.first';
  static const String variationFinalPrice = 'variation.finalPrice';
  static const String variationSalePrice = 'variation.salePrice';
  static const String variationPrice = 'variation.price';
  static const String variationCostPrice = 'variation.costPrice';
  static const String variationStockQty = 'variation.stockQty';
  static const String variationUnitLabelEn = 'variation.unitLabelEn';
  static const String variationUnitLabelBn = 'variation.unitLabelBn';
  static const String variationQuantityValue = 'variation.quantityValue';
  static const String variationQuantityType = 'variation.quantityType';
  static const String variationAttributeSummary = 'variation.attributeSummary';

  static const String purchaseOptionLabelEn = 'purchaseOption.labelEn';
  static const String purchaseOptionLabelBn = 'purchaseOption.labelBn';
  static const String purchaseOptionFinalPrice = 'purchaseOption.finalPrice';
  static const String purchaseOptionSalePrice = 'purchaseOption.salePrice';
  static const String purchaseOptionPrice = 'purchaseOption.price';
  static const String purchaseOptionQuantityValue = 'purchaseOption.quantityValue';
  static const String purchaseOptionUnitLabelEn = 'purchaseOption.unitLabelEn';
  static const String purchaseOptionUnitLabelBn = 'purchaseOption.unitLabelBn';
  static const String purchaseOptionPackText = 'purchaseOption.packText';

  static const String productAttributeNameEn = 'productAttribute.nameEn';
  static const String productAttributeNameBn = 'productAttribute.nameBn';
  static const String productAttributeDisplayName = 'productAttribute.displayName';

  static const String attributeValueTextEn = 'attributeValue.valueEn';
  static const String attributeValueTextBn = 'attributeValue.valueBn';
  static const String attributeValueColorHex = 'attributeValue.colorHex';
  static const String attributeValueImageUrl = 'attributeValue.imageUrl';

  static const String attributePresetNameEn = 'attributePreset.nameEn';
  static const String attributePresetNameBn = 'attributePreset.nameBn';
  static const String attributePresetValueEn = 'attributePreset.valueEn';
  static const String attributePresetValueBn = 'attributePreset.valueBn';
  static const String attributePresetColorHex = 'attributePreset.colorHex';
  static const String attributePresetImageUrl = 'attributePreset.imageUrl';

  static const String staticDiscount = 'static.discount';
  static const String staticSaving = 'static.saving';
  static const String staticDelivery = 'static.delivery';
  static const String staticStock = 'static.stock';
  static const String staticRating = 'static.rating';
  static const String staticBadge = 'static.badge';
  static const String staticFlash = 'static.flash';
  static const String staticNew = 'static.new';
  static const String staticPremium = 'static.premium';
  static const String staticFeature = 'static.feature';
  static const String staticPromo = 'static.promo';
  static const String staticPanel = 'static.panel';
  static const String staticShape = 'static.shape';
  static const String staticDivider = 'static.divider';
  static const String staticBorder = 'static.border';
  static const String staticEffect = 'static.effect';
  static const String staticShadow = 'static.shadow';
  static const String staticAnimation = 'static.animation';
  static const String staticProgress = 'static.progress';
  static const String staticDots = 'static.dots';
  static const String timerCountdown = 'timer.countdown';

  static const String actionBuy = 'action.buy';
  static const String actionAdd = 'action.add';
  static const String actionDetails = 'action.details';
  static const String actionWishlist = 'action.wishlist';
  static const String actionCompare = 'action.compare';
  static const String actionShare = 'action.share';
}

class MBAdvancedBindingDefinition {
  const MBAdvancedBindingDefinition({
    required this.key,
    required this.groupId,
    required this.label,
    required this.valueType,
    this.description = '',
    this.fallback = '',
  });

  final String key;
  final String groupId;
  final String label;
  final String valueType;
  final String description;
  final String fallback;
}

class MBAdvancedBindingRegistry {
  const MBAdvancedBindingRegistry._();

  static const List<MBAdvancedBindingDefinition> definitions =
      <MBAdvancedBindingDefinition>[
    MBAdvancedBindingDefinition(
      key: MBAdvancedBindingKey.cardSurface,
      groupId: MBAdvancedBindingGroupId.card,
      label: 'Card surface',
      valueType: MBAdvancedBindingValueType.text,
      fallback: 'Card',
    ),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productTitleEn, groupId: MBAdvancedBindingGroupId.product, label: 'Product title EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Product title'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productTitleBn, groupId: MBAdvancedBindingGroupId.product, label: 'Product title BN', valueType: MBAdvancedBindingValueType.text, fallback: 'পণ্য'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productShortDescriptionEn, groupId: MBAdvancedBindingGroupId.product, label: 'Short description EN', valueType: MBAdvancedBindingValueType.text),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productShortDescriptionBn, groupId: MBAdvancedBindingGroupId.product, label: 'Short description BN', valueType: MBAdvancedBindingValueType.text),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productThumbnailUrl, groupId: MBAdvancedBindingGroupId.product, label: 'Thumbnail URL', valueType: MBAdvancedBindingValueType.imageUrl),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productFirstImageUrl, groupId: MBAdvancedBindingGroupId.product, label: 'First image URL', valueType: MBAdvancedBindingValueType.imageUrl),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productFinalPrice, groupId: MBAdvancedBindingGroupId.product, label: 'Final price', valueType: MBAdvancedBindingValueType.currency, fallback: '৳0'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productSalePrice, groupId: MBAdvancedBindingGroupId.product, label: 'Sale price', valueType: MBAdvancedBindingValueType.currency, fallback: '৳0'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productPrice, groupId: MBAdvancedBindingGroupId.product, label: 'Price/MRP', valueType: MBAdvancedBindingValueType.currency, fallback: '৳0'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productCostPrice, groupId: MBAdvancedBindingGroupId.product, label: 'Cost price', valueType: MBAdvancedBindingValueType.currency, fallback: '৳0'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productBrandNameEn, groupId: MBAdvancedBindingGroupId.product, label: 'Product brand EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Brand'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productBrandNameBn, groupId: MBAdvancedBindingGroupId.product, label: 'Product brand BN', valueType: MBAdvancedBindingValueType.text, fallback: 'Brand'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productCategoryNameEn, groupId: MBAdvancedBindingGroupId.product, label: 'Product category EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Category'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productCategoryNameBn, groupId: MBAdvancedBindingGroupId.product, label: 'Product category BN', valueType: MBAdvancedBindingValueType.text, fallback: 'Category'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productUnitLabelEn, groupId: MBAdvancedBindingGroupId.product, label: 'Unit EN', valueType: MBAdvancedBindingValueType.text, fallback: 'pcs'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productUnitLabelBn, groupId: MBAdvancedBindingGroupId.product, label: 'Unit BN', valueType: MBAdvancedBindingValueType.text, fallback: 'pcs'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productQuantityValue, groupId: MBAdvancedBindingGroupId.product, label: 'Quantity value', valueType: MBAdvancedBindingValueType.text, fallback: '1'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productQuantityType, groupId: MBAdvancedBindingGroupId.product, label: 'Quantity type', valueType: MBAdvancedBindingValueType.text, fallback: 'pcs'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productStockQty, groupId: MBAdvancedBindingGroupId.product, label: 'Stock quantity', valueType: MBAdvancedBindingValueType.number),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productStockText, groupId: MBAdvancedBindingGroupId.product, label: 'Stock text', valueType: MBAdvancedBindingValueType.text, fallback: 'In stock'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productDeliveryHint, groupId: MBAdvancedBindingGroupId.product, label: 'Delivery hint', valueType: MBAdvancedBindingValueType.text, fallback: 'Fast delivery'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productRating, groupId: MBAdvancedBindingGroupId.product, label: 'Rating', valueType: MBAdvancedBindingValueType.text, fallback: '★ 4.8'),

    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.brandNameEn, groupId: MBAdvancedBindingGroupId.brand, label: 'Brand name EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Brand'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.brandNameBn, groupId: MBAdvancedBindingGroupId.brand, label: 'Brand name BN', valueType: MBAdvancedBindingValueType.text, fallback: 'Brand'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.brandLogoUrl, groupId: MBAdvancedBindingGroupId.brand, label: 'Brand logo URL', valueType: MBAdvancedBindingValueType.imageUrl),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.categoryNameEn, groupId: MBAdvancedBindingGroupId.category, label: 'Category name EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Category'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.categoryNameBn, groupId: MBAdvancedBindingGroupId.category, label: 'Category name BN', valueType: MBAdvancedBindingValueType.text, fallback: 'Category'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.categoryImageUrl, groupId: MBAdvancedBindingGroupId.category, label: 'Category image URL', valueType: MBAdvancedBindingValueType.imageUrl),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.categoryIconUrl, groupId: MBAdvancedBindingGroupId.category, label: 'Category icon URL', valueType: MBAdvancedBindingValueType.imageUrl),

    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.variationTitleEn, groupId: MBAdvancedBindingGroupId.variation, label: 'Variation title EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Variation'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.variationTitleBn, groupId: MBAdvancedBindingGroupId.variation, label: 'Variation title BN', valueType: MBAdvancedBindingValueType.text, fallback: 'Variation'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.variationSku, groupId: MBAdvancedBindingGroupId.variation, label: 'Variation SKU', valueType: MBAdvancedBindingValueType.text),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.variationThumbnailUrl, groupId: MBAdvancedBindingGroupId.variation, label: 'Variation thumbnail URL', valueType: MBAdvancedBindingValueType.imageUrl),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.variationFinalPrice, groupId: MBAdvancedBindingGroupId.variation, label: 'Variation final price', valueType: MBAdvancedBindingValueType.currency, fallback: '৳0'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.variationPrice, groupId: MBAdvancedBindingGroupId.variation, label: 'Variation price', valueType: MBAdvancedBindingValueType.currency, fallback: '৳0'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.variationStockQty, groupId: MBAdvancedBindingGroupId.variation, label: 'Variation stock quantity', valueType: MBAdvancedBindingValueType.number),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.variationAttributeSummary, groupId: MBAdvancedBindingGroupId.variation, label: 'Variation attributes', valueType: MBAdvancedBindingValueType.text),

    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.purchaseOptionLabelEn, groupId: MBAdvancedBindingGroupId.purchaseOption, label: 'Purchase option label EN', valueType: MBAdvancedBindingValueType.text, fallback: '1 pcs'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.purchaseOptionLabelBn, groupId: MBAdvancedBindingGroupId.purchaseOption, label: 'Purchase option label BN', valueType: MBAdvancedBindingValueType.text, fallback: '১ পিস'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.purchaseOptionFinalPrice, groupId: MBAdvancedBindingGroupId.purchaseOption, label: 'Purchase option final price', valueType: MBAdvancedBindingValueType.currency, fallback: '৳0'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.purchaseOptionPrice, groupId: MBAdvancedBindingGroupId.purchaseOption, label: 'Purchase option price', valueType: MBAdvancedBindingValueType.currency, fallback: '৳0'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.purchaseOptionPackText, groupId: MBAdvancedBindingGroupId.purchaseOption, label: 'Purchase option pack text', valueType: MBAdvancedBindingValueType.text, fallback: 'Pack'),

    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productAttributeNameEn, groupId: MBAdvancedBindingGroupId.productAttribute, label: 'Attribute name EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Attribute'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productAttributeNameBn, groupId: MBAdvancedBindingGroupId.productAttribute, label: 'Attribute name BN', valueType: MBAdvancedBindingValueType.text, fallback: 'Attribute'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.productAttributeDisplayName, groupId: MBAdvancedBindingGroupId.productAttribute, label: 'Attribute display name', valueType: MBAdvancedBindingValueType.text, fallback: 'Attribute'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.attributeValueTextEn, groupId: MBAdvancedBindingGroupId.attributeValue, label: 'Attribute value EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Value'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.attributeValueTextBn, groupId: MBAdvancedBindingGroupId.attributeValue, label: 'Attribute value BN', valueType: MBAdvancedBindingValueType.text, fallback: 'Value'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.attributeValueColorHex, groupId: MBAdvancedBindingGroupId.attributeValue, label: 'Attribute color hex', valueType: MBAdvancedBindingValueType.color, fallback: '#FF6500'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.attributeValueImageUrl, groupId: MBAdvancedBindingGroupId.attributeValue, label: 'Attribute value image URL', valueType: MBAdvancedBindingValueType.imageUrl),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.attributePresetNameEn, groupId: MBAdvancedBindingGroupId.attributePreset, label: 'Preset name EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Preset'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.attributePresetValueEn, groupId: MBAdvancedBindingGroupId.attributePreset, label: 'Preset value EN', valueType: MBAdvancedBindingValueType.text, fallback: 'Value'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.attributePresetColorHex, groupId: MBAdvancedBindingGroupId.attributePreset, label: 'Preset color hex', valueType: MBAdvancedBindingValueType.color, fallback: '#FF6500'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.attributePresetImageUrl, groupId: MBAdvancedBindingGroupId.attributePreset, label: 'Preset image URL', valueType: MBAdvancedBindingValueType.imageUrl),

    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.staticDiscount, groupId: MBAdvancedBindingGroupId.staticValue, label: 'Auto discount', valueType: MBAdvancedBindingValueType.text, fallback: 'Save'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.staticSaving, groupId: MBAdvancedBindingGroupId.staticValue, label: 'Saving text', valueType: MBAdvancedBindingValueType.text, fallback: 'Save more'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.staticDelivery, groupId: MBAdvancedBindingGroupId.staticValue, label: 'Delivery text', valueType: MBAdvancedBindingValueType.text, fallback: 'Fast delivery'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.staticRating, groupId: MBAdvancedBindingGroupId.staticValue, label: 'Rating text', valueType: MBAdvancedBindingValueType.text, fallback: '★ 4.8'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.staticFlash, groupId: MBAdvancedBindingGroupId.staticValue, label: 'Flash label', valueType: MBAdvancedBindingValueType.text, fallback: 'Flash'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.staticNew, groupId: MBAdvancedBindingGroupId.staticValue, label: 'New label', valueType: MBAdvancedBindingValueType.text, fallback: 'New'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.staticPremium, groupId: MBAdvancedBindingGroupId.staticValue, label: 'Premium label', valueType: MBAdvancedBindingValueType.text, fallback: 'Premium'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.timerCountdown, groupId: MBAdvancedBindingGroupId.timer, label: 'Countdown timer', valueType: MBAdvancedBindingValueType.text, fallback: '02:15:08'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.actionBuy, groupId: MBAdvancedBindingGroupId.action, label: 'Buy action', valueType: MBAdvancedBindingValueType.action, fallback: 'Buy'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.actionAdd, groupId: MBAdvancedBindingGroupId.action, label: 'Add action', valueType: MBAdvancedBindingValueType.action, fallback: 'Add'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.actionDetails, groupId: MBAdvancedBindingGroupId.action, label: 'Details action', valueType: MBAdvancedBindingValueType.action, fallback: 'View'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.actionWishlist, groupId: MBAdvancedBindingGroupId.action, label: 'Wishlist action', valueType: MBAdvancedBindingValueType.action, fallback: '♡'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.actionCompare, groupId: MBAdvancedBindingGroupId.action, label: 'Compare action', valueType: MBAdvancedBindingValueType.action, fallback: '⇄'),
    MBAdvancedBindingDefinition(key: MBAdvancedBindingKey.actionShare, groupId: MBAdvancedBindingGroupId.action, label: 'Share action', valueType: MBAdvancedBindingValueType.action, fallback: '↗'),
  ];

  static MBAdvancedBindingDefinition? find(String key) {
    final normalized = key.trim();
    for (final definition in definitions) {
      if (definition.key == normalized) return definition;
    }
    return null;
  }

  static bool contains(String key) => find(key) != null;

  static List<MBAdvancedBindingDefinition> byGroup(String groupId) {
    return definitions
        .where((definition) => definition.groupId == groupId)
        .toList(growable: false);
  }

  static String fallbackFor(String key, {String fallback = ''}) {
    return find(key)?.fallback ?? fallback;
  }

  static bool isCurrencyBinding(String key) {
    return find(key)?.valueType == MBAdvancedBindingValueType.currency ||
        key.toLowerCase().contains('price') ||
        key.toLowerCase().contains('mrp') ||
        key.toLowerCase().contains('cost');
  }

  static bool isImageBinding(String key) {
    return find(key)?.valueType == MBAdvancedBindingValueType.imageUrl ||
        key.toLowerCase().contains('imageurl') ||
        key.toLowerCase().contains('thumbnail') ||
        key.toLowerCase().contains('logourl') ||
        key.toLowerCase().contains('iconurl');
  }
}
