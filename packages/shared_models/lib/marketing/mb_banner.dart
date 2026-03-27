import 'dart:convert';

// MB Banner Model
// ---------------
// For hero banners, promo sliders, and campaign banners on the home page.

class MBBanner {
  final String id;

  final String titleEn;
  final String titleBn;

  final String subtitleEn;
  final String subtitleBn;

  final String buttonTextEn;
  final String buttonTextBn;

  final String imageUrl;
  final String mobileImageUrl;

  /// none | product | category | offer | route | external
  final String targetType;

  final String? targetId;
  final String? targetRoute;
  final String? externalUrl;

  final bool isActive;
  final int sortOrder;

  final DateTime? startsAt;
  final DateTime? endsAt;

  const MBBanner({
    required this.id,
    this.titleEn = '',
    this.titleBn = '',
    this.subtitleEn = '',
    this.subtitleBn = '',
    this.buttonTextEn = '',
    this.buttonTextBn = '',
    this.imageUrl = '',
    this.mobileImageUrl = '',
    this.targetType = 'none',
    this.targetId,
    this.targetRoute,
    this.externalUrl,
    this.isActive = true,
    this.sortOrder = 0,
    this.startsAt,
    this.endsAt,
  });

  factory MBBanner.empty() => const MBBanner(id: '');

  MBBanner copyWith({
    String? id,
    String? titleEn,
    String? titleBn,
    String? subtitleEn,
    String? subtitleBn,
    String? buttonTextEn,
    String? buttonTextBn,
    String? imageUrl,
    String? mobileImageUrl,
    String? targetType,
    String? targetId,
    bool clearTargetId = false,
    String? targetRoute,
    bool clearTargetRoute = false,
    String? externalUrl,
    bool clearExternalUrl = false,
    bool? isActive,
    int? sortOrder,
    DateTime? startsAt,
    bool clearStartsAt = false,
    DateTime? endsAt,
    bool clearEndsAt = false,
  }) {
    return MBBanner(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      buttonTextEn: buttonTextEn ?? this.buttonTextEn,
      buttonTextBn: buttonTextBn ?? this.buttonTextBn,
      imageUrl: imageUrl ?? this.imageUrl,
      mobileImageUrl: mobileImageUrl ?? this.mobileImageUrl,
      targetType: targetType ?? this.targetType,
      targetId: clearTargetId ? null : (targetId ?? this.targetId),
      targetRoute: clearTargetRoute ? null : (targetRoute ?? this.targetRoute),
      externalUrl: clearExternalUrl ? null : (externalUrl ?? this.externalUrl),
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      startsAt: clearStartsAt ? null : (startsAt ?? this.startsAt),
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
    );
  }

  bool get isWithinSchedule {
    final now = DateTime.now();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }

  bool get isAvailable => isActive && isWithinSchedule;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'subtitleEn': subtitleEn,
      'subtitleBn': subtitleBn,
      'buttonTextEn': buttonTextEn,
      'buttonTextBn': buttonTextBn,
      'imageUrl': imageUrl,
      'mobileImageUrl': mobileImageUrl,
      'targetType': targetType,
      'targetId': targetId,
      'targetRoute': targetRoute,
      'externalUrl': externalUrl,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'startsAt': startsAt?.toIso8601String(),
      'endsAt': endsAt?.toIso8601String(),
    };
  }

  factory MBBanner.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBBanner.empty();

    return MBBanner(
      id: (map['id'] ?? '').toString(),
      titleEn: (map['titleEn'] ?? '').toString(),
      titleBn: (map['titleBn'] ?? '').toString(),
      subtitleEn: (map['subtitleEn'] ?? '').toString(),
      subtitleBn: (map['subtitleBn'] ?? '').toString(),
      buttonTextEn: (map['buttonTextEn'] ?? '').toString(),
      buttonTextBn: (map['buttonTextBn'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      mobileImageUrl: (map['mobileImageUrl'] ?? '').toString(),
      targetType: (map['targetType'] ?? 'none').toString(),
      targetId: map['targetId']?.toString(),
      targetRoute: map['targetRoute']?.toString(),
      externalUrl: map['externalUrl']?.toString(),
      isActive: map['isActive'] ?? true,
      sortOrder: (map['sortOrder'] ?? 0) is int
          ? map['sortOrder'] as int
          : int.tryParse((map['sortOrder'] ?? '0').toString()) ?? 0,
      startsAt: map['startsAt'] == null
          ? null
          : DateTime.tryParse(map['startsAt'].toString()),
      endsAt: map['endsAt'] == null
          ? null
          : DateTime.tryParse(map['endsAt'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBBanner.fromJson(String source) =>
      MBBanner.fromMap(json.decode(source) as Map<String, dynamic>);
}











