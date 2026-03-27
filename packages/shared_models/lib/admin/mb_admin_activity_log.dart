import 'dart:convert';

class MBAdminActivityLog {
  final String id;
  final String adminUid;
  final String adminName;
  final String adminEmail;
  final String adminRole;

  final String action;
  final String targetType;
  final String targetId;
  final String targetTitle;
  final String summary;

  final Map<String, dynamic>? beforeData;
  final Map<String, dynamic>? afterData;

  final DateTime? createdAt;

  const MBAdminActivityLog({
    required this.id,
    required this.adminUid,
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.targetTitle,
    required this.summary,
    this.beforeData,
    this.afterData,
    this.createdAt,
  });

  factory MBAdminActivityLog.empty() {
    return const MBAdminActivityLog(
      id: '',
      adminUid: '',
      adminName: '',
      adminEmail: '',
      adminRole: '',
      action: '',
      targetType: '',
      targetId: '',
      targetTitle: '',
      summary: '',
    );
  }

  MBAdminActivityLog copyWith({
    String? id,
    String? adminUid,
    String? adminName,
    String? adminEmail,
    String? adminRole,
    String? action,
    String? targetType,
    String? targetId,
    String? targetTitle,
    String? summary,
    Map<String, dynamic>? beforeData,
    bool clearBeforeData = false,
    Map<String, dynamic>? afterData,
    bool clearAfterData = false,
    DateTime? createdAt,
  }) {
    return MBAdminActivityLog(
      id: id ?? this.id,
      adminUid: adminUid ?? this.adminUid,
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
      adminRole: adminRole ?? this.adminRole,
      action: action ?? this.action,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetTitle: targetTitle ?? this.targetTitle,
      summary: summary ?? this.summary,
      beforeData: clearBeforeData ? null : (beforeData ?? this.beforeData),
      afterData: clearAfterData ? null : (afterData ?? this.afterData),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminUid': adminUid,
      'adminName': adminName,
      'adminEmail': adminEmail,
      'adminRole': adminRole,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'targetTitle': targetTitle,
      'summary': summary,
      'beforeData': beforeData,
      'afterData': afterData,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory MBAdminActivityLog.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBAdminActivityLog.empty();

    return MBAdminActivityLog(
      id: (map['id'] ?? '').toString(),
      adminUid: (map['adminUid'] ?? '').toString(),
      adminName: (map['adminName'] ?? '').toString(),
      adminEmail: (map['adminEmail'] ?? '').toString(),
      adminRole: (map['adminRole'] ?? '').toString(),
      action: (map['action'] ?? '').toString(),
      targetType: (map['targetType'] ?? '').toString(),
      targetId: (map['targetId'] ?? '').toString(),
      targetTitle: (map['targetTitle'] ?? '').toString(),
      summary: (map['summary'] ?? '').toString(),
      beforeData: map['beforeData'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['beforeData'] as Map<String, dynamic>)
          : null,
      afterData: map['afterData'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['afterData'] as Map<String, dynamic>)
          : null,
      createdAt: map['createdAt'] == null
          ? null
          : DateTime.tryParse(map['createdAt'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBAdminActivityLog.fromJson(String source) =>
      MBAdminActivityLog.fromMap(json.decode(source) as Map<String, dynamic>);
}











