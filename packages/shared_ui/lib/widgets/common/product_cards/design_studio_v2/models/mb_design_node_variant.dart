import 'package:flutter/material.dart';

// MuthoBazar Design Studio V2 Node Variant Registry
// ------------------------------------------------
// Patch 1 shell registry.
// Later patches will expand this with renderer-specific variant builders.

class MBDesignNodeVariant {
  const MBDesignNodeVariant({
    required this.id,
    required this.elementType,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String id;
  final String elementType;
  final String label;
  final String description;
  final IconData icon;
}

class MBDesignNodeVariantRegistry {
  const MBDesignNodeVariantRegistry._();

  static const List<MBDesignNodeVariant> all = <MBDesignNodeVariant>[
    MBDesignNodeVariant(
      id: 'text_basic',
      elementType: 'title',
      label: 'Title Text',
      description: 'Simple product title text.',
      icon: Icons.title_rounded,
    ),
    MBDesignNodeVariant(
      id: 'text_italic',
      elementType: 'title',
      label: 'Italic Title',
      description: 'Bold italic title for poster cards.',
      icon: Icons.format_italic_rounded,
    ),
    MBDesignNodeVariant(
      id: 'chip_title',
      elementType: 'title',
      label: 'Title Chip',
      description: 'Title inside a rounded chip.',
      icon: Icons.label_rounded,
    ),
    MBDesignNodeVariant(
      id: 'text_small',
      elementType: 'subtitle',
      label: 'Subtitle Text',
      description: 'Small product description text.',
      icon: Icons.short_text_rounded,
    ),
    MBDesignNodeVariant(
      id: 'soft_chip',
      elementType: 'subtitle',
      label: 'Subtitle Chip',
      description: 'Description inside a subtle chip.',
      icon: Icons.sticky_note_2_rounded,
    ),
    MBDesignNodeVariant(
      id: 'circle_ring',
      elementType: 'media',
      label: 'Circle Image',
      description: 'Circular product image with ring.',
      icon: Icons.circle_outlined,
    ),
    MBDesignNodeVariant(
      id: 'rounded_rect',
      elementType: 'media',
      label: 'Rounded Image',
      description: 'Rounded rectangular media block.',
      icon: Icons.crop_square_rounded,
    ),
    MBDesignNodeVariant(
      id: 'circle_top_right',
      elementType: 'priceBadge',
      label: 'Price Bubble',
      description: 'Circular price badge.',
      icon: Icons.paid_rounded,
    ),
    MBDesignNodeVariant(
      id: 'pill_price',
      elementType: 'priceBadge',
      label: 'Price Pill',
      description: 'Pill-shaped price badge.',
      icon: Icons.sell_rounded,
    ),
    MBDesignNodeVariant(
      id: 'pill_button',
      elementType: 'secondaryCta',
      label: 'Pill Button',
      description: 'Rounded CTA button.',
      icon: Icons.touch_app_rounded,
    ),
    MBDesignNodeVariant(
      id: 'flat_button',
      elementType: 'secondaryCta',
      label: 'Flat Button',
      description: 'Compact flat CTA.',
      icon: Icons.smart_button_rounded,
    ),
    MBDesignNodeVariant(
      id: 'soft_chip',
      elementType: 'deliveryHint',
      label: 'Delivery Chip',
      description: 'Small delivery information chip.',
      icon: Icons.local_shipping_rounded,
    ),
    MBDesignNodeVariant(
      id: 'soft_chip',
      elementType: 'timer',
      label: 'Timer Chip',
      description: 'Time or countdown chip.',
      icon: Icons.timer_rounded,
    ),
    MBDesignNodeVariant(
      id: 'soft_chip',
      elementType: 'promoBadge',
      label: 'Promo Chip',
      description: 'Promotion or discount badge.',
      icon: Icons.local_offer_rounded,
    ),
  ];

  static List<MBDesignNodeVariant> byElementType(String elementType) {
    return [
      for (final variant in all)
        if (variant.elementType == elementType) variant,
    ];
  }

  static Map<String, List<MBDesignNodeVariant>> grouped() {
    final result = <String, List<MBDesignNodeVariant>>{};

    for (final variant in all) {
      result.putIfAbsent(variant.elementType, () => <MBDesignNodeVariant>[]);
      result[variant.elementType]!.add(variant);
    }

    return result;
  }

  static MBDesignNodeVariant? find(String elementType, String variantId) {
    for (final variant in all) {
      if (variant.elementType == elementType && variant.id == variantId) {
        return variant;
      }
    }

    return null;
  }

  static String labelForElementType(String elementType) {
    switch (elementType) {
      case 'title':
        return 'Title';
      case 'subtitle':
        return 'Subtitle';
      case 'media':
        return 'Product image';
      case 'priceBadge':
        return 'Price';
      case 'secondaryCta':
      case 'primaryCta':
        return 'Button';
      case 'deliveryHint':
        return 'Delivery';
      case 'timer':
        return 'Timer';
      case 'promoBadge':
        return 'Promo badge';
      default:
        return elementType;
    }
  }
}
