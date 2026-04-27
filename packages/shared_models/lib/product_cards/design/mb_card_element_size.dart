// MuthoBazar Product Card Design System V1
// File: mb_card_element_size.dart
//
// Purpose:
// Defines size/transform controls for a single design-card element.
//
// This model is intentionally generic so any element can support:
// - width / height
// - min/max width/height
// - scale
// - rotation
// - opacity
//
// Notes:
// - width/height are nullable. If null, renderer uses natural size.
// - scale defaults to 1.0.
// - rotation is in degrees.
// - opacity is 0.0 to 1.0.

class MBCardElementSize {
  const MBCardElementSize({
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.scale,
    this.rotation,
    this.opacity,
  });

  factory MBCardElementSize.fromMap(Map map) {
    return MBCardElementSize(
      width: _double(map['width'] ?? map['w']),
      height: _double(map['height'] ?? map['h']),
      minWidth: _double(map['minWidth'] ?? map['min_width']),
      maxWidth: _double(map['maxWidth'] ?? map['max_width']),
      minHeight: _double(map['minHeight'] ?? map['min_height']),
      maxHeight: _double(map['maxHeight'] ?? map['max_height']),
      scale: _double(map['scale']),
      rotation: _double(map['rotation'] ?? map['rotationDeg']),
      opacity: _double(map['opacity']),
    );
  }

  final double? width;
  final double? height;
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;
  final double? scale;

  // Degrees.
  final double? rotation;

  // 0.0 to 1.0
  final double? opacity;

  bool get hasExplicitWidth => width != null;
  bool get hasExplicitHeight => height != null;
  bool get hasExplicitSize => hasExplicitWidth || hasExplicitHeight;

  bool get hasConstraints {
    return minWidth != null ||
        maxWidth != null ||
        minHeight != null ||
        maxHeight != null;
  }

  bool get hasTransform {
    return scale != null || rotation != null || opacity != null;
  }

  bool get isEmpty => !hasExplicitSize && !hasConstraints && !hasTransform;
  bool get isNotEmpty => !isEmpty;

  double get effectiveScale => scale ?? 1.0;
  double get effectiveRotation => rotation ?? 0.0;
  double get effectiveOpacity => (opacity ?? 1.0).clamp(0.0, 1.0);

  MBCardElementSize copyWith({
    Object? width = _sentinel,
    Object? height = _sentinel,
    Object? minWidth = _sentinel,
    Object? maxWidth = _sentinel,
    Object? minHeight = _sentinel,
    Object? maxHeight = _sentinel,
    Object? scale = _sentinel,
    Object? rotation = _sentinel,
    Object? opacity = _sentinel,
  }) {
    return MBCardElementSize(
      width: identical(width, _sentinel) ? this.width : _nullableDouble(width),
      height:
          identical(height, _sentinel) ? this.height : _nullableDouble(height),
      minWidth: identical(minWidth, _sentinel)
          ? this.minWidth
          : _nullableDouble(minWidth),
      maxWidth: identical(maxWidth, _sentinel)
          ? this.maxWidth
          : _nullableDouble(maxWidth),
      minHeight: identical(minHeight, _sentinel)
          ? this.minHeight
          : _nullableDouble(minHeight),
      maxHeight: identical(maxHeight, _sentinel)
          ? this.maxHeight
          : _nullableDouble(maxHeight),
      scale: identical(scale, _sentinel) ? this.scale : _nullableDouble(scale),
      rotation: identical(rotation, _sentinel)
          ? this.rotation
          : _nullableDouble(rotation),
      opacity:
          identical(opacity, _sentinel) ? this.opacity : _nullableDouble(opacity),
    );
  }

  Map<String, Object?> toMap() {
    return _cleanMap({
      'width': width,
      'height': height,
      'minWidth': minWidth,
      'maxWidth': maxWidth,
      'minHeight': minHeight,
      'maxHeight': maxHeight,
      'scale': scale,
      'rotation': rotation,
      'opacity': opacity,
    });
  }

  @override
  String toString() {
    return 'MBCardElementSize('
        'width: $width, '
        'height: $height, '
        'minWidth: $minWidth, '
        'maxWidth: $maxWidth, '
        'minHeight: $minHeight, '
        'maxHeight: $maxHeight, '
        'scale: $scale, '
        'rotation: $rotation, '
        'opacity: $opacity'
        ')';
  }

  static const Object _sentinel = Object();
}

double? _double(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();

  return double.tryParse(value.toString().trim());
}

double? _nullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();

  return double.tryParse(value.toString().trim());
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(
    map.entries.where((entry) => entry.value != null),
  );
}
