import 'package:shared_models/shared_models.dart';

// File: cart_item_builder.dart
//
// Purpose:
// Centralized builder for creating cart lines from:
// - simple products
// - selected variations
//
// Pricing source:
// - base price comes from MBPricingResolver.basePrice
// - payable price comes from MBPricingResolver.finalUnitPrice
//
// This keeps Add to Cart / Buy Now / Quick Add flows consistent.

class MBCartItemBuilder {
  const MBCartItemBuilder._();

  static MBCartItem buildForProduct({
    required MBProduct product,
    required int quantity,
    String purchaseMode = 'instant',
    DateTime? selectedDate,
    String? selectedShift,
    List<MBOffer> offers = const <MBOffer>[],
    bool isEstimatedPrice = false,
  }) {
    final normalizedQuantity = quantity < 1 ? 1 : quantity;

    final resolved = MBPricingResolver.resolveProduct(
      product: product,
      offers: offers,
    );

    return MBCartItem(
      productId: product.id,
      titleEn: product.titleEn,
      titleBn: product.titleBn,
      imageUrl: _normalizedImage(product.thumbnailUrl),
      variationId: null,
      unitPrice: resolved.basePrice,
      finalUnitPrice: resolved.finalUnitPrice == resolved.basePrice
          ? null
          : resolved.finalUnitPrice,
      isEstimatedPrice: isEstimatedPrice,
      quantity: normalizedQuantity,
      purchaseMode: purchaseMode,
      selectedDate: selectedDate,
      selectedShift: selectedShift,
    );
  }

  static MBCartItem buildForVariation({
    required MBProduct product,
    required MBProductVariation variation,
    required int quantity,
    String purchaseMode = 'instant',
    DateTime? selectedDate,
    String? selectedShift,
    List<MBOffer> offers = const <MBOffer>[],
    bool isEstimatedPrice = false,
  }) {
    final normalizedQuantity = quantity < 1 ? 1 : quantity;

    final resolved = MBPricingResolver.resolveVariation(
      product: product,
      variation: variation,
      offers: offers,
    );

    final titleEn = variation.titleEn.trim().isNotEmpty
        ? variation.titleEn.trim()
        : product.titleEn;

    final titleBn = variation.titleBn.trim().isNotEmpty
        ? variation.titleBn.trim()
        : product.titleBn;

    final imageUrl = _resolveVariationImage(
      product: product,
      variation: variation,
    );

    return MBCartItem(
      productId: product.id,
      titleEn: titleEn,
      titleBn: titleBn,
      imageUrl: imageUrl,
      variationId: variation.id,
      unitPrice: resolved.basePrice,
      finalUnitPrice: resolved.finalUnitPrice == resolved.basePrice
          ? null
          : resolved.finalUnitPrice,
      isEstimatedPrice: isEstimatedPrice,
      quantity: normalizedQuantity,
      purchaseMode: purchaseMode,
      selectedDate: selectedDate,
      selectedShift: selectedShift,
    );
  }

  static String? _resolveVariationImage({
    required MBProduct product,
    required MBProductVariation variation,
  }) {
    final variationThumb = variation.effectiveThumbImageUrl.trim();
    if (variationThumb.isNotEmpty) return variationThumb;

    final variationFull = variation.effectiveFullImageUrl.trim();
    if (variationFull.isNotEmpty) return variationFull;

    final productThumb = product.thumbnailUrl.trim();
    if (productThumb.isNotEmpty) return productThumb;

    return null;
  }

  static String? _normalizedImage(String? value) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}