// MBCartItem (FINAL - Production Ready)
// ------------------------------------
// Supports:
// - Instant + Scheduled orders
// - Estimated price (fresh items)
// - Final price override
// - Cart merge & update (copyWith)
// - Safe Firestore serialization

class MBCartItem {
  final String productId;

  final String titleEn;
  final String titleBn;

  final String? imageUrl;       // optional (UI use)
  final String? variationId;    // optional (future variants)

  final double unitPrice;
  final double? finalUnitPrice;

  final bool isEstimatedPrice;

  final int quantity;

  final String purchaseMode; // instant | scheduled

  final DateTime? selectedDate;
  final String? selectedShift;

  const MBCartItem({
    required this.productId,
    required this.titleEn,
    required this.titleBn,
    required this.unitPrice,
    required this.quantity,

    this.imageUrl,
    this.variationId,

    this.purchaseMode = 'instant',
    this.selectedDate,
    this.selectedShift,

    this.isEstimatedPrice = false,
    this.finalUnitPrice,
  });

  // --------------------------------------------------
  // 🔹 COMPUTED
  // --------------------------------------------------

  double get effectivePrice => finalUnitPrice ?? unitPrice;

  double get total => effectivePrice * quantity;

  bool get isScheduled => purchaseMode == 'scheduled';

  bool get isInstant => purchaseMode == 'instant';

  // --------------------------------------------------
  // 🔹 COPY WITH (VERY IMPORTANT)
  // --------------------------------------------------

  MBCartItem copyWith({
    String? productId,
    String? titleEn,
    String? titleBn,
    String? imageUrl,
    String? variationId,
    double? unitPrice,
    double? finalUnitPrice,
    bool clearFinalUnitPrice = false,
    bool? isEstimatedPrice,
    int? quantity,
    String? purchaseMode,
    DateTime? selectedDate,
    String? selectedShift,
    bool clearDate = false,
    bool clearShift = false,
  }) {
    return MBCartItem(
      productId: productId ?? this.productId,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      imageUrl: imageUrl ?? this.imageUrl,
      variationId: variationId ?? this.variationId,
      unitPrice: unitPrice ?? this.unitPrice,
      finalUnitPrice: clearFinalUnitPrice
          ? null
          : (finalUnitPrice ?? this.finalUnitPrice),
      isEstimatedPrice: isEstimatedPrice ?? this.isEstimatedPrice,
      quantity: quantity ?? this.quantity,
      purchaseMode: purchaseMode ?? this.purchaseMode,
      selectedDate: clearDate
          ? null
          : (selectedDate ?? this.selectedDate),
      selectedShift: clearShift
          ? null
          : (selectedShift ?? this.selectedShift),
    );
  }

  // --------------------------------------------------
  // 🔹 UNIQUE KEY (for merging items in cart)
  // --------------------------------------------------

  String get uniqueKey {
    final dateKey = selectedDate != null
        ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
        : 'no_date';

    return '$productId|$variationId|$purchaseMode|$dateKey|${selectedShift ?? ''}';
  }

  // --------------------------------------------------
  // 🔹 SERIALIZATION
  // --------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'imageUrl': imageUrl,
      'variationId': variationId,
      'unitPrice': unitPrice,
      'finalUnitPrice': finalUnitPrice,
      'isEstimatedPrice': isEstimatedPrice,
      'quantity': quantity,
      'purchaseMode': purchaseMode,
      'selectedDate': selectedDate?.toIso8601String(),
      'selectedShift': selectedShift,
    };
  }

  factory MBCartItem.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const MBCartItem(
        productId: '',
        titleEn: '',
        titleBn: '',
        unitPrice: 0,
        quantity: 0,
      );
    }

    return MBCartItem(
      productId: map['productId'] ?? '',
      titleEn: map['titleEn'] ?? '',
      titleBn: map['titleBn'] ?? '',
      imageUrl: map['imageUrl'],
      variationId: map['variationId'],
      unitPrice: ((map['unitPrice'] ?? 0) as num).toDouble(),
      finalUnitPrice: map['finalUnitPrice'] != null
          ? (map['finalUnitPrice'] as num).toDouble()
          : null,
      isEstimatedPrice: map['isEstimatedPrice'] ?? false,
      quantity: (map['quantity'] ?? 0) as int,
      purchaseMode: map['purchaseMode'] ?? 'instant',
      selectedDate: map['selectedDate'] != null
          ? DateTime.tryParse(map['selectedDate'])
          : null,
      selectedShift: map['selectedShift'],
    );
  }

  // --------------------------------------------------
  // 🔹 EQUALITY (important for list operations)
  // --------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MBCartItem &&
        other.productId == productId &&
        other.variationId == variationId &&
        other.purchaseMode == purchaseMode &&
        _sameDate(other.selectedDate, selectedDate) &&
        other.selectedShift == selectedShift;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
    (variationId ?? '').hashCode ^
    purchaseMode.hashCode ^
    (selectedDate?.day ?? 0) ^
    (selectedShift ?? '').hashCode;
  }

  bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}











