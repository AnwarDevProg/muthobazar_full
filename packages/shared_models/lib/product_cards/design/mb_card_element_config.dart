import 'mb_card_element_binding.dart';
import 'mb_card_element_position.dart';
import 'mb_card_element_size.dart';
import 'mb_card_element_style.dart';
import 'mb_card_element_type.dart';

// MuthoBazar Product Card Design System V1
// File: mb_card_element_config.dart
//
// Purpose:
// Defines a single configurable card element.
// Examples: title, media, price, CTA, badge, rating, ribbon.
//
// This version includes copyWith(), needed by the design lab/admin studio
// to toggle visibility and build safe config overrides.

class MBCardElementConfig {
  const MBCardElementConfig({
    required this.elementId,
    required this.type,
    this.visible = true,
    this.slot = 'bodyCenter',
    this.stylePreset,
    this.position,
    this.size,
    this.style,
    this.binding,
    this.children = const <String>[],
    this.order = 0,
    this.enabledInEditor = true,
    this.extra = const <String, Object?>{},
  });

  factory MBCardElementConfig.fromMap(Map map) {
    return MBCardElementConfig(
      elementId: _string(map['elementId'] ?? map['id']),
      type: MBCardElementTypeHelper.parse(map['type']),
      visible: _bool(map['visible'], fallback: true),
      slot: _string(map['slot'], fallback: 'bodyCenter'),
      stylePreset: _stringOrNull(
        map['stylePreset'] ?? map['style_preset'],
      ),
      position: _map(
        map['position'],
        MBCardElementPosition.fromMap,
      ),
      size: _map(
        map['size'],
        MBCardElementSize.fromMap,
      ),
      style: _map(
        map['style'],
        MBCardElementStyle.fromMap,
      ),
      binding: _binding(map['binding']),
      children: _stringList(map['children']),
      order: _int(map['order']),
      enabledInEditor: _bool(
        map['enabledInEditor'] ?? map['enabled_in_editor'],
        fallback: true,
      ),
      extra: _readExtra(map['extra']),
    );
  }

  final String elementId;
  final MBCardElementType type;
  final bool visible;

  // Common shortcut for slot-based placement.
  final String slot;

  // Named preset; renderer resolves this into a visual style.
  final String? stylePreset;

  final MBCardElementPosition? position;
  final MBCardElementSize? size;
  final MBCardElementStyle? style;
  final MBCardElementBinding? binding;

  final List<String> children;
  final int order;
  final bool enabledInEditor;

  final Map<String, Object?> extra;

  String get typeId => type.id;

  MBCardElementPosition get effectivePosition {
    return position ?? MBCardElementPosition(slot: slot);
  }

  Map<String, Object?> toMap() {
    return _cleanMap({
      'elementId': elementId,
      'type': type.id,
      'visible': visible,
      'slot': slot,
      'stylePreset': stylePreset,
      'position': position?.toMap(),
      'size': size?.toMap(),
      'style': style?.toMap(),
      'binding': binding?.toMap(),
      'children': children,
      'order': order,
      'enabledInEditor': enabledInEditor,
      if (extra.isNotEmpty) 'extra': extra,
    });
  }

  MBCardElementConfig copyWith({
    String? elementId,
    MBCardElementType? type,
    bool? visible,
    String? slot,
    Object? stylePreset = _sentinel,
    Object? position = _sentinel,
    Object? size = _sentinel,
    Object? style = _sentinel,
    Object? binding = _sentinel,
    List<String>? children,
    int? order,
    bool? enabledInEditor,
    Map<String, Object?>? extra,
  }) {
    return MBCardElementConfig(
      elementId: elementId ?? this.elementId,
      type: type ?? this.type,
      visible: visible ?? this.visible,
      slot: slot ?? this.slot,
      stylePreset: identical(stylePreset, _sentinel)
          ? this.stylePreset
          : _stringOrNull(stylePreset),
      position: identical(position, _sentinel)
          ? this.position
          : position as MBCardElementPosition?,
      size: identical(size, _sentinel)
          ? this.size
          : size as MBCardElementSize?,
      style: identical(style, _sentinel)
          ? this.style
          : style as MBCardElementStyle?,
      binding: identical(binding, _sentinel)
          ? this.binding
          : binding as MBCardElementBinding?,
      children: children ?? this.children,
      order: order ?? this.order,
      enabledInEditor: enabledInEditor ?? this.enabledInEditor,
      extra: extra ?? this.extra,
    );
  }

  static const Object _sentinel = Object();
}

T? _map<T>(Object? value, T Function(Map map) builder) {
  if (value is Map) {
    return builder(value);
  }

  return null;
}

MBCardElementBinding? _binding(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is String) {
    return MBCardElementBinding(source: value);
  }

  if (value is Map) {
    return MBCardElementBinding.fromMap(value);
  }

  return null;
}

String _string(Object? value, {String fallback = ''}) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return fallback;
  return normalized;
}

String? _stringOrNull(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

bool _bool(Object? value, {required bool fallback}) {
  if (value == null) return fallback;
  if (value is bool) return value;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }

  return fallback;
}

int _int(Object? value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? 0;
}

List<String> _stringList(Object? value) {
  if (value is! Iterable) return const <String>[];

  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

Map<String, Object?> _readExtra(Object? value) {
  if (value is Map<String, Object?>) {
    return Map<String, Object?>.from(value);
  }

  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }

  return const <String, Object?>{};
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(
    map.entries.where((entry) {
      final value = entry.value;
      if (value == null) return false;
      if (value is String && value.isEmpty) return false;
      if (value is Iterable && value.isEmpty) return false;
      if (value is Map && value.isEmpty) return false;
      return true;
    }),
  );
}
