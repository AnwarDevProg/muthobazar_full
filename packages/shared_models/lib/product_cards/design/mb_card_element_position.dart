// MuthoBazar Product Card Design System V1
// File: mb_card_element_position.dart
//
// Purpose:
// Defines slot-based and free-position placement for card elements.
//
// Important fix:
// Slider values and debug/default values can arrive as int or double.
// copyWith() must safely normalize x/y/z to double? instead of casting directly.
// This prevents runtime errors like:
// type 'int' is not a subtype of type 'double?' in type cast.

enum MBCardElementPositionMode {
  slot,
  free,
}

extension MBCardElementPositionModeX on MBCardElementPositionMode {
  String get id {
    switch (this) {
      case MBCardElementPositionMode.slot:
        return 'slot';
      case MBCardElementPositionMode.free:
        return 'free';
    }
  }
}

class MBCardElementPositionModeHelper {
  const MBCardElementPositionModeHelper._();

  static MBCardElementPositionMode parse(
    Object? value, {
    MBCardElementPositionMode fallback = MBCardElementPositionMode.slot,
  }) {
    final normalized = value?.toString().trim().toLowerCase();

    if (normalized == null || normalized.isEmpty) {
      return fallback;
    }

    for (final mode in MBCardElementPositionMode.values) {
      if (mode.id == normalized || mode.name.toLowerCase() == normalized) {
        return mode;
      }
    }

    return fallback;
  }
}

class MBCardElementPosition {
  const MBCardElementPosition({
    this.mode = MBCardElementPositionMode.slot,
    this.slot = 'bodyCenter',
    this.x,
    this.y,
    this.z,
    this.anchor,
    this.alignment,
  });

  factory MBCardElementPosition.fromMap(Map map) {
    return MBCardElementPosition(
      mode: MBCardElementPositionModeHelper.parse(
        map['mode'] ?? map['positionMode'] ?? map['position_mode'],
      ),
      slot: _string(map['slot'], fallback: 'bodyCenter'),
      x: _double(map['x']),
      y: _double(map['y']),
      z: _double(map['z']),
      anchor: _stringOrNull(map['anchor']),
      alignment: _stringOrNull(map['alignment']),
    );
  }

  final MBCardElementPositionMode mode;
  final String slot;

  // Normalized coordinates used in free mode:
  // x: 0.0 left -> 1.0 right
  // y: 0.0 top  -> 1.0 bottom
  // z: layer/order
  final double? x;
  final double? y;
  final double? z;

  final String? anchor;
  final String? alignment;

  bool get isSlotBased => mode == MBCardElementPositionMode.slot;
  bool get isFreePositioned => mode == MBCardElementPositionMode.free;

  MBCardElementPosition copyWith({
    MBCardElementPositionMode? mode,
    String? slot,
    Object? x = _sentinel,
    Object? y = _sentinel,
    Object? z = _sentinel,
    Object? anchor = _sentinel,
    Object? alignment = _sentinel,
  }) {
    return MBCardElementPosition(
      mode: mode ?? this.mode,
      slot: slot ?? this.slot,
      x: identical(x, _sentinel) ? this.x : _nullableDouble(x),
      y: identical(y, _sentinel) ? this.y : _nullableDouble(y),
      z: identical(z, _sentinel) ? this.z : _nullableDouble(z),
      anchor: identical(anchor, _sentinel)
          ? this.anchor
          : _nullableString(anchor),
      alignment: identical(alignment, _sentinel)
          ? this.alignment
          : _nullableString(alignment),
    );
  }

  Map<String, Object?> toMap() {
    return _cleanMap({
      'mode': mode.id,
      'slot': slot,
      'x': x,
      'y': y,
      'z': z,
      'anchor': anchor,
      'alignment': alignment,
    });
  }

  @override
  String toString() {
    return 'MBCardElementPosition('
        'mode: ${mode.id}, '
        'slot: $slot, '
        'x: $x, '
        'y: $y, '
        'z: $z, '
        'anchor: $anchor, '
        'alignment: $alignment'
        ')';
  }

  static const Object _sentinel = Object();
}

String _string(
  Object? value, {
  required String fallback,
}) {
  final normalized = value?.toString().trim();

  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }

  return normalized;
}

String? _stringOrNull(Object? value) {
  final normalized = value?.toString().trim();

  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}

String? _nullableString(Object? value) {
  if (value == null) {
    return null;
  }

  return _stringOrNull(value);
}

double? _double(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString().trim());
}

double? _nullableDouble(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString().trim());
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(
    map.entries.where((entry) {
      final value = entry.value;
      if (value == null) return false;
      if (value is String && value.trim().isEmpty) return false;
      return true;
    }),
  );
}
