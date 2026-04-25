// MuthoBazar Product Card Design System
// File: mb_card_indicator_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_indicator_settings.dart
//
// Purpose:
// Defines optional indicator/dot settings for product cards.

class MBCardIndicatorSettings {
  const MBCardIndicatorSettings({
    this.showDots,
    this.dotCount,
    this.activeDotCount,
    this.dotColorToken,
    this.inactiveDotColorToken,
    this.dotPlacement,
  });

  factory MBCardIndicatorSettings.fromMap(Map map) {
    return MBCardIndicatorSettings(
      showDots: _readNullableBool(map['showDots'] ?? map['show_dots']),
      dotCount: _readNullableInt(map['dotCount'] ?? map['dot_count']),
      activeDotCount: _readNullableInt(
        map['activeDotCount'] ?? map['active_dot_count'],
      ),
      dotColorToken: _readNullableString(
        map['dotColorToken'] ?? map['dot_color_token'],
      ),
      inactiveDotColorToken: _readNullableString(
        map['inactiveDotColorToken'] ?? map['inactive_dot_color_token'],
      ),
      dotPlacement: _readNullableString(
        map['dotPlacement'] ?? map['dot_placement'],
      ),
    );
  }

  final bool? showDots;
  final int? dotCount;
  final int? activeDotCount;
  final String? dotColorToken;
  final String? inactiveDotColorToken;
  final String? dotPlacement;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showDots': showDots,
      'dotCount': dotCount,
      'activeDotCount': activeDotCount,
      'dotColorToken': dotColorToken,
      'inactiveDotColorToken': inactiveDotColorToken,
      'dotPlacement': dotPlacement,
    });
  }
}


String? _readNullableString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

bool? _readNullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

double? _readNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(
    map.entries.where((entry) => entry.value != null),
  );
}
