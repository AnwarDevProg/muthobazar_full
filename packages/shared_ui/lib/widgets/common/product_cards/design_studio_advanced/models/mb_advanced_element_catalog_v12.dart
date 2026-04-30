// MuthoBazar Advanced Product Card Design Studio
// Patch 12.1 element catalog.
//
// Purpose:
// - Provide a product-model-aware, data-driven catalog for the Studio V3 left
//   drawer.
// - Keep the existing MBAdvancedElementVariant / MBAdvancedElementGroup types so
//   drag/drop and JSON saving remain compatible with previous patches.
// - Align element items with MBProduct plus future Brand/Category/Variation /
//   PurchaseOption preview bindings.

import 'mb_advanced_card_design_document.dart';
import 'mb_advanced_element_variant.dart';

class MBAdvancedElementCatalogV12 {
  const MBAdvancedElementCatalogV12._();

  static List<MBAdvancedElementGroup> groups() {
    return <MBAdvancedElementGroup>[
      _cardGroup(),
      _titleGroup(),
      _subtitleGroup(),
      _brandGroup(),
      _categoryGroup(),
      _mediaGroup(),
      _unitQuantityGroup(),
      _priceGroup(),
      _mrpGroup(),
      _discountGroup(),
      _promoGroup(),
      _stockDeliveryGroup(),
      _ratingGroup(),
      _actionIconGroup(),
      _ctaGroup(),
      _timerProgressGroup(),
      _visualGroup(),
      _effectGroup(),
    ];
  }

  static MBAdvancedElementGroup _group(
    String id,
    String title,
    String subtitle,
    List<MBAdvancedElementVariant> variants,
  ) {
    return MBAdvancedElementGroup(
      id: id,
      title: title,
      subtitle: subtitle,
      variants: variants,
    );
  }

  static MBAdvancedElementVariant _item({
    required String id,
    required String groupId,
    required String elementType,
    required String title,
    required String description,
    required String binding,
    required double x,
    required double y,
    required int z,
    required double width,
    required double height,
    Map<String, dynamic> style = const <String, dynamic>{},
    Map<String, dynamic> layoutPatch = const <String, dynamic>{},
    Map<String, dynamic> palettePatch = const <String, dynamic>{},
  }) {
    return MBAdvancedElementVariant(
      id: id,
      groupId: groupId,
      elementType: elementType,
      title: title,
      description: description,
      binding: binding,
      defaultPosition: MBAdvancedDesignNodePosition(x: x, y: y, z: z),
      defaultSize: MBAdvancedDesignNodeSize(width: width, height: height),
      defaultStyle: style,
      cardLayoutPatch: layoutPatch,
      cardPalettePatch: palettePatch,
    );
  }

  static MBAdvancedElementGroup _cardGroup() {
    return _group(
      'card',
      'Card / Surface',
      'Card size, surface and base family presets',
      <MBAdvancedElementVariant>[
        _item(
          id: 'card_half_orange_poster',
          groupId: 'card',
          elementType: 'card',
          title: 'Half poster',
          description: '185 x 255 orange card',
          binding: 'card.surface',
          x: 0.5,
          y: 0.5,
          z: 0,
          width: 185,
          height: 255,
          layoutPatch: const <String, dynamic>{
            'cardWidth': 185.0,
            'cardHeight': 255.0,
            'borderRadius': 0.0,
            'resizeMode': 'responsive',
            'lockElementsToCard': true,
            'cardLayoutType': 'hero_poster_circle_diagonal_v1',
          },
          palettePatch: const <String, dynamic>{
            'presetId': 'orangeGradient',
            'backgroundHex': '#FF6500',
            'backgroundHex2': '#FF9A3D',
            'surfaceHex': '#FFFFFF',
          },
        ),
        _item(
          id: 'card_full_feature_gradient',
          groupId: 'card',
          elementType: 'card',
          title: 'Full feature',
          description: '392 x 255 full-width card',
          binding: 'card.surface',
          x: 0.5,
          y: 0.5,
          z: 0,
          width: 392,
          height: 255,
          layoutPatch: const <String, dynamic>{
            'cardWidth': 392.0,
            'cardHeight': 255.0,
            'borderRadius': 24.0,
            'resizeMode': 'responsive',
            'lockElementsToCard': true,
            'cardLayoutType': 'feature_full_width_gradient_v1',
            'footprint': 'full',
          },
          palettePatch: const <String, dynamic>{
            'presetId': 'orangeGradient',
            'backgroundHex': '#FF6500',
            'backgroundHex2': '#FF9A3D',
            'surfaceHex': '#FFFFFF',
          },
        ),
        _item(
          id: 'card_minimal_white',
          groupId: 'card',
          elementType: 'card',
          title: 'White grocery',
          description: 'Clean white grocery surface',
          binding: 'card.surface',
          x: 0.5,
          y: 0.5,
          z: 0,
          width: 185,
          height: 255,
          layoutPatch: const <String, dynamic>{
            'cardWidth': 185.0,
            'cardHeight': 255.0,
            'borderRadius': 22.0,
            'resizeMode': 'responsive',
            'lockElementsToCard': true,
            'cardLayoutType': 'grocery_minimal_white_v1',
          },
          palettePatch: const <String, dynamic>{
            'presetId': 'whiteSoft',
            'backgroundHex': '#FFFFFF',
            'backgroundHex2': '#FFF7EF',
            'surfaceHex': '#FFE6CF',
          },
        ),
      ],
    );
  }

  static MBAdvancedElementGroup _titleGroup() {
    return _group('title', 'Title', 'Product title EN/BN text and chips', <MBAdvancedElementVariant>[
      _item(id: 'title_text_bold', groupId: 'title', elementType: 'title', title: 'Title bold EN', description: 'product.titleEn', binding: 'product.titleEn', x: 0.32, y: 0.08, z: 20, width: 118, height: 26, style: _textStyle('#FFFFFF', 20, 'w900', 'left')),
      _item(id: 'title_text_bn', groupId: 'title', elementType: 'title', title: 'Title BN', description: 'product.titleBn', binding: 'product.titleBn', x: 0.32, y: 0.12, z: 20, width: 128, height: 26, style: _textStyle('#FFFFFF', 18, 'w900', 'left')),
      _item(id: 'title_multiline', groupId: 'title', elementType: 'title', title: 'Multiline title', description: '2-line title block', binding: 'product.titleEn', x: 0.42, y: 0.13, z: 20, width: 152, height: 46, style: _textStyle('#FFFFFF', 17, 'w900', 'left')),
      _item(id: 'title_chip_dark', groupId: 'title', elementType: 'title', title: 'Dark title chip', description: 'title in pill chip', binding: 'product.titleEn', x: 0.42, y: 0.12, z: 22, width: 126, height: 30, style: _chipStyle('#151922', '#FFFFFF', 13, 'w900')),
      _item(id: 'title_chip_light', groupId: 'title', elementType: 'title', title: 'Light title chip', description: 'orange text chip', binding: 'product.titleEn', x: 0.42, y: 0.12, z: 22, width: 126, height: 30, style: _chipStyle('#FFFFFF', '#FF6500', 13, 'w900')),
    ]);
  }

  static MBAdvancedElementGroup _subtitleGroup() {
    return _group('subtitle', 'Subtitle / Description', 'Short description and detail snippets', <MBAdvancedElementVariant>[
      _item(id: 'subtitle_small_text', groupId: 'subtitle', elementType: 'subtitle', title: 'Short description EN', description: 'product.shortDescriptionEn', binding: 'product.shortDescriptionEn', x: 0.50, y: 0.77, z: 20, width: 170, height: 36, style: _textStyle('#FFF4E8', 12.5, 'w600', 'left')),
      _item(id: 'subtitle_bn_text', groupId: 'subtitle', elementType: 'subtitle', title: 'Short description BN', description: 'product.shortDescriptionBn', binding: 'product.shortDescriptionBn', x: 0.50, y: 0.77, z: 20, width: 170, height: 36, style: _textStyle('#FFF4E8', 12, 'w600', 'left')),
      _item(id: 'subtitle_chip', groupId: 'subtitle', elementType: 'subtitle', title: 'Subtitle chip', description: 'short text in chip', binding: 'product.shortDescriptionEn', x: 0.50, y: 0.77, z: 22, width: 168, height: 28, style: _chipStyle('#FFF4E8', '#B84300', 10.5, 'w800')),
      _item(id: 'description_preview', groupId: 'subtitle', elementType: 'description', title: 'Description preview', description: 'product.descriptionEn', binding: 'product.descriptionEn', x: 0.50, y: 0.78, z: 20, width: 170, height: 46, style: _textStyle('#FFF4E8', 10.5, 'w600', 'left')),
    ]);
  }

  static MBAdvancedElementGroup _brandGroup() {
    return _group('brand', 'Brand', 'Brand model and denormalized product brand', <MBAdvancedElementVariant>[
      _item(id: 'brand_text_en', groupId: 'brand', elementType: 'brand', title: 'Brand EN', description: 'product.brandNameEn', binding: 'product.brandNameEn', x: 0.24, y: 0.28, z: 22, width: 104, height: 24, style: _textStyle('#FFFFFF', 10.5, 'w800', 'left')),
      _item(id: 'brand_text_bn', groupId: 'brand', elementType: 'brand', title: 'Brand BN', description: 'product.brandNameBn', binding: 'product.brandNameBn', x: 0.24, y: 0.28, z: 22, width: 104, height: 24, style: _textStyle('#FFFFFF', 10.5, 'w800', 'left')),
      _item(id: 'brand_chip', groupId: 'brand', elementType: 'brand', title: 'Brand chip', description: 'brand pill', binding: 'product.brandNameEn', x: 0.30, y: 0.28, z: 22, width: 108, height: 26, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
      _item(id: 'brand_model_name', groupId: 'brand', elementType: 'brand', title: 'Brand object', description: 'brand.nameEn fallback', binding: 'brand.nameEn', x: 0.30, y: 0.28, z: 22, width: 108, height: 26, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
    ]);
  }

  static MBAdvancedElementGroup _categoryGroup() {
    return _group('category', 'Category', 'Category model and product category', <MBAdvancedElementVariant>[
      _item(id: 'category_text_en', groupId: 'category', elementType: 'category', title: 'Category EN', description: 'product.categoryNameEn', binding: 'product.categoryNameEn', x: 0.26, y: 0.34, z: 22, width: 126, height: 24, style: _textStyle('#FFFFFF', 10.5, 'w800', 'left')),
      _item(id: 'category_text_bn', groupId: 'category', elementType: 'category', title: 'Category BN', description: 'product.categoryNameBn', binding: 'product.categoryNameBn', x: 0.26, y: 0.34, z: 22, width: 126, height: 24, style: _textStyle('#FFFFFF', 10.5, 'w800', 'left')),
      _item(id: 'category_chip', groupId: 'category', elementType: 'category', title: 'Category chip', description: 'category pill', binding: 'product.categoryNameEn', x: 0.32, y: 0.34, z: 22, width: 120, height: 26, style: _chipStyle('#FFFFFF', '#D85B00', 10.5, 'w900')),
      _item(id: 'category_model_name', groupId: 'category', elementType: 'category', title: 'Category object', description: 'category.nameEn fallback', binding: 'category.nameEn', x: 0.32, y: 0.34, z: 22, width: 120, height: 26, style: _chipStyle('#FFFFFF', '#D85B00', 10.5, 'w900')),
    ]);
  }

  static MBAdvancedElementGroup _mediaGroup() {
    return _group('media', 'Media', 'Product, brand and category image sources', <MBAdvancedElementVariant>[
      _item(id: 'media_circle_ring', groupId: 'media', elementType: 'media', title: 'Thumbnail circle', description: 'product.thumbnailUrl', binding: 'product.thumbnailUrl', x: 0.50, y: 0.42, z: 30, width: 173, height: 140, style: _mediaStyle(999, 7)),
      _item(id: 'media_rounded_thumb', groupId: 'media', elementType: 'media', title: 'Thumbnail rounded', description: 'product.thumbnailUrl', binding: 'product.thumbnailUrl', x: 0.50, y: 0.42, z: 30, width: 158, height: 128, style: _mediaStyle(24, 5)),
      _item(id: 'media_full_image', groupId: 'media', elementType: 'media', title: 'Full image', description: 'product.imageUrls.first', binding: 'product.imageUrls.first', x: 0.50, y: 0.42, z: 30, width: 166, height: 132, style: _mediaStyle(20, 4)),
      _item(id: 'brand_logo_round', groupId: 'media', elementType: 'media', title: 'Brand logo', description: 'brand.logoUrl', binding: 'brand.logoUrl', x: 0.82, y: 0.12, z: 34, width: 42, height: 42, style: _mediaStyle(999, 3)),
      _item(id: 'category_icon_round', groupId: 'media', elementType: 'media', title: 'Category icon', description: 'category.iconUrl', binding: 'category.iconUrl', x: 0.18, y: 0.12, z: 34, width: 42, height: 42, style: _mediaStyle(999, 3)),
    ]);
  }

  static MBAdvancedElementGroup _unitQuantityGroup() {
    return _group('unit_quantity', 'Unit / Quantity', 'Unit labels, quantity values and pack info', <MBAdvancedElementVariant>[
      _item(id: 'unit_text_en', groupId: 'unit_quantity', elementType: 'unit', title: 'Unit EN', description: 'product.unitLabelEn', binding: 'product.unitLabelEn', x: 0.22, y: 0.37, z: 25, width: 72, height: 22, style: _textStyle('#FFFFFF', 10.5, 'w800', 'left')),
      _item(id: 'unit_chip_en', groupId: 'unit_quantity', elementType: 'unit', title: 'Unit chip', description: 'unit pill', binding: 'product.unitLabelEn', x: 0.25, y: 0.37, z: 25, width: 80, height: 25, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
      _item(id: 'quantity_value', groupId: 'unit_quantity', elementType: 'quantity', title: 'Quantity value', description: 'product.quantityValue', binding: 'product.quantityValue', x: 0.22, y: 0.43, z: 25, width: 72, height: 24, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
      _item(id: 'quantity_type', groupId: 'unit_quantity', elementType: 'quantity', title: 'Quantity type', description: 'product.quantityType', binding: 'product.quantityType', x: 0.22, y: 0.47, z: 25, width: 72, height: 24, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
    ]);
  }

  static MBAdvancedElementGroup _priceGroup() {
    return _group('price', 'Price', 'Final, sale and price badges', <MBAdvancedElementVariant>[
      _item(id: 'price_circle_badge', groupId: 'price', elementType: 'price', title: 'Final price circle', description: 'product.finalPrice', binding: 'product.finalPrice', x: 0.16, y: 0.22, z: 40, width: 52, height: 38, style: _chipStyle('#FFFFFF', '#FF6500', 14, 'w900')),
      _item(id: 'price_pill_badge', groupId: 'price', elementType: 'price', title: 'Final price pill', description: 'product.finalPrice', binding: 'product.finalPrice', x: 0.25, y: 0.22, z: 40, width: 78, height: 30, style: _chipStyle('#FFFFFF', '#FF6500', 14, 'w900')),
      _item(id: 'sale_price_text', groupId: 'price', elementType: 'price', title: 'Sale price text', description: 'product.salePrice', binding: 'product.salePrice', x: 0.25, y: 0.83, z: 40, width: 86, height: 28, style: _textStyle('#FFFFFF', 18, 'w900', 'left')),
      _item(id: 'price_dark_pill', groupId: 'price', elementType: 'price', title: 'Dark price pill', description: 'dark price chip', binding: 'product.finalPrice', x: 0.25, y: 0.83, z: 40, width: 92, height: 30, style: _chipStyle('#151922', '#FFFFFF', 14, 'w900')),
      _item(id: 'price_with_unit', groupId: 'price', elementType: 'price', title: 'Price + unit', description: 'final price badge', binding: 'product.finalPrice', x: 0.28, y: 0.83, z: 40, width: 104, height: 30, style: <String, dynamic>{..._chipStyle('#FFFFFF', '#FF6500', 13, 'w900'), 'suffixText': '/pcs'}),
    ]);
  }

  static MBAdvancedElementGroup _mrpGroup() {
    return _group('mrp', 'MRP / Original Price', 'Old price text/chip with strike support', <MBAdvancedElementVariant>[
      _item(id: 'mrp_text_line', groupId: 'mrp', elementType: 'mrp', title: 'MRP text', description: 'product.price', binding: 'product.price', x: 0.55, y: 0.83, z: 39, width: 70, height: 22, style: <String, dynamic>{..._textStyle('#FFE6D1', 11, 'w700', 'left'), 'autoStrikeWhenDiscounted': true, 'strikeMode': 'lineThrough'}),
      _item(id: 'mrp_chip_cross', groupId: 'mrp', elementType: 'mrp', title: 'MRP chip cross', description: 'crossed chip', binding: 'product.price', x: 0.55, y: 0.83, z: 39, width: 76, height: 25, style: <String, dynamic>{..._chipStyle('#FFF4E8', '#A44500', 10.5, 'w800'), 'autoStrikeWhenDiscounted': true, 'strikeMode': 'cross', 'strikeColorHex': '#FF4A4A'}),
    ]);
  }

  static MBAdvancedElementGroup _discountGroup() {
    return _group('discount', 'Discount / Saving', 'Auto discount and saving text', <MBAdvancedElementVariant>[
      _item(id: 'discount_badge', groupId: 'discount', elementType: 'discount', title: 'Discount badge', description: 'static.discount', binding: 'static.discount', x: 0.23, y: 0.90, z: 41, width: 76, height: 28, style: _chipStyle('#151922', '#FFFFFF', 11, 'w900')),
      _item(id: 'discount_light_badge', groupId: 'discount', elementType: 'discount', title: 'Light discount', description: 'white offer pill', binding: 'static.discount', x: 0.23, y: 0.90, z: 41, width: 76, height: 28, style: _chipStyle('#FFFFFF', '#FF6500', 11, 'w900')),
      _item(id: 'saving_text', groupId: 'discount', elementType: 'savingText', title: 'Saving text', description: 'static.saving', binding: 'static.saving', x: 0.50, y: 0.90, z: 41, width: 120, height: 24, style: _textStyle('#FFFFFF', 11, 'w800', 'center')),
    ]);
  }

  static MBAdvancedElementGroup _promoGroup() {
    return _group('promo', 'Promo / Flash', 'Promo, flash and campaign labels', <MBAdvancedElementVariant>[
      _item(id: 'promo_badge', groupId: 'promo', elementType: 'promoBadge', title: 'Promo badge', description: 'static.promo', binding: 'static.promo', x: 0.78, y: 0.12, z: 45, width: 74, height: 26, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
      _item(id: 'flash_badge', groupId: 'promo', elementType: 'flashBadge', title: 'Flash badge', description: 'static.flash', binding: 'static.flash', x: 0.78, y: 0.12, z: 45, width: 74, height: 26, style: _chipStyle('#151922', '#FFFFFF', 10.5, 'w900')),
      _item(id: 'new_ribbon', groupId: 'promo', elementType: 'ribbon', title: 'New ribbon', description: 'static.new', binding: 'static.new', x: 0.82, y: 0.08, z: 45, width: 62, height: 24, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
      _item(id: 'premium_badge', groupId: 'promo', elementType: 'badge', title: 'Premium badge', description: 'static.premium', binding: 'static.premium', x: 0.78, y: 0.18, z: 45, width: 86, height: 26, style: _chipStyle('#151922', '#FFFFFF', 10.5, 'w900')),
    ]);
  }

  static MBAdvancedElementGroup _stockDeliveryGroup() {
    return _group('stock_delivery', 'Stock / Delivery', 'Availability and delivery hints', <MBAdvancedElementVariant>[
      _item(id: 'stock_text', groupId: 'stock_delivery', elementType: 'stock', title: 'Stock text', description: 'product.stockText', binding: 'product.stockText', x: 0.32, y: 0.72, z: 38, width: 96, height: 22, style: _textStyle('#FFFFFF', 10.5, 'w800', 'left')),
      _item(id: 'stock_chip', groupId: 'stock_delivery', elementType: 'stock', title: 'Stock chip', description: 'stock pill', binding: 'product.stockText', x: 0.32, y: 0.72, z: 38, width: 96, height: 26, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
      _item(id: 'delivery_text', groupId: 'stock_delivery', elementType: 'delivery', title: 'Delivery text', description: 'static.delivery', binding: 'static.delivery', x: 0.33, y: 0.86, z: 38, width: 112, height: 24, style: _textStyle('#FFFFFF', 10.5, 'w800', 'left')),
      _item(id: 'delivery_chip', groupId: 'stock_delivery', elementType: 'delivery', title: 'Delivery chip', description: 'delivery pill', binding: 'static.delivery', x: 0.34, y: 0.86, z: 38, width: 118, height: 26, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
    ]);
  }

  static MBAdvancedElementGroup _ratingGroup() {
    return _group('rating', 'Rating / Review', 'Stars and review count placeholders', <MBAdvancedElementVariant>[
      _item(id: 'rating_text', groupId: 'rating', elementType: 'rating', title: 'Rating text', description: 'static.rating', binding: 'static.rating', x: 0.32, y: 0.66, z: 38, width: 90, height: 22, style: _textStyle('#FFFFFF', 10.5, 'w800', 'left')),
      _item(id: 'rating_chip', groupId: 'rating', elementType: 'rating', title: 'Rating chip', description: 'rating pill', binding: 'static.rating', x: 0.32, y: 0.66, z: 38, width: 90, height: 25, style: _chipStyle('#FFFFFF', '#FF6500', 10.5, 'w900')),
    ]);
  }

  static MBAdvancedElementGroup _actionIconGroup() {
    return _group('actions', 'Wishlist / Compare / Share', 'Floating action icons', <MBAdvancedElementVariant>[
      _item(id: 'wishlist_heart', groupId: 'actions', elementType: 'wishlist', title: 'Wishlist', description: 'heart action', binding: 'action.wishlist', x: 0.88, y: 0.12, z: 50, width: 34, height: 34, style: _chipStyle('#FFFFFF', '#FF6500', 16, 'w900')),
      _item(id: 'compare_icon', groupId: 'actions', elementType: 'compare', title: 'Compare', description: 'compare action', binding: 'action.compare', x: 0.88, y: 0.24, z: 50, width: 34, height: 34, style: _chipStyle('#FFFFFF', '#FF6500', 15, 'w900')),
      _item(id: 'share_icon', groupId: 'actions', elementType: 'share', title: 'Share', description: 'share action', binding: 'action.share', x: 0.88, y: 0.36, z: 50, width: 34, height: 34, style: _chipStyle('#FFFFFF', '#FF6500', 15, 'w900')),
    ]);
  }

  static MBAdvancedElementGroup _ctaGroup() {
    return _group('cta', 'CTA / Buttons', 'Primary and secondary action buttons', <MBAdvancedElementVariant>[
      _item(id: 'cta_pill_solid', groupId: 'cta', elementType: 'cta', title: 'Buy solid', description: 'action.buy', binding: 'action.buy', x: 0.72, y: 0.90, z: 40, width: 86, height: 30, style: _chipStyle('#151922', '#FFFFFF', 12, 'w900')),
      _item(id: 'cta_pill_light', groupId: 'cta', elementType: 'cta', title: 'Buy light', description: 'white CTA', binding: 'action.buy', x: 0.72, y: 0.90, z: 40, width: 86, height: 30, style: _chipStyle('#FFFFFF', '#FF6500', 12, 'w900')),
      _item(id: 'cta_add_cart', groupId: 'cta', elementType: 'cta', title: 'Add cart', description: 'action.add', binding: 'action.add', x: 0.70, y: 0.90, z: 40, width: 98, height: 30, style: _chipStyle('#151922', '#FFFFFF', 12, 'w900')),
      _item(id: 'secondary_cta_outline', groupId: 'cta', elementType: 'secondaryCta', title: 'View outline', description: 'action.details', binding: 'action.details', x: 0.70, y: 0.90, z: 40, width: 90, height: 30, style: <String, dynamic>{..._chipStyle('#FFFFFF', '#FF6500', 12, 'w900'), 'borderHex': '#FF6500', 'borderWidth': 1.2}),
    ]);
  }

  static MBAdvancedElementGroup _timerProgressGroup() {
    return _group('timer_progress', 'Timer / Progress', 'Countdown, stock progress and dots', <MBAdvancedElementVariant>[
      _item(id: 'timer_chip', groupId: 'timer_progress', elementType: 'timer', title: 'Timer chip', description: 'timer.countdown', binding: 'timer.countdown', x: 0.50, y: 0.64, z: 38, width: 100, height: 26, style: _chipStyle('#151922', '#FFFFFF', 10.5, 'w900')),
      _item(id: 'stock_progress_bar', groupId: 'timer_progress', elementType: 'progress', title: 'Progress bar', description: 'stock progress', binding: 'static.progress', x: 0.50, y: 0.72, z: 36, width: 132, height: 10, style: <String, dynamic>{'backgroundHex': '#FFFFFF', 'fillHex': '#FF6500', 'borderRadius': 999.0, 'progress': 0.72}),
      _item(id: 'indicator_dots', groupId: 'timer_progress', elementType: 'dots', title: 'Indicator dots', description: 'small dots', binding: 'static.dots', x: 0.50, y: 0.70, z: 36, width: 62, height: 16, style: <String, dynamic>{'fillHex': '#FF6500'}),
    ]);
  }

  static MBAdvancedElementGroup _visualGroup() {
    return _group('visual', 'Panels / Shapes / Borders', 'Background shapes and layout helpers', <MBAdvancedElementVariant>[
      _item(id: 'panel_soft_top', groupId: 'visual', elementType: 'panel', title: 'Soft panel', description: 'rounded panel', binding: 'static.panel', x: 0.50, y: 0.30, z: 5, width: 170, height: 92, style: <String, dynamic>{'backgroundHex': '#FFFFFF', 'opacity': 0.25, 'borderRadius': 24.0}),
      _item(id: 'shape_circle_glow', groupId: 'visual', elementType: 'shape', title: 'Circle glow', description: 'soft circle shape', binding: 'static.shape', x: 0.84, y: 0.18, z: 4, width: 82, height: 82, style: <String, dynamic>{'backgroundHex': '#FFFFFF', 'opacity': 0.16, 'borderRadius': 999.0}),
      _item(id: 'divider_line', groupId: 'visual', elementType: 'divider', title: 'Divider line', description: 'thin separator', binding: 'static.divider', x: 0.50, y: 0.74, z: 35, width: 150, height: 2, style: <String, dynamic>{'backgroundHex': '#FFFFFF', 'opacity': 0.45, 'borderRadius': 999.0}),
      _item(id: 'outer_border_line', groupId: 'visual', elementType: 'border', title: 'Outer border', description: 'decorative line', binding: 'static.border', x: 0.50, y: 0.50, z: 60, width: 176, height: 246, style: <String, dynamic>{'backgroundHex': '#00000000', 'borderHex': '#FFFFFF', 'borderWidth': 1.2, 'opacity': 0.55, 'borderRadius': 20.0}),
    ]);
  }

  static MBAdvancedElementGroup _effectGroup() {
    return _group('effects', 'Effects / Animation', 'Visual effect placeholders', <MBAdvancedElementVariant>[
      _item(id: 'effect_glow', groupId: 'effects', elementType: 'effect', title: 'Glow', description: 'soft glow effect', binding: 'static.effect', x: 0.50, y: 0.42, z: 3, width: 150, height: 120, style: <String, dynamic>{'backgroundHex': '#FFFFFF', 'opacity': 0.12, 'borderRadius': 999.0}),
      _item(id: 'shadow_soft', groupId: 'effects', elementType: 'shadow', title: 'Soft shadow', description: 'shadow marker', binding: 'static.shadow', x: 0.50, y: 0.50, z: 2, width: 150, height: 120, style: <String, dynamic>{'backgroundHex': '#000000', 'opacity': 0.08, 'borderRadius': 28.0}),
      _item(id: 'animation_pulse_dot', groupId: 'effects', elementType: 'animation', title: 'Pulse dot', description: 'animation marker', binding: 'static.animation', x: 0.82, y: 0.08, z: 55, width: 18, height: 18, style: _chipStyle('#FFFFFF', '#FF6500', 10, 'w900')),
    ]);
  }

  static Map<String, dynamic> _textStyle(
    String textColor,
    double fontSize,
    String weight,
    String align,
  ) {
    return <String, dynamic>{
      'textColorHex': textColor,
      'fontSize': fontSize,
      'fontWeight': weight,
      'textAlign': align,
    };
  }

  static Map<String, dynamic> _chipStyle(
    String background,
    String textColor,
    double fontSize,
    String weight,
  ) {
    return <String, dynamic>{
      'backgroundHex': background,
      'textColorHex': textColor,
      'fontSize': fontSize,
      'fontWeight': weight,
      'borderRadius': 999.0,
      'textAlign': 'center',
    };
  }

  static Map<String, dynamic> _mediaStyle(double radius, double ringWidth) {
    return <String, dynamic>{
      'backgroundHex': '#FFFFFF',
      'borderHex': '#FFFFFF',
      'ringWidth': ringWidth,
      'borderRadius': radius,
      'imageFit': 'cover',
      'imageAlignment': 'center',
    };
  }
}
