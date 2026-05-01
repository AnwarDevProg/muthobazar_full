import 'dart:convert';

// File: mb_product_purchase_option.dart
// MB Product Purchase Option Model
// --------------------------------
// Handles instant, scheduled, and fresh-product purchase flows.

class MBProductPurchaseOption {
final String id;
final String mode;
final String labelEn;
final String labelBn;
final double price;
final double? salePrice;
final bool isEnabled;
final bool supportsDateSelection;
final int minScheduleDays;
final int maxScheduleDays;
final List<String> availableShifts;
final String? cutoffTime;
final String? helperTextEn;
final String? helperTextBn;
final int sortOrder;
final bool isDefault;
final double? maxQtyPerOrder;
final String fulfillmentType;

const MBProductPurchaseOption({
required this.id,
required this.mode,
required this.labelEn,
required this.labelBn,
required this.price,
this.salePrice,
this.isEnabled = true,
this.supportsDateSelection = false,
this.minScheduleDays = 0,
this.maxScheduleDays = 0,
this.availableShifts = const [],
this.cutoffTime,
this.helperTextEn,
this.helperTextBn,
this.sortOrder = 0,
this.isDefault = false,
this.maxQtyPerOrder,
this.fulfillmentType = 'standard',
});

static const MBProductPurchaseOption empty = MBProductPurchaseOption(
id: '',
mode: '',
labelEn: '',
labelBn: '',
price: 0.0,
);

MBProductPurchaseOption copyWith({
String? id,
String? mode,
String? labelEn,
String? labelBn,
double? price,
double? salePrice,
bool clearSalePrice = false,
bool? isEnabled,
bool? supportsDateSelection,
int? minScheduleDays,
int? maxScheduleDays,
List<String>? availableShifts,
String? cutoffTime,
bool clearCutoffTime = false,
String? helperTextEn,
bool clearHelperTextEn = false,
String? helperTextBn,
bool clearHelperTextBn = false,
int? sortOrder,
bool? isDefault,
double? maxQtyPerOrder,
bool clearMaxQtyPerOrder = false,
String? fulfillmentType,
}) {
return MBProductPurchaseOption(
id: id ?? this.id,
mode: mode ?? this.mode,
labelEn: labelEn ?? this.labelEn,
labelBn: labelBn ?? this.labelBn,
price: price ?? this.price,
salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
isEnabled: isEnabled ?? this.isEnabled,
supportsDateSelection:
supportsDateSelection ?? this.supportsDateSelection,
minScheduleDays: minScheduleDays ?? this.minScheduleDays,
maxScheduleDays: maxScheduleDays ?? this.maxScheduleDays,
availableShifts: availableShifts ?? this.availableShifts,
cutoffTime: clearCutoffTime ? null : (cutoffTime ?? this.cutoffTime),
helperTextEn:
clearHelperTextEn ? null : (helperTextEn ?? this.helperTextEn),
helperTextBn:
clearHelperTextBn ? null : (helperTextBn ?? this.helperTextBn),
sortOrder: sortOrder ?? this.sortOrder,
isDefault: isDefault ?? this.isDefault,
maxQtyPerOrder: clearMaxQtyPerOrder
? null
    : (maxQtyPerOrder ?? this.maxQtyPerOrder),
fulfillmentType: fulfillmentType ?? this.fulfillmentType,
);
}

bool get hasDiscount => salePrice != null && salePrice! > 0 && salePrice! < price;

double get effectivePrice => hasDiscount ? salePrice! : price;

int get discountPercent {
if (!hasDiscount || price <= 0) return 0;
return (((price - salePrice!) / price) * 100).round();
}

bool get isScheduledMode => mode == 'scheduled';

Map<String, dynamic> toMap() {
return {
'id': id,
'mode': mode,
'labelEn': labelEn,
'labelBn': labelBn,
'price': price,
'salePrice': salePrice,
'isEnabled': isEnabled,
'supportsDateSelection': supportsDateSelection,
'minScheduleDays': minScheduleDays,
'maxScheduleDays': maxScheduleDays,
'availableShifts': availableShifts,
'cutoffTime': cutoffTime,
'helperTextEn': helperTextEn,
'helperTextBn': helperTextBn,
'sortOrder': sortOrder,
'isDefault': isDefault,
'maxQtyPerOrder': maxQtyPerOrder,
'fulfillmentType': fulfillmentType,
};
}

factory MBProductPurchaseOption.fromMap(Map<String, dynamic>? map) {
if (map == null) return empty;

return MBProductPurchaseOption(
id: (map['id'] ?? '').toString(),
mode: (map['mode'] ?? '').toString(),
labelEn: (map['labelEn'] ?? '').toString(),
labelBn: (map['labelBn'] ?? '').toString(),
price: _asDouble(map['price'], fallback: 0.0),
salePrice: _asNullableDouble(map['salePrice']),
isEnabled: _asBool(map['isEnabled'], fallback: true),
supportsDateSelection: _asBool(
map['supportsDateSelection'],
fallback: false,
),
minScheduleDays: _asInt(map['minScheduleDays'], fallback: 0),
maxScheduleDays: _asInt(map['maxScheduleDays'], fallback: 0),
availableShifts: List<String>.from(map['availableShifts'] ?? const []),
cutoffTime: map['cutoffTime']?.toString(),
helperTextEn: map['helperTextEn']?.toString(),
helperTextBn: map['helperTextBn']?.toString(),
sortOrder: _asInt(map['sortOrder'], fallback: 0),
isDefault: _asBool(map['isDefault'], fallback: false),
maxQtyPerOrder: _asNullableDouble(map['maxQtyPerOrder']),
fulfillmentType: (map['fulfillmentType'] ?? 'standard').toString(),
);
}

String toJson() => json.encode(toMap());

factory MBProductPurchaseOption.fromJson(String source) =>
MBProductPurchaseOption.fromMap(
json.decode(source) as Map<String, dynamic>,
);
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
if (value is double) return value;
if (value is num) return value.toDouble();
return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _asNullableDouble(dynamic value) {
if (value == null) return null;
if (value is double) return value;
if (value is num) return value.toDouble();
return double.tryParse(value.toString());
}

int _asInt(dynamic value, {int fallback = 0}) {
if (value is int) return value;
if (value is num) return value.toInt();
return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
if (value is bool) return value;
if (value is String) {
final normalized = value.trim().toLowerCase();
if (normalized == 'true') return true;
if (normalized == 'false') return false;
}
return fallback;
}
