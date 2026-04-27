// MuthoBazar Product Card Design System V1
// Design-family identities. A family describes visual language, not only size.

enum MBCardDesignFamily {
  heroPosterCircle,
  catalogFashionPanel,
  premiumProductTile,
  promoVoucherBanner,
  darkTechShowcase,
  minimalCleanTile,
  custom,
}

extension MBCardDesignFamilyX on MBCardDesignFamily {
  String get id {
    switch (this) {
      case MBCardDesignFamily.heroPosterCircle:
        return 'hero_poster_circle';
      case MBCardDesignFamily.catalogFashionPanel:
        return 'catalog_fashion_panel';
      case MBCardDesignFamily.premiumProductTile:
        return 'premium_product_tile';
      case MBCardDesignFamily.promoVoucherBanner:
        return 'promo_voucher_banner';
      case MBCardDesignFamily.darkTechShowcase:
        return 'dark_tech_showcase';
      case MBCardDesignFamily.minimalCleanTile:
        return 'minimal_clean_tile';
      case MBCardDesignFamily.custom:
        return 'custom';
    }
  }

  String get label {
    switch (this) {
      case MBCardDesignFamily.heroPosterCircle:
        return 'Hero Poster Circle';
      case MBCardDesignFamily.catalogFashionPanel:
        return 'Catalog Fashion Panel';
      case MBCardDesignFamily.premiumProductTile:
        return 'Premium Product Tile';
      case MBCardDesignFamily.promoVoucherBanner:
        return 'Promo Voucher Banner';
      case MBCardDesignFamily.darkTechShowcase:
        return 'Dark Tech Showcase';
      case MBCardDesignFamily.minimalCleanTile:
        return 'Minimal Clean Tile';
      case MBCardDesignFamily.custom:
        return 'Custom';
    }
  }
}

class MBCardDesignFamilyHelper {
  const MBCardDesignFamilyHelper._();

  static MBCardDesignFamily parse(
    Object? value, {
    MBCardDesignFamily fallback = MBCardDesignFamily.heroPosterCircle,
  }) {
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return fallback;

    for (final family in MBCardDesignFamily.values) {
      if (family.id == normalized || family.name.toLowerCase() == normalized) {
        return family;
      }
    }

    switch (normalized) {
      case 'compact':
      case 'compact01':
      case 'hero':
      case 'poster':
      case 'hero_poster':
        return MBCardDesignFamily.heroPosterCircle;
      case 'compact02':
      case 'fashion':
      case 'catalog':
      case 'shop_catalog':
        return MBCardDesignFamily.catalogFashionPanel;
      case 'premium':
      case 'perfume':
      case 'beauty':
        return MBCardDesignFamily.premiumProductTile;
      case 'wide':
      case 'banner':
      case 'voucher':
      case 'promo':
        return MBCardDesignFamily.promoVoucherBanner;
      case 'dark':
      case 'tech':
      case 'neon':
        return MBCardDesignFamily.darkTechShowcase;
      case 'minimal':
      case 'clean':
      case 'simple':
        return MBCardDesignFamily.minimalCleanTile;
      default:
        return fallback;
    }
  }
}
