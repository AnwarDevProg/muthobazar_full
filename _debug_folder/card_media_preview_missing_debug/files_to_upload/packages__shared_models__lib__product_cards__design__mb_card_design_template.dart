import 'mb_card_design_family.dart';

// Design template and footprint definitions.

enum MBCardFootprintType {
  halfWidth,
  tallHalfWidth,
  fullWidth,
  squarePromo,
  wideBanner,
  compactList,
  heroPoster,
}

extension MBCardFootprintTypeX on MBCardFootprintType {
  String get id {
    switch (this) {
      case MBCardFootprintType.halfWidth:
        return 'half_width';
      case MBCardFootprintType.tallHalfWidth:
        return 'tall_half_width';
      case MBCardFootprintType.fullWidth:
        return 'full_width';
      case MBCardFootprintType.squarePromo:
        return 'square_promo';
      case MBCardFootprintType.wideBanner:
        return 'wide_banner';
      case MBCardFootprintType.compactList:
        return 'compact_list';
      case MBCardFootprintType.heroPoster:
        return 'hero_poster';
    }
  }

  bool get isFullWidth {
    switch (this) {
      case MBCardFootprintType.fullWidth:
      case MBCardFootprintType.wideBanner:
      case MBCardFootprintType.compactList:
      case MBCardFootprintType.heroPoster:
        return true;
      case MBCardFootprintType.halfWidth:
      case MBCardFootprintType.tallHalfWidth:
      case MBCardFootprintType.squarePromo:
        return false;
    }
  }

  int get columnSpan => isFullWidth ? 2 : 1;
}

class MBCardFootprintTypeHelper {
  const MBCardFootprintTypeHelper._();

  static MBCardFootprintType parse(
    Object? value, {
    MBCardFootprintType fallback = MBCardFootprintType.halfWidth,
  }) {
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return fallback;

    for (final type in MBCardFootprintType.values) {
      if (type.id == normalized || type.name.toLowerCase() == normalized) {
        return type;
      }
    }

    switch (normalized) {
      case 'half':
      case 'halfwidth':
        return MBCardFootprintType.halfWidth;
      case 'tallhalf':
      case 'tall_half':
        return MBCardFootprintType.tallHalfWidth;
      case 'full':
      case 'fullwidth':
        return MBCardFootprintType.fullWidth;
      case 'square':
      case 'promo_square':
        return MBCardFootprintType.squarePromo;
      case 'wide':
      case 'banner':
        return MBCardFootprintType.wideBanner;
      case 'list':
      case 'horizontal':
        return MBCardFootprintType.compactList;
      case 'poster':
      case 'hero':
        return MBCardFootprintType.heroPoster;
      default:
        return fallback;
    }
  }
}

class MBCardDesignTemplate {
  const MBCardDesignTemplate({
    required this.id,
    required this.family,
    required this.label,
    required this.footprint,
    this.description = '',
    this.defaultAspectRatio,
    this.defaultPreferredHeight,
    this.defaultMinHeight,
    this.defaultMaxHeight,
    this.supportedElementIds = const <String>[],
  });

  factory MBCardDesignTemplate.fromMap(Map map) {
    return MBCardDesignTemplate(
      id: _string(map['id']),
      family: MBCardDesignFamilyHelper.parse(map['familyId'] ?? map['family']),
      label: _string(map['label']),
      footprint: MBCardFootprintTypeHelper.parse(map['footprint']),
      description: _string(map['description']),
      defaultAspectRatio: _double(map['defaultAspectRatio']),
      defaultPreferredHeight: _double(map['defaultPreferredHeight']),
      defaultMinHeight: _double(map['defaultMinHeight']),
      defaultMaxHeight: _double(map['defaultMaxHeight']),
      supportedElementIds: _stringList(map['supportedElementIds']),
    );
  }

  final String id;
  final MBCardDesignFamily family;
  final String label;
  final MBCardFootprintType footprint;
  final String description;
  final double? defaultAspectRatio;
  final double? defaultPreferredHeight;
  final double? defaultMinHeight;
  final double? defaultMaxHeight;
  final List<String> supportedElementIds;

  String get familyId => family.id;
  bool get isFullWidth => footprint.isFullWidth;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'id': id,
      'familyId': family.id,
      'label': label,
      'footprint': footprint.id,
      'description': description,
      'defaultAspectRatio': defaultAspectRatio,
      'defaultPreferredHeight': defaultPreferredHeight,
      'defaultMinHeight': defaultMinHeight,
      'defaultMaxHeight': defaultMaxHeight,
      'supportedElementIds': supportedElementIds,
    });
  }
}

String _string(Object? value) => value?.toString().trim() ?? '';

double? _double(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

List<String> _stringList(Object? value) {
  if (value is! Iterable) return const <String>[];
  return value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList(growable: false);
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
