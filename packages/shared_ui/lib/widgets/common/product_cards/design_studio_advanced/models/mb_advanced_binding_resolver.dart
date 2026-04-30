// MuthoBazar Advanced Product Card Design Studio
// Patch 12.1 binding resolver.
//
// Purpose:
// - Provide a safe, product-model-aware preview value resolver for the Studio V3
//   element drawer and future inspector controls.
// - Keep saved V3 JSON clean: only binding paths are saved, not resolved preview
//   values.
// - Work with both real MBProduct model objects and temporary Map-based preview
//   objects created from the product dialog state.

import 'dart:math' as math;

class MBAdvancedPreviewContext {
  const MBAdvancedPreviewContext({
    required this.product,
    this.brand,
    this.category,
    this.selectedVariation,
    this.selectedPurchaseOption,
    this.fallbackTitle = 'Product title',
    this.fallbackSubtitle = 'Fresh product detail',
  });

  final dynamic product;
  final dynamic brand;
  final dynamic category;
  final dynamic selectedVariation;
  final dynamic selectedPurchaseOption;
  final String fallbackTitle;
  final String fallbackSubtitle;

  factory MBAdvancedPreviewContext.fromProduct({
    required dynamic product,
    String fallbackTitle = 'Product title',
    String fallbackSubtitle = 'Fresh product detail',
  }) {
    return MBAdvancedPreviewContext(
      product: product,
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

    switch (normalized) {
      case 'product.titleEn':
      case 'product.nameEn':
        return _readAny(context.product, const <String>['titleEn', 'nameEn'], context.fallbackTitle);
      case 'product.titleBn':
      case 'product.nameBn':
        return _readAny(context.product, const <String>['titleBn', 'nameBn'], context.fallbackTitle);
      case 'product.shortDescriptionEn':
        return _readAny(context.product, const <String>['shortDescriptionEn'], context.fallbackSubtitle);
      case 'product.shortDescriptionBn':
        return _readAny(context.product, const <String>['shortDescriptionBn'], context.fallbackSubtitle);
      case 'product.descriptionEn':
        return _readAny(context.product, const <String>['descriptionEn'], context.fallbackSubtitle);
      case 'product.descriptionBn':
        return _readAny(context.product, const <String>['descriptionBn'], context.fallbackSubtitle);
      case 'product.thumbnailUrl':
      case 'product.imageUrl':
        return resolveImageUrl(context, binding);
      case 'product.imageUrls.first':
        return _readFirstImageUrl(context.product);
      case 'product.finalPrice':
        return formatCurrency(_readFinalPrice(context.product));
      case 'product.salePrice':
        return formatCurrency(_readNumber(context.product, 'salePrice') ?? _readFinalPrice(context.product));
      case 'product.price':
      case 'product.originalPrice':
      case 'product.mrp':
        return formatCurrency(_readNumber(context.product, 'price') ?? _readFinalPrice(context.product));
      case 'product.costPrice':
        return formatCurrency(_readNumber(context.product, 'costPrice') ?? 0);
      case 'product.discountPercent':
      case 'static.discount':
        return _discountLabel(context.product);
      case 'product.brandNameEn':
      case 'product.brandName':
      case 'product.brand':
        return _readAny(context.product, const <String>['brandNameEn', 'brandName'], 'Brand');
      case 'product.brandNameBn':
        return _readAny(context.product, const <String>['brandNameBn'], 'Brand');
      case 'brand.nameEn':
        return _readAny(context.brand, const <String>['nameEn', 'brandNameEn', 'name'],
            _readAny(context.product, const <String>['brandNameEn', 'brandName'], 'Brand'));
      case 'brand.nameBn':
        return _readAny(context.brand, const <String>['nameBn', 'brandNameBn'],
            _readAny(context.product, const <String>['brandNameBn'], 'Brand'));
      case 'product.categoryNameEn':
      case 'product.categoryName':
      case 'product.category':
        return _readAny(context.product, const <String>['categoryNameEn', 'categoryName'], 'Category');
      case 'product.categoryNameBn':
        return _readAny(context.product, const <String>['categoryNameBn'], 'Category');
      case 'category.nameEn':
        return _readAny(context.category, const <String>['nameEn', 'categoryNameEn', 'name'],
            _readAny(context.product, const <String>['categoryNameEn', 'categoryName'], 'Category'));
      case 'category.nameBn':
        return _readAny(context.category, const <String>['nameBn', 'categoryNameBn'],
            _readAny(context.product, const <String>['categoryNameBn'], 'Category'));
      case 'product.unitLabelEn':
        return _readAny(context.product, const <String>['unitLabelEn'], 'pcs');
      case 'product.unitLabelBn':
        return _readAny(context.product, const <String>['unitLabelBn'], 'pcs');
      case 'product.quantityValue':
        return _readAny(context.product, const <String>['quantityValue'], '1');
      case 'product.quantityType':
        return _readAny(context.product, const <String>['quantityType'], 'pcs');
      case 'product.stockQty':
        return '${_readNumber(context.product, 'stockQty')?.round() ?? 0} left';
      case 'product.stockText':
      case 'static.stock':
        return (_readNumber(context.product, 'stockQty') ?? 0) > 0 ? 'In stock' : 'Limited stock';
      case 'product.deliveryHint':
      case 'static.delivery':
        return 'Fast delivery';
      case 'product.rating':
      case 'static.rating':
        return '★ 4.8';
      case 'timer.countdown':
      case 'static.timer':
        return '02:15:08';
      case 'static.badge':
        return 'HOT';
      case 'static.flash':
        return 'Flash';
      case 'static.new':
        return 'New';
      case 'static.premium':
        return 'Premium';
      case 'static.feature':
        return 'Farm fresh';
      case 'static.saving':
        return 'Save more';
      case 'action.buy':
        return 'Buy';
      case 'action.add':
        return 'Add';
      case 'action.details':
        return 'View';
      case 'action.wishlist':
        return '♡';
      case 'action.compare':
        return '⇄';
      case 'action.share':
        return '↗';
      default:
        if (normalized.startsWith('static.')) {
          final value = normalized.substring('static.'.length).replaceAll('_', ' ');
          return value.isEmpty ? fallback : _titleCase(value);
        }
        return fallback;
    }
  }

  static String resolveImageUrl(
    MBAdvancedPreviewContext context,
    String binding, {
    String fallback = '',
  }) {
    switch (binding.trim()) {
      case 'product.thumbnailUrl':
        return _readAny(context.product, const <String>['thumbnailUrl'], fallback);
      case 'product.imageUrl':
        return _readAny(context.product, const <String>['imageUrl'], fallback);
      case 'product.imageUrls.first':
        return _readFirstImageUrl(context.product).isNotEmpty
            ? _readFirstImageUrl(context.product)
            : fallback;
      case 'brand.logoUrl':
        return _readAny(context.brand, const <String>['logoUrl', 'imageUrl'], fallback);
      case 'category.imageUrl':
        return _readAny(context.category, const <String>['imageUrl'], fallback);
      case 'category.iconUrl':
        return _readAny(context.category, const <String>['iconUrl'], fallback);
      case 'variation.thumbnailUrl':
        return _readAny(context.selectedVariation, const <String>['thumbnailUrl'], fallback);
      default:
        return fallback;
    }
  }

  static String formatCurrency(num value) {
    final cleanValue = value.isFinite ? value : 0;
    final number = cleanValue % 1 == 0 ? cleanValue.toInt().toString() : cleanValue.toStringAsFixed(1);
    return '৳$number';
  }

  static num _readFinalPrice(dynamic product) {
    final sale = _readNumber(product, 'salePrice');
    if (sale != null && sale > 0) return sale;
    return _readNumber(product, 'price') ?? 0;
  }

  static String _discountLabel(dynamic product) {
    final original = _readNumber(product, 'price') ?? 0;
    final finalPrice = _readFinalPrice(product);

    if (original <= 0 || finalPrice <= 0 || finalPrice >= original) {
      return 'Save';
    }

    final percent = (((original - finalPrice) / math.max(1, original)) * 100).round();
    return '$percent% OFF';
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
    try {
      if (source is Map && source.containsKey(fieldName)) {
        final text = source[fieldName]?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    } catch (_) {}

    try {
      late final Object? value;
      switch (fieldName) {
        case 'titleEn':
          value = source.titleEn;
          break;
        case 'titleBn':
          value = source.titleBn;
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
        case 'costPrice':
          value = source.costPrice;
          break;
        case 'stockQty':
          value = source.stockQty;
          break;
        default:
          value = null;
      }
      if (value is num) return value;
      return num.tryParse(value?.toString().trim() ?? '');
    } catch (_) {}

    return null;
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
