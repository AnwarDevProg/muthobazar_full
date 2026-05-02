// File: mb_advanced_binding_resolver.dart
//
// MuthoBazar Advanced Product Card Design Studio
// Patch 12.7.3 binding resolver.
//
// Purpose:
// - Resolve saved V3 binding keys from a shared preview/runtime context.
// - Keep saved V3 JSON clean: only binding paths are saved, not resolved values.
// - Support MBProduct, MBBrand, MBCategory, MBProductVariation,
//   MBProductPurchaseOption, MBProductAttribute, MBProductAttributeValue,
//   and MBAttributePreset style objects.
// - Work with real model objects and temporary Map-based product-dialog state.
// - Patch 12.7.3 adds variation image fallback and dynamic variation-attribute bindings.

import 'dart:math' as math;

import 'mb_advanced_binding_registry.dart';

class MBAdvancedPreviewContext {
  const MBAdvancedPreviewContext({
    required this.product,
    this.brand,
    this.category,
    this.selectedVariation,
    this.selectedPurchaseOption,
    this.selectedProductAttribute,
    this.selectedAttributeValue,
    this.selectedAttributePreset,
    this.fallbackTitle = 'Product title',
    this.fallbackSubtitle = 'Fresh product detail',
  });

  final dynamic product;
  final dynamic brand;
  final dynamic category;
  final dynamic selectedVariation;
  final dynamic selectedPurchaseOption;
  final dynamic selectedProductAttribute;
  final dynamic selectedAttributeValue;
  final dynamic selectedAttributePreset;
  final String fallbackTitle;
  final String fallbackSubtitle;

  factory MBAdvancedPreviewContext.fromProduct({
    required dynamic product,
    dynamic brand,
    dynamic category,
    dynamic selectedVariation,
    dynamic selectedPurchaseOption,
    dynamic selectedProductAttribute,
    dynamic selectedAttributeValue,
    dynamic selectedAttributePreset,
    String fallbackTitle = 'Product title',
    String fallbackSubtitle = 'Fresh product detail',
  }) {
    return MBAdvancedPreviewContext(
      product: product,
      brand: brand,
      category: category,
      selectedVariation: selectedVariation,
      selectedPurchaseOption: selectedPurchaseOption,
      selectedProductAttribute: selectedProductAttribute,
      selectedAttributeValue: selectedAttributeValue,
      selectedAttributePreset: selectedAttributePreset,
      fallbackTitle: fallbackTitle,
      fallbackSubtitle: fallbackSubtitle,
    );
  }
}

class MBAdvancedBindingResolver {
  const MBAdvancedBindingResolver._();

  static String resolveText(
    MBAdvancedPreviewContext context,
    String binding, {
    String fallback = '',
  }) {
    final normalized = binding.trim();
    if (normalized.isEmpty) return fallback;

    final registryFallback = MBAdvancedBindingRegistry.fallbackFor(
      normalized,
      fallback: fallback,
    );

    if (MBAdvancedBindingRegistry.isCurrencyBinding(normalized)) {
      final number = resolveNumber(context, normalized);
      if (number != null) return formatCurrency(number);
      return registryFallback;
    }

    if (normalized.startsWith('variation.attribute.')) {
      final attributeKey = normalized.substring('variation.attribute.'.length).trim();
      return _variationAttributeValue(
        context.selectedVariation,
        attributeKey,
        fallback: registryFallback,
      );
    }

    switch (normalized) {
      case MBAdvancedBindingKey.cardSurface:
        return 'Card';

      case MBAdvancedBindingKey.productId:
        return _readAny(context.product, const <String>['id', 'productId'], registryFallback);
      case MBAdvancedBindingKey.productSlug:
        return _readAny(context.product, const <String>['slug'], registryFallback);
      case MBAdvancedBindingKey.productTitleEn:
      case MBAdvancedBindingKey.productNameEn:
        return _readAny(context.product, const <String>['titleEn', 'nameEn', 'name'], context.fallbackTitle);
      case MBAdvancedBindingKey.productTitleBn:
      case MBAdvancedBindingKey.productNameBn:
        return _readAny(context.product, const <String>['titleBn', 'nameBn'], context.fallbackTitle);
      case MBAdvancedBindingKey.productSku:
        return _readAny(context.product, const <String>['sku', 'productSku'], registryFallback);
      case MBAdvancedBindingKey.productType:
        return _readAny(context.product, const <String>['productType', 'type'], registryFallback);
      case MBAdvancedBindingKey.productShortDescriptionEn:
        return _readAny(context.product, const <String>['shortDescriptionEn'], context.fallbackSubtitle);
      case MBAdvancedBindingKey.productShortDescriptionBn:
        return _readAny(context.product, const <String>['shortDescriptionBn'], context.fallbackSubtitle);
      case MBAdvancedBindingKey.productDescriptionEn:
        return _readAny(context.product, const <String>['descriptionEn'], context.fallbackSubtitle);
      case MBAdvancedBindingKey.productDescriptionBn:
        return _readAny(context.product, const <String>['descriptionBn'], context.fallbackSubtitle);
      case MBAdvancedBindingKey.productThumbnailUrl:
      case MBAdvancedBindingKey.productImageUrl:
      case MBAdvancedBindingKey.productFirstImageUrl:
        return resolveImageUrl(context, normalized, fallback: registryFallback);
      case MBAdvancedBindingKey.productDiscountPercent:
      case MBAdvancedBindingKey.staticDiscount:
        return _discountLabel(context);
      case MBAdvancedBindingKey.productBrandNameEn:
      case MBAdvancedBindingKey.productBrandName:
      case 'product.brand':
        return _readAny(context.product, const <String>['brandNameEn', 'brandName'], 'Brand');
      case MBAdvancedBindingKey.productBrandNameBn:
        return _readAny(context.product, const <String>['brandNameBn'], 'Brand');
      case MBAdvancedBindingKey.productCategoryNameEn:
      case MBAdvancedBindingKey.productCategoryName:
      case 'product.category':
        return _readAny(context.product, const <String>['categoryNameEn', 'categoryName'], 'Category');
      case MBAdvancedBindingKey.productCategoryNameBn:
        return _readAny(context.product, const <String>['categoryNameBn'], 'Category');
      case MBAdvancedBindingKey.productUnitLabelEn:
        return _readAny(context.product, const <String>['unitLabelEn'], 'pcs');
      case MBAdvancedBindingKey.productUnitLabelBn:
        return _readAny(context.product, const <String>['unitLabelBn'], 'pcs');
      case MBAdvancedBindingKey.productQuantityValue:
        return _readAny(context.product, const <String>['quantityValue'], '1');
      case MBAdvancedBindingKey.productQuantityType:
        return _readAny(context.product, const <String>['quantityType'], 'pcs');
      case MBAdvancedBindingKey.productStockQty:
        return '${resolveNumber(context, normalized)?.round() ?? 0} left';
      case MBAdvancedBindingKey.productStockText:
      case MBAdvancedBindingKey.staticStock:
        return _stockLabel(context);
      case MBAdvancedBindingKey.productDeliveryHint:
      case MBAdvancedBindingKey.staticDelivery:
        return _readAny(context.product, const <String>['deliveryHint'], 'Fast delivery');
      case MBAdvancedBindingKey.productRating:
      case MBAdvancedBindingKey.staticRating:
        final rating = _readAny(context.product, const <String>['rating'], '');
        return rating.isEmpty ? '★ 4.8' : '★ $rating';
      case MBAdvancedBindingKey.productReviewCount:
        return _readAny(context.product, const <String>['reviewCount'], registryFallback);
      case MBAdvancedBindingKey.productIsFeatured:
        return resolveBool(context, normalized) ? 'Featured' : registryFallback;
      case MBAdvancedBindingKey.productIsFlashSale:
        return resolveBool(context, normalized) ? 'Flash sale' : registryFallback;
      case MBAdvancedBindingKey.productIsNewArrival:
        return resolveBool(context, normalized) ? 'New arrival' : registryFallback;
      case MBAdvancedBindingKey.productIsBestSeller:
        return resolveBool(context, normalized) ? 'Best seller' : registryFallback;

      case MBAdvancedBindingKey.brandNameEn:
        return _readAny(context.brand, const <String>['nameEn', 'brandNameEn', 'name'],
            _readAny(context.product, const <String>['brandNameEn', 'brandName'], 'Brand'));
      case MBAdvancedBindingKey.brandNameBn:
        return _readAny(context.brand, const <String>['nameBn', 'brandNameBn'],
            _readAny(context.product, const <String>['brandNameBn'], 'Brand'));
      case MBAdvancedBindingKey.brandLogoUrl:
        return resolveImageUrl(context, normalized, fallback: registryFallback);
      case MBAdvancedBindingKey.brandSlug:
        return _readAny(context.brand, const <String>['slug'], registryFallback);

      case MBAdvancedBindingKey.categoryNameEn:
        return _readAny(context.category, const <String>['nameEn', 'categoryNameEn', 'name'],
            _readAny(context.product, const <String>['categoryNameEn', 'categoryName'], 'Category'));
      case MBAdvancedBindingKey.categoryNameBn:
        return _readAny(context.category, const <String>['nameBn', 'categoryNameBn'],
            _readAny(context.product, const <String>['categoryNameBn'], 'Category'));
      case MBAdvancedBindingKey.categoryImageUrl:
      case MBAdvancedBindingKey.categoryIconUrl:
        return resolveImageUrl(context, normalized, fallback: registryFallback);
      case MBAdvancedBindingKey.categorySlug:
        return _readAny(context.category, const <String>['slug'], registryFallback);

      case MBAdvancedBindingKey.variationTitleEn:
      case MBAdvancedBindingKey.variationNameEn:
        return _readAny(context.selectedVariation, const <String>['titleEn', 'nameEn', 'name'], 'Variation');
      case MBAdvancedBindingKey.variationTitleBn:
      case MBAdvancedBindingKey.variationNameBn:
        return _readAny(context.selectedVariation, const <String>['titleBn', 'nameBn'], 'Variation');
      case MBAdvancedBindingKey.variationSku:
        return _readAny(context.selectedVariation, const <String>['sku', 'variationSku'], registryFallback);
      case MBAdvancedBindingKey.variationThumbnailUrl:
      case MBAdvancedBindingKey.variationFirstImageUrl:
        return resolveImageUrl(context, normalized, fallback: registryFallback);
      case MBAdvancedBindingKey.variationStockQty:
        return '${resolveNumber(context, normalized)?.round() ?? 0} left';
      case MBAdvancedBindingKey.variationUnitLabelEn:
        return _readAny(context.selectedVariation, const <String>['unitLabelEn'], 'pcs');
      case MBAdvancedBindingKey.variationUnitLabelBn:
        return _readAny(context.selectedVariation, const <String>['unitLabelBn'], 'pcs');
      case MBAdvancedBindingKey.variationQuantityValue:
        return _readAny(context.selectedVariation, const <String>['quantityValue'], '1');
      case MBAdvancedBindingKey.variationQuantityType:
        return _readAny(context.selectedVariation, const <String>['quantityType'], 'pcs');
      case MBAdvancedBindingKey.variationAttributeSummary:
        return _variationAttributeSummary(context.selectedVariation, fallback: registryFallback);

      case MBAdvancedBindingKey.purchaseOptionLabelEn:
        return _readAny(context.selectedPurchaseOption, const <String>['labelEn', 'nameEn', 'titleEn'], '1 pcs');
      case MBAdvancedBindingKey.purchaseOptionLabelBn:
        return _readAny(context.selectedPurchaseOption, const <String>['labelBn', 'nameBn', 'titleBn'], '১ পিস');
      case MBAdvancedBindingKey.purchaseOptionQuantityValue:
        return _readAny(context.selectedPurchaseOption, const <String>['quantityValue'], '1');
      case MBAdvancedBindingKey.purchaseOptionUnitLabelEn:
        return _readAny(context.selectedPurchaseOption, const <String>['unitLabelEn'], 'pcs');
      case MBAdvancedBindingKey.purchaseOptionUnitLabelBn:
        return _readAny(context.selectedPurchaseOption, const <String>['unitLabelBn'], 'pcs');
      case MBAdvancedBindingKey.purchaseOptionPackText:
        return _purchaseOptionPackText(context.selectedPurchaseOption, fallback: 'Pack');

      case MBAdvancedBindingKey.productAttributeNameEn:
        return _readAny(context.selectedProductAttribute, const <String>['nameEn', 'titleEn', 'labelEn'], 'Attribute');
      case MBAdvancedBindingKey.productAttributeNameBn:
        return _readAny(context.selectedProductAttribute, const <String>['nameBn', 'titleBn', 'labelBn'], 'Attribute');
      case MBAdvancedBindingKey.productAttributeDisplayName:
        return _readAny(context.selectedProductAttribute, const <String>['displayName', 'nameEn', 'titleEn'], 'Attribute');

      case MBAdvancedBindingKey.attributeValueTextEn:
        return _readAny(context.selectedAttributeValue, const <String>['valueEn', 'nameEn', 'labelEn'], 'Value');
      case MBAdvancedBindingKey.attributeValueTextBn:
        return _readAny(context.selectedAttributeValue, const <String>['valueBn', 'nameBn', 'labelBn'], 'Value');
      case MBAdvancedBindingKey.attributeValueColorHex:
        return _readAny(context.selectedAttributeValue, const <String>['colorHex', 'hex'], '#FF6500');
      case MBAdvancedBindingKey.attributeValueImageUrl:
        return resolveImageUrl(context, normalized, fallback: registryFallback);

      case MBAdvancedBindingKey.attributePresetNameEn:
        return _readAny(context.selectedAttributePreset, const <String>['nameEn', 'titleEn'], 'Preset');
      case MBAdvancedBindingKey.attributePresetNameBn:
        return _readAny(context.selectedAttributePreset, const <String>['nameBn', 'titleBn'], 'Preset');
      case MBAdvancedBindingKey.attributePresetValueEn:
        return _readAny(context.selectedAttributePreset, const <String>['valueEn', 'labelEn'], 'Value');
      case MBAdvancedBindingKey.attributePresetValueBn:
        return _readAny(context.selectedAttributePreset, const <String>['valueBn', 'labelBn'], 'Value');
      case MBAdvancedBindingKey.attributePresetColorHex:
        return _readAny(context.selectedAttributePreset, const <String>['colorHex', 'hex'], '#FF6500');
      case MBAdvancedBindingKey.attributePresetImageUrl:
        return resolveImageUrl(context, normalized, fallback: registryFallback);

      case MBAdvancedBindingKey.staticSaving:
        return 'Save more';
      case MBAdvancedBindingKey.staticBadge:
        return 'HOT';
      case MBAdvancedBindingKey.staticFlash:
        return 'Flash';
      case MBAdvancedBindingKey.staticNew:
        return 'New';
      case MBAdvancedBindingKey.staticPremium:
        return 'Premium';
      case MBAdvancedBindingKey.staticFeature:
        return 'Farm fresh';
      case MBAdvancedBindingKey.staticPromo:
        return 'Promo';
      case MBAdvancedBindingKey.timerCountdown:
      case 'static.timer':
        return '02:15:08';
      case MBAdvancedBindingKey.actionBuy:
        return 'Buy';
      case MBAdvancedBindingKey.actionAdd:
        return 'Add';
      case MBAdvancedBindingKey.actionDetails:
        return 'View';
      case MBAdvancedBindingKey.actionWishlist:
        return '♡';
      case MBAdvancedBindingKey.actionCompare:
        return '⇄';
      case MBAdvancedBindingKey.actionShare:
        return '↗';
      default:
        if (normalized.startsWith('static.')) {
          final value = normalized.substring('static.'.length).replaceAll('_', ' ');
          return value.isEmpty ? registryFallback : _titleCase(value);
        }
        return registryFallback;
    }
  }

  static String resolveImageUrl(
    MBAdvancedPreviewContext context,
    String binding, {
    String fallback = '',
  }) {
    switch (binding.trim()) {
      case MBAdvancedBindingKey.productThumbnailUrl:
        return _readAny(context.product, const <String>['thumbnailUrl'], fallback);
      case MBAdvancedBindingKey.productImageUrl:
        return _readAny(context.product, const <String>['imageUrl'], fallback);
      case MBAdvancedBindingKey.productFirstImageUrl:
        return _readFirstImageUrl(context.product).isNotEmpty
            ? _readFirstImageUrl(context.product)
            : fallback;
      case MBAdvancedBindingKey.brandLogoUrl:
        return _readAny(context.brand, const <String>['logoUrl', 'imageUrl'], fallback);
      case MBAdvancedBindingKey.categoryImageUrl:
        return _readAny(context.category, const <String>['imageUrl'], fallback);
      case MBAdvancedBindingKey.categoryIconUrl:
        return _readAny(context.category, const <String>['iconUrl'], fallback);
      case MBAdvancedBindingKey.variationThumbnailUrl:
        return _resolveVariationImageUrl(context.selectedVariation, fallback: fallback);
      case MBAdvancedBindingKey.variationFirstImageUrl:
        final resolved = _resolveVariationImageUrl(context.selectedVariation, fallback: '');
        return resolved.isNotEmpty ? resolved : fallback;
      case MBAdvancedBindingKey.attributeValueImageUrl:
        return _readAny(context.selectedAttributeValue, const <String>['imageUrl', 'thumbnailUrl'], fallback);
      case MBAdvancedBindingKey.attributePresetImageUrl:
        return _readAny(context.selectedAttributePreset, const <String>['imageUrl', 'thumbnailUrl'], fallback);
      default:
        return fallback;
    }
  }

  static num? resolveNumber(
    MBAdvancedPreviewContext context,
    String binding,
  ) {
    switch (binding.trim()) {
      case MBAdvancedBindingKey.productFinalPrice:
        return _readFinalPrice(context.product);
      case MBAdvancedBindingKey.productSalePrice:
        return _readNumber(context.product, 'salePrice') ?? _readFinalPrice(context.product);
      case MBAdvancedBindingKey.productPrice:
      case MBAdvancedBindingKey.productOriginalPrice:
      case MBAdvancedBindingKey.productMrp:
        return _readNumber(context.product, 'price') ?? _readFinalPrice(context.product);
      case MBAdvancedBindingKey.productCostPrice:
        return _readNumber(context.product, 'costPrice') ?? 0;
      case MBAdvancedBindingKey.productStockQty:
        return _readNumber(context.product, 'stockQty') ?? 0;
      case MBAdvancedBindingKey.productReviewCount:
        return _readNumber(context.product, 'reviewCount') ?? 0;
      case MBAdvancedBindingKey.variationFinalPrice:
        return _readFinalPrice(context.selectedVariation) ?? _readFinalPrice(context.product);
      case MBAdvancedBindingKey.variationSalePrice:
        return _readNumber(context.selectedVariation, 'salePrice') ??
            _readFinalPrice(context.selectedVariation);
      case MBAdvancedBindingKey.variationPrice:
        return _readNumber(context.selectedVariation, 'price') ??
            _readFinalPrice(context.selectedVariation);
      case MBAdvancedBindingKey.variationCostPrice:
        return _readNumber(context.selectedVariation, 'costPrice') ?? 0;
      case MBAdvancedBindingKey.variationStockQty:
        return _readNumber(context.selectedVariation, 'stockQty') ?? 0;
      case MBAdvancedBindingKey.purchaseOptionFinalPrice:
        return _readFinalPrice(context.selectedPurchaseOption) ?? _readFinalPrice(context.product);
      case MBAdvancedBindingKey.purchaseOptionSalePrice:
        return _readNumber(context.selectedPurchaseOption, 'salePrice') ??
            _readFinalPrice(context.selectedPurchaseOption);
      case MBAdvancedBindingKey.purchaseOptionPrice:
        return _readNumber(context.selectedPurchaseOption, 'price') ??
            _readFinalPrice(context.selectedPurchaseOption);
      default:
        return null;
    }
  }

  static bool resolveBool(
    MBAdvancedPreviewContext context,
    String binding, {
    bool fallback = false,
  }) {
    switch (binding.trim()) {
      case MBAdvancedBindingKey.productIsFeatured:
        return _readBool(context.product, 'isFeatured', fallback: fallback);
      case MBAdvancedBindingKey.productIsFlashSale:
        return _readBool(context.product, 'isFlashSale', fallback: fallback);
      case MBAdvancedBindingKey.productIsNewArrival:
        return _readBool(context.product, 'isNewArrival', fallback: fallback);
      case MBAdvancedBindingKey.productIsBestSeller:
        return _readBool(context.product, 'isBestSeller', fallback: fallback);
      default:
        return fallback;
    }
  }

  static String formatCurrency(num value) {
    final cleanValue = value.isFinite ? value : 0;
    final number = cleanValue % 1 == 0 ? cleanValue.toInt().toString() : cleanValue.toStringAsFixed(1);
    return '৳$number';
  }

  static num? _readFinalPrice(dynamic source) {
    final sale = _readNumber(source, 'salePrice');
    if (sale != null && sale > 0) return sale;
    return _readNumber(source, 'price') ?? _readNumber(source, 'finalPrice') ?? 0;
  }

  static String _discountLabel(MBAdvancedPreviewContext context) {
    final original = _readNumber(context.product, 'price') ?? 0;
    final finalPrice = _readFinalPrice(context.product) ?? 0;

    if (original <= 0 || finalPrice <= 0 || finalPrice >= original) {
      return 'Save';
    }

    final percent = (((original - finalPrice) / math.max(1, original)) * 100).round();
    return '$percent% OFF';
  }

  static String _stockLabel(MBAdvancedPreviewContext context) {
    final variationStock = _readNumber(context.selectedVariation, 'stockQty');
    final productStock = _readNumber(context.product, 'stockQty');
    final stock = variationStock ?? productStock ?? 0;

    if (stock <= 0) return 'Limited stock';
    return 'In stock';
  }

  static String _variationAttributeSummary(dynamic variation, {required String fallback}) {
    final direct = _readAny(variation, const <String>[
      'attributeSummary',
      'attributesText',
      'variantText',
    ], '');
    if (direct.isNotEmpty) return direct;

    try {
      final raw = variation is Map ? variation['attributes'] : variation.attributes;
      if (raw is Map && raw.isNotEmpty) {
        return raw.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
      }
      if (raw is Iterable && raw.isNotEmpty) {
        return raw.map((item) => item.toString()).join(', ');
      }
    } catch (_) {}

    return fallback;
  }


  static String _variationAttributeValue(
    dynamic variation,
    String attributeKey, {
    required String fallback,
  }) {
    final normalizedKey = attributeKey.trim().toLowerCase();
    if (normalizedKey.isEmpty) return fallback;

    try {
      final raw = variation is Map ? variation['attributes'] : variation.attributes;
      if (raw is Map && raw.isNotEmpty) {
        for (final entry in raw.entries) {
          final key = entry.key?.toString().trim() ?? '';
          if (key.toLowerCase() == normalizedKey) {
            final value = entry.value?.toString().trim() ?? '';
            return value.isEmpty ? fallback : value;
          }
        }
      }
      if (raw is Iterable && raw.isNotEmpty) {
        for (final item in raw) {
          final name = _readAny(item, const <String>[
            'nameEn',
            'nameBn',
            'attributeName',
            'attributeKey',
            'key',
            'label',
            'title',
          ], '');
          if (name.trim().toLowerCase() != normalizedKey) continue;
          final value = _readAny(item, const <String>[
            'valueEn',
            'valueBn',
            'value',
            'labelEn',
            'labelBn',
            'label',
            'text',
            'displayName',
            'name',
          ], '');
          return value.isEmpty ? fallback : value;
        }
      }
    } catch (_) {}

    return fallback;
  }

  static String _resolveVariationImageUrl(
    dynamic variation, {
    required String fallback,
  }) {
    final direct = _readAny(
      variation,
      const <String>['thumbnailUrl', 'thumbUrl', 'imageUrl'],
      '',
    );
    if (direct.isNotEmpty) return direct;

    final firstImage = _readFirstImageUrl(variation);
    if (firstImage.isNotEmpty) return firstImage;

    try {
      final dynamic mediaItems = variation is Map
          ? variation['mediaItems']
          : variation.mediaItems;
      if (mediaItems is Iterable && mediaItems.isNotEmpty) {
        for (final item in mediaItems) {
          final thumb = _readAny(item, const <String>['thumbUrl', 'thumbnailUrl'], '');
          if (thumb.isNotEmpty) return thumb;
          final full = _readAny(item, const <String>['fullUrl', 'imageUrl', 'url'], '');
          if (full.isNotEmpty) return full;
        }
      }
    } catch (_) {}

    final productThumb = _readAny(variation, const <String>['productThumbnailUrl'], '');
    return productThumb.isNotEmpty ? productThumb : fallback;
  }

  static String _purchaseOptionPackText(dynamic option, {required String fallback}) {
    final direct = _readAny(option, const <String>['packText', 'labelEn', 'nameEn'], '');
    if (direct.isNotEmpty) return direct;

    final quantity = _readAny(option, const <String>['quantityValue'], '');
    final unit = _readAny(option, const <String>['unitLabelEn'], '');
    final combined = '$quantity $unit'.trim();

    return combined.isEmpty ? fallback : combined;
  }

  static String _readFirstImageUrl(dynamic source) {
    try {
      final map = source is Map ? source : null;
      final raw = map == null ? null : map['imageUrls'];
      if (raw is Iterable && raw.isNotEmpty) {
        final value = raw.first?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    } catch (_) {}

    try {
      final dynamic raw = source.imageUrls;
      if (raw is Iterable && raw.isNotEmpty) {
        final value = raw.first?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    } catch (_) {}

    try {
      final dynamic mediaItems = source is Map ? source['mediaItems'] : source.mediaItems;
      if (mediaItems is Iterable && mediaItems.isNotEmpty) {
        for (final item in mediaItems) {
          final thumb = _readAny(item, const <String>['thumbUrl', 'thumbnailUrl'], '');
          if (thumb.isNotEmpty) return thumb;
          final full = _readAny(item, const <String>['fullUrl', 'imageUrl', 'url'], '');
          if (full.isNotEmpty) return full;
        }
      }
    } catch (_) {}

    return '';
  }

  static String _readAny(dynamic source, List<String> fields, String fallback) {
    for (final field in fields) {
      final value = _readString(source, field);
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  static String _readString(dynamic source, String fieldName) {
    if (source == null) return '';

    try {
      if (source is Map && source.containsKey(fieldName)) {
        final text = source[fieldName]?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    } catch (_) {}

    try {
      late final Object? value;
      switch (fieldName) {
        case 'id':
          value = source.id;
          break;
        case 'productId':
          value = source.productId;
          break;
        case 'slug':
          value = source.slug;
          break;
        case 'sku':
          value = source.sku;
          break;
        case 'productSku':
          value = source.productSku;
          break;
        case 'productType':
          value = source.productType;
          break;
        case 'type':
          value = source.type;
          break;
        case 'titleEn':
          value = source.titleEn;
          break;
        case 'titleBn':
          value = source.titleBn;
          break;
        case 'name':
          value = source.name;
          break;
        case 'nameEn':
          value = source.nameEn;
          break;
        case 'nameBn':
          value = source.nameBn;
          break;
        case 'shortDescriptionEn':
          value = source.shortDescriptionEn;
          break;
        case 'shortDescriptionBn':
          value = source.shortDescriptionBn;
          break;
        case 'descriptionEn':
          value = source.descriptionEn;
          break;
        case 'descriptionBn':
          value = source.descriptionBn;
          break;
        case 'thumbnailUrl':
          value = source.thumbnailUrl;
          break;
        case 'imageUrl':
          value = source.imageUrl;
          break;
        case 'brandName':
          value = source.brandName;
          break;
        case 'brandNameEn':
          value = source.brandNameEn;
          break;
        case 'brandNameBn':
          value = source.brandNameBn;
          break;
        case 'categoryName':
          value = source.categoryName;
          break;
        case 'categoryNameEn':
          value = source.categoryNameEn;
          break;
        case 'categoryNameBn':
          value = source.categoryNameBn;
          break;
        case 'unitLabelEn':
          value = source.unitLabelEn;
          break;
        case 'unitLabelBn':
          value = source.unitLabelBn;
          break;
        case 'quantityValue':
          value = source.quantityValue;
          break;
        case 'quantityType':
          value = source.quantityType;
          break;
        case 'logoUrl':
          value = source.logoUrl;
          break;
        case 'iconUrl':
          value = source.iconUrl;
          break;
        case 'labelEn':
          value = source.labelEn;
          break;
        case 'labelBn':
          value = source.labelBn;
          break;
        case 'displayName':
          value = source.displayName;
          break;
        case 'valueEn':
          value = source.valueEn;
          break;
        case 'valueBn':
          value = source.valueBn;
          break;
        case 'colorHex':
          value = source.colorHex;
          break;
        case 'hex':
          value = source.hex;
          break;
        case 'packText':
          value = source.packText;
          break;
        case 'rating':
          value = source.rating;
          break;
        case 'reviewCount':
          value = source.reviewCount;
          break;
        default:
          value = null;
      }

      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    } catch (_) {}

    return '';
  }

  static num? _readNumber(dynamic source, String fieldName) {
    final text = _readString(source, fieldName);
    if (text.isNotEmpty) {
      return num.tryParse(text.replaceAll(RegExp(r'[^0-9\.-]'), ''));
    }

    try {
      if (source is Map && source.containsKey(fieldName)) {
        final value = source[fieldName];
        if (value is num) return value;
        return num.tryParse(value?.toString().trim() ?? '');
      }
    } catch (_) {}

    try {
      late final Object? value;
      switch (fieldName) {
        case 'price':
          value = source.price;
          break;
        case 'salePrice':
          value = source.salePrice;
          break;
        case 'finalPrice':
          value = source.finalPrice;
          break;
        case 'costPrice':
          value = source.costPrice;
          break;
        case 'stockQty':
          value = source.stockQty;
          break;
        case 'reviewCount':
          value = source.reviewCount;
          break;
        default:
          value = null;
      }
      if (value is num) return value;
      return num.tryParse(value?.toString().trim() ?? '');
    } catch (_) {}

    return null;
  }

  static bool _readBool(dynamic source, String fieldName, {required bool fallback}) {
    try {
      if (source is Map && source.containsKey(fieldName)) {
        final value = source[fieldName];
        if (value is bool) return value;
        final normalized = value?.toString().trim().toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
    } catch (_) {}

    try {
      late final Object? value;
      switch (fieldName) {
        case 'isFeatured':
          value = source.isFeatured;
          break;
        case 'isFlashSale':
          value = source.isFlashSale;
          break;
        case 'isNewArrival':
          value = source.isNewArrival;
          break;
        case 'isBestSeller':
          value = source.isBestSeller;
          break;
        default:
          value = null;
      }

      if (value is bool) return value;
      final normalized = value?.toString().trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    } catch (_) {}

    return fallback;
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
