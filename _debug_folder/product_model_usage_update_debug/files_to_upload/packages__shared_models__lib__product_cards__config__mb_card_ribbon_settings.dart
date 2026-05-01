// MuthoBazar Product Card Design System
// File: mb_card_ribbon_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_ribbon_settings.dart
//
// Purpose:
// Defines optional ribbon/corner tag settings for product cards.

class MBCardRibbonSettings {
  const MBCardRibbonSettings({
    this.showRibbon,
    this.ribbonText,
    this.ribbonPlacement,
    this.ribbonColorToken,
    this.ribbonTextColorToken,
  });

  factory MBCardRibbonSettings.fromMap(Map map) {
    return MBCardRibbonSettings(
      showRibbon: _readNullableBool(map['showRibbon'] ?? map['show_ribbon']),
      ribbonText: _readNullableString(map['ribbonText'] ?? map['ribbon_text']),
      ribbonPlacement: _readNullableString(
        map['ribbonPlacement'] ?? map['ribbon_placement'],
      ),
      ribbonColorToken: _readNullableString(
        map['ribbonColorToken'] ?? map['ribbon_color_token'],
      ),
      ribbonTextColorToken: _readNullableString(
        map['ribbonTextColorToken'] ?? map['ribbon_text_color_token'],
      ),
    );
  }

  final bool? showRibbon;
  final String? ribbonText;
  final String? ribbonPlacement;
  final String? ribbonColorToken;
  final String? ribbonTextColorToken;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showRibbon': showRibbon,
      'ribbonText': ribbonText,
      'ribbonPlacement': ribbonPlacement,
      'ribbonColorToken': ribbonColorToken,
      'ribbonTextColorToken': ribbonTextColorToken,
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
