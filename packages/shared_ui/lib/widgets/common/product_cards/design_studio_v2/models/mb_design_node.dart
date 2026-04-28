import 'dart:convert';

import 'package:flutter/foundation.dart';

// MuthoBazar Design Studio V2 Node Models
// ---------------------------------------
// Preview/interaction cleanup patch.
//
// Main fixes:
// - Legacy V1 import now ignores non-renderable helper elements:
//   backgroundPanel, decorativeShape, imageFrame, imageOverlay, etc.
// - Existing messy V2 JSON is also normalized so unsupported nodes are removed.
// - This prevents stacked/duplicate product text and broken preview.
// - Only real editable/renderable nodes remain in the canvas.

@immutable
class MBDesignNodePosition {
  const MBDesignNodePosition({
    required this.x,
    required this.y,
    this.z = 10,
    this.anchor = 'center',
    this.alignment = 'center',
  });

  final double x;
  final double y;
  final int z;
  final String anchor;
  final String alignment;

  MBDesignNodePosition copyWith({
    double? x,
    double? y,
    int? z,
    String? anchor,
    String? alignment,
  }) {
    return MBDesignNodePosition(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      anchor: anchor ?? this.anchor,
      alignment: alignment ?? this.alignment,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'mode': 'free',
      'x': x,
      'y': y,
      'z': z,
      'anchor': anchor,
      'alignment': alignment,
    };
  }

  factory MBDesignNodePosition.fromMap(Object? value) {
    final map = _asMap(value);

    return MBDesignNodePosition(
      x: _asDouble(map['x'], 0.5).clamp(0.0, 1.0).toDouble(),
      y: _asDouble(map['y'], 0.5).clamp(0.0, 1.0).toDouble(),
      z: _asInt(map['z'], 10),
      anchor: _asString(map['anchor'], 'center'),
      alignment: _asString(map['alignment'], 'center'),
    );
  }
}

@immutable
class MBDesignNodeSize {
  const MBDesignNodeSize({
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.scale = 1,
  });

  final double? width;
  final double? height;
  final double? minWidth;
  final double? maxWidth;
  final double scale;

  MBDesignNodeSize copyWith({
    double? width,
    bool clearWidth = false,
    double? height,
    bool clearHeight = false,
    double? minWidth,
    bool clearMinWidth = false,
    double? maxWidth,
    bool clearMaxWidth = false,
    double? scale,
  }) {
    return MBDesignNodeSize(
      width: clearWidth ? null : (width ?? this.width),
      height: clearHeight ? null : (height ?? this.height),
      minWidth: clearMinWidth ? null : (minWidth ?? this.minWidth),
      maxWidth: clearMaxWidth ? null : (maxWidth ?? this.maxWidth),
      scale: scale ?? this.scale,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (minWidth != null) 'minWidth': minWidth,
      if (maxWidth != null) 'maxWidth': maxWidth,
      'scale': scale,
    };
  }

  factory MBDesignNodeSize.fromMap(Object? value) {
    final map = _asMap(value);

    return MBDesignNodeSize(
      width: _asNullableDouble(map['width']),
      height: _asNullableDouble(map['height']),
      minWidth: _asNullableDouble(map['minWidth']),
      maxWidth: _asNullableDouble(map['maxWidth']),
      scale: _asDouble(map['scale'], 1),
    );
  }
}

@immutable
class MBDesignNode {
  const MBDesignNode({
    required this.id,
    required this.elementType,
    required this.variantId,
    required this.binding,
    this.label,
    this.visible = true,
    this.locked = false,
    required this.position,
    required this.size,
    this.style = const <String, Object?>{},
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String elementType;
  final String variantId;
  final String binding;
  final String? label;
  final bool visible;
  final bool locked;
  final MBDesignNodePosition position;
  final MBDesignNodeSize size;
  final Map<String, Object?> style;
  final Map<String, Object?> metadata;

  bool get isRenderable => MBDesignDocument.isRenderableElementType(
        elementType,
      );

  MBDesignNode copyWith({
    String? id,
    String? elementType,
    String? variantId,
    String? binding,
    String? label,
    bool clearLabel = false,
    bool? visible,
    bool? locked,
    MBDesignNodePosition? position,
    MBDesignNodeSize? size,
    Map<String, Object?>? style,
    Map<String, Object?>? metadata,
  }) {
    return MBDesignNode(
      id: id ?? this.id,
      elementType: elementType ?? this.elementType,
      variantId: variantId ?? this.variantId,
      binding: binding ?? this.binding,
      label: clearLabel ? null : (label ?? this.label),
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      position: position ?? this.position,
      size: size ?? this.size,
      style: style ?? this.style,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
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

  factory MBDesignNode.fromMap(Object? value) {
    final map = _asMap(value);
    final elementType = _asString(map['elementType'], 'title');

    return MBDesignNode(
      id: _asString(map['id'], 'node_${DateTime.now().microsecondsSinceEpoch}'),
      elementType: elementType,
      variantId: _asString(
        map['variantId'],
        MBDesignDocument.defaultVariantForElement(elementType),
      ),
      binding: _asString(
        map['binding'],
        MBDesignDocument.defaultBindingForElement(elementType),
      ),
      label: _asNullableString(map['label']),
      visible: _asBool(map['visible'], true),
      locked: _asBool(map['locked'], false),
      position: MBDesignNodePosition.fromMap(map['position']),
      size: MBDesignNodeSize.fromMap(map['size']),
      style: _cleanMap(_asMap(map['style'])),
      metadata: _cleanMap(_asMap(map['metadata'])),
    );
  }
}

@immutable
class MBDesignDocument {
  const MBDesignDocument({
    this.version = 2,
    this.type = 'muthobazar_card_design_v2',
    this.templateId = 'hero_poster_circle_diagonal_v1',
    this.designFamilyId = 'hero_poster_circle',
    this.selectedNodeId,
    this.layout = const <String, Object?>{
      'cardWidth': 230.0,
      'aspectRatio': 0.58,
      'minHeight': 360.0,
      'maxHeight': 420.0,
    },
    this.palette = const <String, Object?>{
      'presetId': 'orange_fresh',
    },
    this.nodes = const <MBDesignNode>[],
    this.metadata = const <String, Object?>{},
  });

  static const Set<String> renderableElementTypes = <String>{
    'title',
    'subtitle',
    'media',
    'priceBadge',
    'finalPrice',
    'secondaryCta',
    'primaryCta',
    'deliveryHint',
    'timer',
    'promoBadge',
    'savingBadge',
    'stockHint',
    'brand',
    'categoryChip',
    'unitLabel',
  };

  final int version;
  final String type;
  final String templateId;
  final String designFamilyId;
  final String? selectedNodeId;
  final Map<String, Object?> layout;
  final Map<String, Object?> palette;
  final List<MBDesignNode> nodes;
  final Map<String, Object?> metadata;

  double get cardWidth => _asDouble(layout['cardWidth'], 230);
  double get aspectRatio => _asDouble(layout['aspectRatio'], 0.58);
  double get minHeight => _asDouble(layout['minHeight'], 360);
  double get maxHeight => _asDouble(layout['maxHeight'], 420);

  MBDesignNode? get selectedNode {
    if (selectedNodeId == null) return null;

    for (final node in nodes) {
      if (node.id == selectedNodeId) {
        return node;
      }
    }

    return null;
  }

  static bool isRenderableElementType(String elementType) {
    return renderableElementTypes.contains(elementType);
  }

  MBDesignDocument copyWith({
    int? version,
    String? type,
    String? templateId,
    String? designFamilyId,
    String? selectedNodeId,
    bool clearSelectedNodeId = false,
    Map<String, Object?>? layout,
    Map<String, Object?>? palette,
    List<MBDesignNode>? nodes,
    Map<String, Object?>? metadata,
  }) {
    final normalizedNodes = _normalizeNodes(nodes ?? this.nodes);
    final nextSelected =
        clearSelectedNodeId ? null : (selectedNodeId ?? this.selectedNodeId);

    return MBDesignDocument(
      version: version ?? this.version,
      type: type ?? this.type,
      templateId: templateId ?? this.templateId,
      designFamilyId: designFamilyId ?? this.designFamilyId,
      selectedNodeId: normalizedNodes.any((node) => node.id == nextSelected)
          ? nextSelected
          : null,
      layout: layout ?? this.layout,
      palette: palette ?? this.palette,
      nodes: normalizedNodes,
      metadata: metadata ?? this.metadata,
    );
  }

  MBDesignDocument upsertNode(MBDesignNode node) {
    if (!node.isRenderable) {
      return this;
    }

    final next = <MBDesignNode>[
      for (final item in nodes)
        if (item.id == node.id) node else item,
    ];

    if (!next.any((item) => item.id == node.id)) {
      next.add(node);
    }

    return copyWith(
      nodes: next,
      selectedNodeId: node.id,
    );
  }

  MBDesignDocument removeNode(String nodeId) {
    return copyWith(
      nodes: [
        for (final node in nodes)
          if (node.id != nodeId) node,
      ],
      clearSelectedNodeId: selectedNodeId == nodeId,
    );
  }

  Map<String, Object?> toMap() {
    final safeNodes = _normalizeNodes(nodes);

    return <String, Object?>{
      'version': version,
      'type': type,
      'templateId': templateId,
      'designFamilyId': designFamilyId,
      if (selectedNodeId != null) 'selectedNodeId': selectedNodeId,
      'layout': _cleanMap(layout),
      'palette': _cleanMap(palette),
      'nodes': [for (final node in safeNodes) node.toMap()],
      if (metadata.isNotEmpty) 'metadata': _cleanMap(metadata),
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }

  factory MBDesignDocument.fromJson(String? source) {
    final normalized = source?.trim();
    if (normalized == null || normalized.isEmpty) {
      return MBDesignDocument.defaults();
    }

    try {
      final decoded = jsonDecode(normalized);
      if (decoded is! Map) {
        return MBDesignDocument.defaults();
      }

      return MBDesignDocument.fromMap(decoded);
    } catch (_) {
      return MBDesignDocument.defaults();
    }
  }

  factory MBDesignDocument.fromMap(Object? value) {
    final map = _asMap(value);
    final rawNodes = map['nodes'];

    if (rawNodes is Iterable) {
      final nodes = _normalizeNodes([
        for (final item in rawNodes) MBDesignNode.fromMap(item),
      ]);

      return MBDesignDocument(
        version: 2,
        type: 'muthobazar_card_design_v2',
        templateId: _asString(
          map['templateId'],
          'hero_poster_circle_diagonal_v1',
        ),
        designFamilyId: _asString(
          map['designFamilyId'],
          'hero_poster_circle',
        ),
        selectedNodeId: _selectSafeNodeId(
          _asNullableString(map['selectedNodeId']),
          nodes,
        ),
        layout: _safeLayout(_asMap(map['layout'])),
        palette: _cleanMap(_asMap(map['palette'])),
        nodes: nodes,
        metadata: _cleanMap(_asMap(map['metadata'])),
      );
    }

    return MBDesignDocument.fromLegacyMap(map);
  }

  factory MBDesignDocument.defaults() {
    return const MBDesignDocument(
      nodes: <MBDesignNode>[
        MBDesignNode(
          id: 'title_01',
          elementType: 'title',
          variantId: 'text_italic',
          binding: 'product.titleEn',
          position: MBDesignNodePosition(x: 0.30, y: 0.10, z: 20),
          size: MBDesignNodeSize(width: 145, height: 38),
          style: <String, Object?>{
            'textColorHex': '#FFFFFF',
            'fontSize': 18.0,
            'fontWeight': 'w900',
            'fontStyle': 'italic',
          },
        ),
        MBDesignNode(
          id: 'subtitle_01',
          elementType: 'subtitle',
          variantId: 'text_small',
          binding: 'product.shortDescriptionEn',
          position: MBDesignNodePosition(x: 0.33, y: 0.20, z: 20),
          size: MBDesignNodeSize(width: 170, height: 44),
          style: <String, Object?>{
            'textColorHex': '#FFF2E7',
            'fontSize': 11.0,
          },
        ),
        MBDesignNode(
          id: 'media_01',
          elementType: 'media',
          variantId: 'circle_ring',
          binding: 'product.thumbnailUrl',
          position: MBDesignNodePosition(x: 0.50, y: 0.52, z: 30),
          size: MBDesignNodeSize(width: 160, height: 160),
          style: <String, Object?>{
            'borderHex': '#FFFFFF',
            'ringWidth': 7.0,
          },
        ),
        MBDesignNode(
          id: 'price_01',
          elementType: 'priceBadge',
          variantId: 'circle_top_right',
          binding: 'product.finalPrice',
          position: MBDesignNodePosition(x: 0.86, y: 0.12, z: 40),
          size: MBDesignNodeSize(width: 58, height: 58),
          style: <String, Object?>{
            'backgroundHex': '#FFE1CF',
            'textColorHex': '#0D4C7A',
            'borderHex': '#FFFFFF',
          },
        ),
        MBDesignNode(
          id: 'cta_01',
          elementType: 'secondaryCta',
          variantId: 'pill_button',
          binding: 'action.buy',
          position: MBDesignNodePosition(x: 0.82, y: 0.92, z: 40),
          size: MBDesignNodeSize(width: 62, height: 32),
          style: <String, Object?>{
            'backgroundHex': '#FF6500',
            'textColorHex': '#FFFFFF',
            'borderRadius': 999.0,
          },
        ),
      ],
    );
  }

  factory MBDesignDocument.fromLegacyMap(Map<String, Object?> map) {
    final visibleIds = _asStringSet(map['visibleElementIds']);
    final positions = _asMap(map['positionOverrides']);
    final sizes = _asMap(map['sizeOverrides']);
    final styles = _asMap(map['elementStyles']);

    final legacyIds = visibleIds.isEmpty
        ? const <String>{
            'title',
            'subtitle',
            'media',
            'priceBadge',
            'secondaryCta',
          }
        : visibleIds;

    final nodes = _normalizeNodes([
      for (final elementId in legacyIds)
        if (isRenderableElementType(elementId))
          _legacyNode(
            elementId: elementId,
            position: positions[elementId],
            size: sizes[elementId],
            style: styles[elementId],
          ),
    ]);

    return MBDesignDocument(
      version: 2,
      type: 'muthobazar_card_design_v2',
      templateId: _asString(
        map['templateId'],
        'hero_poster_circle_diagonal_v1',
      ),
      designFamilyId: _asString(
        map['designFamilyId'],
        'hero_poster_circle',
      ),
      selectedNodeId: _selectSafeNodeId(
        _asNullableString(map['activeElementId']),
        nodes,
      ),
      layout: _safeLayout(_asMap(map['layout'])),
      palette: _cleanMap(_asMap(map['palette'])),
      nodes: nodes.isEmpty ? MBDesignDocument.defaults().nodes : nodes,
      metadata: <String, Object?>{
        'migratedFrom': 'v1_visibleElementIds',
      },
    );
  }

  static MBDesignNode _legacyNode({
    required String elementId,
    required Object? position,
    required Object? size,
    required Object? style,
  }) {
    final nodeStyle = _cleanMap(_asMap(style));

    return MBDesignNode(
      id: '${elementId}_01',
      elementType: elementId,
      variantId: defaultVariantForElement(elementId),
      binding: defaultBindingForElement(elementId),
      position: _legacyPosition(elementId, position),
      size: _legacySize(elementId, size),
      style: nodeStyle.isEmpty ? defaultStyleForElement(elementId) : nodeStyle,
    );
  }

  static MBDesignNodePosition _legacyPosition(
    String elementId,
    Object? value,
  ) {
    final raw = MBDesignNodePosition.fromMap(value);

    if (value is Map || value is Map<String, Object?>) {
      return raw;
    }

    switch (elementId) {
      case 'title':
        return const MBDesignNodePosition(x: 0.30, y: 0.10, z: 20);
      case 'subtitle':
        return const MBDesignNodePosition(x: 0.34, y: 0.20, z: 20);
      case 'media':
        return const MBDesignNodePosition(x: 0.50, y: 0.52, z: 30);
      case 'priceBadge':
      case 'finalPrice':
        return const MBDesignNodePosition(x: 0.86, y: 0.12, z: 40);
      case 'secondaryCta':
      case 'primaryCta':
        return const MBDesignNodePosition(x: 0.82, y: 0.92, z: 40);
      case 'deliveryHint':
        return const MBDesignNodePosition(x: 0.28, y: 0.92, z: 35);
      case 'timer':
        return const MBDesignNodePosition(x: 0.25, y: 0.80, z: 35);
      default:
        return raw;
    }
  }

  static MBDesignNodeSize _legacySize(String elementId, Object? value) {
    final raw = MBDesignNodeSize.fromMap(value);

    if (raw.width != null || raw.height != null) {
      return raw;
    }

    switch (elementId) {
      case 'title':
        return const MBDesignNodeSize(width: 145, height: 38);
      case 'subtitle':
        return const MBDesignNodeSize(width: 170, height: 44);
      case 'media':
        return const MBDesignNodeSize(width: 160, height: 160);
      case 'priceBadge':
      case 'finalPrice':
        return const MBDesignNodeSize(width: 58, height: 58);
      case 'secondaryCta':
      case 'primaryCta':
        return const MBDesignNodeSize(width: 64, height: 32);
      case 'deliveryHint':
      case 'timer':
        return const MBDesignNodeSize(width: 110, height: 28);
      default:
        return raw;
    }
  }

  static String defaultVariantForElement(String elementId) {
    switch (elementId) {
      case 'media':
        return 'circle_ring';
      case 'priceBadge':
      case 'finalPrice':
        return 'circle_top_right';
      case 'secondaryCta':
      case 'primaryCta':
        return 'pill_button';
      case 'deliveryHint':
      case 'timer':
      case 'stockHint':
      case 'promoBadge':
      case 'savingBadge':
        return 'soft_chip';
      case 'title':
        return 'text_italic';
      case 'subtitle':
        return 'text_small';
      default:
        return 'basic';
    }
  }

  static String defaultBindingForElement(String elementId) {
    switch (elementId) {
      case 'title':
        return 'product.titleEn';
      case 'subtitle':
        return 'product.shortDescriptionEn';
      case 'media':
        return 'product.thumbnailUrl';
      case 'priceBadge':
      case 'finalPrice':
        return 'product.finalPrice';
      case 'secondaryCta':
      case 'primaryCta':
        return 'action.buy';
      case 'deliveryHint':
        return 'product.deliveryHint';
      case 'timer':
        return 'product.timer';
      case 'brand':
        return 'product.brandNameEn';
      case 'categoryChip':
        return 'product.categoryNameEn';
      case 'unitLabel':
        return 'product.unitLabelEn';
      default:
        return 'static';
    }
  }

  static Map<String, Object?> defaultStyleForElement(String elementId) {
    switch (elementId) {
      case 'title':
        return <String, Object?>{
          'textColorHex': '#FFFFFF',
          'fontSize': 18.0,
          'fontWeight': 'w900',
          'fontStyle': 'italic',
        };
      case 'subtitle':
        return <String, Object?>{
          'textColorHex': '#FFF2E7',
          'fontSize': 11.0,
        };
      case 'media':
        return <String, Object?>{
          'borderHex': '#FFFFFF',
          'ringWidth': 7.0,
        };
      case 'priceBadge':
      case 'finalPrice':
        return <String, Object?>{
          'backgroundHex': '#FFE1CF',
          'textColorHex': '#0D4C7A',
          'borderHex': '#FFFFFF',
        };
      case 'secondaryCta':
      case 'primaryCta':
        return <String, Object?>{
          'backgroundHex': '#FF6500',
          'textColorHex': '#FFFFFF',
          'borderRadius': 999.0,
        };
      default:
        return <String, Object?>{
          'backgroundHex': '#FFFFFF',
          'textColorHex': '#FF6500',
        };
    }
  }

  static List<MBDesignNode> _normalizeNodes(List<MBDesignNode> source) {
    final result = <MBDesignNode>[];
    final usedIds = <String>{};

    for (final node in source) {
      if (!node.isRenderable) {
        continue;
      }

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

  static String? _selectSafeNodeId(
    String? requestedId,
    List<MBDesignNode> nodes,
  ) {
    if (requestedId == null) {
      return null;
    }

    if (nodes.any((node) => node.id == requestedId)) {
      return requestedId;
    }

    final normalized = '${requestedId}_01';
    if (nodes.any((node) => node.id == normalized)) {
      return normalized;
    }

    return null;
  }

  static Map<String, Object?> _safeLayout(Map<String, Object?> value) {
    final cleaned = _cleanMap(value);

    return <String, Object?>{
      'cardWidth': _asDouble(cleaned['cardWidth'], 230).clamp(170, 330),
      'aspectRatio': _asDouble(cleaned['aspectRatio'], 0.58).clamp(0.42, 0.9),
      'minHeight': _asDouble(cleaned['minHeight'], 360).clamp(240, 600),
      'maxHeight': _asDouble(cleaned['maxHeight'], 420).clamp(280, 760),
    };
  }
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map<String, Object?>) {
    return Map<String, Object?>.from(value);
  }

  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }

  return <String, Object?>{};
}

Map<String, Object?> _cleanMap(Map<String, Object?> value) {
  final result = <String, Object?>{};

  for (final entry in value.entries) {
    final key = entry.key.trim();
    final item = entry.value;

    if (key.isEmpty || item == null) {
      continue;
    }

    if (item is String && item.trim().isEmpty) {
      continue;
    }

    result[key] = item;
  }

  return result;
}

Set<String> _asStringSet(Object? value) {
  if (value is! Iterable) {
    return <String>{};
  }

  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toSet();
}

String _asString(Object? value, String fallback) {
  final normalized = value?.toString().trim();

  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }

  return normalized;
}

String? _asNullableString(Object? value) {
  final normalized = value?.toString().trim();

  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}

double _asDouble(Object? value, double fallback) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

double? _asNullableDouble(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString().trim());
}

int _asInt(Object? value, int fallback) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

bool _asBool(Object? value, bool fallback) {
  if (value is bool) {
    return value;
  }

  final normalized = value?.toString().trim().toLowerCase();

  if (normalized == 'true') {
    return true;
  }

  if (normalized == 'false') {
    return false;
  }

  return fallback;
}
