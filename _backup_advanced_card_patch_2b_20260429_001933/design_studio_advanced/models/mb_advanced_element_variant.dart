// MuthoBazar Advanced Product Card Design Studio
// Patch 1 element/variant catalog.
//
// Purpose:
// - Defines expandable left-drawer groups.
// - Each group owns several visual variants.
// - Variants provide default node binding, position, size, and style.
// - Card variants patch the selected card layout/palette instead of creating nodes.

import 'mb_advanced_card_design_document.dart';

class MBAdvancedElementVariant {
  const MBAdvancedElementVariant({
    required this.id,
    required this.groupId,
    required this.elementType,
    required this.title,
    required this.description,
    required this.binding,
    required this.defaultPosition,
    required this.defaultSize,
    required this.defaultStyle,
    this.cardLayoutPatch = const <String, dynamic>{},
    this.cardPalettePatch = const <String, dynamic>{},
  });

  final String id;
  final String groupId;
  final String elementType;
  final String title;
  final String description;
  final String binding;
  final MBAdvancedDesignNodePosition defaultPosition;
  final MBAdvancedDesignNodeSize defaultSize;
  final Map<String, dynamic> defaultStyle;
  final Map<String, dynamic> cardLayoutPatch;
  final Map<String, dynamic> cardPalettePatch;

  bool get isCardVariant => elementType == 'card';
}

class MBAdvancedElementGroup {
  const MBAdvancedElementGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.variants,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<MBAdvancedElementVariant> variants;
}

class MBAdvancedElementCatalog {
  const MBAdvancedElementCatalog._();

  static List<MBAdvancedElementGroup> groups() {
    return const <MBAdvancedElementGroup>[
      MBAdvancedElementGroup(
        id: 'card',
        title: 'Card',
        subtitle: 'Card body, size, radius and background',
        variants: <MBAdvancedElementVariant>[
          MBAdvancedElementVariant(
            id: 'card_orange_gradient',
            groupId: 'card',
            elementType: 'card',
            title: 'Orange poster',
            description: 'Tall orange gradient product card',
            binding: 'card',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.5, y: 0.5),
            defaultSize: MBAdvancedDesignNodeSize(width: 240, height: 380),
            defaultStyle: <String, dynamic>{},
            cardLayoutPatch: <String, dynamic>{
              'cardWidth': 240.0,
              'cardHeight': 380.0,
              'borderRadius': 28.0,
            },
            cardPalettePatch: <String, dynamic>{
              'presetId': 'orangeGradient',
              'backgroundHex': '#FF6500',
              'backgroundHex2': '#FF9A3D',
              'surfaceHex': '#FFFFFF',
            },
          ),
          MBAdvancedElementVariant(
            id: 'card_white_soft',
            groupId: 'card',
            elementType: 'card',
            title: 'White soft',
            description: 'White product card with orange accents',
            binding: 'card',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.5, y: 0.5),
            defaultSize: MBAdvancedDesignNodeSize(width: 240, height: 340),
            defaultStyle: <String, dynamic>{},
            cardLayoutPatch: <String, dynamic>{
              'cardWidth': 240.0,
              'cardHeight': 340.0,
              'borderRadius': 24.0,
            },
            cardPalettePatch: <String, dynamic>{
              'presetId': 'whiteSoft',
              'backgroundHex': '#FFFFFF',
              'backgroundHex2': '#FFFFFF',
              'surfaceHex': '#FFF3EB',
            },
          ),
          MBAdvancedElementVariant(
            id: 'card_compact_row',
            groupId: 'card',
            elementType: 'card',
            title: 'Compact row',
            description: 'Short wide card for full-width grid rows',
            binding: 'card',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.5, y: 0.5),
            defaultSize: MBAdvancedDesignNodeSize(width: 330, height: 170),
            defaultStyle: <String, dynamic>{},
            cardLayoutPatch: <String, dynamic>{
              'cardWidth': 330.0,
              'cardHeight': 170.0,
              'borderRadius': 24.0,
            },
            cardPalettePatch: <String, dynamic>{
              'presetId': 'compactOrange',
              'backgroundHex': '#FFF6EF',
              'backgroundHex2': '#FFE5D1',
              'surfaceHex': '#FFFFFF',
            },
          ),
        ],
      ),
      MBAdvancedElementGroup(
        id: 'title',
        title: 'Title',
        subtitle: 'Product name text and chip variants',
        variants: <MBAdvancedElementVariant>[
          MBAdvancedElementVariant(
            id: 'title_text_bold',
            groupId: 'title',
            elementType: 'title',
            title: 'Text',
            description: 'Bold product title text',
            binding: 'product.titleEn',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.12, y: 0.12, z: 20),
            defaultSize: MBAdvancedDesignNodeSize(width: 184, height: 48),
            defaultStyle: <String, dynamic>{
              'textColorHex': '#FFFFFF',
              'fontSize': 20.0,
              'fontWeight': 'w900',
              'textAlign': 'left',
            },
          ),
          MBAdvancedElementVariant(
            id: 'title_chip_soft',
            groupId: 'title',
            elementType: 'title',
            title: 'Soft chip',
            description: 'Product title inside rounded chip',
            binding: 'product.titleEn',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.18, y: 0.13, z: 24),
            defaultSize: MBAdvancedDesignNodeSize(width: 164, height: 34),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#FFFFFF',
              'textColorHex': '#FF6500',
              'fontSize': 13.0,
              'fontWeight': 'w900',
              'borderRadius': 999.0,
            },
          ),
          MBAdvancedElementVariant(
            id: 'title_chip_dark',
            groupId: 'title',
            elementType: 'title',
            title: 'Dark chip',
            description: 'Dark rounded title badge',
            binding: 'product.titleEn',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.20, y: 0.13, z: 24),
            defaultSize: MBAdvancedDesignNodeSize(width: 164, height: 34),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#151922',
              'textColorHex': '#FFFFFF',
              'fontSize': 13.0,
              'fontWeight': 'w900',
              'borderRadius': 999.0,
            },
          ),
        ],
      ),
      MBAdvancedElementGroup(
        id: 'subtitle',
        title: 'Subtitle',
        subtitle: 'Short product detail or selling point',
        variants: <MBAdvancedElementVariant>[
          MBAdvancedElementVariant(
            id: 'subtitle_small_text',
            groupId: 'subtitle',
            elementType: 'subtitle',
            title: 'Small text',
            description: 'Two-line supporting product text',
            binding: 'product.shortDescriptionEn',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.14, y: 0.22, z: 20),
            defaultSize: MBAdvancedDesignNodeSize(width: 180, height: 42),
            defaultStyle: <String, dynamic>{
              'textColorHex': '#FFF4E8',
              'fontSize': 11.0,
              'fontWeight': 'w600',
              'textAlign': 'left',
            },
          ),
          MBAdvancedElementVariant(
            id: 'subtitle_soft_chip',
            groupId: 'subtitle',
            elementType: 'subtitle',
            title: 'Info chip',
            description: 'Compact subtitle chip',
            binding: 'product.shortDescriptionEn',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.28, y: 0.24, z: 22),
            defaultSize: MBAdvancedDesignNodeSize(width: 154, height: 30),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#FFF5EC',
              'textColorHex': '#B84300',
              'fontSize': 10.0,
              'fontWeight': 'w800',
              'borderRadius': 999.0,
            },
          ),
        ],
      ),
      MBAdvancedElementGroup(
        id: 'media',
        title: 'Media',
        subtitle: 'Product image styles',
        variants: <MBAdvancedElementVariant>[
          MBAdvancedElementVariant(
            id: 'media_circle_ring',
            groupId: 'media',
            elementType: 'media',
            title: 'Circle ring',
            description: 'Circular image with white ring',
            binding: 'product.thumbnailUrl',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.50, y: 0.55, z: 30),
            defaultSize: MBAdvancedDesignNodeSize(width: 162, height: 162),
            defaultStyle: <String, dynamic>{
              'borderHex': '#FFFFFF',
              'ringWidth': 7.0,
              'borderRadius': 999.0,
            },
          ),
          MBAdvancedElementVariant(
            id: 'media_rounded_square',
            groupId: 'media',
            elementType: 'media',
            title: 'Rounded square',
            description: 'Rounded image block',
            binding: 'product.thumbnailUrl',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.50, y: 0.55, z: 30),
            defaultSize: MBAdvancedDesignNodeSize(width: 160, height: 140),
            defaultStyle: <String, dynamic>{
              'borderHex': '#FFFFFF',
              'ringWidth': 5.0,
              'borderRadius': 26.0,
            },
          ),
        ],
      ),
      MBAdvancedElementGroup(
        id: 'price',
        title: 'Price',
        subtitle: 'Price label and price badge variants',
        variants: <MBAdvancedElementVariant>[
          MBAdvancedElementVariant(
            id: 'price_circle_badge',
            groupId: 'price',
            elementType: 'price',
            title: 'Circle price',
            description: 'Round floating price badge',
            binding: 'product.finalPrice',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.82, y: 0.16, z: 40),
            defaultSize: MBAdvancedDesignNodeSize(width: 68, height: 68),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#FFFFFF',
              'textColorHex': '#FF6500',
              'fontSize': 14.0,
              'fontWeight': 'w900',
              'borderRadius': 999.0,
            },
          ),
          MBAdvancedElementVariant(
            id: 'price_pill_badge',
            groupId: 'price',
            elementType: 'price',
            title: 'Pill price',
            description: 'Horizontal price pill',
            binding: 'product.finalPrice',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.72, y: 0.82, z: 40),
            defaultSize: MBAdvancedDesignNodeSize(width: 108, height: 34),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#FFFFFF',
              'textColorHex': '#FF6500',
              'fontSize': 14.0,
              'fontWeight': 'w900',
              'borderRadius': 999.0,
            },
          ),
        ],
      ),
      MBAdvancedElementGroup(
        id: 'cta',
        title: 'CTA',
        subtitle: 'Buy button and action variants',
        variants: <MBAdvancedElementVariant>[
          MBAdvancedElementVariant(
            id: 'cta_pill_solid',
            groupId: 'cta',
            elementType: 'cta',
            title: 'Buy pill',
            description: 'Solid rounded buy button',
            binding: 'action.buy',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.75, y: 0.90, z: 40),
            defaultSize: MBAdvancedDesignNodeSize(width: 86, height: 34),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#151922',
              'textColorHex': '#FFFFFF',
              'fontSize': 12.0,
              'fontWeight': 'w900',
              'borderRadius': 999.0,
            },
          ),
          MBAdvancedElementVariant(
            id: 'cta_outline_pill',
            groupId: 'cta',
            elementType: 'cta',
            title: 'Outline',
            description: 'Outlined rounded CTA',
            binding: 'action.details',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.72, y: 0.90, z: 40),
            defaultSize: MBAdvancedDesignNodeSize(width: 96, height: 34),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#FFFFFF',
              'textColorHex': '#FF6500',
              'borderHex': '#FF6500',
              'fontSize': 12.0,
              'fontWeight': 'w900',
              'borderRadius': 999.0,
            },
          ),
        ],
      ),
      MBAdvancedElementGroup(
        id: 'badge',
        title: 'Badge',
        subtitle: 'Promo, stock, hot and feature badges',
        variants: <MBAdvancedElementVariant>[
          MBAdvancedElementVariant(
            id: 'badge_soft_chip',
            groupId: 'badge',
            elementType: 'badge',
            title: 'Soft chip',
            description: 'Small promo chip',
            binding: 'static.badge',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.22, y: 0.82, z: 45),
            defaultSize: MBAdvancedDesignNodeSize(width: 82, height: 28),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#FFFFFF',
              'textColorHex': '#FF6500',
              'fontSize': 11.0,
              'fontWeight': 'w900',
              'borderRadius': 999.0,
              'label': 'HOT',
            },
          ),
          MBAdvancedElementVariant(
            id: 'badge_dark_chip',
            groupId: 'badge',
            elementType: 'badge',
            title: 'Dark chip',
            description: 'Dark promo chip',
            binding: 'static.badge',
            defaultPosition: MBAdvancedDesignNodePosition(x: 0.22, y: 0.82, z: 45),
            defaultSize: MBAdvancedDesignNodeSize(width: 92, height: 28),
            defaultStyle: <String, dynamic>{
              'backgroundHex': '#151922',
              'textColorHex': '#FFFFFF',
              'fontSize': 11.0,
              'fontWeight': 'w900',
              'borderRadius': 999.0,
              'label': 'SAVE',
            },
          ),
        ],
      ),
    ];
  }
}
