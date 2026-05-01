// MuthoBazar Product Card Design System
// File: mb_card_stock_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_stock_settings.dart
//
// Purpose:
// Defines optional stock display settings for product cards.

class MBCardStockSettings {
  const MBCardStockSettings({
    this.showStockStatus,
    this.showStockQty,
    this.showLowStockWarning,
    this.stockDisplayMode,
    this.lowStockThreshold,
  });

  factory MBCardStockSettings.fromMap(Map map) {
    return MBCardStockSettings(
      showStockStatus: _readNullableBool(
        map['showStockStatus'] ?? map['show_stock_status'],
      ),
      showStockQty: _readNullableBool(map['showStockQty'] ?? map['show_stock_qty']),
      showLowStockWarning: _readNullableBool(
        map['showLowStockWarning'] ?? map['show_low_stock_warning'],
      ),
      stockDisplayMode: _readNullableString(
        map['stockDisplayMode'] ?? map['stock_display_mode'],
      ),
      lowStockThreshold: _readNullableInt(
        map['lowStockThreshold'] ?? map['low_stock_threshold'],
      ),
    );
  }

  final bool? showStockStatus;
  final bool? showStockQty;
  final bool? showLowStockWarning;
  final String? stockDisplayMode;
  final int? lowStockThreshold;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'showStockStatus': showStockStatus,
      'showStockQty': showStockQty,
      'showLowStockWarning': showLowStockWarning,
      'stockDisplayMode': stockDisplayMode,
      'lowStockThreshold': lowStockThreshold,
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
