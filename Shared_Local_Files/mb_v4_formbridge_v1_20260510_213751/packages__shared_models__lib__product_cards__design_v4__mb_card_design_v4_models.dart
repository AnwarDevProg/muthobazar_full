// MuthoBazar Card Design V4 Models
//
// Purpose:
// - Provides the durable, serializable Studio V4 design schema.
// - Lives in shared_models so admin editor, customer renderer, and future
//   backend tooling can all understand the same saved card-design JSON.
// - This file is a foundation-only schema. It does not replace Studio V3 yet.

import 'dart:convert';

enum MBDesignNodeTypeV4 {
  cardSurface,
  group,
  component,
  shape,
  text,
  media,
  price,
  badge,
  button,
  delivery,
  timer,
  stock,
  rating,
  divider,
  icon,
  unknown,
}

extension MBDesignNodeTypeV4X on MBDesignNodeTypeV4 {
  String get id => name;

  static MBDesignNodeTypeV4 parse(Object? value) {
    final raw = _asString(value, 'unknown').trim();
    for (final item in MBDesignNodeTypeV4.values) {
      if (item.name == raw) return item;
    }
    return MBDesignNodeTypeV4.unknown;
  }
}

class MBCardDesignDocumentV4 {
  const MBCardDesignDocumentV4({
    required this.id,
    this.schemaVersion = 4,
    this.type = 'muthobazar_card_design_v4',
    this.name = 'Untitled card design',
    this.canvas = const MBDesignCanvasSpecV4(),
    this.nodes = const <MBDesignNodeV4>[],
    this.tokens = const <MBDesignTokenV4>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final int schemaVersion;
  final String type;
  final String name;
  final MBDesignCanvasSpecV4 canvas;
  final List<MBDesignNodeV4> nodes;
  final List<MBDesignTokenV4> tokens;
  final Map<String, dynamic> metadata;

  List<MBDesignNodeV4> get sortedNodes => <MBDesignNodeV4>[...nodes]
        ..sort(MBDesignNodeV4.compareByLayer);

  MBDesignNodeV4? nodeById(String nodeId) {
    for (final node in nodes) {
      if (node.id == nodeId) return node;
    }
    return null;
  }

  MBCardDesignDocumentV4 copyWith({
    String? id,
    int? schemaVersion,
    String? type,
    String? name,
    MBDesignCanvasSpecV4? canvas,
    List<MBDesignNodeV4>? nodes,
    List<MBDesignTokenV4>? tokens,
    Map<String, dynamic>? metadata,
  }) {
    return MBCardDesignDocumentV4(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      type: type ?? this.type,
      name: name ?? this.name,
      canvas: canvas ?? this.canvas,
      nodes: nodes ?? this.nodes,
      tokens: tokens ?? this.tokens,
      metadata: metadata ?? this.metadata,
    );
  }

  MBCardDesignDocumentV4 upsertNode(MBDesignNodeV4 node) {
    var replaced = false;
    final next = <MBDesignNodeV4>[];
    for (final item in nodes) {
      if (item.id == node.id) {
        next.add(node);
        replaced = true;
      } else {
        next.add(item);
      }
    }
    if (!replaced) next.add(node);
    return copyWith(nodes: next..sort(MBDesignNodeV4.compareByLayer));
  }

  MBCardDesignDocumentV4 removeNode(String nodeId) {
    return copyWith(
      nodes: <MBDesignNodeV4>[
        for (final node in nodes)
          if (node.id != nodeId && node.parentId != nodeId) node,
      ],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'schemaVersion': schemaVersion,
      'type': type,
      'name': name,
      'canvas': canvas.toMap(),
      'nodes': <Map<String, dynamic>>[
        for (final node in sortedNodes) node.toMap(),
      ],
      if (tokens.isNotEmpty)
        'tokens': <Map<String, dynamic>>[
          for (final token in tokens) token.toMap(),
        ],
      if (metadata.isNotEmpty) 'metadata': _cleanMap(metadata),
    };
  }

  String toJson() => jsonEncode(toMap());

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }

  factory MBCardDesignDocumentV4.fromJson(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return MBCardDesignDocumentV4.blank();
    try {
      final decoded = jsonDecode(raw);
      return MBCardDesignDocumentV4.fromMap(decoded);
    } catch (_) {
      return MBCardDesignDocumentV4.blank();
    }
  }

  factory MBCardDesignDocumentV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    final rawNodes = map['nodes'];
    final rawTokens = map['tokens'];
    return MBCardDesignDocumentV4(
      id: _asString(
        map['id'],
        'design_v4_${DateTime.now().microsecondsSinceEpoch}',
      ),
      schemaVersion: _asInt(map['schemaVersion'], 4),
      type: _asString(map['type'], 'muthobazar_card_design_v4'),
      name: _asString(map['name'], 'Untitled card design'),
      canvas: MBDesignCanvasSpecV4.fromMap(map['canvas']),
      nodes: <MBDesignNodeV4>[
        if (rawNodes is Iterable)
          for (final item in rawNodes) MBDesignNodeV4.fromMap(item),
      ]..sort(MBDesignNodeV4.compareByLayer),
      tokens: <MBDesignTokenV4>[
        if (rawTokens is Iterable)
          for (final item in rawTokens) MBDesignTokenV4.fromMap(item),
      ],
      metadata: _cleanMap(_asStringMap(map['metadata'])),
    );
  }

  factory MBCardDesignDocumentV4.blank() {
    return MBCardDesignDocumentV4(
      id: 'design_v4_${DateTime.now().microsecondsSinceEpoch}',
    );
  }
}

class MBDesignCanvasSpecV4 {
  const MBDesignCanvasSpecV4({
    this.width = 200,
    this.height = 342,
    this.layoutType = 'hero_poster_circle_diagonal_v1',
    this.backgroundMode = 'gradient',
    this.backgroundColor = '#FF6500',
    this.backgroundGradientId = 'orangeGradient',
    this.borderRadius = 28,
  });

  final double width;
  final double height;
  final String layoutType;
  final String backgroundMode;
  final String? backgroundColor;
  final String? backgroundGradientId;
  final double borderRadius;

  MBDesignCanvasSpecV4 copyWith({
    double? width,
    double? height,
    String? layoutType,
    String? backgroundMode,
    String? backgroundColor,
    bool clearBackgroundColor = false,
    String? backgroundGradientId,
    bool clearBackgroundGradientId = false,
    double? borderRadius,
  }) {
    return MBDesignCanvasSpecV4(
      width: width ?? this.width,
      height: height ?? this.height,
      layoutType: layoutType ?? this.layoutType,
      backgroundMode: backgroundMode ?? this.backgroundMode,
      backgroundColor:
          clearBackgroundColor ? null : (backgroundColor ?? this.backgroundColor),
      backgroundGradientId: clearBackgroundGradientId
          ? null
          : (backgroundGradientId ?? this.backgroundGradientId),
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'layoutType': layoutType,
      'backgroundMode': backgroundMode,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (backgroundGradientId != null) 'backgroundGradientId': backgroundGradientId,
      'borderRadius': borderRadius,
    };
  }

  factory MBDesignCanvasSpecV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBDesignCanvasSpecV4(
      width: _asDouble(map['width'], 200).clamp(120.0, 900.0).toDouble(),
      height: _asDouble(map['height'], 342).clamp(160.0, 1200.0).toDouble(),
      layoutType: _asString(map['layoutType'], 'hero_poster_circle_diagonal_v1'),
      backgroundMode: _asString(map['backgroundMode'], 'gradient'),
      backgroundColor: _asNullableString(map['backgroundColor']),
      backgroundGradientId: _asNullableString(map['backgroundGradientId']),
      borderRadius: _asDouble(map['borderRadius'], 28).clamp(0.0, 120.0).toDouble(),
    );
  }
}

class MBDesignNodeV4 {
  const MBDesignNodeV4({
    required this.id,
    required this.name,
    this.type = MBDesignNodeTypeV4.unknown,
    this.parentId,
    this.visible = true,
    this.locked = false,
    this.transform = const MBDesignTransformV4(),
    this.style = const MBDesignStyleV4(),
    this.binding,
    this.content = const <String, dynamic>{},
    this.effects = const <MBDesignEffectV4>[],
    this.props = const <String, dynamic>{},
  });

  final String id;
  final String name;
  final MBDesignNodeTypeV4 type;
  final String? parentId;
  final bool visible;
  final bool locked;
  final MBDesignTransformV4 transform;
  final MBDesignStyleV4 style;
  final MBDesignBindingV4? binding;
  final Map<String, dynamic> content;
  final List<MBDesignEffectV4> effects;
  final Map<String, dynamic> props;

  static int compareByLayer(MBDesignNodeV4 a, MBDesignNodeV4 b) {
    final z = a.transform.zIndex.compareTo(b.transform.zIndex);
    if (z != 0) return z;
    return a.id.compareTo(b.id);
  }

  MBDesignNodeV4 copyWith({
    String? id,
    String? name,
    MBDesignNodeTypeV4? type,
    String? parentId,
    bool clearParentId = false,
    bool? visible,
    bool? locked,
    MBDesignTransformV4? transform,
    MBDesignStyleV4? style,
    MBDesignBindingV4? binding,
    bool clearBinding = false,
    Map<String, dynamic>? content,
    List<MBDesignEffectV4>? effects,
    Map<String, dynamic>? props,
  }) {
    return MBDesignNodeV4(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      transform: transform ?? this.transform,
      style: style ?? this.style,
      binding: clearBinding ? null : (binding ?? this.binding),
      content: content ?? this.content,
      effects: effects ?? this.effects,
      props: props ?? this.props,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type.id,
      if (parentId != null) 'parentId': parentId,
      'visible': visible,
      'locked': locked,
      'transform': transform.toMap(),
      if (style.isNotEmpty) 'style': style.toMap(),
      if (binding != null) 'binding': binding!.toMap(),
      if (content.isNotEmpty) 'content': _cleanMap(content),
      if (effects.isNotEmpty)
        'effects': <Map<String, dynamic>>[
          for (final effect in effects) effect.toMap(),
        ],
      if (props.isNotEmpty) 'props': _cleanMap(props),
    };
  }

  factory MBDesignNodeV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    final id = _asString(
      map['id'],
      'node_${DateTime.now().microsecondsSinceEpoch}',
    );
    return MBDesignNodeV4(
      id: id,
      name: _asString(map['name'], id),
      type: MBDesignNodeTypeV4X.parse(map['type']),
      parentId: _asNullableString(map['parentId']),
      visible: _asBool(map['visible'], true),
      locked: _asBool(map['locked'], false),
      transform: MBDesignTransformV4.fromMap(map['transform']),
      style: MBDesignStyleV4.fromMap(map['style']),
      binding: map.containsKey('binding')
          ? MBDesignBindingV4.fromMap(map['binding'])
          : null,
      content: _cleanMap(_asStringMap(map['content'])),
      effects: <MBDesignEffectV4>[
        if (map['effects'] is Iterable)
          for (final item in map['effects'] as Iterable)
            MBDesignEffectV4.fromMap(item),
      ],
      props: _cleanMap(_asStringMap(map['props'])),
    );
  }
}

class MBDesignTransformV4 {
  const MBDesignTransformV4({
    this.x = 0.5,
    this.y = 0.5,
    this.width = 120,
    this.height = 40,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.opacity = 1,
    this.zIndex = 10,
    this.anchor = 'center',
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final double scaleX;
  final double scaleY;
  final double opacity;
  final int zIndex;
  final String anchor;

  MBDesignTransformV4 copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? scaleX,
    double? scaleY,
    double? opacity,
    int? zIndex,
    String? anchor,
  }) {
    return MBDesignTransformV4(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex ?? this.zIndex,
      anchor: anchor ?? this.anchor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'scaleX': scaleX,
      'scaleY': scaleY,
      'opacity': opacity,
      'zIndex': zIndex,
      'anchor': anchor,
    };
  }

  factory MBDesignTransformV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBDesignTransformV4(
      x: _asDouble(map['x'], 0.5),
      y: _asDouble(map['y'], 0.5),
      width: _asDouble(map['width'], 120),
      height: _asDouble(map['height'], 40),
      rotation: _asDouble(map['rotation'], 0),
      scaleX: _asDouble(map['scaleX'], 1),
      scaleY: _asDouble(map['scaleY'], 1),
      opacity: _asDouble(map['opacity'], 1).clamp(0.0, 1.0).toDouble(),
      zIndex: _asInt(map['zIndex'], 10),
      anchor: _asString(map['anchor'], 'center'),
    );
  }
}

class MBDesignStyleV4 {
  const MBDesignStyleV4({
    this.fill,
    this.border,
    this.radius,
    this.shadows = const <MBShadowStyleV4>[],
    this.textStyleId,
    this.gradientId,
    this.blendMode,
    this.clipMode,
    this.extra = const <String, dynamic>{},
  });

  final String? fill;
  final MBBorderStyleV4? border;
  final double? radius;
  final List<MBShadowStyleV4> shadows;
  final String? textStyleId;
  final String? gradientId;
  final String? blendMode;
  final String? clipMode;
  final Map<String, dynamic> extra;

  bool get isNotEmpty => toMap().isNotEmpty;
  bool get isEmpty => !isNotEmpty;

  MBDesignStyleV4 copyWith({
    String? fill,
    bool clearFill = false,
    MBBorderStyleV4? border,
    bool clearBorder = false,
    double? radius,
    bool clearRadius = false,
    List<MBShadowStyleV4>? shadows,
    String? textStyleId,
    bool clearTextStyleId = false,
    String? gradientId,
    bool clearGradientId = false,
    String? blendMode,
    bool clearBlendMode = false,
    String? clipMode,
    bool clearClipMode = false,
    Map<String, dynamic>? extra,
  }) {
    return MBDesignStyleV4(
      fill: clearFill ? null : (fill ?? this.fill),
      border: clearBorder ? null : (border ?? this.border),
      radius: clearRadius ? null : (radius ?? this.radius),
      shadows: shadows ?? this.shadows,
      textStyleId: clearTextStyleId ? null : (textStyleId ?? this.textStyleId),
      gradientId: clearGradientId ? null : (gradientId ?? this.gradientId),
      blendMode: clearBlendMode ? null : (blendMode ?? this.blendMode),
      clipMode: clearClipMode ? null : (clipMode ?? this.clipMode),
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (fill != null) 'fill': fill,
      if (border != null) 'border': border!.toMap(),
      if (radius != null) 'radius': radius,
      if (shadows.isNotEmpty)
        'shadows': <Map<String, dynamic>>[
          for (final shadow in shadows) shadow.toMap(),
        ],
      if (textStyleId != null) 'textStyleId': textStyleId,
      if (gradientId != null) 'gradientId': gradientId,
      if (blendMode != null) 'blendMode': blendMode,
      if (clipMode != null) 'clipMode': clipMode,
      if (extra.isNotEmpty) ..._cleanMap(extra),
    };
  }

  factory MBDesignStyleV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBDesignStyleV4(
      fill: _asNullableString(map['fill']),
      border: map.containsKey('border') ? MBBorderStyleV4.fromMap(map['border']) : null,
      radius: map.containsKey('radius') ? _asDouble(map['radius'], 0) : null,
      shadows: <MBShadowStyleV4>[
        if (map['shadows'] is Iterable)
          for (final item in map['shadows'] as Iterable) MBShadowStyleV4.fromMap(item),
      ],
      textStyleId: _asNullableString(map['textStyleId']),
      gradientId: _asNullableString(map['gradientId']),
      blendMode: _asNullableString(map['blendMode']),
      clipMode: _asNullableString(map['clipMode']),
      extra: _cleanMap(<String, dynamic>{
        for (final entry in map.entries)
          if (!<String>{
            'fill',
            'border',
            'radius',
            'shadows',
            'textStyleId',
            'gradientId',
            'blendMode',
            'clipMode',
          }.contains(entry.key))
            entry.key: entry.value,
      }),
    );
  }
}

class MBBorderStyleV4 {
  const MBBorderStyleV4({
    this.color = '#000000',
    this.width = 1,
    this.style = 'solid',
  });

  final String color;
  final double width;
  final String style;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'color': color,
      'width': width,
      'style': style,
    };
  }

  factory MBBorderStyleV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBBorderStyleV4(
      color: _asString(map['color'], '#000000'),
      width: _asDouble(map['width'], 1),
      style: _asString(map['style'], 'solid'),
    );
  }
}

class MBShadowStyleV4 {
  const MBShadowStyleV4({
    this.color = '#33000000',
    this.blur = 12,
    this.spread = 0,
    this.offsetX = 0,
    this.offsetY = 4,
    this.inset = false,
  });

  final String color;
  final double blur;
  final double spread;
  final double offsetX;
  final double offsetY;
  final bool inset;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'color': color,
      'blur': blur,
      'spread': spread,
      'offsetX': offsetX,
      'offsetY': offsetY,
      'inset': inset,
    };
  }

  factory MBShadowStyleV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBShadowStyleV4(
      color: _asString(map['color'], '#33000000'),
      blur: _asDouble(map['blur'], 12),
      spread: _asDouble(map['spread'], 0),
      offsetX: _asDouble(map['offsetX'], 0),
      offsetY: _asDouble(map['offsetY'], 4),
      inset: _asBool(map['inset'], false),
    );
  }
}

class MBDesignBindingV4 {
  const MBDesignBindingV4({
    required this.source,
    required this.path,
    this.fallbackMode = 'empty',
    this.fallbackValue,
    this.formatter,
  });

  final String source;
  final String path;
  final String fallbackMode;
  final dynamic fallbackValue;
  final String? formatter;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'source': source,
      'path': path,
      'fallbackMode': fallbackMode,
      if (fallbackValue != null) 'fallbackValue': fallbackValue,
      if (formatter != null) 'formatter': formatter,
    };
  }

  factory MBDesignBindingV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBDesignBindingV4(
      source: _asString(map['source'], 'product'),
      path: _asString(map['path'], ''),
      fallbackMode: _asString(map['fallbackMode'], 'empty'),
      fallbackValue: map['fallbackValue'],
      formatter: _asNullableString(map['formatter']),
    );
  }
}

class MBDesignEffectV4 {
  const MBDesignEffectV4({
    required this.type,
    this.enabled = true,
    this.params = const <String, dynamic>{},
  });

  final String type;
  final bool enabled;
  final Map<String, dynamic> params;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'enabled': enabled,
      if (params.isNotEmpty) 'params': _cleanMap(params),
    };
  }

  factory MBDesignEffectV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBDesignEffectV4(
      type: _asString(map['type'], 'unknown'),
      enabled: _asBool(map['enabled'], true),
      params: _cleanMap(_asStringMap(map['params'])),
    );
  }
}

class MBDesignTokenV4 {
  const MBDesignTokenV4({
    required this.id,
    required this.type,
    required this.value,
    this.name,
  });

  final String id;
  final String type;
  final dynamic value;
  final String? name;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'value': value,
      if (name != null) 'name': name,
    };
  }

  factory MBDesignTokenV4.fromMap(Object? value) {
    final map = _asStringMap(value);
    return MBDesignTokenV4(
      id: _asString(map['id'], 'token_${DateTime.now().microsecondsSinceEpoch}'),
      type: _asString(map['type'], 'unknown'),
      value: map['value'],
      name: _asNullableString(map['name']),
    );
  }
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }
  return <String, dynamic>{};
}

Map<String, dynamic> _cleanMap(Map<String, dynamic> value) {
  return <String, dynamic>{
    for (final entry in value.entries)
      if (entry.value != null) entry.key: entry.value,
  };
}

String _asString(Object? value, String fallback) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return fallback;
  return text;
}

String? _asNullableString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

int _asInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(Object? value, double fallback) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(Object? value, bool fallback) {
  if (value is bool) return value;
  final text = value?.toString().trim().toLowerCase();
  if (text == 'true') return true;
  if (text == 'false') return false;
  return fallback;
}
