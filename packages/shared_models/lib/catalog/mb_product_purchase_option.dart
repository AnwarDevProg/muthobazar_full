import 'dart:convert';

// MB Product Purchase Option Model
// --------------------------------
// Handles fresh-product purchase flows like:
// - Get today
// - Schedule for tomorrow
// - Schedule within N days
// Each option can have its own price, shifts, helper text, and cut-off.

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
    String? helperTextBn,
    bool clearHelperText = false,
  }) {
    return MBProductPurchaseOption(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      labelEn: labelEn ?? this.labelEn,
      labelBn: labelBn ?? this.labelBn,
      price: price ?? this.price,
      salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
      isEnabled: isEnabled ?? this.isEnabled,
      supportsDateSelection: supportsDateSelection ?? this.supportsDateSelection,
      minScheduleDays: minScheduleDays ?? this.minScheduleDays,
      maxScheduleDays: maxScheduleDays ?? this.maxScheduleDays,
      availableShifts: availableShifts ?? this.availableShifts,
      cutoffTime: clearCutoffTime ? null : (cutoffTime ?? this.cutoffTime),
      helperTextEn: clearHelperText ? null : (helperTextEn ?? this.helperTextEn),
      helperTextBn: clearHelperText ? null : (helperTextBn ?? this.helperTextBn),
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
    };
  }

  factory MBProductPurchaseOption.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBProductPurchaseOption(
      id: (map['id'] ?? '').toString(),
      mode: (map['mode'] ?? '').toString(),
      labelEn: (map['labelEn'] ?? '').toString(),
      labelBn: (map['labelBn'] ?? '').toString(),
      price: ((map['price'] ?? 0) as num).toDouble(),
      salePrice: map['salePrice'] == null ? null : ((map['salePrice'] as num).toDouble()),
      isEnabled: map['isEnabled'] ?? true,
      supportsDateSelection: map['supportsDateSelection'] ?? false,
      minScheduleDays: (map['minScheduleDays'] ?? 0) is int
          ? (map['minScheduleDays'] ?? 0) as int
          : int.tryParse((map['minScheduleDays'] ?? '0').toString()) ?? 0,
      maxScheduleDays: (map['maxScheduleDays'] ?? 0) is int
          ? (map['maxScheduleDays'] ?? 0) as int
          : int.tryParse((map['maxScheduleDays'] ?? '0').toString()) ?? 0,
      availableShifts: List<String>.from(map['availableShifts'] ?? const []),
      cutoffTime: map['cutoffTime']?.toString(),
      helperTextEn: map['helperTextEn']?.toString(),
      helperTextBn: map['helperTextBn']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductPurchaseOption.fromJson(String source) =>
      MBProductPurchaseOption.fromMap(json.decode(source) as Map<String, dynamic>);
}












