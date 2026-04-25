// MuthoBazar Product Card Design System
// File: mb_card_quantity_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_quantity_settings.dart
//
// Purpose:
// Defines optional quantity selector settings for product cards.

class MBCardQuantitySettings {
  const MBCardQuantitySettings({
    this.showQuantitySelector,
    this.showUnitLabel,
    this.selectorStyle,
    this.minQty,
    this.maxQty,
    this.stepQty,
  });

  factory MBCardQuantitySettings.fromMap(Map map) {
    return MBCardQuantitySettings(
      showQuantitySelector: _readNullableBool(
        map['showQuantitySelector'] ?? map['show_quantity_selector'],
      ),
      showUnitLabel: _readNullableBool(
        map['showUnitLabel'] ?? map['show_unit_label'],
      ),
      selectorStyle: _readNullableString(
        map['selectorStyle'] ?? map['selector_style'],
      ),
      minQty: _readNullableDouble(map['minQty'] ?? map['min_qty']),
      maxQty: _readNullableDouble(map['maxQty'] ?? map['max_qty']),
      stepQty: _readNullableDouble(map['stepQty'] ?? map['step_qty']),
    );
  }

  final bool? showQuantitySelector;
  final bool? showUnitLabel;
  final String? selectorStyle;
  final double? minQty;
  final double? maxQty;
  final double? stepQty;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showQuantitySelector': showQuantitySelector,
      'showUnitLabel': showUnitLabel,
      'selectorStyle': selectorStyle,
      'minQty': minQty,
      'maxQty': maxQty,
      'stepQty': stepQty,
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
