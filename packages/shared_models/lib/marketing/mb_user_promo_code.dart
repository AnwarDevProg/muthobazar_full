import 'dart:convert';

// MB User Promo Code Model
// ------------------------
// Represents a promo code assigned to a specific user.
//
// Use cases:
// - Welcome bonus
// - Referral rewards
// - Compensation coupons
// - Loyalty rewards
//
// This replaces the old UserPromoCodeModel.

class MBUserPromoCode {
  final String id;

  /// Owner of this promo
  final String userId;

  /// Promo code string
  final String code;

  /// Discount value
  final double discountValue;

  /// "percent" | "amount"
  final String discountType;

  /// Has user used this promo already
  final bool isRedeemed;

  /// Redeem timestamp
  final DateTime? redeemedAt;

  /// Expiration date
  final DateTime expirationDate;

  /// Creation timestamp
  final DateTime createdAt;

  /// Optional campaign source
  final String? source;

  const MBUserPromoCode({
    required this.id,
    required this.userId,
    required this.code,
    this.discountValue = 0,
    this.discountType = 'percent',
    this.isRedeemed = false,
    this.redeemedAt,
    required this.expirationDate,
    required this.createdAt,
    this.source,
  });

  factory MBUserPromoCode.empty() => MBUserPromoCode(
    id: '',
    userId: '',
    code: '',
    expirationDate: DateTime.now(),
    createdAt: DateTime.now(),
  );

  MBUserPromoCode copyWith({
    String? id,
    String? userId,
    String? code,
    double? discountValue,
    String? discountType,
    bool? isRedeemed,
    DateTime? redeemedAt,
    bool clearRedeemedAt = false,
    DateTime? expirationDate,
    DateTime? createdAt,
    String? source,
    bool clearSource = false,
  }) {
    return MBUserPromoCode(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      code: code ?? this.code,
      discountValue: discountValue ?? this.discountValue,
      discountType: discountType ?? this.discountType,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      redeemedAt: clearRedeemedAt ? null : (redeemedAt ?? this.redeemedAt),
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      source: clearSource ? null : (source ?? this.source),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expirationDate);

  bool get isAvailable => !isRedeemed && !isExpired;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'code': code,
      'discountValue': discountValue,
      'discountType': discountType,
      'isRedeemed': isRedeemed,
      'redeemedAt': redeemedAt?.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'source': source,
    };
  }

  factory MBUserPromoCode.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBUserPromoCode.empty();

    return MBUserPromoCode(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      discountValue: ((map['discountValue'] ?? 0) as num).toDouble(),
      discountType: (map['discountType'] ?? 'percent').toString(),
      isRedeemed: map['isRedeemed'] ?? false,
      redeemedAt: map['redeemedAt'] == null
          ? null
          : DateTime.tryParse(map['redeemedAt'].toString()),
      expirationDate: map['expirationDate'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['expirationDate'].toString()) ??
          DateTime.now(),
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['createdAt'].toString()) ??
          DateTime.now(),
      source: map['source']?.toString(),
    );
  }

  // Legacy compatibility (UserPromoCodeModel)
  factory MBUserPromoCode.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) return MBUserPromoCode.empty();

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return MBUserPromoCode(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      code: (map['promoCode'] ?? '').toString(),
      discountValue: ((map['discount'] ?? 0) as num).toDouble(),
      discountType: 'percent',
      isRedeemed: map['isRedeemed'] ?? false,
      expirationDate: parseDate(map['expirationDate']),
      createdAt: DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBUserPromoCode.fromJson(String source) =>
      MBUserPromoCode.fromMap(json.decode(source) as Map<String, dynamic>);
}











