import '../config/mb_card_layout_settings.dart';
import 'mb_card_design_family.dart';
import 'mb_card_design_template.dart';
import 'mb_card_element_binding.dart';
import 'mb_card_element_config.dart';
import 'mb_card_element_type.dart';

// Lightweight model-side registry for V1 family/template defaults.
// The shared_ui renderer can use a richer registry later.

class MBCardDesignRegistry {
  const MBCardDesignRegistry._();

  static const String heroPosterCircleDiagonalV1 =
      'hero_poster_circle_diagonal_v1';
  static const String catalogFashionPanelTallV1 =
      'catalog_fashion_panel_tall_v1';
  static const String premiumProductTileGradientCtaV1 =
      'premium_product_tile_gradient_cta_v1';
  static const String promoVoucherCurveSplitV1 =
      'promo_voucher_curve_split_v1';
  static const String darkTechNeonPosterV1 = 'dark_tech_neon_poster_v1';
  static const String minimalCleanOutlinedV1 = 'minimal_clean_outlined_v1';

  static const List<MBCardDesignTemplate> templates = <MBCardDesignTemplate>[
    MBCardDesignTemplate(
      id: heroPosterCircleDiagonalV1,
      family: MBCardDesignFamily.heroPosterCircle,
      label: 'Diagonal Circle Hero',
      footprint: MBCardFootprintType.tallHalfWidth,
      description:
          'Diagonal hero panel with circular media and richer poster content.',
      defaultAspectRatio: 0.56,
      supportedElementIds: <String>[
        'backgroundPanel',
        'decorativeShape',
        'ribbon',
        'priceBadge',
        'promoBadge',
        'flashBadge',
        'brand',
        'categoryChip',
        'wishlistButton',
        'compareButton',
        'shareButton',
        'media',
        'imageFrame',
        'imageOverlay',
        'title',
        'subtitle',
        'rating',
        'reviewCount',
        'stockHint',
        'deliveryHint',
        'timer',
        'progressBar',
        'finalPrice',
        'originalPrice',
        'unitLabel',
        'savingBadge',
        'indicatorDots',
        'primaryCta',
        'secondaryCta',
        'borderEffect',
      ],
    ),
    MBCardDesignTemplate(
      id: catalogFashionPanelTallV1,
      family: MBCardDesignFamily.catalogFashionPanel,
      label: 'Tall Catalog Panel',
      footprint: MBCardFootprintType.tallHalfWidth,
      description: 'Fashion/catalog card with media, rating, options and CTA.',
      defaultAspectRatio: 0.42,
      supportedElementIds: <String>[
        'media',
        'categoryChip',
        'wishlistButton',
        'title',
        'subtitle',
        'rating',
        'finalPrice',
        'originalPrice',
        'sizeSelector',
        'colorSelector',
        'quantitySelector',
        'primaryCta',
      ],
    ),
    MBCardDesignTemplate(
      id: premiumProductTileGradientCtaV1,
      family: MBCardDesignFamily.premiumProductTile,
      label: 'Premium Gradient CTA',
      footprint: MBCardFootprintType.tallHalfWidth,
      description: 'Premium clean product card with gradient CTA.',
      defaultAspectRatio: 0.50,
      supportedElementIds: <String>[
        'premiumBadge',
        'wishlistButton',
        'viewButton',
        'media',
        'brand',
        'title',
        'subtitle',
        'finalPrice',
        'originalPrice',
        'primaryCta',
        'secondaryCta',
      ],
    ),
    MBCardDesignTemplate(
      id: promoVoucherCurveSplitV1,
      family: MBCardDesignFamily.promoVoucherBanner,
      label: 'Voucher Curve Split',
      footprint: MBCardFootprintType.wideBanner,
      description: 'Wide promotional voucher banner with curve split layout.',
      defaultAspectRatio: 2.40,
      supportedElementIds: <String>[
        'brand',
        'mediaGroup',
        'campaignTitle',
        'discountText',
        'subtitle',
        'description',
        'primaryCta',
        'decorativeShape',
      ],
    ),
    MBCardDesignTemplate(
      id: darkTechNeonPosterV1,
      family: MBCardDesignFamily.darkTechShowcase,
      label: 'Dark Neon Poster',
      footprint: MBCardFootprintType.heroPoster,
      description: 'Dark tech card with neon accents and product showcase.',
      defaultAspectRatio: 0.75,
      supportedElementIds: <String>[
        'media',
        'priceBadge',
        'title',
        'subtitle',
        'rating',
        'specList',
        'primaryCta',
        'decorativeShape',
      ],
    ),
    MBCardDesignTemplate(
      id: minimalCleanOutlinedV1,
      family: MBCardDesignFamily.minimalCleanTile,
      label: 'Minimal Outlined Tile',
      footprint: MBCardFootprintType.halfWidth,
      description: 'Clean outlined tile with media, title, price and CTA.',
      defaultAspectRatio: 0.62,
      supportedElementIds: <String>[
        'media',
        'title',
        'finalPrice',
        'unitLabel',
        'primaryCta',
        'borderEffect',
      ],
    ),
  ];

  static MBCardDesignTemplate? findTemplate(String templateId) {
    final normalized = templateId.trim();
    if (normalized.isEmpty) return null;

    for (final template in templates) {
      if (template.id == normalized) return template;
    }

    return null;
  }

  static List<MBCardDesignTemplate> templatesForFamily(
    MBCardDesignFamily family,
  ) {
    return templates
        .where((template) => template.family == family)
        .toList(growable: false);
  }

  static MBCardLayoutSettings defaultLayoutForTemplate(String templateId) {
    final template = findTemplate(templateId);
    if (template == null) {
      return const MBCardLayoutSettings(
        footprint: 'half_width',
        aspectRatio: 0.58,
        canShrink: true,
        canExpand: true,
        maxShrinkPercent: 7,
        maxExpandPercent: 12,
      );
    }

    return MBCardLayoutSettings(
      footprint: template.footprint.id,
      aspectRatio: template.defaultAspectRatio,
      preferredHeight: template.defaultPreferredHeight,
      minHeight: template.defaultMinHeight,
      maxHeight: template.defaultMaxHeight,
      canShrink: true,
      canExpand: true,
      maxShrinkPercent: 7,
      maxExpandPercent: 12,
    );
  }

  static Map<String, MBCardElementConfig> defaultElementsForTemplate(
    String templateId,
  ) {
    switch (templateId) {
      case heroPosterCircleDiagonalV1:
        return _heroPosterCircleElements;
      case catalogFashionPanelTallV1:
        return _catalogFashionElements;
      case premiumProductTileGradientCtaV1:
        return _premiumTileElements;
      case promoVoucherCurveSplitV1:
        return _promoVoucherElements;
      case darkTechNeonPosterV1:
        return _darkTechElements;
      case minimalCleanOutlinedV1:
        return _minimalCleanElements;
      default:
        return _heroPosterCircleElements;
    }
  }

  static Map<String, MBCardElementConfig> get _heroPosterCircleElements =>
      <String, MBCardElementConfig>{
        'backgroundPanel': _element(
          'backgroundPanel',
          MBCardElementType.backgroundPanel,
          'fullBackground',
          'panel_diagonal_orange_soft',
          '',
        ),
        'decorativeShape': _element(
          'decorativeShape',
          MBCardElementType.decorativeShape,
          'heroGlow',
          'shape_soft_circle',
          '',
        ),
        'ribbon': _element(
          'ribbon',
          MBCardElementType.ribbon,
          'topLeftOverlay',
          'ribbon_soft',
          'preset.ribbonText',
        ),
        'priceBadge': _element(
          'priceBadge',
          MBCardElementType.priceBadge,
          'topRightOverlay',
          'price_badge_round',
          'resolved.finalPrice',
        ),
        'promoBadge': _element(
          'promoBadge',
          MBCardElementType.promoBadge,
          'heroLowerLeft',
          'badge_promo_pill',
          'preset.promoLabel',
        ),
        'flashBadge': _element(
          'flashBadge',
          MBCardElementType.flashBadge,
          'heroLowerRight',
          'badge_flash_pill',
          'preset.flashLabel',
        ),
        'brand': _element(
          'brand',
          MBCardElementType.brand,
          'topTextStart',
          'brand_small_soft',
          'product.brandNameEn',
        ),
        'categoryChip': _element(
          'categoryChip',
          MBCardElementType.category,
          'belowBrand',
          'badge_outline_white',
          'product.categoryNameEn',
        ),
        'wishlistButton': _element(
          'wishlistButton',
          MBCardElementType.wishlistButton,
          'actionTop1',
          'icon_round_white',
          'action.wishlist',
        ),
        'compareButton': _element(
          'compareButton',
          MBCardElementType.compareButton,
          'actionTop2',
          'icon_round_white',
          'action.compare',
        ),
        'shareButton': _element(
          'shareButton',
          MBCardElementType.shareButton,
          'actionTop3',
          'icon_round_white',
          'action.share',
        ),
        'media': _element(
          'media',
          MBCardElementType.media,
          'centerHero',
          'media_circle',
          'product.thumbnailUrl',
        ),
        'imageFrame': _element(
          'imageFrame',
          MBCardElementType.imageFrame,
          'aroundMedia',
          'frame_circle_soft',
          '',
        ),
        'imageOverlay': _element(
          'imageOverlay',
          MBCardElementType.imageOverlay,
          'mediaBottomRight',
          'chip_save_small',
          'resolved.savingText',
        ),
        'title': _element(
          'title',
          MBCardElementType.title,
          'bodyTitle',
          'title_bold_italic',
          'product.titleEn',
        ),
        'subtitle': _element(
          'subtitle',
          MBCardElementType.subtitle,
          'bodySubtitle',
          'subtitle_compact_italic',
          'product.shortDescriptionEn',
        ),
        'rating': _element(
          'rating',
          MBCardElementType.rating,
          'metaLine1',
          'rating_stars_soft',
          'product.rating',
        ),
        'reviewCount': _element(
          'reviewCount',
          MBCardElementType.reviewCount,
          'metaLine1Right',
          'text_meta_small',
          'product.reviewCount',
        ),
        'stockHint': _element(
          'stockHint',
          MBCardElementType.stockHint,
          'metaLine2Left',
          'chip_soft_success',
          'resolved.stockHint',
        ),
        'deliveryHint': _element(
          'deliveryHint',
          MBCardElementType.deliveryHint,
          'metaLine2Right',
          'chip_soft_info',
          'resolved.deliveryHint',
        ),
        'timer': _element(
          'timer',
          MBCardElementType.timer,
          'metaLine3Left',
          'timer_soft',
          'resolved.timerText',
        ),
        'progressBar': _element(
          'progressBar',
          MBCardElementType.progressBar,
          'metaLine3Right',
          'progress_soft',
          'resolved.progressValue',
        ),
        'finalPrice': _element(
          'finalPrice',
          MBCardElementType.finalPrice,
          'priceRowStart',
          'price_plain_large',
          'resolved.finalPrice',
        ),
        'originalPrice': _element(
          'originalPrice',
          MBCardElementType.originalPrice,
          'priceRowMiddle',
          'price_old_small',
          'resolved.oldPrice',
        ),
        'unitLabel': _element(
          'unitLabel',
          MBCardElementType.unitLabel,
          'priceRowEnd',
          'unit_soft',
          'product.unit',
        ),
        'savingBadge': _element(
          'savingBadge',
          MBCardElementType.savingText,
          'priceRowBadge',
          'badge_discount_pill',
          'resolved.savingText',
        ),
        'indicatorDots': _element(
          'indicatorDots',
          MBCardElementType.indicatorDots,
          'bottomLeftSecondary',
          'dots_soft',
          '',
        ),
        'primaryCta': _element(
          'primaryCta',
          MBCardElementType.primaryCta,
          'bottomRightMain',
          'cta_pill_solid',
          'action.addToCart',
        ),
        'secondaryCta': _element(
          'secondaryCta',
          MBCardElementType.secondaryCta,
          'bottomRightSecondary',
          'cta_pill_outline',
          'action.buyNow',
        ),
        'borderEffect': _element(
          'borderEffect',
          MBCardElementType.borderEffect,
          'fullOutline',
          'border_soft',
          '',
        ),
      };

  static Map<String, MBCardElementConfig> get _catalogFashionElements =>
      <String, MBCardElementConfig>{
        'media': _element(
          'media',
          MBCardElementType.media,
          'topMedia',
          'media_rounded_rect',
          'product.thumbnailUrl',
        ),
        'categoryChip': _element(
          'categoryChip',
          MBCardElementType.category,
          'belowMediaLeft',
          'badge_minimal_outline',
          'product.categoryNameEn',
        ),
        'wishlistButton': _element(
          'wishlistButton',
          MBCardElementType.wishlistButton,
          'belowMediaRight',
          'icon_heart_filled',
          'action.wishlist',
        ),
        'title': _element(
          'title',
          MBCardElementType.title,
          'bodyTop',
          'title_fashion_blue',
          'product.titleEn',
        ),
        'subtitle': _element(
          'subtitle',
          MBCardElementType.subtitle,
          'belowTitle',
          'subtitle_clean',
          'product.shortDescriptionEn',
        ),
        'rating': _element(
          'rating',
          MBCardElementType.rating,
          'belowSubtitle',
          'rating_stars_yellow',
          'product.rating',
        ),
        'finalPrice': _element(
          'finalPrice',
          MBCardElementType.finalPrice,
          'priceLeft',
          'price_plain_large',
          'resolved.finalPrice',
        ),
        'quantitySelector': _element(
          'quantitySelector',
          MBCardElementType.quantitySelector,
          'priceRight',
          'quantity_stepper_soft',
          'cart.quantity',
        ),
        'primaryCta': _element(
          'primaryCta',
          MBCardElementType.primaryCta,
          'bottomBar',
          'cta_full_width_bar',
          'action.addToCart',
        ),
      };

  static Map<String, MBCardElementConfig> get _premiumTileElements =>
      <String, MBCardElementConfig>{
        'premiumBadge': _element(
          'premiumBadge',
          MBCardElementType.promoBadge,
          'topLeftOverlay',
          'badge_premium',
          'preset.premiumLabel',
        ),
        'wishlistButton': _element(
          'wishlistButton',
          MBCardElementType.wishlistButton,
          'topRightOverlay',
          'icon_heart_outline',
          'action.wishlist',
        ),
        'media': _element(
          'media',
          MBCardElementType.media,
          'topMedia',
          'media_shadowed',
          'product.thumbnailUrl',
        ),
        'brand': _element(
          'brand',
          MBCardElementType.brand,
          'bodyTop',
          'brand_small',
          'product.brandNameEn',
        ),
        'title': _element(
          'title',
          MBCardElementType.title,
          'belowBrand',
          'title_clean_medium',
          'product.titleEn',
        ),
        'finalPrice': _element(
          'finalPrice',
          MBCardElementType.finalPrice,
          'priceLeft',
          'price_plain_large',
          'resolved.finalPrice',
        ),
        'primaryCta': _element(
          'primaryCta',
          MBCardElementType.primaryCta,
          'bottomLeft',
          'cta_gradient_bar',
          'action.buyNow',
        ),
        'secondaryCta': _element(
          'secondaryCta',
          MBCardElementType.secondaryCta,
          'bottomRight',
          'cta_icon_cart',
          'action.addToCart',
        ),
      };

  static Map<String, MBCardElementConfig> get _promoVoucherElements =>
      <String, MBCardElementConfig>{
        'brand': _element(
          'brand',
          MBCardElementType.brand,
          'topLeft',
          'brand_campaign',
          'product.brandNameEn',
        ),
        'mediaGroup': _element(
          'mediaGroup',
          MBCardElementType.media,
          'leftHero',
          'media_group_showcase',
          'product.mediaGroup',
        ),
        'campaignTitle': _element(
          'campaignTitle',
          MBCardElementType.title,
          'rightTop',
          'title_campaign_large',
          'campaign.title',
        ),
        'discountText': _element(
          'discountText',
          MBCardElementType.savingText,
          'rightCenter',
          'discount_huge',
          'campaign.discountText',
        ),
      };

  static Map<String, MBCardElementConfig> get _darkTechElements =>
      <String, MBCardElementConfig>{
        'media': _element(
          'media',
          MBCardElementType.media,
          'centerHero',
          'media_floating_hero',
          'product.thumbnailUrl',
        ),
        'priceBadge': _element(
          'priceBadge',
          MBCardElementType.priceBadge,
          'topRight',
          'price_dark_neon',
          'resolved.finalPrice',
        ),
        'title': _element(
          'title',
          MBCardElementType.title,
          'bottomLeft',
          'title_neon_tech',
          'product.titleEn',
        ),
        'primaryCta': _element(
          'primaryCta',
          MBCardElementType.primaryCta,
          'bottomCenter',
          'cta_dark_glow',
          'action.addToCart',
        ),
      };

  static Map<String, MBCardElementConfig> get _minimalCleanElements =>
      <String, MBCardElementConfig>{
        'media': _element(
          'media',
          MBCardElementType.media,
          'topCenter',
          'media_square_soft',
          'product.thumbnailUrl',
        ),
        'title': _element(
          'title',
          MBCardElementType.title,
          'bodyLeft',
          'title_minimal_dark',
          'product.titleEn',
        ),
        'finalPrice': _element(
          'finalPrice',
          MBCardElementType.finalPrice,
          'belowTitle',
          'price_plain_small',
          'resolved.finalPrice',
        ),
        'primaryCta': _element(
          'primaryCta',
          MBCardElementType.primaryCta,
          'bottomFull',
          'cta_pill_outline',
          'action.chooseOptions',
        ),
      };

  static MBCardElementConfig _element(
    String id,
    MBCardElementType type,
    String slot,
    String stylePreset,
    String binding,
  ) {
    return MBCardElementConfig(
      elementId: id,
      type: type,
      slot: slot,
      stylePreset: stylePreset,
      binding:
          binding.isEmpty ? null : MBCardElementBinding(source: binding),
    );
  }
}
