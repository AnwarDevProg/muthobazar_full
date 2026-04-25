// MuthoBazar Product Card Design System
// File: mb_card_progress_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_progress_settings.dart
//
// Purpose:
// Defines optional progress bar settings for stock/sale/card states.

class MBCardProgressSettings {
  const MBCardProgressSettings({
    this.showProgressBar,
    this.progressType,
    this.progressColorToken,
    this.showProgressText,
  });

  factory MBCardProgressSettings.fromMap(Map map) {
    return MBCardProgressSettings(
      showProgressBar: _readNullableBool(
        map['showProgressBar'] ?? map['show_progress_bar'],
      ),
      progressType: _readNullableString(
        map['progressType'] ?? map['progress_type'],
      ),
      progressColorToken: _readNullableString(
        map['progressColorToken'] ?? map['progress_color_token'],
      ),
      showProgressText: _readNullableBool(
        map['showProgressText'] ?? map['show_progress_text'],
      ),
    );
  }

  final bool? showProgressBar;
  final String? progressType;
  final String? progressColorToken;
  final bool? showProgressText;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showProgressBar': showProgressBar,
      'progressType': progressType,
      'progressColorToken': progressColorToken,
      'showProgressText': showProgressText,
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
