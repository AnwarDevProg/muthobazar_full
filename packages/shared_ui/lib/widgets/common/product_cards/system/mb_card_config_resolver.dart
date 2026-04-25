// MuthoBazar Product Card Design System
// File: mb_card_config_resolver.dart
// Location: packages/shared_ui/lib/widgets/common/product_cards/system/mb_card_config_resolver.dart
//
// Purpose:
// Resolves a card instance configuration into a registry-backed effective
// variant definition and a fully merged settings bundle.

import 'package:shared_models/product_cards/config/product_card_config.dart';

import 'mb_card_variant_registry.dart';

class MBResolvedCardConfig {
  const MBResolvedCardConfig({
    required this.instance,
    required this.definition,
    required this.surface,
    required this.layout,
    required this.background,
    required this.typography,
    required this.accent,
    required this.borderEffect,
    required this.price,
    required this.actions,
    required this.media,
    required this.badges,
    required this.meta,
    required this.stock,
    required this.delivery,
    required this.rating,
    required this.quantity,
    required this.timer,
    required this.progress,
    required this.indicator,
    required this.ribbon,
    required this.animation,
  });

  final MBCardInstanceConfig instance;
  final MBCardVariantDefinition definition;

  final MBCardSurfaceSettings surface;
  final MBCardLayoutSettings layout;
  final MBCardBackgroundSettings background;
  final MBCardTypographySettings typography;
  final MBCardAccentSettings accent;
  final MBCardBorderEffectSettings borderEffect;
  final MBCardPriceSettings price;
  final MBCardActionSettings actions;
  final MBCardMediaSettings media;
  final MBCardBadgeSettings badges;
  final MBCardMetaSettings meta;
  final MBCardStockSettings stock;
  final MBCardDeliverySettings delivery;
  final MBCardRatingSettings rating;
  final MBCardQuantitySettings quantity;
  final MBCardTimerSettings timer;
  final MBCardProgressSettings progress;
  final MBCardIndicatorSettings indicator;
  final MBCardRibbonSettings ribbon;
  final MBCardAnimationSettings animation;

  MBCardVariant get variant => definition.variant;
  MBCardFamily get family => definition.family;
  MBCardFootprint get footprint => definition.footprint;
  bool get supportsAnyCustomization => definition.supportsAnyCustomization;
  bool get hasPreset => instance.hasPreset;

  Map toMap() {
    return {
      'instance': instance.toMap(),
      'definition': definition.toMap(),
      'surface': surface.toMap(),
      'layout': layout.toMap(),
      'background': background.toMap(),
      'typography': typography.toMap(),
      'accent': accent.toMap(),
      'borderEffect': borderEffect.toMap(),
      'price': price.toMap(),
      'actions': actions.toMap(),
      'media': media.toMap(),
      'badges': badges.toMap(),
      'meta': meta.toMap(),
      'stock': stock.toMap(),
      'delivery': delivery.toMap(),
      'rating': rating.toMap(),
      'quantity': quantity.toMap(),
      'timer': timer.toMap(),
      'progress': progress.toMap(),
      'indicator': indicator.toMap(),
      'ribbon': ribbon.toMap(),
      'animation': animation.toMap(),
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
    final definition =
        definitionOverride ??
        MBCardVariantRegistry.definitionFor(normalizedInstance.variant);
    final normalizedDefinition = definition.normalized();

    final defaults = normalizedDefinition.defaults;
    final overrides = normalizedInstance.settings;

    return MBResolvedCardConfig(
      instance: normalizedInstance,
      definition: normalizedDefinition,
      surface: _mergeSurface(
        base: defaults.surface ?? const MBCardSurfaceSettings(),
        override: overrides.surface,
      ),
      layout: _mergeLayout(
        base: defaults.layout ?? const MBCardLayoutSettings(),
        override: overrides.layout,
      ),
      background: _mergeBackground(
        base: defaults.background ?? const MBCardBackgroundSettings(),
        override: overrides.background,
      ),
      typography: _mergeTypography(
        base: defaults.typography ?? const MBCardTypographySettings(),
        override: overrides.typography,
      ),
      accent: _mergeAccent(
        base: defaults.accent ?? const MBCardAccentSettings(),
        override: overrides.accent,
      ),
      borderEffect: _mergeBorderEffect(
        base: defaults.borderEffect ?? const MBCardBorderEffectSettings(),
        override: overrides.borderEffect,
      ),
      price: _mergePrice(
        base: defaults.price ?? const MBCardPriceSettings(),
        override: overrides.price,
      ),
      actions: _mergeActions(
        base: defaults.actions ?? const MBCardActionSettings(),
        override: overrides.actions,
      ),
      media: _mergeMedia(
        base: defaults.media ?? const MBCardMediaSettings(),
        override: overrides.media,
      ),
      badges: _mergeBadges(
        base: defaults.badges ?? const MBCardBadgeSettings(),
        override: overrides.badges,
      ),
      meta: _mergeMeta(
        base: defaults.meta ?? const MBCardMetaSettings(),
        override: overrides.meta,
      ),
      stock: overrides.stock ?? defaults.stock ?? const MBCardStockSettings(),
      delivery: overrides.delivery ??
          defaults.delivery ??
          const MBCardDeliverySettings(),
      rating: overrides.rating ?? defaults.rating ?? const MBCardRatingSettings(),
      quantity: overrides.quantity ??
          defaults.quantity ??
          const MBCardQuantitySettings(),
      timer: overrides.timer ?? defaults.timer ?? const MBCardTimerSettings(),
      progress: overrides.progress ??
          defaults.progress ??
          const MBCardProgressSettings(),
      indicator: overrides.indicator ??
          defaults.indicator ??
          const MBCardIndicatorSettings(),
      ribbon: overrides.ribbon ?? defaults.ribbon ?? const MBCardRibbonSettings(),
      animation: overrides.animation ??
          defaults.animation ??
          const MBCardAnimationSettings(),
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
    final variant = MBCardVariantHelper.parse(
      variantId,
      fallback: fallback,
    );

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
    if (override == null) return base;

    return base.copyWith(
      backgroundColorToken: override.backgroundColorToken,
      backgroundGradientToken: override.backgroundGradientToken,
      borderRadius: override.borderRadius,
      cornerStyle: override.cornerStyle,
      elevationLevel: override.elevationLevel,
      useGlassEffect: override.useGlassEffect,
      use3DEffect: override.use3DEffect,
      threeDDepth: override.threeDDepth,
      paddingScale: override.paddingScale,
      showShadow: override.showShadow,
      shadowStyleToken: override.shadowStyleToken,
      surfaceOpacity: override.surfaceOpacity,
      borderClipBehavior: override.borderClipBehavior,
    );
  }

  static MBCardLayoutSettings _mergeLayout({
    required MBCardLayoutSettings base,
    MBCardLayoutSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      footprint: override.footprint,
      aspectRatio: override.aspectRatio,
      minHeight: override.minHeight,
      maxHeight: override.maxHeight,
      contentAlignment: override.contentAlignment,
      imagePosition: override.imagePosition,
      pricePosition: override.pricePosition,
      ctaPosition: override.ctaPosition,
      sectionGap: override.sectionGap,
    );
  }

  static MBCardBackgroundSettings _mergeBackground({
    required MBCardBackgroundSettings base,
    MBCardBackgroundSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      showTopPanel: override.showTopPanel,
      topPanelColorToken: override.topPanelColorToken,
      topPanelGradientToken: override.topPanelGradientToken,
      panelShape: override.panelShape,
      panelHeightRatio: override.panelHeightRatio,
      diagonalStartRatio: override.diagonalStartRatio,
      diagonalEndRatio: override.diagonalEndRatio,
      showPattern: override.showPattern,
      patternToken: override.patternToken,
      patternOpacity: override.patternOpacity,
    );
  }

  static MBCardTypographySettings _mergeTypography({
    required MBCardTypographySettings base,
    MBCardTypographySettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      titleColorToken: override.titleColorToken,
      subtitleColorToken: override.subtitleColorToken,
      priceColorToken: override.priceColorToken,
      oldPriceColorToken: override.oldPriceColorToken,
      metaColorToken: override.metaColorToken,
      titleStyleToken: override.titleStyleToken,
      subtitleStyleToken: override.subtitleStyleToken,
      priceStyleToken: override.priceStyleToken,
      metaStyleToken: override.metaStyleToken,
      titleMaxLines: override.titleMaxLines,
      subtitleMaxLines: override.subtitleMaxLines,
      titleMinFontSize: override.titleMinFontSize,
      subtitleMinFontSize: override.subtitleMinFontSize,
      titleFontSize: override.titleFontSize,
      subtitleFontSize: override.subtitleFontSize,
      priceFontSize: override.priceFontSize,
      oldPriceFontSize: override.oldPriceFontSize,
      titleAutoShrink: override.titleAutoShrink,
      subtitleAutoShrink: override.subtitleAutoShrink,
      titleBold: override.titleBold,
      priceBold: override.priceBold,
      italicTitle: override.italicTitle,
      italicSubtitle: override.italicSubtitle,
      titleLineHeight: override.titleLineHeight,
      subtitleLineHeight: override.subtitleLineHeight,
      priceLineHeight: override.priceLineHeight,
    );
  }

  static MBCardAccentSettings _mergeAccent({
    required MBCardAccentSettings base,
    MBCardAccentSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      accentBarPosition: override.accentBarPosition,
      accentColorToken: override.accentColorToken,
      showAccentBar: override.showAccentBar,
      showPromoStrip: override.showPromoStrip,
      promoStripStyle: override.promoStripStyle,
      promoStripColorToken: override.promoStripColorToken,
      themeDecorationPreset: override.themeDecorationPreset,
      accentIntensity: override.accentIntensity,
      showIndicatorDots: override.showIndicatorDots,
      indicatorDotColorToken: override.indicatorDotColorToken,
      indicatorDotCount: override.indicatorDotCount,
    );
  }

  static MBCardBorderEffectSettings _mergeBorderEffect({
    required MBCardBorderEffectSettings base,
    MBCardBorderEffectSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      showBorder: override.showBorder,
      borderColorToken: override.borderColorToken,
      borderWidth: override.borderWidth,
      borderRadiusOffset: override.borderRadiusOffset,
      effectPreset: override.effectPreset,
      effectIntensity: override.effectIntensity,
      animateEffect: override.animateEffect,
      effectSpeedMs: override.effectSpeedMs,
      effectColorToken: override.effectColorToken,
    );
  }

  static MBCardPriceSettings _mergePrice({
    required MBCardPriceSettings base,
    MBCardPriceSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      priceMode: override.priceMode,
      showDiscountBadge: override.showDiscountBadge,
      showSavingsText: override.showSavingsText,
      emphasizeFinalPrice: override.emphasizeFinalPrice,
      showCurrencySymbol: override.showCurrencySymbol,
      showOriginalPriceWhenSaleActive: override.showOriginalPriceWhenSaleActive,
      savingsDisplayMode: override.savingsDisplayMode,
      showPriceBadge: override.showPriceBadge,
      discountBadgeStyle: override.discountBadgeStyle,
      priceBadgeStyleToken: override.priceBadgeStyleToken,
      priceBadgeBackgroundToken: override.priceBadgeBackgroundToken,
      priceBadgeTextColorToken: override.priceBadgeTextColorToken,
      finalPricePrefix: override.finalPricePrefix,
      finalPriceSuffix: override.finalPriceSuffix,
    );
  }

  static MBCardActionSettings _mergeActions({
    required MBCardActionSettings base,
    MBCardActionSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      showAddToCart: override.showAddToCart,
      showBuyNow: override.showBuyNow,
      showQuickAdd: override.showQuickAdd,
      showWishlist: override.showWishlist,
      showViewDetails: override.showViewDetails,
      showCompare: override.showCompare,
      showShare: override.showShare,
      ctaText: override.ctaText,
      ctaStylePreset: override.ctaStylePreset,
      ctaColorToken: override.ctaColorToken,
      ctaTextColorToken: override.ctaTextColorToken,
      ctaIcon: override.ctaIcon,
      primaryCtaPosition: override.primaryCtaPosition,
    );
  }

  static MBCardMediaSettings _mergeMedia({
    required MBCardMediaSettings base,
    MBCardMediaSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      imageFitMode: override.imageFitMode,
      imageShape: override.imageShape,
      imageCornerRadius: override.imageCornerRadius,
      imageOverlayOpacity: override.imageOverlayOpacity,
      showImageShadow: override.showImageShadow,
      imageFrameStyle: override.imageFrameStyle,
      imageBackgroundToken: override.imageBackgroundToken,
      imageEmphasis: override.imageEmphasis,
      imageSizeRatio: override.imageSizeRatio,
      imageTopRatio: override.imageTopRatio,
      imageLeftRatio: override.imageLeftRatio,
      imageRingThickness: override.imageRingThickness,
      showImageFrame: override.showImageFrame,
      enableImageZoom: override.enableImageZoom,
    );
  }

  static MBCardBadgeSettings _mergeBadges({
    required MBCardBadgeSettings base,
    MBCardBadgeSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      showPrimaryBadge: override.showPrimaryBadge,
      showSecondaryBadge: override.showSecondaryBadge,
      showDiscountBadge: override.showDiscountBadge,
      showNewBadge: override.showNewBadge,
      showBestSellerBadge: override.showBestSellerBadge,
      showFlashBadge: override.showFlashBadge,
      primaryBadgeText: override.primaryBadgeText,
      secondaryBadgeText: override.secondaryBadgeText,
      primaryBadgeStyle: override.primaryBadgeStyle,
      secondaryBadgeStyle: override.secondaryBadgeStyle,
      badgePlacement: override.badgePlacement,
      badgeColorToken: override.badgeColorToken,
      badgeTextColorToken: override.badgeTextColorToken,
      discountBadgeTextMode: override.discountBadgeTextMode,
    );
  }

  static MBCardMetaSettings _mergeMeta({
    required MBCardMetaSettings base,
    MBCardMetaSettings? override,
  }) {
    if (override == null) return base;

    return base.copyWith(
      showSubtitle: override.showSubtitle,
      showShortDescription: override.showShortDescription,
      showBrand: override.showBrand,
      showCategory: override.showCategory,
      showUnitLabel: override.showUnitLabel,
      showStockHint: override.showStockHint,
      showDeliveryHint: override.showDeliveryHint,
      showRating: override.showRating,
      showReviewCount: override.showReviewCount,
      showSku: override.showSku,
      showProductCode: override.showProductCode,
    );
  }
}
