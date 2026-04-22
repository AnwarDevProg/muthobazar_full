// MuthoBazar Product Card Design System
// File: mb_card_config_resolver.dart
// Location: packages/shared_ui/lib/widgets/common/product_cards/system/mb_card_config_resolver.dart
//
// Purpose:
// Resolves a card instance configuration into a registry-backed effective
// variant definition and a fully merged settings bundle.
//
// This resolver is responsible for combining:
// - variant registry defaults
// - optional preset defaults (future integration point)
// - instance-level overrides
//
// Important:
// - This file belongs to shared_ui because it is part of the rendering layer.
// - It should not contain concrete widget builder logic.
// - Token-to-Color/TextStyle resolution is also not handled here; that belongs
//   to later token resolver files.
// - This resolver produces a stable settings object that widgets can consume.

import 'package:shared_models/product_cards/config/product_card_config.dart';

import 'mb_card_variant_registry.dart';

class MBResolvedCardConfig {
  const MBResolvedCardConfig({
    required this.instance,
    required this.definition,
    required this.surface,
    required this.typography,
    required this.accent,
    required this.borderEffect,
    required this.price,
    required this.actions,
    required this.media,
    required this.badges,
    required this.meta,
  });

  final MBCardInstanceConfig instance;
  final MBCardVariantDefinition definition;
  final MBCardSurfaceSettings surface;
  final MBCardTypographySettings typography;
  final MBCardAccentSettings accent;
  final MBCardBorderEffectSettings borderEffect;
  final MBCardPriceSettings price;
  final MBCardActionSettings actions;
  final MBCardMediaSettings media;
  final MBCardBadgeSettings badges;
  final MBCardMetaSettings meta;

  MBCardVariant get variant => definition.variant;

  MBCardFamily get family => definition.family;

  MBCardFootprint get footprint => definition.footprint;

  bool get supportsAnyCustomization => definition.supportsAnyCustomization;

  bool get hasPreset => instance.hasPreset;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'instance': instance.toMap(),
      'definition': definition.toMap(),
      'surface': surface.toMap(),
      'typography': typography.toMap(),
      'accent': accent.toMap(),
      'borderEffect': borderEffect.toMap(),
      'price': price.toMap(),
      'actions': actions.toMap(),
      'media': media.toMap(),
      'badges': badges.toMap(),
      'meta': meta.toMap(),
    };
  }
}

class MBCardConfigResolver {
  const MBCardConfigResolver._();

  static MBResolvedCardConfig resolve(
      MBCardInstanceConfig instance, {
        MBCardVariantDefinition? definitionOverride,
      }) {
    final normalizedInstance = instance.normalized();
    final definition = definitionOverride ??
        MBCardVariantRegistry.definitionFor(normalizedInstance.variant);
    final normalizedDefinition = definition.normalized();

    final defaults = normalizedDefinition.defaults;
    final overrides = normalizedInstance.settings;

    // Future preset integration point:
    // final presetSettings = MBCardPresetRegistry.settingsFor(
    //   normalizedInstance.presetId,
    //   fallbackVariant: normalizedDefinition.variant,
    // );
    // For now presets are intentionally not resolved yet.

    final surface = _mergeSurface(
      base: defaults.surface ?? const MBCardSurfaceSettings(),
      override: overrides.surface,
    );
    final typography = _mergeTypography(
      base: defaults.typography ?? const MBCardTypographySettings(),
      override: overrides.typography,
    );
    final accent = _mergeAccent(
      base: defaults.accent ?? const MBCardAccentSettings(),
      override: overrides.accent,
    );
    final borderEffect = _mergeBorderEffect(
      base: defaults.borderEffect ?? const MBCardBorderEffectSettings(),
      override: overrides.borderEffect,
    );
    final price = _mergePrice(
      base: defaults.price ?? const MBCardPriceSettings(),
      override: overrides.price,
    );
    final actions = _mergeActions(
      base: defaults.actions ?? const MBCardActionSettings(),
      override: overrides.actions,
    );
    final media = _mergeMedia(
      base: defaults.media ?? const MBCardMediaSettings(),
      override: overrides.media,
    );
    final badges = _mergeBadges(
      base: defaults.badges ?? const MBCardBadgeSettings(),
      override: overrides.badges,
    );
    final meta = _mergeMeta(
      base: defaults.meta ?? const MBCardMetaSettings(),
      override: overrides.meta,
    );

    return MBResolvedCardConfig(
      instance: normalizedInstance,
      definition: normalizedDefinition,
      surface: surface,
      typography: typography,
      accent: accent,
      borderEffect: borderEffect,
      price: price,
      actions: actions,
      media: media,
      badges: badges,
      meta: meta,
    );
  }

  static MBCardVariantDefinition definitionForVariant(MBCardVariant variant) {
    return MBCardVariantRegistry.definitionFor(variant);
  }

  static MBResolvedCardConfig resolveByVariant(
      MBCardVariant variant, {
        String? presetId,
        MBCardSettingsOverride settings = const MBCardSettingsOverride(),
      }) {
    final definition = MBCardVariantRegistry.definitionFor(variant);

    return resolve(
      MBCardInstanceConfig(
        family: definition.family,
        variant: variant,
        presetId: presetId,
        settings: settings,
      ),
      definitionOverride: definition,
    );
  }

  static MBResolvedCardConfig resolveByVariantId(
      String variantId, {
        String? presetId,
        MBCardSettingsOverride settings = const MBCardSettingsOverride(),
        MBCardVariant fallback = MBCardVariant.compact01,
      }) {
    final variant = MBCardVariantHelper.parse(variantId);
    return resolveByVariant(
      variant,
      presetId: presetId,
      settings: settings,
    );
  }

  static MBCardSurfaceSettings _mergeSurface({
    required MBCardSurfaceSettings base,
    MBCardSurfaceSettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      backgroundColorToken: override.backgroundColorToken,
      backgroundGradientToken: override.backgroundGradientToken,
      borderRadius: override.borderRadius,
      elevationLevel: override.elevationLevel,
      useGlassEffect: override.useGlassEffect,
      use3DEffect: override.use3DEffect,
      threeDDepth: override.threeDDepth,
      paddingScale: override.paddingScale,
    );
  }

  static MBCardTypographySettings _mergeTypography({
    required MBCardTypographySettings base,
    MBCardTypographySettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      titleColorToken: override.titleColorToken,
      subtitleColorToken: override.subtitleColorToken,
      priceColorToken: override.priceColorToken,
      oldPriceColorToken: override.oldPriceColorToken,
      titleStyleToken: override.titleStyleToken,
      subtitleStyleToken: override.subtitleStyleToken,
      titleMaxLines: override.titleMaxLines,
      subtitleMaxLines: override.subtitleMaxLines,
      titleBold: override.titleBold,
      priceBold: override.priceBold,
    );
  }

  static MBCardAccentSettings _mergeAccent({
    required MBCardAccentSettings base,
    MBCardAccentSettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      accentBarPosition: override.accentBarPosition,
      accentColorToken: override.accentColorToken,
      showAccentBar: override.showAccentBar,
      showPromoStrip: override.showPromoStrip,
      promoStripStyle: override.promoStripStyle,
      promoStripColorToken: override.promoStripColorToken,
      themeDecorationPreset: override.themeDecorationPreset,
    );
  }

  static MBCardBorderEffectSettings _mergeBorderEffect({
    required MBCardBorderEffectSettings base,
    MBCardBorderEffectSettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      showBorder: override.showBorder,
      borderColorToken: override.borderColorToken,
      borderWidth: override.borderWidth,
      effectPreset: override.effectPreset,
      effectIntensity: override.effectIntensity,
    );
  }

  static MBCardPriceSettings _mergePrice({
    required MBCardPriceSettings base,
    MBCardPriceSettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      priceMode: override.priceMode,
      showDiscountBadge: override.showDiscountBadge,
      showSavingsText: override.showSavingsText,
      emphasizeFinalPrice: override.emphasizeFinalPrice,
      showCurrencySymbol: override.showCurrencySymbol,
      discountBadgeStyle: override.discountBadgeStyle,
    );
  }

  static MBCardActionSettings _mergeActions({
    required MBCardActionSettings base,
    MBCardActionSettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      showAddToCart: override.showAddToCart,
      showQuickAdd: override.showQuickAdd,
      showWishlist: override.showWishlist,
      showViewDetails: override.showViewDetails,
      ctaStylePreset: override.ctaStylePreset,
      ctaColorToken: override.ctaColorToken,
    );
  }

  static MBCardMediaSettings _mergeMedia({
    required MBCardMediaSettings base,
    MBCardMediaSettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      imageFitMode: override.imageFitMode,
      imageCornerRadius: override.imageCornerRadius,
      imageOverlayOpacity: override.imageOverlayOpacity,
      showImageShadow: override.showImageShadow,
      imageFrameStyle: override.imageFrameStyle,
      imageEmphasis: override.imageEmphasis,
    );
  }

  static MBCardBadgeSettings _mergeBadges({
    required MBCardBadgeSettings base,
    MBCardBadgeSettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      showPrimaryBadge: override.showPrimaryBadge,
      showSecondaryBadge: override.showSecondaryBadge,
      primaryBadgeStyle: override.primaryBadgeStyle,
      secondaryBadgeStyle: override.secondaryBadgeStyle,
      badgePlacement: override.badgePlacement,
    );
  }

  static MBCardMetaSettings _mergeMeta({
    required MBCardMetaSettings base,
    MBCardMetaSettings? override,
  }) {
    if (override == null) {
      return base;
    }

    return base.copyWith(
      showSubtitle: override.showSubtitle,
      showShortDescription: override.showShortDescription,
      showBrand: override.showBrand,
      showUnitLabel: override.showUnitLabel,
      showStockHint: override.showStockHint,
      showDeliveryHint: override.showDeliveryHint,
      showRating: override.showRating,
    );
  }
}
