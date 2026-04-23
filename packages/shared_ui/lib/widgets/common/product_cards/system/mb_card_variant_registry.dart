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
    // Compact family
    MBCardVariant.compact01: _compactDefinition(
      variant: MBCardVariant.compact01,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: false,
      canChangeBorderEffect: false,
      canChangeMedia: false,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: false,
        effectPreset: 'none',
        effectIntensity: 0,
      ),
    ),
    MBCardVariant.compact02: _compactDefinition(
      variant: MBCardVariant.compact02,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: true,
      showAddToCart: false,
      showViewDetails: false,
      canChangeBorderEffect: true,
      canChangeMedia: true,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.compact03: _compactDefinition(
      variant: MBCardVariant.compact03,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: true,
      canChangeBorderEffect: true,
      canChangeMedia: true,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.compact04: _compactDefinition(
      variant: MBCardVariant.compact04,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: true,
      showViewDetails: true,
      canChangeBorderEffect: true,
      canChangeMedia: true,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.compact05: _compactDefinition(
      variant: MBCardVariant.compact05,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: true,
      canChangeBorderEffect: true,
      canChangeMedia: true,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),

    // Price family
    MBCardVariant.price01: _priceDefinition(
      variant: MBCardVariant.price01,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: false,
      canChangeActions: false,
      badgePlacement: 'top_right',
      showSavingsText: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.price02: _priceDefinition(
      variant: MBCardVariant.price02,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: false,
      canChangeActions: true,
      badgePlacement: 'top_right',
      showSavingsText: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.price03: _priceDefinition(
      variant: MBCardVariant.price03,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: true,
      showViewDetails: false,
      canChangeActions: true,
      badgePlacement: 'top_left',
      showSavingsText: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'deal_pulse',
        effectIntensity: 2,
      ),
    ),
    MBCardVariant.price04: _priceDefinition(
      variant: MBCardVariant.price04,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: false,
      canChangeActions: true,
      badgePlacement: 'top_left',
      showSavingsText: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.price05: _priceDefinition(
      variant: MBCardVariant.price05,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: false,
      canChangeActions: true,
      badgePlacement: 'top_left',
      showSavingsText: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),

    // Horizontal family
    MBCardVariant.horizontal01: _horizontalDefinition(
      variant: MBCardVariant.horizontal01,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      canChangeBorderEffect: false,
      badgePlacement: 'inline',
    ),
    MBCardVariant.horizontal02: _horizontalDefinition(
      variant: MBCardVariant.horizontal02,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: true,
      canChangeBorderEffect: true,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.horizontal03: _horizontalDefinition(
      variant: MBCardVariant.horizontal03,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: true,
      showViewDetails: true,
      canChangeBorderEffect: true,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'deal_pulse',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.horizontal04: _horizontalDefinition(
      variant: MBCardVariant.horizontal04,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: true,
      canChangeBorderEffect: true,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.horizontal05: _horizontalDefinition(
      variant: MBCardVariant.horizontal05,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: true,
      canChangeBorderEffect: true,
      badgePlacement: 'top_left',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),

    // Premium family
    MBCardVariant.premium01: _premiumDefinition(
      variant: MBCardVariant.premium01,
      showSubtitle: false,
      showBrand: true,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: false,
      badgePlacement: 'top_right',
      showImageShadow: false,
      canChangeActions: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'premium_outline',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.premium02: _premiumDefinition(
      variant: MBCardVariant.premium02,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: true,
      badgePlacement: 'top_right',
      showImageShadow: false,
      canChangeActions: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'premium_outline',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.premium03: _premiumDefinition(
      variant: MBCardVariant.premium03,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: true,
      showViewDetails: true,
      badgePlacement: 'top_left',
      showImageShadow: false,
      canChangeActions: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'premium_outline',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.premium04: _premiumDefinition(
      variant: MBCardVariant.premium04,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: true,
      badgePlacement: 'top_right',
      showImageShadow: false,
      canChangeActions: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'premium_outline',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.premium05: _premiumDefinition(
      variant: MBCardVariant.premium05,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: true,
      showViewDetails: true,
      badgePlacement: 'top_left',
      showImageShadow: false,
      canChangeActions: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),

    // Wide family
    MBCardVariant.wide01: _wideDefinition(
      variant: MBCardVariant.wide01,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      canChangeAccent: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: false,
        effectPreset: 'none',
        effectIntensity: 0,
      ),
    ),
    MBCardVariant.wide02: _wideDefinition(
      variant: MBCardVariant.wide02,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      canChangeAccent: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.wide03: _wideDefinition(
      variant: MBCardVariant.wide03,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      canChangeAccent: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.wide04: _wideDefinition(
      variant: MBCardVariant.wide04,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      canChangeAccent: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'deal_pulse',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.wide05: _wideDefinition(
      variant: MBCardVariant.wide05,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      canChangeAccent: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: false,
        effectPreset: 'none',
        effectIntensity: 0,
      ),
    ),

    // Featured family
    MBCardVariant.featured01: _featuredDefinition(
      variant: MBCardVariant.featured01,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.15,
      showPromoStrip: false,
      promoStripStyle: null,
      themeDecorationPreset: null,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: false,
        effectPreset: 'none',
        effectIntensity: 0,
      ),
    ),
    MBCardVariant.featured02: _featuredDefinition(
      variant: MBCardVariant.featured02,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.15,
      showPromoStrip: false,
      promoStripStyle: null,
      themeDecorationPreset: null,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.featured03: _featuredDefinition(
      variant: MBCardVariant.featured03,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.18,
      showPromoStrip: false,
      promoStripStyle: null,
      themeDecorationPreset: null,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.featured04: _featuredDefinition(
      variant: MBCardVariant.featured04,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.15,
      showPromoStrip: false,
      promoStripStyle: null,
      themeDecorationPreset: null,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'premium_outline',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.featured05: _featuredDefinition(
      variant: MBCardVariant.featured05,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.12,
      showPromoStrip: false,
      promoStripStyle: null,
      themeDecorationPreset: null,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: false,
        effectPreset: 'none',
        effectIntensity: 0,
      ),
    ),

    // Promo family
    MBCardVariant.promo01: _promoDefinition(
      variant: MBCardVariant.promo01,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      showPromoStrip: true,
      promoStripStyle: 'soft_ribbon',
      themeDecorationPreset: 'festive_warm',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: false,
        effectPreset: 'none',
        effectIntensity: 0,
      ),
    ),
    MBCardVariant.promo02: _promoDefinition(
      variant: MBCardVariant.promo02,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      showPromoStrip: true,
      promoStripStyle: 'soft_ribbon',
      themeDecorationPreset: 'festive_warm',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.promo03: _promoDefinition(
      variant: MBCardVariant.promo03,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      showPromoStrip: true,
      promoStripStyle: 'festive_ribbon',
      themeDecorationPreset: 'festive_warm',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.promo04: _promoDefinition(
      variant: MBCardVariant.promo04,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.1,
      showPromoStrip: false,
      promoStripStyle: null,
      themeDecorationPreset: 'festive_warm',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
    MBCardVariant.promo05: _promoDefinition(
      variant: MBCardVariant.promo05,
      showSubtitle: true,
      showBrand: true,
      showUnitLabel: false,
      showStockHint: false,
      showDeliveryHint: true,
      showAddToCart: false,
      showViewDetails: true,
      badgePlacement: 'top_left',
      imageEmphasis: 1.08,
      showPromoStrip: false,
      promoStripStyle: null,
      themeDecorationPreset: 'soft_story',
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: false,
        effectPreset: 'none',
        effectIntensity: 0,
      ),
    ),

    // Flash family
    MBCardVariant.flash01: _flashDefinition(
      variant: MBCardVariant.flash01,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: false,
      showViewDetails: false,
      badgePlacement: 'top_right',
      showSavingsText: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: false,
        effectPreset: 'none',
        effectIntensity: 0,
      ),
    ),
    MBCardVariant.flash02: _flashDefinition(
      variant: MBCardVariant.flash02,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: true,
      showViewDetails: false,
      badgePlacement: 'top_left',
      showSavingsText: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'deal_pulse',
        effectIntensity: 2,
      ),
    ),
    MBCardVariant.flash03: _flashDefinition(
      variant: MBCardVariant.flash03,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: true,
      showViewDetails: false,
      badgePlacement: 'top_right',
      showSavingsText: true,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'deal_pulse',
        effectIntensity: 2,
      ),
    ),
    MBCardVariant.flash04: _flashDefinition(
      variant: MBCardVariant.flash04,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: false,
      showStockHint: true,
      showDeliveryHint: false,
      showAddToCart: true,
      showViewDetails: false,
      badgePlacement: 'top_left',
      showSavingsText: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'fire',
        effectIntensity: 2,
      ),
    ),
    MBCardVariant.flash05: _flashDefinition(
      variant: MBCardVariant.flash05,
      showSubtitle: true,
      showBrand: false,
      showUnitLabel: true,
      showStockHint: false,
      showDeliveryHint: false,
      showAddToCart: true,
      showViewDetails: false,
      badgePlacement: 'top_left',
      showSavingsText: false,
      borderEffect: const MBCardBorderEffectSettings(
        showBorder: true,
        effectPreset: 'soft_glow',
        effectIntensity: 1,
      ),
    ),
  };

  static final List<MBCardVariant> _starterVariants =
  List<MBCardVariant>.unmodifiable(MBCardVariant.values);

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
    return MBCardVariantHelper.parse(raw, fallback: fallback);
  }

  static MBCardVariantDefinition _compactDefinition({
    required MBCardVariant variant,
    required bool showSubtitle,
    required bool showBrand,
    required bool showUnitLabel,
    required bool showStockHint,
    required bool showDeliveryHint,
    required bool showAddToCart,
    required bool showViewDetails,
    required bool canChangeBorderEffect,
    required bool canChangeMedia,
    required String badgePlacement,
    MBCardBorderEffectSettings? borderEffect,
  }) {
    return MBCardVariantDefinition(
      variant: variant,
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
        borderEffect: borderEffect,
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: true,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: showAddToCart,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: showViewDetails,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 14,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: badgePlacement,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: showSubtitle,
          showShortDescription: false,
          showBrand: showBrand,
          showUnitLabel: showUnitLabel,
          showStockHint: showStockHint,
          showDeliveryHint: showDeliveryHint,
          showRating: false,
        ),
      ),
      supportedSettings: MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: canChangeBorderEffect,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: canChangeMedia,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    );
  }

  static MBCardVariantDefinition _priceDefinition({
    required MBCardVariant variant,
    required bool showSubtitle,
    required bool showBrand,
    required bool showUnitLabel,
    required bool showStockHint,
    required bool showDeliveryHint,
    required bool showAddToCart,
    required bool showViewDetails,
    required bool canChangeActions,
    required String badgePlacement,
    required bool showSavingsText,
    MBCardBorderEffectSettings? borderEffect,
  }) {
    return MBCardVariantDefinition(
      variant: variant,
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
        borderEffect: borderEffect,
        price: MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalFinalAndDiscount,
          showDiscountBadge: true,
          showSavingsText: showSavingsText,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: showAddToCart,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: showViewDetails,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 14,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: badgePlacement,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: showSubtitle,
          showShortDescription: false,
          showBrand: showBrand,
          showUnitLabel: showUnitLabel,
          showStockHint: showStockHint,
          showDeliveryHint: showDeliveryHint,
          showRating: false,
        ),
      ),
      supportedSettings: MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: canChangeActions,
        canChangeMedia: false,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    );
  }

  static MBCardVariantDefinition _horizontalDefinition({
    required MBCardVariant variant,
    required bool showSubtitle,
    required bool showBrand,
    required bool showUnitLabel,
    required bool showStockHint,
    required bool showDeliveryHint,
    required bool showAddToCart,
    required bool showViewDetails,
    required bool canChangeBorderEffect,
    required String badgePlacement,
    MBCardBorderEffectSettings? borderEffect,
  }) {
    return MBCardVariantDefinition(
      variant: variant,
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
        borderEffect: borderEffect,
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: false,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: showAddToCart,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: showViewDetails,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 14,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: badgePlacement,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: showSubtitle,
          showShortDescription: false,
          showBrand: showBrand,
          showUnitLabel: showUnitLabel,
          showStockHint: showStockHint,
          showDeliveryHint: showDeliveryHint,
          showRating: false,
        ),
      ),
      supportedSettings: MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: canChangeBorderEffect,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    );
  }

  static MBCardVariantDefinition _premiumDefinition({
    required MBCardVariant variant,
    required bool showSubtitle,
    required bool showBrand,
    required bool showUnitLabel,
    required bool showStockHint,
    required bool showDeliveryHint,
    required bool showAddToCart,
    required bool showViewDetails,
    required String badgePlacement,
    required bool showImageShadow,
    required bool canChangeActions,
    MBCardBorderEffectSettings? borderEffect,
  }) {
    return MBCardVariantDefinition(
      variant: variant,
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
        borderEffect: borderEffect,
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: false,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: showAddToCart,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: showViewDetails,
        ),
        media: MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 16,
          imageOverlayOpacity: 0,
          showImageShadow: showImageShadow,
          imageEmphasis: 1,
        ),
        badges: MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: badgePlacement,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: showSubtitle,
          showShortDescription: false,
          showBrand: showBrand,
          showUnitLabel: showUnitLabel,
          showStockHint: showStockHint,
          showDeliveryHint: showDeliveryHint,
          showRating: false,
        ),
      ),
      supportedSettings: MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: false,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: canChangeActions,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    );
  }

  static MBCardVariantDefinition _wideDefinition({
    required MBCardVariant variant,
    required bool showSubtitle,
    required bool showBrand,
    required bool showUnitLabel,
    required bool showStockHint,
    required bool showDeliveryHint,
    required bool showAddToCart,
    required bool showViewDetails,
    required String badgePlacement,
    required double imageEmphasis,
    required bool canChangeAccent,
    MBCardBorderEffectSettings? borderEffect,
  }) {
    return MBCardVariantDefinition(
      variant: variant,
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
        borderEffect: borderEffect,
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: false,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: showAddToCart,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: showViewDetails,
        ),
        media: MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 16,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: imageEmphasis,
        ),
        badges: MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: badgePlacement,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: showSubtitle,
          showShortDescription: false,
          showBrand: showBrand,
          showUnitLabel: showUnitLabel,
          showStockHint: showStockHint,
          showDeliveryHint: showDeliveryHint,
          showRating: false,
        ),
      ),
      supportedSettings: MBCardSupportedSettings(
        canChangeSurface: true,
        canChangeTypography: true,
        canChangeAccent: canChangeAccent,
        canChangeBorderEffect: true,
        canChangePrice: true,
        canChangeActions: true,
        canChangeMedia: true,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    );
  }

  static MBCardVariantDefinition _featuredDefinition({
    required MBCardVariant variant,
    required bool showSubtitle,
    required bool showBrand,
    required bool showUnitLabel,
    required bool showStockHint,
    required bool showDeliveryHint,
    required bool showAddToCart,
    required bool showViewDetails,
    required String badgePlacement,
    required double imageEmphasis,
    required bool showPromoStrip,
    required String? promoStripStyle,
    required String? themeDecorationPreset,
    MBCardBorderEffectSettings? borderEffect,
  }) {
    return MBCardVariantDefinition(
      variant: variant,
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
        accent: MBCardAccentSettings(
          accentBarPosition: 'top',
          showAccentBar: false,
          showPromoStrip: showPromoStrip,
          promoStripStyle: promoStripStyle,
          themeDecorationPreset: themeDecorationPreset,
        ),
        borderEffect: borderEffect,
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: true,
          showSavingsText: false,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: showAddToCart,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: showViewDetails,
        ),
        media: MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 18,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: imageEmphasis,
        ),
        badges: MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: badgePlacement,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: showSubtitle,
          showShortDescription: false,
          showBrand: showBrand,
          showUnitLabel: showUnitLabel,
          showStockHint: showStockHint,
          showDeliveryHint: showDeliveryHint,
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
    );
  }

  static MBCardVariantDefinition _promoDefinition({
    required MBCardVariant variant,
    required bool showSubtitle,
    required bool showBrand,
    required bool showUnitLabel,
    required bool showStockHint,
    required bool showDeliveryHint,
    required bool showAddToCart,
    required bool showViewDetails,
    required String badgePlacement,
    required double imageEmphasis,
    required bool showPromoStrip,
    required String? promoStripStyle,
    required String? themeDecorationPreset,
    MBCardBorderEffectSettings? borderEffect,
  }) {
    return MBCardVariantDefinition(
      variant: variant,
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
        accent: MBCardAccentSettings(
          accentBarPosition: 'top',
          showAccentBar: false,
          showPromoStrip: showPromoStrip,
          promoStripStyle: promoStripStyle,
          themeDecorationPreset: themeDecorationPreset,
        ),
        borderEffect: borderEffect,
        price: const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalFinalAndDiscount,
          showDiscountBadge: true,
          showSavingsText: true,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: showAddToCart,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: showViewDetails,
        ),
        media: MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 18,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: imageEmphasis,
        ),
        badges: MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: badgePlacement,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: showSubtitle,
          showShortDescription: false,
          showBrand: showBrand,
          showUnitLabel: showUnitLabel,
          showStockHint: showStockHint,
          showDeliveryHint: showDeliveryHint,
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
    );
  }

  static MBCardVariantDefinition _flashDefinition({
    required MBCardVariant variant,
    required bool showSubtitle,
    required bool showBrand,
    required bool showUnitLabel,
    required bool showStockHint,
    required bool showDeliveryHint,
    required bool showAddToCart,
    required bool showViewDetails,
    required String badgePlacement,
    required bool showSavingsText,
    MBCardBorderEffectSettings? borderEffect,
  }) {
    return MBCardVariantDefinition(
      variant: variant,
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
        borderEffect: borderEffect,
        price: MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalFinalAndDiscount,
          showDiscountBadge: true,
          showSavingsText: showSavingsText,
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: showAddToCart,
          showQuickAdd: false,
          showWishlist: false,
          showViewDetails: showViewDetails,
        ),
        media: const MBCardMediaSettings(
          imageFitMode: 'cover',
          imageCornerRadius: 14,
          imageOverlayOpacity: 0,
          showImageShadow: false,
          imageEmphasis: 1,
        ),
        badges: MBCardBadgeSettings(
          showPrimaryBadge: true,
          showSecondaryBadge: false,
          badgePlacement: badgePlacement,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: showSubtitle,
          showShortDescription: false,
          showBrand: showBrand,
          showUnitLabel: showUnitLabel,
          showStockHint: showStockHint,
          showDeliveryHint: showDeliveryHint,
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
        canChangeMedia: false,
        canChangeBadges: true,
        canChangeMeta: true,
      ),
    );
  }
}