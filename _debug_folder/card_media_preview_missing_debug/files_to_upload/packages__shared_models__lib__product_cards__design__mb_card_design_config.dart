import '../config/mb_card_background_settings.dart';
import '../config/mb_card_layout_settings.dart';
import '../config/mb_card_surface_settings.dart';
import 'mb_card_design_family.dart';
import 'mb_card_element_config.dart';

// Saved design config for product cards.
// This can live beside old cardConfig during migration.

class MBCardDesignConfig {
  const MBCardDesignConfig({
    required this.designFamily,
    required this.templateId,
    this.version = 1,
    this.presetId,
    this.layout,
    this.surface,
    this.background,
    this.elements = const <String, MBCardElementConfig>{},
    this.bindings = const <String, String>{},
    this.metadata = const <String, Object?>{},
  });

  factory MBCardDesignConfig.fromMap(Map map) {
    return MBCardDesignConfig(
      designFamily: MBCardDesignFamilyHelper.parse(map['designFamilyId'] ?? map['familyId'] ?? map['family']),
      templateId: _string(map['templateId'] ?? map['template']),
      version: _int(map['version'], fallback: 1),
      presetId: _stringOrNull(map['presetId'] ?? map['preset']),
      layout: _group(map['layout'], MBCardLayoutSettings.fromMap),
      surface: _group(map['surface'], MBCardSurfaceSettings.fromMap),
      background: _group(map['background'], MBCardBackgroundSettings.fromMap),
      elements: _elements(map['elements']),
      bindings: _stringMap(map['bindings']),
      metadata: _objectMap(map['metadata']),
    );
  }

  final MBCardDesignFamily designFamily;
  final String templateId;
  final int version;
  final String? presetId;
  final MBCardLayoutSettings? layout;
  final MBCardSurfaceSettings? surface;
  final MBCardBackgroundSettings? background;
  final Map<String, MBCardElementConfig> elements;
  final Map<String, String> bindings;
  final Map<String, Object?> metadata;

  String get designFamilyId => designFamily.id;
  bool get hasPreset => presetId != null && presetId!.trim().isNotEmpty;
  bool get hasElements => elements.isNotEmpty;

  Map<String, Object?> toMap() => _cleanMap({
        'designFamilyId': designFamily.id,
        'templateId': templateId,
        'version': version,
        'presetId': presetId,
        'layout': layout?.toMap(),
        'surface': surface?.toMap(),
        'background': background?.toMap(),
        'elements': elements.map((key, value) => MapEntry(key, value.toMap())),
        'bindings': bindings,
        'metadata': metadata,
      });

  MBCardDesignConfig copyWith({
    MBCardDesignFamily? designFamily,
    String? templateId,
    int? version,
    Object? presetId = _sentinel,
    Object? layout = _sentinel,
    Object? surface = _sentinel,
    Object? background = _sentinel,
    Map<String, MBCardElementConfig>? elements,
    Map<String, String>? bindings,
    Map<String, Object?>? metadata,
  }) {
    return MBCardDesignConfig(
      designFamily: designFamily ?? this.designFamily,
      templateId: templateId ?? this.templateId,
      version: version ?? this.version,
      presetId: identical(presetId, _sentinel) ? this.presetId : _stringOrNull(presetId),
      layout: identical(layout, _sentinel) ? this.layout : layout as MBCardLayoutSettings?,
      surface: identical(surface, _sentinel) ? this.surface : surface as MBCardSurfaceSettings?,
      background: identical(background, _sentinel) ? this.background : background as MBCardBackgroundSettings?,
      elements: elements ?? this.elements,
      bindings: bindings ?? this.bindings,
      metadata: metadata ?? this.metadata,
    );
  }

  static const Object _sentinel = Object();
}

T? _group<T>(Object? value, T Function(Map map) builder) => value is Map ? builder(value) : null;

Map<String, MBCardElementConfig> _elements(Object? value) {
  if (value is! Map) return const <String, MBCardElementConfig>{};
  final result = <String, MBCardElementConfig>{};
  value.forEach((key, rawElement) {
    if (rawElement is Map) {
      final id = key.toString();
      result[id] = MBCardElementConfig.fromMap({'elementId': id, ...rawElement});
    }
  });
  return Map<String, MBCardElementConfig>.unmodifiable(result);
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) return const <String, String>{};
  return Map<String, String>.unmodifiable(value.map((key, val) => MapEntry(key.toString(), val.toString())));
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is Map<String, Object?>) return Map<String, Object?>.unmodifiable(value);
  if (value is Map) return Map<String, Object?>.unmodifiable(value.map((key, val) => MapEntry(key.toString(), val)));
  return const <String, Object?>{};
}

String _string(Object? value) => value?.toString().trim() ?? '';

String? _stringOrNull(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

int _int(Object? value, {required int fallback}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? fallback;
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(map.entries.where((entry) {
    final value = entry.value;
    if (value == null) return false;
    if (value is String && value.isEmpty) return false;
    if (value is Iterable && value.isEmpty) return false;
    if (value is Map && value.isEmpty) return false;
    return true;
  }));
}
