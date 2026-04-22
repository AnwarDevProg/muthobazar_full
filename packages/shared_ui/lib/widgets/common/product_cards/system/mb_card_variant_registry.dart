// MuthoBazar Product Card Design System
// File: mb_card_variant_registry.dart
// Location: packages/shared_ui/lib/widgets/common/product_cards/system/mb_card_variant_registry.dart
//
// Purpose:
// Central registry for product card variant definitions.
//
// This file provides a single source of truth for:
// - which variants currently exist
// - which family each variant belongs to
// - which footprint each variant uses by default
// - which default settings bundle applies to each variant
// - which settings groups each variant is allowed to expose/customize
//
// Important:
// - This is a shared_ui registry file, not a persistence model.
// - The actual widget builder mapping belongs in router / renderer files.
// - Defaults here should stay aligned with the design documentation.

import 'package:shared_models/product_cards/config/product_card_config.dart';

class MBCardVariantRegistry {
  const MBCardVariantRegistry._();

  static final Map<MBCardVariant, MBCardVariantDefinition> _definitions =
  <MBCardVariant, MBCardVariantDefinition>{
    MBCardVariant.compact01: MBCardVariantDefinition(
      variant: MBCardVariant.compact01,
      family: MBCardFamily.compact,
      footprint: MBCardFootprint.halfWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 18,
          elevationLevel: 1,
          paddingScale: 1,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: true,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: const MBCardActionSettings(
          showAddToCart: false,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: false,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 14,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'top_left',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: false,
          showBrand: false,
          showUnitLabel: true,
          showStockHint: false,
          showDeliveryHint: false,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: false,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: false,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),

    MBCardVariant.compact02: MBCardVariantDefinition(
      variant: MBCardVariant.compact02,
      family: MBCardFamily.compact,
      footprint: MBCardFootprint.halfWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 18,
          elevationLevel: 1,
          paddingScale: 1,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: true,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: const MBCardActionSettings(
          showAddToCart: false,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: false,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 14,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'top_left',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: false,
          showBrand: true,
          showUnitLabel: true,
          showStockHint: true,
          showDeliveryHint: true,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),

    MBCardVariant.price01: MBCardVariantDefinition(
      variant: MBCardVariant.price01,
      family: MBCardFamily.price,
      footprint: MBCardFootprint.halfWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 18,
          elevationLevel: 1,
          paddingScale: 1,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalFinalAndDiscount,
          showDiscountBadge: true,
          showSavingsText: true,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'top_right',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: false,
          showBrand: false,
          showUnitLabel: true,
          showStockHint: true,
          showDeliveryHint: false,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: false,
        canChangeMedia: false,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),

    MBCardVariant.horizontal01: MBCardVariantDefinition(
      variant: MBCardVariant.horizontal01,
      family: MBCardFamily.horizontal,
      footprint: MBCardFootprint.fullWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 18,
          elevationLevel: 1,
          paddingScale: 1,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: false,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: const MBCardActionSettings(
          showAddToCart: false,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: true,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 14,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'inline',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: false,
          showBrand: false,
          showUnitLabel: true,
          showStockHint: false,
          showDeliveryHint: false,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: false,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),

    MBCardVariant.premium01: MBCardVariantDefinition(
      variant: MBCardVariant.premium01,
      family: MBCardFamily.premium,
      footprint: MBCardFootprint.halfWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 20,
          elevationLevel: 1,
          paddingScale: 1,
          useGlassEffect: false,
          use3DEffect: false,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: false,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 16,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'top_right',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: false,
          showShortDescription: false,
          showBrand: true,
          showUnitLabel: false,
          showStockHint: false,
          showDeliveryHint: false,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: false,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),

    MBCardVariant.wide01: MBCardVariantDefinition(
      variant: MBCardVariant.wide01,
      family: MBCardFamily.wide,
      footprint: MBCardFootprint.fullWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 20,
          elevationLevel: 1,
          paddingScale: 1,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: false,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: const MBCardActionSettings(
          showAddToCart: false,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: true,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 16,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1.1,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'top_left',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: false,
          showBrand: false,
          showUnitLabel: true,
          showStockHint: false,
          showDeliveryHint: false,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: false,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),

    MBCardVariant.featured01: MBCardVariantDefinition(
      variant: MBCardVariant.featured01,
      family: MBCardFamily.featured,
      footprint: MBCardFootprint.fullWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 22,
          elevationLevel: 1,
          paddingScale: 1,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        accent: const MBCardAccentSettings(
          accentBarPosition: 'top',
          showAccentBar: false,
          showPromoStrip: false,
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: true,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: const MBCardActionSettings(
          showAddToCart: false,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: true,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 18,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1.15,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'top_left',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: false,
          showBrand: false,
          showUnitLabel: true,
          showStockHint: false,
          showDeliveryHint: false,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: true,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),

    MBCardVariant.promo01: MBCardVariantDefinition(
      variant: MBCardVariant.promo01,
      family: MBCardFamily.promo,
      footprint: MBCardFootprint.fullWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 22,
          elevationLevel: 1,
          paddingScale: 1,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        accent: const MBCardAccentSettings(
          accentBarPosition: 'top',
          showAccentBar: false,
          showPromoStrip: true,
          promoStripStyle: 'soft_ribbon',
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalFinalAndDiscount,
          showDiscountBadge: true,
          showSavingsText: true,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: const MBCardActionSettings(
          showAddToCart: false,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: true,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 18,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1.1,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'top_left',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: false,
          showBrand: false,
          showUnitLabel: true,
          showStockHint: false,
          showDeliveryHint: false,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: true,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),

    MBCardVariant.flash01: MBCardVariantDefinition(
      variant: MBCardVariant.flash01,
      family: MBCardFamily.flashSale,
      footprint: MBCardFootprint.halfWidth,
      defaults: MBCardSettingsOverride(
        surface: const MBCardSurfaceSettings(
          borderRadius: 18,
          elevationLevel: 1,
          paddingScale: 1,
        ),
        typography: const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 1,
          titleBold: true,
          priceBold: true,
        ),
        accent: const MBCardAccentSettings(
          accentBarPosition: 'top',
          showAccentBar: false,
          showPromoStrip: false,
        ),
        borderEffect: const MBCardBorderEffectSettings(
          showBorder: false,
          effectPreset: 'none',
          effectIntensity: 0,
        ),
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalFinalAndDiscount,
          showDiscountBadge: true,
          showSavingsText: true,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 14,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: const MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: 'top_right',
        ),
        meta: const MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: false,
          showBrand: false,
          showUnitLabel: true,
          showStockHint: true,
          showDeliveryHint: false,
          showRating: false,
        ),
      ),
      supportedSettings: const MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: true,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: false,
        canChangeMedia: false,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    ),
  };

  static const List<MBCardVariant> _starterVariants = <MBCardVariant>[
    MBCardVariant.compact01,
    MBCardVariant.compact02,
    MBCardVariant.price01,
    MBCardVariant.horizontal01,
    MBCardVariant.premium01,
    MBCardVariant.wide01,
    MBCardVariant.featured01,
    MBCardVariant.promo01,
    MBCardVariant.flash01,
  ];

  static List<MBCardVariantDefinition> all() {
    return _definitions.values.toList(growable: false);
  }

  static List<MBCardVariantDefinition> starterDefinitions() {
    return _starterVariants.map(definitionFor).toList(growable: false);
  }

  static MBCardVariantDefinition definitionFor(MBCardVariant variant) {
    final definition = _definitions[variant];
    if (definition == null) {
      throw StateError(
        'Missing card variant definition for variant: ${variant.id}',
      );
    }
    return definition;
  }

  static MBCardVariantDefinition definitionById(
      String variantId, {
        MBCardVariant fallback = MBCardVariant.compact01,
      }) {
    final variant = _parseVariantId(variantId, fallback: fallback);
    return definitionFor(variant);
  }

  static bool hasVariant(MBCardVariant variant) {
    return _definitions.containsKey(variant);
  }

  static bool hasVariantId(String? variantId) {
    if (variantId == null || variantId.trim().isEmpty) {
      return false;
    }
    final variant = _parseVariantId(variantId, fallback: fallbackVariant);
    return _definitions.containsKey(variant) && variant.id == variantId.trim();
  }

  static List<MBCardVariantDefinition> byFamily(MBCardFamily family) {
    return _definitions.values
        .where((definition) => definition.family == family)
        .toList(growable: false);
  }

  static List<MBCardVariant> variantsByFamily(MBCardFamily family) {
    return byFamily(family)
        .map((definition) => definition.variant)
        .toList(growable: false);
  }

  static List<MBCardVariantDefinition> byFootprint(MBCardFootprint footprint) {
    return _definitions.values
        .where((definition) => definition.footprint == footprint)
        .toList(growable: false);
  }

  static List<MBCardVariantDefinition> customizableDefinitions() {
    return _definitions.values
        .where((definition) => definition.supportsAnyCustomization)
        .toList(growable: false);
  }

  static Map<MBCardFamily, List<MBCardVariantDefinition>> groupedByFamily() {
    final map = <MBCardFamily, List<MBCardVariantDefinition>>{};
    for (final definition in _definitions.values) {
      map.putIfAbsent(definition.family, () => <MBCardVariantDefinition>[])
          .add(definition);
    }

    return map.map(
          (key, value) => MapEntry(
        key,
        List<MBCardVariantDefinition>.unmodifiable(value),
      ),
    );
  }

  static MBCardVariant get fallbackVariant => MBCardVariant.compact01;

  static MBCardVariant _parseVariantId(
      String raw, {
        MBCardVariant fallback = MBCardVariant.compact01,
      }) {
    final value = raw.trim().toLowerCase();

    switch (value) {
      case 'compact01':
        return MBCardVariant.compact01;
      case 'compact02':
        return MBCardVariant.compact02;
      case 'price01':
        return MBCardVariant.price01;
      case 'horizontal01':
        return MBCardVariant.horizontal01;
      case 'premium01':
        return MBCardVariant.premium01;
      case 'wide01':
        return MBCardVariant.wide01;
      case 'featured01':
        return MBCardVariant.featured01;
      case 'promo01':
        return MBCardVariant.promo01;
      case 'flash01':
        return MBCardVariant.flash01;
      default:
        return fallback;
    }
  }
}