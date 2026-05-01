import 'dart:convert';

// MB Review Reply Model
// ---------------------
// Represents replies to product reviews.
// Used for:
// - admin replies
// - seller replies
// - threaded discussions in reviews

class MBReviewReply {
  final String id;
  final String reviewId;
  final String userId;
  final String userName;

  final String replyEn;
  final String replyBn;

  final bool isAdminReply;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const MBReviewReply({
    required this.id,
    required this.reviewId,
    required this.userId,
    this.userName = '',
    this.replyEn = '',
    this.replyBn = '',
    this.isAdminReply = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory MBReviewReply.empty() => MBReviewReply(
    id: '',
    reviewId: '',
    userId: '',
    createdAt: DateTime.now(),
  );

  MBReviewReply copyWith({
    String? id,
    String? reviewId,
    String? userId,
    String? userName,
    String? replyEn,
    String? replyBn,
    bool? isAdminReply,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return MBReviewReply(
      id: id ?? this.id,
      reviewId: reviewId ?? this.reviewId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      replyEn: replyEn ?? this.replyEn,
      replyBn: replyBn ?? this.replyBn,
      isAdminReply: isAdminReply ?? this.isAdminReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  bool get isEdited => updatedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewId': reviewId,
      'userId': userId,
      'userName': userName,
      'replyEn': replyEn,
      'replyBn': replyBn,
      'isAdminReply': isAdminReply,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBReviewReply.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBReviewReply.empty();

    return MBReviewReply(
      id: (map['id'] ?? '').toString(),
      reviewId: (map['reviewId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? '').toString(),
      replyEn: (map['replyEn'] ?? '').toString(),
      replyBn: (map['replyBn'] ?? '').toString(),
      isAdminReply: map['isAdminReply'] ?? false,
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
      updatedAt: map['updatedAt'] == null
          ? null
          : DateTime.tryParse(map['updatedAt'].toString()),
    );
  }

  // Legacy compatibility (ReplyToReviewModel)
  factory MBReviewReply.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) return MBReviewReply.empty();

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return MBReviewReply(
      id: (map['replyId'] ?? '').toString(),
      reviewId: (map['reviewId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? 'Anonymous').toString(),
      replyEn: (map['replyText'] ?? '').toString(),
      replyBn: '',
      isAdminReply: false,
      createdAt: parseDate(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBReviewReply.fromJson(String source) =>
      MBReviewReply.fromMap(json.decode(source) as Map<String, dynamic>);
}











