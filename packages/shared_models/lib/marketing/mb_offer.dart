import 'dart:convert';

// MB Offer Model
// --------------
// Represents promotional offers/campaigns for:
// - home sections
// - strips
// - banners
// - floating overlays

class MBOffer {
  final String id;

  final String titleEn;
  final String titleBn;

  final String subtitleEn;
  final String subtitleBn;

  final String badgeTextEn;
  final String badgeTextBn;

  /// percent | amount | free_delivery | bundle | custom
  final String offerType;

  final double offerValue;

  final List<String> productIds;
  final List<String> categoryIds;
  final List<String> brandIds;

  final bool isFeatured;
  final bool isActive;

  final DateTime? startsAt;
  final DateTime? endsAt;

  final int sortOrder;

  // Floating / overlay presentation
  /// strip | card | banner | floating
  final String presentationType;

  final bool showAsFloatingOverlay;
  final bool dismissible;
  final bool showOncePerAppLife;
  final bool randomEligible;
  final int floatingPriority;

  final String imageUrl;
  final String mobileImageUrl;

  /// none | product | category | offer | route | external
  final String targetType;
  final String? targetId;
  final String? targetRoute;
  final String? externalUrl;

  const MBOffer({
    required this.id,
    this.titleEn = '',
    this.titleBn = '',
    this.subtitleEn = '',
    this.subtitleBn = '',
    this.badgeTextEn = '',
    this.badgeTextBn = '',
    this.offerType = 'percent',
    this.offerValue = 0.0,
    this.productIds = const [],
    this.categoryIds = const [],
    this.brandIds = const [],
    this.isFeatured = false,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
    this.sortOrder = 0,
    this.presentationType = 'strip',
    this.showAsFloatingOverlay = false,
    this.dismissible = true,
    this.showOncePerAppLife = true,
    this.randomEligible = true,
    this.floatingPriority = 0,
    this.imageUrl = '',
    this.mobileImageUrl = '',
    this.targetType = 'none',
    this.targetId,
    this.targetRoute,
    this.externalUrl,
  });

  factory MBOffer.empty() => const MBOffer(id: '');

  MBOffer copyWith({
    String? id,
    String? titleEn,
    String? titleBn,
    String? subtitleEn,
    String? subtitleBn,
    String? badgeTextEn,
    String? badgeTextBn,
    String? offerType,
    double? offerValue,
    List<String>? productIds,
    List<String>? categoryIds,
    List<String>? brandIds,
    bool? isFeatured,
    bool? isActive,
    DateTime? startsAt,
    bool clearStartsAt = false,
    DateTime? endsAt,
    bool clearEndsAt = false,
    int? sortOrder,
    String? presentationType,
    bool? showAsFloatingOverlay,
    bool? dismissible,
    bool? showOncePerAppLife,
    bool? randomEligible,
    int? floatingPriority,
    String? imageUrl,
    String? mobileImageUrl,
    String? targetType,
    String? targetId,
    bool clearTargetId = false,
    String? targetRoute,
    bool clearTargetRoute = false,
    String? externalUrl,
    bool clearExternalUrl = false,
  }) {
    return MBOffer(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      badgeTextEn: badgeTextEn ?? this.badgeTextEn,
      badgeTextBn: badgeTextBn ?? this.badgeTextBn,
      offerType: offerType ?? this.offerType,
      offerValue: offerValue ?? this.offerValue,
      productIds: productIds ?? this.productIds,
      categoryIds: categoryIds ?? this.categoryIds,
      brandIds: brandIds ?? this.brandIds,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      startsAt: clearStartsAt ? null : (startsAt ?? this.startsAt),
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
      sortOrder: sortOrder ?? this.sortOrder,
      presentationType: presentationType ?? this.presentationType,
      showAsFloatingOverlay:
      showAsFloatingOverlay ?? this.showAsFloatingOverlay,
      dismissible: dismissible ?? this.dismissible,
      showOncePerAppLife: showOncePerAppLife ?? this.showOncePerAppLife,
      randomEligible: randomEligible ?? this.randomEligible,
      floatingPriority: floatingPriority ?? this.floatingPriority,
      imageUrl: imageUrl ?? this.imageUrl,
      mobileImageUrl: mobileImageUrl ?? this.mobileImageUrl,
      targetType: targetType ?? this.targetType,
      targetId: clearTargetId ? null : (targetId ?? this.targetId),
      targetRoute: clearTargetRoute ? null : (targetRoute ?? this.targetRoute),
      externalUrl: clearExternalUrl ? null : (externalUrl ?? this.externalUrl),
    );
  }

  bool get isWithinSchedule {
    final now = DateTime.now();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }

  bool get isAvailable => isActive && isWithinSchedule;

  bool get canShowAsFloating => isAvailable && showAsFloatingOverlay;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'subtitleEn': subtitleEn,
      'subtitleBn': subtitleBn,
      'badgeTextEn': badgeTextEn,
      'badgeTextBn': badgeTextBn,
      'offerType': offerType,
      'offerValue': offerValue,
      'productIds': productIds,
      'categoryIds': categoryIds,
      'brandIds': brandIds,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'startsAt': startsAt?.toIso8601String(),
      'endsAt': endsAt?.toIso8601String(),
      'sortOrder': sortOrder,
      'presentationType': presentationType,
      'showAsFloatingOverlay': showAsFloatingOverlay,
      'dismissible': dismissible,
      'showOncePerAppLife': showOncePerAppLife,
      'randomEligible': randomEligible,
      'floatingPriority': floatingPriority,
      'imageUrl': imageUrl,
      'mobileImageUrl': mobileImageUrl,
      'targetType': targetType,
      'targetId': targetId,
      'targetRoute': targetRoute,
      'externalUrl': externalUrl,
    };
  }

  factory MBOffer.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBOffer.empty();

    return MBOffer(
      id: (map['id'] ?? '').toString(),
      titleEn: (map['titleEn'] ?? '').toString(),
      titleBn: (map['titleBn'] ?? '').toString(),
      subtitleEn: (map['subtitleEn'] ?? '').toString(),
      subtitleBn: (map['subtitleBn'] ?? '').toString(),
      badgeTextEn: (map['badgeTextEn'] ?? '').toString(),
      badgeTextBn: (map['badgeTextBn'] ?? '').toString(),
      offerType: (map['offerType'] ?? 'percent').toString(),
      offerValue: ((map['offerValue'] ?? 0) as num).toDouble(),
      productIds: List<String>.from(map['productIds'] ?? const []),
      categoryIds: List<String>.from(map['categoryIds'] ?? const []),
      brandIds: List<String>.from(map['brandIds'] ?? const []),
      isFeatured: map['isFeatured'] ?? false,
      isActive: map['isActive'] ?? true,
      startsAt: map['startsAt'] == null
          ? null
          : DateTime.tryParse(map['startsAt'].toString()),
      endsAt: map['endsAt'] == null
          ? null
          : DateTime.tryParse(map['endsAt'].toString()),
      sortOrder: (map['sortOrder'] ?? 0) is int
          ? map['sortOrder'] as int
          : int.tryParse((map['sortOrder'] ?? '0').toString()) ?? 0,
      presentationType: (map['presentationType'] ?? 'strip').toString(),
      showAsFloatingOverlay: map['showAsFloatingOverlay'] ?? false,
      dismissible: map['dismissible'] ?? true,
      showOncePerAppLife: map['showOncePerAppLife'] ?? true,
      randomEligible: map['randomEligible'] ?? true,
      floatingPriority: (map['floatingPriority'] ?? 0) is int
          ? map['floatingPriority'] as int
          : int.tryParse((map['floatingPriority'] ?? '0').toString()) ?? 0,
      imageUrl: (map['imageUrl'] ?? '').toString(),
      mobileImageUrl: (map['mobileImageUrl'] ?? '').toString(),
      targetType: (map['targetType'] ?? 'none').toString(),
      targetId: map['targetId']?.toString(),
      targetRoute: map['targetRoute']?.toString(),
      externalUrl: map['externalUrl']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBOffer.fromJson(String source) =>
      MBOffer.fromMap(json.decode(source) as Map<String, dynamic>);
}











