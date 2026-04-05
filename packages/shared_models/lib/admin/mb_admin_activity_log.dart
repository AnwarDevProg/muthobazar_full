// ignore_for_file: public_member_api_docs

import 'dart:convert';

class MBAdminActivityLog {
  final String id;

  final String actorUid;
  final String actorName;
  final String actorPhone;
  final String actorRole;

  final String action;
  final String module;

  final String targetType;
  final String targetId;
  final String targetTitle;

  final String status;
  final String reason;

  final Map<String, dynamic>? beforeData;
  final Map<String, dynamic>? afterData;
  final Map<String, dynamic>? metadata;

  final DateTime? createdAt;

  const MBAdminActivityLog({
    required this.id,
    required this.actorUid,
    required this.actorName,
    required this.actorPhone,
    required this.actorRole,
    required this.action,
    required this.module,
    required this.targetType,
    required this.targetId,
    required this.targetTitle,
    required this.status,
    required this.reason,
    this.beforeData,
    this.afterData,
    this.metadata,
    this.createdAt,
  });

  factory MBAdminActivityLog.empty() => const MBAdminActivityLog(
    id: '',
    actorUid: '',
    actorName: '',
    actorPhone: '',
    actorRole: '',
    action: '',
    module: '',
    targetType: '',
    targetId: '',
    targetTitle: '',
    status: '',
    reason: '',
  );

  factory MBAdminActivityLog.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBAdminActivityLog.empty();

    return MBAdminActivityLog(
      id: _s(map['id']),
      actorUid: _s(map['actorUid']),
      actorName: _s(map['actorName']),
      actorPhone: _s(map['actorPhone']),
      actorRole: _s(map['actorRole']),
      action: _s(map['action']),
      module: _s(map['module']),
      targetType: _s(map['targetType']),
      targetId: _s(map['targetId']),
      targetTitle: _s(map['targetTitle']),
      status: _s(map['status']),
      reason: _s(map['reason']),
      beforeData: _safeMap(map['beforeData']),
      afterData: _safeMap(map['afterData']),
      metadata: _safeMap(map['metadata']),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'actorUid': actorUid,
      'actorName': actorName,
      'actorPhone': actorPhone,
      'actorRole': actorRole,
      'action': action,
      'module': module,
      'targetType': targetType,
      'targetId': targetId,
      'targetTitle': targetTitle,
      'status': status,
      'reason': reason,
      'beforeData': beforeData,
      'afterData': afterData,
      'metadata': metadata,
      'createdAt': createdAt,
    };
  }

  String toJson() => json.encode(toMap());

  // 🔥 NEW (IMPORTANT FOR UI SEARCH)
  String get metadataPreview {
    if (metadata == null || metadata!.isEmpty) return '';

    final items = <String>[];
    metadata!.forEach((key, value) {
      if (items.length >= 4) return;
      items.add('$key: $value');
    });

    return items.join(' • ');
  }

  // 🔥 NEW (SEARCH HELPER)
  String get searchableText {
    return [
      actorName,
      actorPhone,
      actorRole,
      action,
      module,
      targetType,
      targetId,
      targetTitle,
      status,
      reason,
      metadataPreview,
    ].join(' ').toLowerCase();
  }

  // ------------------ helpers ------------------

  static String _s(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static Map<String, dynamic>? _safeMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    try {
      final d = value.toDate();
      if (d is DateTime) return d;
    } catch (_) {}

    if (value is String) {
      return DateTime.tryParse(value)?.toLocal();
    }

    return null;
  }
}