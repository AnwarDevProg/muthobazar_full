import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_card_context.dart
//
// Purpose:
// Runtime context passed to the new design-family card renderer.
//
// This context intentionally uses the new cardDesign model.
// It does not depend on old cardConfig/variant-router fallback logic.
//
// Important:
// Keep this file strongly compatible with the current MBProduct model.
// Do not directly read optional/future getters that may not exist yet
// such as unit, rating, reviewCount, stockStatus, etc.

class MBDesignCardContext {
  const MBDesignCardContext({
    required this.product,
    required this.config,
    this.onTap,
    this.onPrimaryCtaTap,
    this.onSecondaryCtaTap,
    this.currencySymbol = '৳',
  });

  final MBProduct product;
  final MBCardDesignConfig config;

  final VoidCallback? onTap;
  final VoidCallback? onPrimaryCtaTap;
  final VoidCallback? onSecondaryCtaTap;

  final String currencySymbol;

  String get title => _normalizeString(
        product.titleEn,
        fallback: 'Product',
      );

  String get subtitle {
    final candidates = <String>[
      _normalizeString(product.shortDescriptionEn),
      _normalizeString(product.descriptionEn),
      _normalizeString(product.titleBn),
    ];

    for (final item in candidates) {
      if (item.trim().isNotEmpty) return item.trim();
    }

    return '';
  }

  String get imageUrl => _normalizeString(
        product.resolvedCardImageUrl,
        fallback: product.resolvedThumbImageUrl,
      );

  String get brandName {
    final candidates = <String>[
      _normalizeString(product.brandNameEn),
      _normalizeString(product.brandNameBn),
    ];

    for (final item in candidates) {
      if (item.trim().isNotEmpty) return item.trim();
    }

    return 'MuthoBazar';
  }

  String get categoryName {
    final candidates = <String>[
      _normalizeString(product.categoryNameEn),
      _normalizeString(product.categoryNameBn),
    ];

    for (final item in candidates) {
      if (item.trim().isNotEmpty) return item.trim();
    }

    return 'General';
  }

  // Temporary lab/default value until the new product model exposes a
  // stable unit-label getter.
  String get unitLabel => '/pcs';

  double get finalPrice => _safeDouble(
        () => product.effectivePrice,
        fallback: _safeDouble(() => product.price, fallback: 0),
      );

  double get originalPrice => _safeDouble(
        () => product.price,
        fallback: finalPrice,
      );

  bool get hasDiscount {
    final configured = _safeBool(() => product.hasDiscount);
    if (configured != null) return configured;

    return originalPrice > finalPrice;
  }

  double get savingAmount {
    final value = originalPrice - finalPrice;
    if (value <= 0) return 0;
    return value;
  }

  String get finalPriceText =>
      '$currencySymbol${finalPrice.toStringAsFixed(0)}';

  String? get originalPriceText {
    if (!hasDiscount) return null;
    return '$currencySymbol${originalPrice.toStringAsFixed(0)}';
  }

  String? get savingText {
    if (!hasDiscount || savingAmount <= 0) return null;

    final percent =
        originalPrice <= 0 ? 0 : (savingAmount / originalPrice) * 100;

    if (percent >= 1) {
      return 'Save ${percent.toStringAsFixed(0)}%';
    }

    return 'Save $currencySymbol${savingAmount.toStringAsFixed(0)}';
  }

  // Temporary visual defaults for lab/design phase.
  // These will later come from product/review/inventory/order analytics models.
  double get ratingValue => 4.6;
  int get reviewCount => 128;
  String get reviewCountText => '($reviewCount)';
  String get stockHint => 'In stock';
  String get deliveryHint => 'Fast delivery';
  String get promoText => 'Premium';
  String get flashText => 'Flash';
  String get ribbonText => 'New';
  String get timerText => '02:15:08';
  double get progressValue => 0.72;

  String resolveBinding(MBCardElementConfig? element) {
    final source = element?.binding?.source.trim() ?? '';

    switch (source) {
      case 'product.titleEn':
        return title;
      case 'product.shortDescriptionEn':
        return subtitle;
      case 'product.thumbnailUrl':
        return imageUrl;
      case 'product.brandNameEn':
        return brandName;
      case 'product.categoryNameEn':
        return categoryName;
      case 'product.unit':
        return unitLabel;
      case 'product.rating':
        return ratingValue.toStringAsFixed(1);
      case 'product.reviewCount':
        return reviewCount.toString();
      case 'resolved.finalPrice':
        return finalPriceText;
      case 'resolved.oldPrice':
        return originalPriceText ?? '';
      case 'resolved.savingText':
        return savingText ?? '';
      case 'resolved.stockHint':
        return stockHint;
      case 'resolved.deliveryHint':
        return deliveryHint;
      case 'resolved.timerText':
        return timerText;
      case 'resolved.progressValue':
        return progressValue.toStringAsFixed(2);
      case 'preset.ribbonText':
        return ribbonText;
      case 'preset.promoLabel':
        return promoText;
      case 'preset.flashLabel':
        return flashText;
      case 'action.addToCart':
        return 'Add';
      case 'action.buyNow':
        return 'Buy';
      case 'action.wishlist':
        return 'Wishlist';
      case 'action.compare':
        return 'Compare';
      case 'action.share':
        return 'Share';
      case 'action.chooseOptions':
        return 'Options';
      default:
        return element?.binding?.fallbackText ?? '';
    }
  }

  static String _normalizeString(
    Object? value, {
    String fallback = '',
  }) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) return fallback;
    return normalized;
  }

  static double _safeDouble(
    num Function() reader, {
    required double fallback,
  }) {
    try {
      return reader().toDouble();
    } catch (_) {
      return fallback;
    }
  }

  static bool? _safeBool(bool Function() reader) {
    try {
      return reader();
    } catch (_) {
      return null;
    }
  }
}
