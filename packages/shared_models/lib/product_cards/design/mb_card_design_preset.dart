import 'mb_card_design_config.dart';
import 'mb_card_design_family.dart';

// Reusable card design preset.

class MBCardDesignPreset {
  const MBCardDesignPreset({
    required this.id,
    required this.name,
    required this.designFamily,
    required this.templateId,
    required this.config,
    this.description = '',
    this.previewImageUrl,
    this.isActive = true,
    this.sortOrder = 0,
    this.tags = const <String>[],
    this.createdAt,
    this.updatedAt,
  });

  factory MBCardDesignPreset.fromMap(Map map) {
    return MBCardDesignPreset(
      id: _string(map['id']),
      name: _string(map['name']),
      designFamily: MBCardDesignFamilyHelper.parse(map['designFamilyId'] ?? map['familyId'] ?? map['family']),
      templateId: _string(map['templateId'] ?? map['template']),
      description: _string(map['description']),
      previewImageUrl: _stringOrNull(map['previewImageUrl']),
      isActive: _bool(map['isActive'], fallback: true),
      sortOrder: _int(map['sortOrder']),
      tags: _stringList(map['tags']),
      config: _config(map['config']),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  final String id;
  final String name;
  final MBCardDesignFamily designFamily;
  final String templateId;
  final String description;
  final String? previewImageUrl;
  final bool isActive;
  final int sortOrder;
  final List<String> tags;
  final MBCardDesignConfig config;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get designFamilyId => designFamily.id;

  Map<String, Object?> toMap() => _cleanMap({
        'id': id,
        'name': name,
        'designFamilyId': designFamily.id,
        'templateId': templateId,
        'description': description,
        'previewImageUrl': previewImageUrl,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'tags': tags,
        'config': config.toMap(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      });
}

MBCardDesignConfig _config(Object? value) {
  if (value is Map) return MBCardDesignConfig.fromMap(value);
  return const MBCardDesignConfig(
    designFamily: MBCardDesignFamily.heroPosterCircle,
    templateId: 'hero_poster_circle_diagonal_v1',
  );
}

String _string(Object? value) => value?.toString().trim() ?? '';

String? _stringOrNull(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

bool _bool(Object? value, {required bool fallback}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') return true;
  if (normalized == 'false' || normalized == '0' || normalized == 'no') return false;
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
  return value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList(growable: false);
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
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
