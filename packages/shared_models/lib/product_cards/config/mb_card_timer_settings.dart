// MuthoBazar Product Card Design System
// File: mb_card_timer_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_timer_settings.dart
//
// Purpose:
// Defines optional urgency/countdown settings for product cards.

class MBCardTimerSettings {
  const MBCardTimerSettings({
    this.showCountdown,
    this.countdownStyle,
    this.showSaleEndTime,
    this.urgencyColorToken,
  });

  factory MBCardTimerSettings.fromMap(Map map) {
    return MBCardTimerSettings(
      showCountdown: _readNullableBool(
        map['showCountdown'] ?? map['show_countdown'],
      ),
      countdownStyle: _readNullableString(
        map['countdownStyle'] ?? map['countdown_style'],
      ),
      showSaleEndTime: _readNullableBool(
        map['showSaleEndTime'] ?? map['show_sale_end_time'],
      ),
      urgencyColorToken: _readNullableString(
        map['urgencyColorToken'] ?? map['urgency_color_token'],
      ),
    );
  }

  final bool? showCountdown;
  final String? countdownStyle;
  final bool? showSaleEndTime;
  final String? urgencyColorToken;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showCountdown': showCountdown,
      'countdownStyle': countdownStyle,
      'showSaleEndTime': showSaleEndTime,
      'urgencyColorToken': urgencyColorToken,
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
