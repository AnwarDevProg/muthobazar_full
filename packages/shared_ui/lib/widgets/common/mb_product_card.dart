import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import 'product_cards/mb_product_card_renderer.dart';

// Legacy generic product card wrapper.
//
// Why this file still exists:
// - Some older call sites still build cards using plain fields like title,
//   priceText, imageUrl, and badgeText.
// - The new design system is variant-first and MBProduct-first.
// - This wrapper exists only to translate older call sites into a real MBProduct
//   before delegating to MBProductCardRenderer.
//
// Cleanup rules for this wrapper:
// - Prefer variantId over old cardLayoutType.
// - Keep only the minimum compatibility props that are still useful.
// - Do not reintroduce old layout decision logic outside the small bridge here.
// - New code should prefer real MBProduct + new variant-first rendering paths.
class MBProductCard extends StatelessWidget {
  const MBProductCard({
    super.key,
    required this.title,
    required this.priceText,
    required this.imageUrl,
    this.oldPriceText,
    this.badgeText,
    this.titleBn,
    this.shortDescriptionEn,
    this.shortDescriptionBn,
    this.descriptionEn,
    this.descriptionBn,
    this.categoryNameEn,
    this.categoryNameBn,
    this.brandNameEn,
    this.brandNameBn,
    this.imageUrls,
    this.mediaItems = const <MBProductMedia>[],
    this.tags = const <String>[],
    this.productCode,
    this.sku,
    this.variantId,
    this.cardLayoutType,
    this.productType = 'simple',
    this.stockQty = 999,
    this.trackInventory = true,
    this.allowBackorder = false,
    this.isFeatured,
    this.isFlashSale,
    this.isNewArrival,
    this.isBestSeller,
    this.saleStartsAt,
    this.saleEndsAt,
    this.onTap,
    this.onAddToCart,
    this.contextType = MBProductCardRenderContext.auto,
    this.featuredHeight = 320,
  });

  final String title;
  final String priceText;
  final String imageUrl;
  final String? oldPriceText;
  final String? badgeText;
  final String? titleBn;
  final String? shortDescriptionEn;
  final String? shortDescriptionBn;
  final String? descriptionEn;
  final String? descriptionBn;
  final String? categoryNameEn;
  final String? categoryNameBn;
  final String? brandNameEn;
  final String? brandNameBn;
  final List<String>? imageUrls;
  final List<MBProductMedia> mediaItems;
  final List<String> tags;
  final String? productCode;
  final String? sku;

  // New preferred input.
  final String? variantId;

  // Legacy bridge input kept temporarily.
  final String? cardLayoutType;

  final String productType;
  final int stockQty;
  final bool trackInventory;
  final bool allowBackorder;
  final bool? isFeatured;
  final bool? isFlashSale;
  final bool? isNewArrival;
  final bool? isBestSeller;
  final DateTime? saleStartsAt;
  final DateTime? saleEndsAt;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final MBProductCardRenderContext contextType;
  final double featuredHeight;

  @override
  Widget build(BuildContext context) {
    final product = _buildLegacyProduct();

    return MBProductCardRenderer(
      product: product,
      contextType: contextType,
      onTap: onTap,
      onAddToCartTap: onAddToCart,
      featuredHeight: featuredHeight,
    );
  }

  MBProduct _buildLegacyProduct() {
    final now = DateTime.now();
    final pricing = _resolvePricing(
      currentPrice: _parsePrice(priceText),
      comparePrice: _parsePrice(oldPriceText),
    );

    final normalizedBadge = badgeText?.trim().toLowerCase() ?? '';
    final resolvedImageUrls = _resolveImageUrls();
    final resolvedVariantId = _resolveVariantId();

    return MBProduct(
      id: 'legacy_${title.hashCode}_${imageUrl.hashCode}',
      slug: _slugify(title),
      productCode: _cleanNullable(productCode),
      sku: _cleanNullable(sku),
      titleEn: title.trim(),
      titleBn: _clean(titleBn),
      shortDescriptionEn: _clean(shortDescriptionEn),
      shortDescriptionBn: _clean(shortDescriptionBn),
      descriptionEn: _clean(descriptionEn),
      descriptionBn: _clean(descriptionBn),
      thumbnailUrl: imageUrl.trim(),
      imageUrls: resolvedImageUrls,
      mediaItems: mediaItems,
      price: pricing.price,
      salePrice: pricing.salePrice,
      saleStartsAt: pricing.salePrice == null ? null : saleStartsAt,
      saleEndsAt: pricing.salePrice == null ? null : saleEndsAt,
      stockQty: stockQty,
      regularStockQty: stockQty,
      trackInventory: trackInventory,
      allowBackorder: allowBackorder,
      categoryNameEn: _cleanNullable(categoryNameEn),
      categoryNameBn: _cleanNullable(categoryNameBn),
      brandNameEn: _cleanNullable(brandNameEn),
      brandNameBn: _cleanNullable(brandNameBn),
      productType: productType.trim().isEmpty ? 'simple' : productType.trim(),
      tags: tags,
      cardLayoutType: resolvedVariantId,
      isFeatured: isFeatured ?? _badgeHas(normalizedBadge, const <String>['featured']),
      isFlashSale: isFlashSale ??
          _badgeHas(normalizedBadge, const <String>['flash', 'flash sale']),
      isNewArrival: isNewArrival ??
          _badgeHas(normalizedBadge, const <String>['new', 'arrival']),
      isBestSeller: isBestSeller ??
          _badgeHas(normalizedBadge, const <String>['best', 'best seller', 'bestseller']),
      isEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  String _resolveVariantId() {
    final normalizedVariantId = _cleanNullable(variantId);
    if (normalizedVariantId != null) {
      return _normalizeVariantId(normalizedVariantId);
    }

    final normalizedLegacyLayout = _cleanNullable(cardLayoutType);
    if (normalizedLegacyLayout != null) {
      return _legacyLayoutToVariantId(normalizedLegacyLayout);
    }

    return MBCardVariant.compact01.id;
  }

  String _normalizeVariantId(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'compact01':
        return MBCardVariant.compact01.id;
      case 'price01':
        return MBCardVariant.price01.id;
      case 'horizontal01':
        return MBCardVariant.horizontal01.id;
      case 'premium01':
        return MBCardVariant.premium01.id;
      case 'wide01':
        return MBCardVariant.wide01.id;
      case 'featured01':
        return MBCardVariant.featured01.id;
      case 'promo01':
        return MBCardVariant.promo01.id;
      case 'flash01':
        return MBCardVariant.flash01.id;
      default:
        return MBCardVariant.compact01.id;
    }
  }

  String _legacyLayoutToVariantId(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'compact':
        return MBCardVariant.compact01.id;
      case 'card01':
        return MBCardVariant.price01.id;
      case 'standard':
        return MBCardVariant.horizontal01.id;
      case 'card02':
        return MBCardVariant.premium01.id;
      case 'featured':
        return MBCardVariant.wide01.id;
      case 'card03':
        return MBCardVariant.featured01.id;
      case 'deal':
        return MBCardVariant.flash01.id;
      default:
        return MBCardVariant.compact01.id;
    }
  }

  List<String> _resolveImageUrls() {
    final urls = <String>[];

    for (final raw in imageUrls ?? const <String>[]) {
      final value = raw.trim();
      if (value.isNotEmpty && !urls.contains(value)) {
        urls.add(value);
      }
    }

    final trimmedThumb = imageUrl.trim();
    if (trimmedThumb.isNotEmpty && !urls.contains(trimmedThumb)) {
      urls.insert(0, trimmedThumb);
    }

    return urls;
  }

  _ResolvedPricing _resolvePricing({
    required double currentPrice,
    required double comparePrice,
  }) {
    if (comparePrice > 0 && currentPrice > 0 && comparePrice > currentPrice) {
      return _ResolvedPricing(
        price: comparePrice,
        salePrice: currentPrice,
      );
    }

    return _ResolvedPricing(
      price: currentPrice,
      salePrice: null,
    );
  }

  double _parsePrice(String? raw) {
    if (raw == null) {
      return 0;
    }

    final cleaned = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
    if (cleaned.isEmpty) {
      return 0;
    }

    return double.tryParse(cleaned) ?? 0;
  }

  String _clean(String? value) {
    return value?.trim() ?? '';
  }

  String? _cleanNullable(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }
    return cleaned;
  }

  bool _badgeHas(String badge, List<String> parts) {
    if (badge.isEmpty) {
      return false;
    }

    for (final part in parts) {
      if (badge.contains(part)) {
        return true;
      }
    }
    return false;
  }

  String _slugify(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }

    return normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

class _ResolvedPricing {
  const _ResolvedPricing({
    required this.price,
    required this.salePrice,
  });

  final double price;
  final double? salePrice;
}
