import 'dart:convert';

class MBAdminInvite {
  final String id;
  final String uid;
  final String phone;
  final String email;
  final String name;

  final String role; // admin | super_admin
  final String status; // pending | accepted | rejected | revoked | expired

  final String invitedBy;
  final String invitedByName;

  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? revokedAt;

  const MBAdminInvite({
    required this.id,
    required this.uid,
    required this.phone,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.invitedBy,
    required this.invitedByName,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedAt,
    this.rejectedAt,
    this.revokedAt,
  });

  factory MBAdminInvite.empty() => MBAdminInvite(
    id: '',
    uid: '',
    phone: '',
    email: '',
    name: '',
    role: 'admin',
    status: 'pending',
    invitedBy: '',
    invitedByName: '',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now(),
  );

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isRevoked => status == 'revoked';
  bool get isExpired => DateTime.now().isAfter(expiresAt) || status == 'expired';

  MBAdminInvite copyWith({
    String? id,
    String? uid,
    String? phone,
    String? email,
    String? name,
    String? role,
    String? status,
    String? invitedBy,
    String? invitedByName,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    bool clearAcceptedAt = false,
    DateTime? rejectedAt,
    bool clearRejectedAt = false,
    DateTime? revokedAt,
    bool clearRevokedAt = false,
  }) {
    return MBAdminInvite(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedByName: invitedByName ?? this.invitedByName,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: clearAcceptedAt ? null : (acceptedAt ?? this.acceptedAt),
      rejectedAt: clearRejectedAt ? null : (rejectedAt ?? this.rejectedAt),
      revokedAt: clearRevokedAt ? null : (revokedAt ?? this.revokedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'phone': phone,
      'email': email,
      'name': name,
      'role': role,
      'status': status,
      'invitedBy': invitedBy,
      'invitedByName': invitedByName,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'revokedAt': revokedAt?.toIso8601String(),
    };
  }

  factory MBAdminInvite.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBAdminInvite.empty();

    return MBAdminInvite(
      id: (map['id'] ?? '').toString(),
      uid: (map['uid'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      role: (map['role'] ?? 'admin').toString(),
      status: (map['status'] ?? 'pending').toString(),
      invitedBy: (map['invitedBy'] ?? '').toString(),
      invitedByName: (map['invitedByName'] ?? '').toString(),
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
      expiresAt: map['expiresAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['expiresAt'].toString()) ?? DateTime.now(),
      acceptedAt: map['acceptedAt'] == null
          ? null
          : DateTime.tryParse(map['acceptedAt'].toString()),
      rejectedAt: map['rejectedAt'] == null
          ? null
          : DateTime.tryParse(map['rejectedAt'].toString()),
      revokedAt: map['revokedAt'] == null
          ? null
          : DateTime.tryParse(map['revokedAt'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBAdminInvite.fromJson(String source) =>
      MBAdminInvite.fromMap(json.decode(source) as Map<String, dynamic>);
}











