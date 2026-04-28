// MuthoBazar Advanced Product Card Design Studio
// Patch 2 model layer.
//
// Purpose:
// - Stores the new node-based editable product-card design JSON.
// - Keeps the card itself selectable by using selectedNodeId = null.
// - Supports safe import from current V1-style JSON maps where possible.
// - Does not replace or modify the existing design_studio / design_studio_v2 code.
//
// Patch 2 scope:
// - Shell-ready design document.
// - Node position/size/style data.
// - JSON import/export.
// - Click selection support.
// - Safe position updates for drag/drop and mouse movement.

import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class MBAdvancedDesignNodePosition {
  const MBAdvancedDesignNodePosition({
    required this.x,
    required this.y,
    this.z = 10,
    this.anchor = 'center',
  });

  final double x;
  final double y;
  final int z;
  final String anchor;

  MBAdvancedDesignNodePosition copyWith({
    double? x,
    double? y,
    int? z,
    String? anchor,
  }) {
    return MBAdvancedDesignNodePosition(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      anchor: anchor ?? this.anchor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mode': 'free',
      'x': x,
      'y': y,
      'z': z,
      'anchor': anchor,
    };
  }

  factory MBAdvancedDesignNodePosition.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBAdvancedDesignNodePosition(
      x: _asDouble(map['x'], 0.5).clamp(0.0, 1.0).toDouble(),
      y: _asDouble(map['y'], 0.5).clamp(0.0, 1.0).toDouble(),
      z: _asInt(map['z'], 10),
      anchor: _asString(map['anchor'], 'center'),
    );
  }
}

@immutable
class MBAdvancedDesignNodeSize {
  const MBAdvancedDesignNodeSize({
    required this.width,
    required this.height,
    this.minWidth = 24,
    this.minHeight = 18,
    this.maxWidth = 420,
    this.maxHeight = 520,
  });

  final double width;
  final double height;
  final double minWidth;
  final double minHeight;
  final double maxWidth;
  final double maxHeight;

  MBAdvancedDesignNodeSize copyWith({
    double? width,
    double? height,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
  }) {
    return MBAdvancedDesignNodeSize(
      width: (width ?? this.width).clamp(12.0, 800.0).toDouble(),
      height: (height ?? this.height).clamp(12.0, 800.0).toDouble(),
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'minWidth': minWidth,
      'minHeight': minHeight,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
    };
  }

  factory MBAdvancedDesignNodeSize.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBAdvancedDesignNodeSize(
      width: _asDouble(map['width'], 120).clamp(12.0, 800.0).toDouble(),
      height: _asDouble(map['height'], 36).clamp(12.0, 800.0).toDouble(),
      minWidth: _asDouble(map['minWidth'], 24),
      minHeight: _asDouble(map['minHeight'], 18),
      maxWidth: _asDouble(map['maxWidth'], 420),
      maxHeight: _asDouble(map['maxHeight'], 520),
    );
  }
}

@immutable
class MBAdvancedDesignNode {
  const MBAdvancedDesignNode({
    required this.id,
    required this.elementType,
    required this.variantId,
    required this.binding,
    required this.position,
    required this.size,
    this.label,
    this.visible = true,
    this.locked = false,
    this.style = const <String, dynamic>{},
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String elementType;
  final String variantId;
  final String binding;
  final MBAdvancedDesignNodePosition position;
  final MBAdvancedDesignNodeSize size;
  final String? label;
  final bool visible;
  final bool locked;
  final Map<String, dynamic> style;
  final Map<String, dynamic> metadata;

  bool get isRenderable => MBAdvancedCardDesignDocument.isRenderableElementType(
        elementType,
      );

  MBAdvancedDesignNode copyWith({
    String? id,
    String? elementType,
    String? variantId,
    String? binding,
    MBAdvancedDesignNodePosition? position,
    MBAdvancedDesignNodeSize? size,
    String? label,
    bool clearLabel = false,
    bool? visible,
    bool? locked,
    Map<String, dynamic>? style,
    Map<String, dynamic>? metadata,
  }) {
    return MBAdvancedDesignNode(
      id: id ?? this.id,
      elementType: elementType ?? this.elementType,
      variantId: variantId ?? this.variantId,
      binding: binding ?? this.binding,
      position: position ?? this.position,
      size: size ?? this.size,
      label: clearLabel ? null : (label ?? this.label),
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      style: style ?? this.style,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'elementType': elementType,
      'variantId': variantId,
      'binding': binding,
      if (label != null && label!.trim().isNotEmpty) 'label': label,
      'visible': visible,
      'locked': locked,
      'position': position.toMap(),
      'size': size.toMap(),
      if (style.isNotEmpty) 'style': _cleanMap(style),
      if (metadata.isNotEmpty) 'metadata': _cleanMap(metadata),
    };
  }

  factory MBAdvancedDesignNode.fromMap(Object? value) {
    final map = _asStringMap(value);
    final elementType = _asString(map['elementType'], 'title');
    return MBAdvancedDesignNode(
      id: _asString(
        map['id'],
        '${elementType}_${DateTime.now().microsecondsSinceEpoch}',
      ),
      elementType: elementType,
      variantId: _asString(
        map['variantId'],
        MBAdvancedCardDesignDocument.defaultVariantForElement(elementType),
      ),
      binding: _asString(
        map['binding'],
        MBAdvancedCardDesignDocument.defaultBindingForElement(elementType),
      ),
      position: MBAdvancedDesignNodePosition.fromMap(map['position']),
      size: MBAdvancedDesignNodeSize.fromMap(map['size']),
      label: _asNullableString(map['label']),
      visible: _asBool(map['visible'], true),
      locked: _asBool(map['locked'], false),
      style: _cleanMap(_asStringMap(map['style'])),
      metadata: _cleanMap(_asStringMap(map['metadata'])),
    );
  }
}

@immutable
class MBAdvancedCardDesignDocument {
  const MBAdvancedCardDesignDocument({
    this.version = 20,
    this.type = 'muthobazar_card_design_advanced_v2',
    this.templateId = 'advanced_orange_phone_card_v1',
    this.designFamilyId = 'advanced_freeform_phone_card',
    this.selectedNodeId,
    this.layout = const <String, dynamic>{
      'cardWidth': 240.0,
      'cardHeight': 380.0,
      'borderRadius': 28.0,
    },
    this.palette = const <String, dynamic>{
      'presetId': 'orangeGradient',
      'backgroundHex': '#FF6500',
      'backgroundHex2': '#FF9A3D',
      'surfaceHex': '#FFFFFF',
    },
    this.nodes = const <MBAdvancedDesignNode>[],
    this.metadata = const <String, dynamic>{},
  });

  static const Set<String> renderableElementTypes = <String>{
    'title',
    'subtitle',
    'brand',
    'category',
    'media',
    'price',
    'mrp',
    'discount',
    'cta',
    'badge',
    'timer',
    'rating',
    'stock',
    'delivery',
    'unit',
    'feature',
    'wishlist',
    'icon',
    'quantity',
    'divider',
    'shape',
    'panel',
    'imageOverlay',
    'priceBadge',
    'promoBadge',
    'flashBadge',
    'savingText',
    'compare',
    'share',
    'secondaryCta',
    'progress',
    'dots',
    'ribbon',
    'border',
    'effect',
    'shadow',
    'spacing',
    'animation',
  };

  final int version;
  final String type;
  final String templateId;
  final String designFamilyId;
  final String? selectedNodeId;
  final Map<String, dynamic> layout;
  final Map<String, dynamic> palette;
  final List<MBAdvancedDesignNode> nodes;
  final Map<String, dynamic> metadata;

  bool get isCardSelected => selectedNodeId == null;

  double get cardWidth => _asDouble(layout['cardWidth'], 240)
      .clamp(160.0, 420.0)
      .toDouble();

  double get cardHeight => _asDouble(layout['cardHeight'], 380)
      .clamp(220.0, 760.0)
      .toDouble();

  double get borderRadius => _asDouble(layout['borderRadius'], 28)
      .clamp(0.0, 80.0)
      .toDouble();

  MBAdvancedDesignNode? get selectedNode {
    final id = selectedNodeId;
    if (id == null) return null;
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  static bool isRenderableElementType(String elementType) {
    return renderableElementTypes.contains(elementType);
  }

  MBAdvancedCardDesignDocument copyWith({
    int? version,
    String? type,
    String? templateId,
    String? designFamilyId,
    String? selectedNodeId,
    bool clearSelectedNodeId = false,
    Map<String, dynamic>? layout,
    Map<String, dynamic>? palette,
    List<MBAdvancedDesignNode>? nodes,
    Map<String, dynamic>? metadata,
  }) {
    final normalizedNodes = _normalizeNodes(nodes ?? this.nodes);
    final requestedSelectedNodeId = clearSelectedNodeId
        ? null
        : (selectedNodeId ?? this.selectedNodeId);
    final safeSelectedNodeId = normalizedNodes.any(
      (node) => node.id == requestedSelectedNodeId,
    )
        ? requestedSelectedNodeId
        : null;

    return MBAdvancedCardDesignDocument(
      version: version ?? this.version,
      type: type ?? this.type,
      templateId: templateId ?? this.templateId,
      designFamilyId: designFamilyId ?? this.designFamilyId,
      selectedNodeId: safeSelectedNodeId,
      layout: _cleanMap(layout ?? this.layout),
      palette: _cleanMap(palette ?? this.palette),
      nodes: normalizedNodes,
      metadata: _cleanMap(metadata ?? this.metadata),
    );
  }

  MBAdvancedCardDesignDocument selectCard() {
    return copyWith(clearSelectedNodeId: true);
  }

  MBAdvancedCardDesignDocument selectNode(String nodeId) {
    return copyWith(selectedNodeId: nodeId);
  }

  MBAdvancedCardDesignDocument upsertNode(MBAdvancedDesignNode node) {
    if (!node.isRenderable) return this;
    final nextNodes = <MBAdvancedDesignNode>[];
    var replaced = false;

    for (final item in nodes) {
      if (item.id == node.id) {
        nextNodes.add(node);
        replaced = true;
      } else {
        nextNodes.add(item);
      }
    }

    if (!replaced) {
      nextNodes.add(node);
    }

    return copyWith(
      nodes: nextNodes,
      selectedNodeId: node.id,
    );
  }

  MBAdvancedCardDesignDocument removeNode(String nodeId) {
    return copyWith(
      nodes: <MBAdvancedDesignNode>[
        for (final node in nodes)
          if (node.id != nodeId) node,
      ],
      clearSelectedNodeId: selectedNodeId == nodeId,
    );
  }

  MBAdvancedCardDesignDocument updateLayout(
    Map<String, dynamic> patch,
  ) {
    return copyWith(
      layout: <String, dynamic>{
        ...layout,
        ...patch,
      },
      clearSelectedNodeId: true,
    );
  }

  MBAdvancedCardDesignDocument updatePalette(
    Map<String, dynamic> patch,
  ) {
    return copyWith(
      palette: <String, dynamic>{
        ...palette,
        ...patch,
      },
      clearSelectedNodeId: true,
    );
  }

  Map<String, dynamic> toMap() {
    final safeNodes = _normalizeNodes(nodes);
    return <String, dynamic>{
      'version': version,
      'type': type,
      'templateId': templateId,
      'designFamilyId': designFamilyId,
      if (selectedNodeId != null) 'selectedNodeId': selectedNodeId,
      'layout': _cleanMap(layout),
      'palette': _cleanMap(palette),
      'nodes': <Map<String, dynamic>>[
        for (final node in safeNodes) node.toMap(),
      ],
      if (metadata.isNotEmpty) 'metadata': _cleanMap(metadata),
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }

  factory MBAdvancedCardDesignDocument.fromJson(String? source) {
    final normalized = source?.trim();
    if (normalized == null || normalized.isEmpty) {
      return MBAdvancedCardDesignDocument.defaults();
    }

    try {
      final decoded = jsonDecode(normalized);
      if (decoded is! Map) {
        return MBAdvancedCardDesignDocument.defaults();
      }
      return MBAdvancedCardDesignDocument.fromMap(decoded);
    } catch (_) {
      return MBAdvancedCardDesignDocument.defaults();
    }
  }

  factory MBAdvancedCardDesignDocument.fromMap(Object? value) {
    final map = _asStringMap(value);
    final rawNodes = map['nodes'];

    if (rawNodes is Iterable) {
      final parsedNodes = _normalizeNodes(<MBAdvancedDesignNode>[
        for (final item in rawNodes) MBAdvancedDesignNode.fromMap(item),
      ]);

      return MBAdvancedCardDesignDocument(
        version: _asInt(map['version'], 20),
        type: _asString(map['type'], 'muthobazar_card_design_advanced_v2'),
        templateId: _asString(map['templateId'], 'advanced_orange_phone_card_v1'),
        designFamilyId: _asString(
          map['designFamilyId'],
          'advanced_freeform_phone_card',
        ),
        selectedNodeId: _safeSelectedNodeId(
          _asNullableString(map['selectedNodeId']),
          parsedNodes,
        ),
        layout: _safeLayout(_asStringMap(map['layout'])),
        palette: _cleanMap(_asStringMap(map['palette'])),
        nodes: parsedNodes.isEmpty
            ? MBAdvancedCardDesignDocument.defaults().nodes
            : parsedNodes,
        metadata: _cleanMap(_asStringMap(map['metadata'])),
      );
    }

    return MBAdvancedCardDesignDocument.fromLegacyMap(map);
  }

  factory MBAdvancedCardDesignDocument.defaults() {
    return const MBAdvancedCardDesignDocument(
      nodes: <MBAdvancedDesignNode>[
        MBAdvancedDesignNode(
          id: 'title_01',
          elementType: 'title',
          variantId: 'title_text_bold',
          binding: 'product.titleEn',
          position: MBAdvancedDesignNodePosition(x: 0.10, y: 0.10, z: 20),
          size: MBAdvancedDesignNodeSize(width: 184, height: 48),
          style: <String, dynamic>{
            'textColorHex': '#FFFFFF',
            'fontSize': 20.0,
            'fontWeight': 'w900',
            'textAlign': 'left',
          },
        ),
        MBAdvancedDesignNode(
          id: 'subtitle_01',
          elementType: 'subtitle',
          variantId: 'subtitle_small_text',
          binding: 'product.shortDescriptionEn',
          position: MBAdvancedDesignNodePosition(x: 0.10, y: 0.22, z: 20),
          size: MBAdvancedDesignNodeSize(width: 180, height: 42),
          style: <String, dynamic>{
            'textColorHex': '#FFF4E8',
            'fontSize': 11.0,
            'fontWeight': 'w600',
            'textAlign': 'left',
          },
        ),
        MBAdvancedDesignNode(
          id: 'media_01',
          elementType: 'media',
          variantId: 'media_circle_ring',
          binding: 'product.thumbnailUrl',
          position: MBAdvancedDesignNodePosition(x: 0.50, y: 0.55, z: 30),
          size: MBAdvancedDesignNodeSize(width: 162, height: 162),
          style: <String, dynamic>{
            'borderHex': '#FFFFFF',
            'ringWidth': 7.0,
            'borderRadius': 999.0,
          },
        ),
        MBAdvancedDesignNode(
          id: 'price_01',
          elementType: 'price',
          variantId: 'price_circle_badge',
          binding: 'product.finalPrice',
          position: MBAdvancedDesignNodePosition(x: 0.82, y: 0.16, z: 40),
          size: MBAdvancedDesignNodeSize(width: 68, height: 68),
          style: <String, dynamic>{
            'backgroundHex': '#FFFFFF',
            'textColorHex': '#FF6500',
            'fontSize': 14.0,
            'fontWeight': 'w900',
            'borderRadius': 999.0,
          },
        ),
        MBAdvancedDesignNode(
          id: 'cta_01',
          elementType: 'cta',
          variantId: 'cta_pill_solid',
          binding: 'action.buy',
          position: MBAdvancedDesignNodePosition(x: 0.75, y: 0.90, z: 40),
          size: MBAdvancedDesignNodeSize(width: 86, height: 34),
          style: <String, dynamic>{
            'backgroundHex': '#151922',
            'textColorHex': '#FFFFFF',
            'fontSize': 12.0,
            'fontWeight': 'w900',
            'borderRadius': 999.0,
          },
        ),
      ],
    );
  }

  factory MBAdvancedCardDesignDocument.fromLegacyMap(
    Map<String, dynamic> map,
  ) {
    final visibleIds = _asStringSet(map['visibleElementIds']);
    final positions = _asStringMap(map['positionOverrides']);
    final sizes = _asStringMap(map['sizeOverrides']);
    final styles = _asStringMap(map['elementStyles']);
    final legacyIds = visibleIds.isEmpty
        ? const <String>{
            'title',
            'subtitle',
            'media',
            'priceBadge',
            'secondaryCta',
          }
        : visibleIds;

    final nodes = _normalizeNodes(<MBAdvancedDesignNode>[
      for (final legacyId in legacyIds)
        if (_legacyElementType(legacyId) != null)
          _legacyNode(
            legacyId: legacyId,
            elementType: _legacyElementType(legacyId)!,
            position: positions[legacyId],
            size: sizes[legacyId],
            style: styles[legacyId],
          ),
    ]);

    return MBAdvancedCardDesignDocument(
      version: 20,
      type: 'muthobazar_card_design_advanced_v2',
      templateId: _asString(map['templateId'], 'advanced_migrated_v1'),
      designFamilyId: _asString(
        map['designFamilyId'],
        'advanced_freeform_phone_card',
      ),
      layout: _safeLayout(_asStringMap(map['layout'])),
      palette: _cleanMap(_asStringMap(map['palette'])),
      nodes: nodes.isEmpty ? MBAdvancedCardDesignDocument.defaults().nodes : nodes,
      metadata: <String, dynamic>{
        'migratedFrom': 'legacy_card_design_json',
      },
    );
  }

  static MBAdvancedDesignNode _legacyNode({
    required String legacyId,
    required String elementType,
    required Object? position,
    required Object? size,
    required Object? style,
  }) {
    final styleMap = _cleanMap(_asStringMap(style));
    return MBAdvancedDesignNode(
      id: '${elementType}_01',
      elementType: elementType,
      variantId: defaultVariantForElement(elementType),
      binding: defaultBindingForElement(elementType),
      position: MBAdvancedDesignNodePosition.fromMap(position),
      size: _legacySize(elementType, size),
      style: styleMap.isEmpty ? defaultStyleForElement(elementType) : styleMap,
      metadata: <String, dynamic>{
        'legacyElementId': legacyId,
      },
    );
  }

  static MBAdvancedDesignNodeSize _legacySize(
    String elementType,
    Object? value,
  ) {
    final parsed = MBAdvancedDesignNodeSize.fromMap(value);
    if (value is Map && value.isNotEmpty) return parsed;

    switch (elementType) {
      case 'title':
        return const MBAdvancedDesignNodeSize(width: 184, height: 48);
      case 'subtitle':
        return const MBAdvancedDesignNodeSize(width: 180, height: 42);
      case 'media':
        return const MBAdvancedDesignNodeSize(width: 162, height: 162);
      case 'price':
        return const MBAdvancedDesignNodeSize(width: 68, height: 68);
      case 'cta':
        return const MBAdvancedDesignNodeSize(width: 86, height: 34);
      case 'badge':
        return const MBAdvancedDesignNodeSize(width: 76, height: 28);
      default:
        return parsed;
    }
  }

  static String? _legacyElementType(String legacyId) {
    switch (legacyId) {
      case 'title':
      case 'subtitle':
      case 'media':
        return legacyId;
      case 'priceBadge':
      case 'finalPrice':
        return 'price';
      case 'secondaryCta':
      case 'primaryCta':
        return 'cta';
      case 'deliveryHint':
      case 'timer':
      case 'promoBadge':
      case 'savingBadge':
      case 'stockHint':
        return 'badge';
      default:
        return null;
    }
  }

  static String defaultVariantForElement(String elementType) {
    switch (elementType) {
      case 'title':
        return 'title_text';
      case 'subtitle':
        return 'subtitle_text';
      case 'brand':
        return 'brand_text';
      case 'category':
        return 'category_text';
      case 'media':
        return 'media_circle_ring';
      case 'price':
        return 'price_circle';
      case 'mrp':
        return 'mrp_text';
      case 'discount':
        return 'discount_badge';
      case 'cta':
        return 'cta_buy';
      case 'badge':
        return 'badge_hot';
      case 'timer':
        return 'timer_chip';
      case 'rating':
        return 'rating_star';
      case 'stock':
        return 'stock_available';
      case 'delivery':
        return 'delivery_chip';
      case 'unit':
        return 'unit_chip';
      case 'feature':
        return 'feature_chip';
      case 'wishlist':
        return 'wishlist_heart';
      case 'icon':
        return 'icon_star';
      case 'quantity':
        return 'quantity_chip';
      case 'divider':
        return 'divider_line';
      case 'shape':
        return 'shape_circle';
      case 'panel':
        return 'panel_top_soft';
      case 'imageOverlay':
        return 'image_overlay_light';
      case 'priceBadge':
        return 'price_badge_round';
      case 'promoBadge':
        return 'promo_badge';
      case 'flashBadge':
        return 'flash_sale_badge';
      case 'savingText':
        return 'saving_text_chip';
      case 'compare':
        return 'compare_icon';
      case 'share':
        return 'share_icon';
      case 'secondaryCta':
        return 'secondary_cta_outline';
      case 'progress':
        return 'stock_progress_bar';
      case 'dots':
        return 'indicator_dots';
      case 'ribbon':
        return 'corner_ribbon';
      case 'border':
        return 'outer_border_line';
      case 'effect':
        return 'effect_glow';
      case 'shadow':
        return 'shadow_soft';
      case 'spacing':
        return 'spacing_padding_guide';
      case 'animation':
        return 'animation_pulse';
      default:
        return 'basic';
    }
  }

  static String defaultBindingForElement(String elementType) {
    switch (elementType) {
      case 'title':
        return 'product.titleEn';
      case 'subtitle':
        return 'product.shortDescriptionEn';
      case 'brand':
        return 'product.brandName';
      case 'category':
        return 'product.categoryName';
      case 'media':
        return 'product.thumbnailUrl';
      case 'price':
        return 'product.finalPrice';
      case 'mrp':
        return 'product.price';
      case 'discount':
        return 'static.discount';
      case 'cta':
        return 'action.buy';
      case 'badge':
        return 'static.badge';
      case 'timer':
        return 'static.timer';
      case 'rating':
        return 'static.rating';
      case 'stock':
        return 'static.stock';
      case 'delivery':
        return 'static.delivery';
      case 'unit':
        return 'static.unit';
      case 'feature':
        return 'static.feature';
      case 'wishlist':
        return 'action.wishlist';
      case 'icon':
        return 'static.icon';
      case 'quantity':
        return 'static.quantity';
      case 'divider':
        return 'static.divider';
      case 'shape':
        return 'static.shape';
      case 'panel':
        return 'static.panel';
      case 'imageOverlay':
        return 'static.overlay';
      case 'priceBadge':
        return 'product.finalPrice';
      case 'promoBadge':
        return 'static.promo';
      case 'flashBadge':
        return 'static.flash';
      case 'savingText':
        return 'static.saving';
      case 'compare':
        return 'action.compare';
      case 'share':
        return 'action.share';
      case 'secondaryCta':
        return 'action.details';
      case 'progress':
        return 'static.progress';
      case 'dots':
        return 'static.dots';
      case 'ribbon':
        return 'static.ribbon';
      case 'border':
        return 'static.border';
      case 'effect':
        return 'static.effect';
      case 'shadow':
        return 'static.shadow';
      case 'spacing':
        return 'static.spacing';
      case 'animation':
        return 'static.animation';
      default:
        return 'static';
    }
  }

  static Map<String, dynamic> defaultStyleForElement(String elementType) {
    switch (elementType) {
      case 'title':
        return <String, dynamic>{'textColorHex': '#FFFFFF', 'fontSize': 20.0, 'fontWeight': 'w900'};
      case 'subtitle':
        return <String, dynamic>{'textColorHex': '#FFF4E8', 'fontSize': 11.0, 'fontWeight': 'w600'};
      case 'brand':
      case 'category':
      case 'delivery':
      case 'unit':
      case 'feature':
      case 'rating':
      case 'stock':
      case 'discount':
      case 'badge':
      case 'timer':
      case 'quantity':
      case 'wishlist':
      case 'icon':
        return <String, dynamic>{'backgroundHex': '#FFFFFF', 'textColorHex': '#FF6500', 'fontSize': 11.0, 'fontWeight': 'w800', 'borderRadius': 999.0};
      case 'mrp':
        return <String, dynamic>{'textColorHex': '#FBE4D5', 'fontSize': 10.0, 'fontWeight': 'w700'};
      case 'media':
        return <String, dynamic>{'borderHex': '#FFFFFF', 'ringWidth': 7.0, 'borderRadius': 999.0};
      case 'price':
        return <String, dynamic>{'backgroundHex': '#FFFFFF', 'textColorHex': '#FF6500', 'fontSize': 14.0, 'fontWeight': 'w900', 'borderRadius': 999.0};
      case 'cta':
        return <String, dynamic>{'backgroundHex': '#151922', 'textColorHex': '#FFFFFF', 'fontSize': 12.0, 'fontWeight': 'w900', 'borderRadius': 999.0};
      case 'divider':
      case 'shape':
        return <String, dynamic>{'backgroundHex': '#FFFFFF', 'opacity': 0.5, 'borderRadius': 999.0};

      case 'panel':
      case 'imageOverlay':
      case 'progress':
      case 'dots':
      case 'border':
      case 'effect':
      case 'shadow':
      case 'spacing':
        return <String, dynamic>{'backgroundHex': '#FFFFFF', 'opacity': 0.5, 'borderRadius': 24.0};
      case 'priceBadge':
      case 'promoBadge':
      case 'flashBadge':
      case 'savingText':
      case 'compare':
      case 'share':
      case 'secondaryCta':
      case 'ribbon':
      case 'animation':
        return <String, dynamic>{'backgroundHex': '#FFFFFF', 'textColorHex': '#FF6500', 'fontSize': 11.0, 'fontWeight': 'w900', 'borderRadius': 999.0};
      default:
        return <String, dynamic>{};
    }
  }

  static List<MBAdvancedDesignNode> _normalizeNodes(
    List<MBAdvancedDesignNode> source,
  ) {
    final result = <MBAdvancedDesignNode>[];
    final usedIds = <String>{};

    for (final node in source) {
      if (!node.isRenderable) continue;
      var id = node.id.trim().isEmpty
          ? '${node.elementType}_${result.length + 1}'
          : node.id.trim();
      if (usedIds.contains(id)) {
        id = '${id}_${result.length + 1}';
      }
      usedIds.add(id);
      result.add(node.copyWith(id: id));
    }

    return result;
  }

  static String? _safeSelectedNodeId(
    String? selectedNodeId,
    List<MBAdvancedDesignNode> nodes,
  ) {
    if (selectedNodeId == null) return null;
    if (nodes.any((node) => node.id == selectedNodeId)) return selectedNodeId;
    return null;
  }

  static Map<String, dynamic> _safeLayout(Map<String, dynamic> value) {
    final cleaned = _cleanMap(value);
    return <String, dynamic>{
      'cardWidth': _asDouble(cleaned['cardWidth'], 240).clamp(160.0, 420.0),
      'cardHeight': _asDouble(cleaned['cardHeight'], 380).clamp(220.0, 760.0),
      'borderRadius': _asDouble(cleaned['borderRadius'], 28).clamp(0.0, 80.0),
    };
  }
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return value.map<String, dynamic>(
      (key, val) => MapEntry<String, dynamic>(key.toString(), val),
    );
  }
  return <String, dynamic>{};
}

Map<String, dynamic> _cleanMap(Map<String, dynamic> value) {
  final result = <String, dynamic>{};
  for (final entry in value.entries) {
    final key = entry.key.trim();
    final item = entry.value;
    if (key.isEmpty || item == null) continue;
    if (item is String && item.trim().isEmpty) continue;
    result[key] = item;
  }
  return result;
}

Set<String> _asStringSet(Object? value) {
  if (value is! Iterable) return <String>{};
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toSet();
}

String _asString(Object? value, String fallback) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return fallback;
  return normalized;
}

String? _asNullableString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

double _asDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

int _asInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

bool _asBool(Object? value, bool fallback) {
  if (value is bool) return value;
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true') return true;
  if (normalized == 'false') return false;
  return fallback;
}
