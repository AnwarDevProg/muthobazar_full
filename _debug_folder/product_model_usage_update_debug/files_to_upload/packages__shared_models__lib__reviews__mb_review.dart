import 'dart:convert';

import 'mb_review_reply.dart';

// MB Product Review Model
// -----------------------
// Used for product rating + review system in MuthoBazar.
// Supports threaded replies and Firestore friendly serialization.

class MBReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;

  final int rating; // 1-5 stars

  final String commentEn;
  final String commentBn;

  final List<String> images;

  final List<MBReviewReply> replies;

  final bool isVerifiedPurchase;

  final int helpfulCount;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const MBReview({
    required this.id,
    required this.productId,
    required this.userId,
    this.userName = '',
    this.rating = 0,
    this.commentEn = '',
    this.commentBn = '',
    this.images = const [],
    this.replies = const [],
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory MBReview.empty() => MBReview(
    id: '',
    productId: '',
    userId: '',
    createdAt: DateTime.now(),
  );

  MBReview copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    int? rating,
    String? commentEn,
    String? commentBn,
    List<String>? images,
    List<MBReviewReply>? replies,
    bool? isVerifiedPurchase,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return MBReview(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      commentEn: commentEn ?? this.commentEn,
      commentBn: commentBn ?? this.commentBn,
      images: images ?? this.images,
      replies: replies ?? this.replies,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  bool get hasImages => images.isNotEmpty;

  bool get hasReplies => replies.isNotEmpty;

  double get normalizedRating => rating.clamp(1, 5).toDouble();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'commentEn': commentEn,
      'commentBn': commentBn,
      'images': images,
      'replies': replies.map((e) => e.toMap()).toList(),
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBReview.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBReview.empty();

    return MBReview(
      id: (map['id'] ?? '').toString(),
      productId: (map['productId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? '').toString(),
      rating: (map['rating'] ?? 0) as int,
      commentEn: (map['commentEn'] ?? '').toString(),
      commentBn: (map['commentBn'] ?? '').toString(),
      images: List<String>.from(map['images'] ?? const []),
      replies: (map['replies'] as List<dynamic>? ?? const [])
          .map((e) => MBReviewReply.fromMap(e as Map<String, dynamic>))
          .toList(),
      isVerifiedPurchase: map['isVerifiedPurchase'] ?? false,
      helpfulCount: map['helpfulCount'] ?? 0,
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
      updatedAt: map['updatedAt'] == null
          ? null
          : DateTime.tryParse(map['updatedAt'].toString()),
    );
  }

  // Legacy compatibility (NewReviewModel)
  factory MBReview.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) return MBReview.empty();

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return MBReview(
      id: (map['reviewId'] ?? '').toString(),
      productId: (map['productId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? 'Anonymous').toString(),
      rating: (map['rating'] ?? 0) as int,
      commentEn: (map['comment'] ?? '').toString(),
      commentBn: '',
      images: const [],
      replies: const [],
      isVerifiedPurchase: false,
      helpfulCount: 0,
      createdAt: parseDate(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBReview.fromJson(String source) =>
      MBReview.fromMap(json.decode(source) as Map<String, dynamic>);
}











