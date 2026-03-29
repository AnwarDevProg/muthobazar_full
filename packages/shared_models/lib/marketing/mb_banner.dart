import 'dart:convert';

// MB Banner Model
// ---------------
// Unified production-ready home banner model for:
// - hero sliders
// - campaign banners
// - section promo banners

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

  /// none | product | category | brand | offer | route | external
  final String targetType;
  final String? targetId;
  final String? targetRoute;
  final String? externalUrl;

  final bool isActive;
  final int sortOrder;

  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.startAt,
    this.endAt,
    this.createdAt,
    this.updatedAt,
  });

  static const MBBanner empty = MBBanner(id: '');

  bool get isWithinSchedule {
    final DateTime now = DateTime.now();
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;
    return true;
  }

  bool get isAvailable => isActive && isWithinSchedule;

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
    DateTime? startAt,
    bool clearStartAt = false,
    DateTime? endAt,
    bool clearEndAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBBanner.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

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

  factory MBBanner.fromJson(String source) =>
      MBBanner.fromMap(json.decode(source) as Map<String, dynamic>);
}