// Configurable visible element types for the V1 design-card engine.

enum MBCardElementType {
  surface,
  backgroundPanel,
  decorativeShape,
  media,
  imageFrame,
  imageOverlay,
  title,
  subtitle,
  brand,
  category,
  unitLabel,
  finalPrice,
  originalPrice,
  savingText,
  priceBadge,
  promoBadge,
  flashBadge,
  stockHint,
  deliveryHint,
  rating,
  reviewCount,
  wishlistButton,
  compareButton,
  shareButton,
  primaryCta,
  secondaryCta,
  quantitySelector,
  timer,
  progressBar,
  indicatorDots,
  ribbon,
  borderEffect,
  animation,
  custom,
}

extension MBCardElementTypeX on MBCardElementType {
  String get id {
    switch (this) {
      case MBCardElementType.surface:
        return 'surface';
      case MBCardElementType.backgroundPanel:
        return 'background_panel';
      case MBCardElementType.decorativeShape:
        return 'decorative_shape';
      case MBCardElementType.media:
        return 'media';
      case MBCardElementType.imageFrame:
        return 'image_frame';
      case MBCardElementType.imageOverlay:
        return 'image_overlay';
      case MBCardElementType.title:
        return 'title';
      case MBCardElementType.subtitle:
        return 'subtitle';
      case MBCardElementType.brand:
        return 'brand';
      case MBCardElementType.category:
        return 'category';
      case MBCardElementType.unitLabel:
        return 'unit_label';
      case MBCardElementType.finalPrice:
        return 'final_price';
      case MBCardElementType.originalPrice:
        return 'original_price';
      case MBCardElementType.savingText:
        return 'saving_text';
      case MBCardElementType.priceBadge:
        return 'price_badge';
      case MBCardElementType.promoBadge:
        return 'promo_badge';
      case MBCardElementType.flashBadge:
        return 'flash_badge';
      case MBCardElementType.stockHint:
        return 'stock_hint';
      case MBCardElementType.deliveryHint:
        return 'delivery_hint';
      case MBCardElementType.rating:
        return 'rating';
      case MBCardElementType.reviewCount:
        return 'review_count';
      case MBCardElementType.wishlistButton:
        return 'wishlist_button';
      case MBCardElementType.compareButton:
        return 'compare_button';
      case MBCardElementType.shareButton:
        return 'share_button';
      case MBCardElementType.primaryCta:
        return 'primary_cta';
      case MBCardElementType.secondaryCta:
        return 'secondary_cta';
      case MBCardElementType.quantitySelector:
        return 'quantity_selector';
      case MBCardElementType.timer:
        return 'timer';
      case MBCardElementType.progressBar:
        return 'progress_bar';
      case MBCardElementType.indicatorDots:
        return 'indicator_dots';
      case MBCardElementType.ribbon:
        return 'ribbon';
      case MBCardElementType.borderEffect:
        return 'border_effect';
      case MBCardElementType.animation:
        return 'animation';
      case MBCardElementType.custom:
        return 'custom';
    }
  }
}

class MBCardElementTypeHelper {
  const MBCardElementTypeHelper._();

  static MBCardElementType parse(Object? value, {MBCardElementType fallback = MBCardElementType.custom}) {
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return fallback;

    for (final type in MBCardElementType.values) {
      if (type.id == normalized || type.name.toLowerCase() == normalized) return type;
    }

    switch (normalized) {
      case 'background':
        return MBCardElementType.backgroundPanel;
      case 'image':
      case 'picture':
      case 'product_image':
        return MBCardElementType.media;
      case 'old_price':
      case 'regular_price':
        return MBCardElementType.originalPrice;
      case 'price':
        return MBCardElementType.finalPrice;
      case 'cta':
      case 'button':
      case 'main_cta':
        return MBCardElementType.primaryCta;
      case 'dots':
      case 'indicators':
        return MBCardElementType.indicatorDots;
      case 'border':
      case 'outer_line':
        return MBCardElementType.borderEffect;
      default:
        return fallback;
    }
  }
}
