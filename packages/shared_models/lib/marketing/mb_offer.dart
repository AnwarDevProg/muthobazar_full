import 'dart:convert';

// MB Offer Model
// --------------
// Unified production-ready marketing offer model for:
// - offer strips
// - cards
// - banners
// - floating overlays
// - category/product/brand campaigns

class MBOffer {
  final String id;

  final String titleEn;
  final String titleBn;

  final String subtitleEn;
  final String subtitleBn;

  final String badgeTextEn;
  final String badgeTextBn;

  final String discountTextEn;
  final String discountTextBn;

  /// percent | amount | free_delivery | bundle | custom
  final String offerType;
  final double offerValue;

  final List<String> productIds;
  final List<String> categoryIds;
  final List<String> brandIds;

  final String imageUrl;
  final String mobileImageUrl;

  /// none | product | category | brand | offer | route | external
  final String targetType;
  final String? targetId;
  final String? targetRoute;
  final String? externalUrl;

  final bool isFeatured;
  final bool isActive;
  final int sortOrder;

  /// strip | card | banner | floating
  final String presentationType;

  final bool showAsFloating;
  final bool dismissible;
  final bool showOncePerAppLife;
  final bool randomEligible;
  final int floatingPriority;

  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MBOffer({
    required this.id,
    this.titleEn = '',
    this.titleBn = '',
    this.subtitleEn = '',
    this.subtitleBn = '',
    this.badgeTextEn = '',
    this.badgeTextBn = '',
    this.discountTextEn = '',
    this.discountTextBn = '',
    this.offerType = 'percent',
    this.offerValue = 0.0,
    this.productIds = const [],
    this.categoryIds = const [],
    this.brandIds = const [],
    this.imageUrl = '',
    this.mobileImageUrl = '',
    this.targetType = 'none',
    this.targetId,
    this.targetRoute,
    this.externalUrl,
    this.isFeatured = false,
    this.isActive = true,
    this.sortOrder = 0,
    this.presentationType = 'strip',
    this.showAsFloating = false,
    this.dismissible = true,
    this.showOncePerAppLife = true,
    this.randomEligible = false,
    this.floatingPriority = 0,
    this.startAt,
    this.endAt,
    this.createdAt,
    this.updatedAt,
  });

  static const MBOffer empty = MBOffer(id: '');

  bool get isWithinSchedule {
    final DateTime now = DateTime.now();
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;
    return true;
  }

  bool get isAvailable => isActive && isWithinSchedule;

  bool get canShowAsFloating => isAvailable && showAsFloating;

  MBOffer copyWith({
    String? id,
    String? titleEn,
    String? titleBn,
    String? subtitleEn,
    String? subtitleBn,
    String? badgeTextEn,
    String? badgeTextBn,
    String? discountTextEn,
    String? discountTextBn,
    String? offerType,
    double? offerValue,
    List<String>? productIds,
    List<String>? categoryIds,
    List<String>? brandIds,
    String? imageUrl,
    String? mobileImageUrl,
    String? targetType,
    String? targetId,
    bool clearTargetId = false,
    String? targetRoute,
    bool clearTargetRoute = false,
    String? externalUrl,
    bool clearExternalUrl = false,
    bool? isFeatured,
    bool? isActive,
    int? sortOrder,
    String? presentationType,
    bool? showAsFloating,
    bool? dismissible,
    bool? showOncePerAppLife,
    bool? randomEligible,
    int? floatingPriority,
    DateTime? startAt,
    bool clearStartAt = false,
    DateTime? endAt,
    bool clearEndAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MBOffer(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      badgeTextEn: badgeTextEn ?? this.badgeTextEn,
      badgeTextBn: badgeTextBn ?? this.badgeTextBn,
      discountTextEn: discountTextEn ?? this.discountTextEn,
      discountTextBn: discountTextBn ?? this.discountTextBn,
      offerType: offerType ?? this.offerType,
      offerValue: offerValue ?? this.offerValue,
      productIds: productIds ?? this.productIds,
      categoryIds: categoryIds ?? this.categoryIds,
      brandIds: brandIds ?? this.brandIds,
      imageUrl: imageUrl ?? this.imageUrl,
      mobileImageUrl: mobileImageUrl ?? this.mobileImageUrl,
      targetType: targetType ?? this.targetType,
      targetId: clearTargetId ? null : (targetId ?? this.targetId),
      targetRoute: clearTargetRoute ? null : (targetRoute ?? this.targetRoute),
      externalUrl: clearExternalUrl ? null : (externalUrl ?? this.externalUrl),
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      presentationType: presentationType ?? this.presentationType,
      showAsFloating: showAsFloating ?? this.showAsFloating,
      dismissible: dismissible ?? this.dismissible,
      showOncePerAppLife: showOncePerAppLife ?? this.showOncePerAppLife,
      randomEligible: randomEligible ?? this.randomEligible,
      floatingPriority: floatingPriority ?? this.floatingPriority,
      startAt: clearStartAt ? null : (startAt ?? this.startAt),
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'subtitleEn': subtitleEn,
      'subtitleBn': subtitleBn,
      'badgeTextEn': badgeTextEn,
      'badgeTextBn': badgeTextBn,
      'discountTextEn': discountTextEn,
      'discountTextBn': discountTextBn,
      'offerType': offerType,
      'offerValue': offerValue,
      'productIds': productIds,
      'categoryIds': categoryIds,
      'brandIds': brandIds,
      'imageUrl': imageUrl,
      'mobileImageUrl': mobileImageUrl,
      'targetType': targetType,
      'targetId': targetId,
      'targetRoute': targetRoute,
      'externalUrl': externalUrl,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'presentationType': presentationType,
      'showAsFloating': showAsFloating,
      'dismissible': dismissible,
      'showOncePerAppLife': showOncePerAppLife,
      'randomEligible': randomEligible,
      'floatingPriority': floatingPriority,
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBOffer.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBOffer(
      id: (map['id'] ?? '').toString(),
      titleEn: (map['titleEn'] ?? '').toString(),
      titleBn: (map['titleBn'] ?? '').toString(),
      subtitleEn: (map['subtitleEn'] ?? '').toString(),
      subtitleBn: (map['subtitleBn'] ?? '').toString(),
      badgeTextEn: (map['badgeTextEn'] ?? '').toString(),
      badgeTextBn: (map['badgeTextBn'] ?? '').toString(),
      discountTextEn: (map['discountTextEn'] ?? '').toString(),
      discountTextBn: (map['discountTextBn'] ?? '').toString(),
      offerType: (map['offerType'] ?? 'percent').toString(),
      offerValue: ((map['offerValue'] ?? 0) as num).toDouble(),
      productIds: List<String>.from(map['productIds'] ?? const []),
      categoryIds: List<String>.from(map['categoryIds'] ?? const []),
      brandIds: List<String>.from(map['brandIds'] ?? const []),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      mobileImageUrl: (map['mobileImageUrl'] ?? '').toString(),
      targetType: (map['targetType'] ?? 'none').toString(),
      targetId: map['targetId']?.toString(),
      targetRoute: map['targetRoute']?.toString(),
      externalUrl: map['externalUrl']?.toString(),
      isFeatured: map['isFeatured'] ?? false,
      isActive: map['isActive'] ?? true,
      sortOrder: (map['sortOrder'] ?? 0) is int
          ? map!['sortOrder'] as int
          : int.tryParse((map['sortOrder'] ?? '0').toString()) ?? 0,
      presentationType: (map['presentationType'] ?? 'strip').toString(),
      showAsFloating: map['showAsFloating'] ??
          map['showAsFloatingOverlay'] ??
          false,
      dismissible: map['dismissible'] ?? true,
      showOncePerAppLife: map['showOncePerAppLife'] ?? true,
      randomEligible: map['randomEligible'] ?? false,
      floatingPriority: (map['floatingPriority'] ?? 0) is int
          ? map['floatingPriority'] as int
          : int.tryParse((map['floatingPriority'] ?? '0').toString()) ?? 0,
      startAt: map['startAt'] == null
          ? (map['startsAt'] == null
          ? null
          : DateTime.tryParse(map['startsAt'].toString()))
          : DateTime.tryParse(map['startAt'].toString()),
      endAt: map['endAt'] == null
          ? (map['endsAt'] == null
          ? null
          : DateTime.tryParse(map['endsAt'].toString()))
          : DateTime.tryParse(map['endAt'].toString()),
      createdAt: map['createdAt'] == null
          ? null
          : DateTime.tryParse(map['createdAt'].toString()),
      updatedAt: map['updatedAt'] == null
          ? null
          : DateTime.tryParse(map['updatedAt'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBOffer.fromJson(String source) =>
      MBOffer.fromMap(json.decode(source) as Map<String, dynamic>);
}