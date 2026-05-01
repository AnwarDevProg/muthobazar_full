// MuthoBazar Product Card Design System
// File: mb_card_delivery_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_delivery_settings.dart
//
// Purpose:
// Defines optional delivery display settings for product cards.

class MBCardDeliverySettings {
  const MBCardDeliverySettings({
    this.showDeliveryTime,
    this.showFreeDelivery,
    this.showDeliveryBadge,
    this.deliveryStyleToken,
  });

  factory MBCardDeliverySettings.fromMap(Map map) {
    return MBCardDeliverySettings(
      showDeliveryTime: _readNullableBool(
        map['showDeliveryTime'] ?? map['show_delivery_time'],
      ),
      showFreeDelivery: _readNullableBool(
        map['showFreeDelivery'] ?? map['show_free_delivery'],
      ),
      showDeliveryBadge: _readNullableBool(
        map['showDeliveryBadge'] ?? map['show_delivery_badge'],
      ),
      deliveryStyleToken: _readNullableString(
        map['deliveryStyleToken'] ?? map['delivery_style_token'],
      ),
    );
  }

  final bool? showDeliveryTime;
  final bool? showFreeDelivery;
  final bool? showDeliveryBadge;
  final String? deliveryStyleToken;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showDeliveryTime': showDeliveryTime,
      'showFreeDelivery': showFreeDelivery,
      'showDeliveryBadge': showDeliveryBadge,
      'deliveryStyleToken': deliveryStyleToken,
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
