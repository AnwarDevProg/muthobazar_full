// File: mb_pricing_resolver.dart
// Shared pricing resolver for:
// - native sale
// - automatic offers
// - promo code application
//
// Design rules in this version:
// 1. Base price always comes from product/variation `price`.
// 2. Native sale is resolved from product/variation sale fields.
// 3. Automatic offers are evaluated separately and do NOT overwrite product docs.
// 4. Only one automatic offer wins.
// 5. Native sale and automatic offer do not stack by default; the lower payable
//    price wins.
// 6. Promo code applies last.
// 7. Promo code does not stack on already discounted items by default, unless
//    explicitly allowed through resolver arguments.

import '../catalog/mb_product.dart';
import '../catalog/mb_product_variation.dart';
import 'mb_offer.dart';
import 'mb_promo_code.dart';

enum MBPricingOwnerType {
  product,
  variation,
}

enum MBResolvedDiscountSource {
  none,
  nativeSale,
  offer,
  promoCode,
}

enum MBResolvedOfferScope {
  none,
  variation,
  product,
  category,
  brand,
}

class MBAppliedOfferResult {
  const MBAppliedOfferResult({
    required this.offer,
    required this.scope,
    required this.resultPrice,
    required this.discountAmount,
  });

  final MBOffer offer;
  final MBResolvedOfferScope scope;
  final double resultPrice;
  final double discountAmount;
}

class MBAppliedPromoResult {
  const MBAppliedPromoResult({
    required this.promoCode,
    required this.resultPrice,
    required this.discountAmount,
  });

  final MBPromoCode promoCode;
  final double resultPrice;
  final double discountAmount;
}

class MBResolvedPrice {
  const MBResolvedPrice({
    required this.ownerType,
    required this.ownerId,
    required this.basePrice,
    required this.nativeSalePrice,
    required this.priceAfterOfferStage,
    required this.finalUnitPrice,
    required this.totalDiscountAmount,
    required this.discountSource,
    required this.nativeSaleApplied,
    required this.offerApplied,
    required this.promoCodeApplied,
    this.appliedOfferId,
    this.appliedOfferTitle,
    this.appliedOfferScope = MBResolvedOfferScope.none,
    this.appliedPromoCode,
    this.debugLabel = '',
  });

  final MBPricingOwnerType ownerType;
  final String ownerId;

  final double basePrice;
  final double nativeSalePrice;
  final double priceAfterOfferStage;
  final double finalUnitPrice;
  final double totalDiscountAmount;

  final MBResolvedDiscountSource discountSource;

  final bool nativeSaleApplied;
  final bool offerApplied;
  final bool promoCodeApplied;

  final String? appliedOfferId;
  final String? appliedOfferTitle;
  final MBResolvedOfferScope appliedOfferScope;
  final String? appliedPromoCode;

  final String debugLabel;

  bool get isDiscounted => finalUnitPrice < basePrice;

  int get discountPercent {
    if (basePrice <= 0 || finalUnitPrice >= basePrice) return 0;
    return (((basePrice - finalUnitPrice) / basePrice) * 100).round();
  }
}

class MBPricingResolver {
  const MBPricingResolver._();

  static MBResolvedPrice resolveProduct({
    required MBProduct product,
    Iterable<MBOffer> offers = const <MBOffer>[],
    MBPromoCode? promoCode,
    String? userId,
    double cartSubtotal = 0,
    DateTime? at,
    bool allowPromoOnDiscountedItems = false,
  }) {
    final now = at ?? DateTime.now();
    final basePrice = _sanitizePrice(product.price);
    final nativeSalePrice = _resolveNativeSalePriceForProduct(
      product: product,
      at: now,
    );

    final bestOffer = _resolveBestOffer(
      product: product,
      variation: null,
      basePrice: basePrice,
      offers: offers,
      at: now,
    );

    final offerStage = _chooseBestPrePromoPrice(
      basePrice: basePrice,
      nativeSalePrice: nativeSalePrice,
      bestOffer: bestOffer,
    );

    final promoResult = _resolvePromoCode(
      promoCode: promoCode,
      currentPrice: offerStage.price,
      cartSubtotal: cartSubtotal,
      at: now,
      userId: userId,
      allowOnDiscountedItems:
      allowPromoOnDiscountedItems || !offerStage.discountApplied,
    );

    final finalUnitPrice = promoResult?.resultPrice ?? offerStage.price;
    final totalDiscountAmount = _positiveOrZero(basePrice - finalUnitPrice);

    return MBResolvedPrice(
      ownerType: MBPricingOwnerType.product,
      ownerId: product.id,
      basePrice: basePrice,
      nativeSalePrice: nativeSalePrice,
      priceAfterOfferStage: offerStage.price,
      finalUnitPrice: finalUnitPrice,
      totalDiscountAmount: totalDiscountAmount,
      discountSource: promoResult != null
          ? MBResolvedDiscountSource.promoCode
          : offerStage.source,
      nativeSaleApplied: offerStage.nativeSaleApplied,
      offerApplied: offerStage.offerApplied,
      promoCodeApplied: promoResult != null,
      appliedOfferId: offerStage.offer?.id,
      appliedOfferTitle: offerStage.offer == null
          ? null
          : _safeOfferTitle(offerStage.offer!),
      appliedOfferScope: offerStage.offerScope,
      appliedPromoCode: promoResult?.promoCode.code,
      debugLabel: 'product',
    );
  }

  static MBResolvedPrice resolveVariation({
    required MBProduct product,
    required MBProductVariation variation,
    Iterable<MBOffer> offers = const <MBOffer>[],
    MBPromoCode? promoCode,
    String? userId,
    double cartSubtotal = 0,
    DateTime? at,
    bool allowPromoOnDiscountedItems = false,
    bool fallbackToProductLevelOffers = true,
  }) {
    final now = at ?? DateTime.now();
    final basePrice = _sanitizePrice(variation.price);
    final nativeSalePrice = _resolveNativeSalePriceForVariation(
      variation: variation,
      at: now,
    );

    final bestOffer = _resolveBestOffer(
      product: product,
      variation: variation,
      basePrice: basePrice,
      offers: offers,
      at: now,
      fallbackToProductLevelOffers: fallbackToProductLevelOffers,
    );

    final offerStage = _chooseBestPrePromoPrice(
      basePrice: basePrice,
      nativeSalePrice: nativeSalePrice,
      bestOffer: bestOffer,
    );

    final promoResult = _resolvePromoCode(
      promoCode: promoCode,
      currentPrice: offerStage.price,
      cartSubtotal: cartSubtotal,
      at: now,
      userId: userId,
      allowOnDiscountedItems:
      allowPromoOnDiscountedItems || !offerStage.discountApplied,
    );

    final finalUnitPrice = promoResult?.resultPrice ?? offerStage.price;
    final totalDiscountAmount = _positiveOrZero(basePrice - finalUnitPrice);

    return MBResolvedPrice(
      ownerType: MBPricingOwnerType.variation,
      ownerId: variation.id,
      basePrice: basePrice,
      nativeSalePrice: nativeSalePrice,
      priceAfterOfferStage: offerStage.price,
      finalUnitPrice: finalUnitPrice,
      totalDiscountAmount: totalDiscountAmount,
      discountSource: promoResult != null
          ? MBResolvedDiscountSource.promoCode
          : offerStage.source,
      nativeSaleApplied: offerStage.nativeSaleApplied,
      offerApplied: offerStage.offerApplied,
      promoCodeApplied: promoResult != null,
      appliedOfferId: offerStage.offer?.id,
      appliedOfferTitle: offerStage.offer == null
          ? null
          : _safeOfferTitle(offerStage.offer!),
      appliedOfferScope: offerStage.offerScope,
      appliedPromoCode: promoResult?.promoCode.code,
      debugLabel: 'variation',
    );
  }

  static double _resolveNativeSalePriceForProduct({
    required MBProduct product,
    required DateTime at,
  }) {
    if (!_isNativeSaleActive(
      basePrice: product.price,
      salePrice: product.salePrice,
      saleStartsAt: product.saleStartsAt,
      saleEndsAt: product.saleEndsAt,
      at: at,
    )) {
      return _sanitizePrice(product.price);
    }

    return _sanitizePrice(product.salePrice ?? product.price);
  }

  static double _resolveNativeSalePriceForVariation({
    required MBProductVariation variation,
    required DateTime at,
  }) {
    if (!_isNativeSaleActive(
      basePrice: variation.price,
      salePrice: variation.salePrice,
      saleStartsAt: variation.saleStartsAt,
      saleEndsAt: variation.saleEndsAt,
      at: at,
    )) {
      return _sanitizePrice(variation.price);
    }

    return _sanitizePrice(variation.salePrice ?? variation.price);
  }

  static bool _isNativeSaleActive({
    required double basePrice,
    required double? salePrice,
    required DateTime? saleStartsAt,
    required DateTime? saleEndsAt,
    required DateTime at,
  }) {
    if (salePrice == null) return false;
    if (salePrice <= 0) return false;
    if (salePrice >= basePrice) return false;
    if (saleStartsAt != null && at.isBefore(saleStartsAt)) return false;
    if (saleEndsAt != null && at.isAfter(saleEndsAt)) return false;
    return true;
  }

  static MBAppliedOfferResult? _resolveBestOffer({
    required MBProduct product,
    required MBProductVariation? variation,
    required double basePrice,
    required Iterable<MBOffer> offers,
    required DateTime at,
    bool fallbackToProductLevelOffers = true,
  }) {
    MBAppliedOfferResult? winner;

    for (final offer in offers) {
      if (!_isOfferActive(offer, at)) continue;

      final scope = _matchOfferScope(
        offer: offer,
        product: product,
        variation: variation,
        fallbackToProductLevelOffers: fallbackToProductLevelOffers,
      );

      if (scope == MBResolvedOfferScope.none) continue;

      final resolvedPrice = _applyOfferToBasePrice(
        basePrice: basePrice,
        offer: offer,
      );

      if (resolvedPrice >= basePrice) continue;

      final discountAmount = _positiveOrZero(basePrice - resolvedPrice);

      final candidate = MBAppliedOfferResult(
        offer: offer,
        scope: scope,
        resultPrice: resolvedPrice,
        discountAmount: discountAmount,
      );

      if (_isBetterOfferCandidate(
        currentWinner: winner,
        candidate: candidate,
      )) {
        winner = candidate;
      }
    }

    return winner;
  }

  static bool _isOfferActive(MBOffer offer, DateTime at) {
    if (!offer.isActive) return false;
    if (offer.startAt != null && at.isBefore(offer.startAt!)) return false;
    if (offer.endAt != null && at.isAfter(offer.endAt!)) return false;
    return true;
  }

  static MBResolvedOfferScope _matchOfferScope({
    required MBOffer offer,
    required MBProduct product,
    required MBProductVariation? variation,
    required bool fallbackToProductLevelOffers,
  }) {
    if (variation != null) {
      final variationId = variation.id.trim();
      if (variationId.isNotEmpty && offer.productIds.contains(variationId)) {
        return MBResolvedOfferScope.variation;
      }

      if (fallbackToProductLevelOffers) {
        final productId = product.id.trim();
        if (productId.isNotEmpty && offer.productIds.contains(productId)) {
          return MBResolvedOfferScope.product;
        }
      }
    } else {
      final productId = product.id.trim();
      if (productId.isNotEmpty && offer.productIds.contains(productId)) {
        return MBResolvedOfferScope.product;
      }
    }

    final categoryId = (product.categoryId ?? '').trim();
    if (categoryId.isNotEmpty && offer.categoryIds.contains(categoryId)) {
      return MBResolvedOfferScope.category;
    }

    final brandId = (product.brandId ?? '').trim();
    if (brandId.isNotEmpty && offer.brandIds.contains(brandId)) {
      return MBResolvedOfferScope.brand;
    }

    return MBResolvedOfferScope.none;
  }

  static double _applyOfferToBasePrice({
    required double basePrice,
    required MBOffer offer,
  }) {
    final type = offer.offerType.trim().toLowerCase();
    final value = offer.offerValue;

    switch (type) {
      case 'percent':
        final percent = value.clamp(0, 100).toDouble();
        return _sanitizePrice(basePrice - ((basePrice * percent) / 100));

      case 'amount':
        return _sanitizePrice(basePrice - value);

      case 'promo_price':
        return _sanitizePrice(value);

      case 'free_delivery':
      case 'bundle':
      case 'custom':
      default:
        return basePrice;
    }
  }

  static bool _isBetterOfferCandidate({
    required MBAppliedOfferResult? currentWinner,
    required MBAppliedOfferResult candidate,
  }) {
    if (currentWinner == null) return true;

    final currentPriority = currentWinner.offer.sortOrder;
    final candidatePriority = candidate.offer.sortOrder;

    if (candidatePriority != currentPriority) {
      return candidatePriority < currentPriority;
    }

    if (candidate.resultPrice != currentWinner.resultPrice) {
      return candidate.resultPrice < currentWinner.resultPrice;
    }

    final candidateScopeRank = _scopeRank(candidate.scope);
    final currentScopeRank = _scopeRank(currentWinner.scope);
    if (candidateScopeRank != currentScopeRank) {
      return candidateScopeRank < currentScopeRank;
    }

    return candidate.offer.id.compareTo(currentWinner.offer.id) < 0;
  }

  static int _scopeRank(MBResolvedOfferScope scope) {
    switch (scope) {
      case MBResolvedOfferScope.variation:
        return 0;
      case MBResolvedOfferScope.product:
        return 1;
      case MBResolvedOfferScope.category:
        return 2;
      case MBResolvedOfferScope.brand:
        return 3;
      case MBResolvedOfferScope.none:
        return 4;
    }
  }

  static _MBPrePromoStage _chooseBestPrePromoPrice({
    required double basePrice,
    required double nativeSalePrice,
    required MBAppliedOfferResult? bestOffer,
  }) {
    final nativeSaleApplied = nativeSalePrice < basePrice;
    final offerApplied = bestOffer != null && bestOffer.resultPrice < basePrice;

    if (!nativeSaleApplied && !offerApplied) {
      return _MBPrePromoStage(
        price: basePrice,
        source: MBResolvedDiscountSource.none,
        nativeSaleApplied: false,
        offerApplied: false,
        offer: null,
        offerScope: MBResolvedOfferScope.none,
      );
    }

    if (nativeSaleApplied && !offerApplied) {
      return _MBPrePromoStage(
        price: nativeSalePrice,
        source: MBResolvedDiscountSource.nativeSale,
        nativeSaleApplied: true,
        offerApplied: false,
        offer: null,
        offerScope: MBResolvedOfferScope.none,
      );
    }

    if (!nativeSaleApplied && offerApplied) {
      return _MBPrePromoStage(
        price: bestOffer!.resultPrice,
        source: MBResolvedDiscountSource.offer,
        nativeSaleApplied: false,
        offerApplied: true,
        offer: bestOffer.offer,
        offerScope: bestOffer.scope,
      );
    }

    if (bestOffer!.resultPrice < nativeSalePrice) {
      return _MBPrePromoStage(
        price: bestOffer.resultPrice,
        source: MBResolvedDiscountSource.offer,
        nativeSaleApplied: false,
        offerApplied: true,
        offer: bestOffer.offer,
        offerScope: bestOffer.scope,
      );
    }

    return _MBPrePromoStage(
      price: nativeSalePrice,
      source: MBResolvedDiscountSource.nativeSale,
      nativeSaleApplied: true,
      offerApplied: false,
      offer: null,
      offerScope: MBResolvedOfferScope.none,
    );
  }

  static MBAppliedPromoResult? _resolvePromoCode({
    required MBPromoCode? promoCode,
    required double currentPrice,
    required double cartSubtotal,
    required DateTime at,
    required String? userId,
    required bool allowOnDiscountedItems,
  }) {
    if (promoCode == null) return null;
    if (!_isPromoCodeActive(promoCode, at)) return null;
    if (!_isPromoUserEligible(promoCode, userId)) return null;
    if (!_isPromoUsageAvailable(promoCode)) return null;

    final minimumOrderAmount = promoCode.minimumOrderAmount;
    if (minimumOrderAmount != null && cartSubtotal < minimumOrderAmount) {
      return null;
    }

    if (!allowOnDiscountedItems) {
      return null;
    }

    final resolvedPrice = _applyPromoToPrice(
      currentPrice: currentPrice,
      promoCode: promoCode,
    );

    if (resolvedPrice >= currentPrice) return null;

    return MBAppliedPromoResult(
      promoCode: promoCode,
      resultPrice: resolvedPrice,
      discountAmount: _positiveOrZero(currentPrice - resolvedPrice),
    );
  }

  static bool _isPromoCodeActive(MBPromoCode promoCode, DateTime at) {
    if (!promoCode.isActive) return false;
    if (promoCode.isArchived) return false;
    if (at.isAfter(promoCode.expirationDate)) return false;
    return true;
  }

  static bool _isPromoUserEligible(MBPromoCode promoCode, String? userId) {
    if (promoCode.eligibleUserIds.isEmpty) return true;
    if (userId == null || userId.trim().isEmpty) return false;
    return promoCode.eligibleUserIds.contains(userId.trim());
  }

  static bool _isPromoUsageAvailable(MBPromoCode promoCode) {
    final limit = promoCode.usageLimit;
    if (limit == null) return true;
    return promoCode.usageCount < limit;
  }

  static double _applyPromoToPrice({
    required double currentPrice,
    required MBPromoCode promoCode,
  }) {
    final type = promoCode.discountType.trim().toLowerCase();
    final value = promoCode.discountValue;

    switch (type) {
      case 'percent':
        final percent = value.clamp(0, 100).toDouble();
        final rawDiscount = (currentPrice * percent) / 100;
        final maxDiscount = promoCode.maximumDiscount;
        final discount = maxDiscount == null
            ? rawDiscount
            : (rawDiscount > maxDiscount ? maxDiscount : rawDiscount);
        return _sanitizePrice(currentPrice - discount);

      case 'amount':
        return _sanitizePrice(currentPrice - value);

      default:
        return currentPrice;
    }
  }

  static String _safeOfferTitle(MBOffer offer) {
    final titleEn = offer.titleEn.trim();
    if (titleEn.isNotEmpty) return titleEn;

    final titleBn = offer.titleBn.trim();
    if (titleBn.isNotEmpty) return titleBn;

    final badgeEn = offer.badgeTextEn.trim();
    if (badgeEn.isNotEmpty) return badgeEn;

    final badgeBn = offer.badgeTextBn.trim();
    if (badgeBn.isNotEmpty) return badgeBn;

    return offer.id;
  }

  static double _sanitizePrice(double value) {
    if (value.isNaN || value.isInfinite) return 0;
    return value < 0 ? 0 : value;
  }

  static double _positiveOrZero(double value) {
    return value < 0 ? 0 : value;
  }
}

class _MBPrePromoStage {
  const _MBPrePromoStage({
    required this.price,
    required this.source,
    required this.nativeSaleApplied,
    required this.offerApplied,
    required this.offer,
    required this.offerScope,
  });

  final double price;
  final MBResolvedDiscountSource source;
  final bool nativeSaleApplied;
  final bool offerApplied;
  final MBOffer? offer;
  final MBResolvedOfferScope offerScope;

  bool get discountApplied => nativeSaleApplied || offerApplied;
}