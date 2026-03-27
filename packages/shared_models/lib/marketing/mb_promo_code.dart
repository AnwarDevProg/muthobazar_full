import 'dart:convert';

// MB Promo Code Model
// -------------------
// Used for:
// - global promo codes
// - campaign promo codes
// - limited promo usage
// - user restricted promo codes
//
// Designed to replace old PromoCodeModel with a safer structure.

class MBPromoCode {
  final String id;
  final String code;

  /// Discount value (percentage or fixed depending on type)
  final double discountValue;

  /// "percent" | "amount"
  final String discountType;

  /// Optional minimum order requirement
  final double? minimumOrderAmount;

  /// Optional maximum discount cap (for percentage promos)
  final double? maximumDiscount;

  /// Maximum times this promo can be used globally
  final int? usageLimit;

  /// Current usage count
  final int usageCount;

  /// If restricted promo (specific users only)
  final List<String> eligibleUserIds;

  /// Promo active flag
  final bool isActive;

  /// Promo archived flag
  final bool isArchived;

  /// Campaign name (optional)
  final String? campaignName;

  /// Expiration date
  final DateTime expirationDate;

  /// Creation timestamp
  final DateTime createdAt;

  const MBPromoCode({
    required this.id,
    required this.code,
    this.discountValue = 0,
    this.discountType = 'percent',
    this.minimumOrderAmount,
    this.maximumDiscount,
    this.usageLimit,
    this.usageCount = 0,
    this.eligibleUserIds = const [],
    this.isActive = true,
    this.isArchived = false,
    this.campaignName,
    required this.expirationDate,
    required this.createdAt,
  });

  factory MBPromoCode.empty() => MBPromoCode(
    id: '',
    code: '',
    expirationDate: DateTime.now(),
    createdAt: DateTime.now(),
  );

  MBPromoCode copyWith({
    String? id,
    String? code,
    double? discountValue,
    String? discountType,
    double? minimumOrderAmount,
    bool clearMinimumOrderAmount = false,
    double? maximumDiscount,
    bool clearMaximumDiscount = false,
    int? usageLimit,
    bool clearUsageLimit = false,
    int? usageCount,
    List<String>? eligibleUserIds,
    bool? isActive,
    bool? isArchived,
    String? campaignName,
    bool clearCampaignName = false,
    DateTime? expirationDate,
    DateTime? createdAt,
  }) {
    return MBPromoCode(
      id: id ?? this.id,
      code: code ?? this.code,
      discountValue: discountValue ?? this.discountValue,
      discountType: discountType ?? this.discountType,
      minimumOrderAmount: clearMinimumOrderAmount
          ? null
          : (minimumOrderAmount ?? this.minimumOrderAmount),
      maximumDiscount:
      clearMaximumDiscount ? null : (maximumDiscount ?? this.maximumDiscount),
      usageLimit: clearUsageLimit ? null : (usageLimit ?? this.usageLimit),
      usageCount: usageCount ?? this.usageCount,
      eligibleUserIds: eligibleUserIds ?? this.eligibleUserIds,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      campaignName:
      clearCampaignName ? null : (campaignName ?? this.campaignName),
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expirationDate);

  bool get isAvailable => isActive && !isArchived && !isExpired;

  bool get hasUsageLimit => usageLimit != null;

  bool get usageLimitReached =>
      usageLimit != null && usageCount >= usageLimit!;

  bool isUserEligible(String userId) {
    if (eligibleUserIds.isEmpty) return true;
    return eligibleUserIds.contains(userId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'discountValue': discountValue,
      'discountType': discountType,
      'minimumOrderAmount': minimumOrderAmount,
      'maximumDiscount': maximumDiscount,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'eligibleUserIds': eligibleUserIds,
      'isActive': isActive,
      'isArchived': isArchived,
      'campaignName': campaignName,
      'expirationDate': expirationDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MBPromoCode.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBPromoCode.empty();

    return MBPromoCode(
      id: (map['id'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      discountValue: ((map['discountValue'] ?? 0) as num).toDouble(),
      discountType: (map['discountType'] ?? 'percent').toString(),
      minimumOrderAmount: map['minimumOrderAmount'] == null
          ? null
          : ((map['minimumOrderAmount'] as num).toDouble()),
      maximumDiscount: map['maximumDiscount'] == null
          ? null
          : ((map['maximumDiscount'] as num).toDouble()),
      usageLimit: map['usageLimit'] == null
          ? null
          : (map['usageLimit'] as num).toInt(),
      usageCount: (map['usageCount'] ?? 0) as int,
      eligibleUserIds: List<String>.from(map['eligibleUserIds'] ?? const []),
      isActive: map['isActive'] ?? true,
      isArchived: map['isArchived'] ?? false,
      campaignName: map['campaignName']?.toString(),
      expirationDate: map['expirationDate'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['expirationDate'].toString()) ?? DateTime.now(),
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
    );
  }

  // Legacy compatibility (PromoCodeModel)
  factory MBPromoCode.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) return MBPromoCode.empty();

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return MBPromoCode(
      id: (map['id'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      discountValue: ((map['discount'] ?? 0) as num).toDouble(),
      discountType: 'percent',
      eligibleUserIds: List<String>.from(map['eligibleUsers'] ?? const []),
      isActive: map['isActive'] ?? true,
      isArchived: map['isArchived'] ?? false,
      usageCount: (map['usageCount'] ?? 0) as int,
      expirationDate: parseDate(map['expirationDate']),
      createdAt: DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBPromoCode.fromJson(String source) =>
      MBPromoCode.fromMap(json.decode(source) as Map<String, dynamic>);
}











