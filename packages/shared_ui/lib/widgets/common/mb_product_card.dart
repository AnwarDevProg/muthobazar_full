import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import 'product_cards/mb_product_card_renderer.dart';

// Legacy generic product card wrapper
// -----------------------------------
// This widget exists only to keep older call sites working while the app moves
// to the centralized MBProduct + MBProductCardRenderer system.
//
// The current shared MBProduct model uses fields such as:
// - titleEn / titleBn
// - shortDescriptionEn / shortDescriptionBn
// - descriptionEn / descriptionBn
// - thumbnailUrl / imageUrls / mediaItems
// - price / salePrice / costPrice
// - brandNameEn / brandNameBn
// - categoryNameEn / categoryNameBn
// - cardLayoutType
// - isFeatured / isFlashSale / isNewArrival / isBestSeller
// - createdAt / updatedAt
//
// So this wrapper now maps legacy plain props into the real MBProduct model
// shape before delegating to MBProductCardRenderer.
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
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showAddToCart = true,
    this.addToCartText = 'Add to Cart',
    this.contextType = MBProductCardRenderContext.auto,
    this.showFavorite = true,
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
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showAddToCart;
  final String addToCartText;
  final MBProductCardRenderContext contextType;
  final bool showFavorite;
  final double featuredHeight;

  @override
  Widget build(BuildContext context) {
    final product = _buildLegacyProduct();

    return MBProductCardRenderer(
      product: product,
      contextType: contextType,
      onTap: onTap,
      onAddToCart: onAddToCart,
      isFavorite: isFavorite,
      onFavoriteTap: onFavoriteTap,
      showAddToCart: showAddToCart,
      showFavorite: showFavorite,
      featuredHeight: featuredHeight,
    );
  }

  MBProduct _buildLegacyProduct() {
    final now = DateTime.now();
    final normalizedLayout = MBProductCardLayoutHelper.normalize(
      cardLayoutType ?? MBProductCardLayout.standard.value,
    );

    final currentPrice = _parsePrice(priceText);
    final comparePrice = _parsePrice(oldPriceText);
    final pricing = _resolvePricing(
      currentPrice: currentPrice,
      comparePrice: comparePrice,
    );

    final normalizedBadge = badgeText?.trim().toLowerCase() ?? '';
    final resolvedImageUrls = _resolveImageUrls();

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
      cardLayoutType: normalizedLayout,
      isFeatured: isFeatured ?? _badgeHas(normalizedBadge, const ['featured']),
      isFlashSale: isFlashSale ??
          _badgeHas(normalizedBadge, const ['flash', 'flash sale']),
      isNewArrival:
      isNewArrival ?? _badgeHas(normalizedBadge, const ['new', 'arrival']),
      isBestSeller: isBestSeller ??
          _badgeHas(normalizedBadge, const ['best', 'best seller', 'bestseller']),
      isEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  List<String> _resolveImageUrls() {
    final urls = <String>[];

    for (final raw in imageUrls ?? const <String>[]) {
      final value = raw.trim();
      if (value.isNotEmpty) {
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
    if (raw == null) return 0;

    final cleaned = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
    if (cleaned.isEmpty) return 0;

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
    if (badge.isEmpty) return false;
    for (final part in parts) {
      if (badge.contains(part)) {
        return true;
      }
    }
    return false;
  }

  String _slugify(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return '';

    final collapsed = normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    return collapsed;
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
