import 'dart:convert';

class MBAdminPermission {
  final String uid;
  final String role;
  final bool isActive;

  final bool canAccessAdminPanel;

  final bool canManageAdmins;
  final bool canManageAdminInvites;
  final bool canManageAdminPermissions;

  final bool canManageUsers;

  final bool canManageCategories;
  final bool canManageBrands;
  final bool canManageProducts;
  final bool canManageBanners;
  final bool canManageCoupons;
  final bool canManageOffers;

  final bool canDeleteProducts;
  final bool canRestoreProducts;
  final bool canViewActivityLogs;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdByUid;
  final String updatedByUid;

  const MBAdminPermission({
    required this.uid,
    required this.role,
    this.isActive = true,
    this.canAccessAdminPanel = true,
    this.canManageAdmins = false,
    this.canManageAdminInvites = false,
    this.canManageAdminPermissions = false,
    this.canManageUsers = false,
    this.canManageCategories = false,
    this.canManageBrands = false,
    this.canManageProducts = false,
    this.canManageBanners = false,
    this.canManageCoupons = false,
    this.canManageOffers = false,
    this.canDeleteProducts = false,
    this.canRestoreProducts = false,
    this.canViewActivityLogs = false,
    this.createdAt,
    this.updatedAt,
    this.createdByUid = '',
    this.updatedByUid = '',
  });

  factory MBAdminPermission.empty() {
    return const MBAdminPermission(
      uid: '',
      role: 'admin',
      canAccessAdminPanel: false,
    );
  }

  factory MBAdminPermission.superAdmin({
    required String uid,
    required String actorUid,
  }) {
    final DateTime now = DateTime.now();

    return MBAdminPermission(
      uid: uid,
      role: 'super_admin',
      isActive: true,
      canAccessAdminPanel: true,
      canManageAdmins: true,
      canManageAdminInvites: true,
      canManageAdminPermissions: true,
      canManageUsers: true,
      canManageCategories: true,
      canManageBrands: true,
      canManageProducts: true,
      canManageBanners: true,
      canManageCoupons: true,
      canManageOffers: true,
      canDeleteProducts: true,
      canRestoreProducts: true,
      canViewActivityLogs: true,
      createdAt: now,
      updatedAt: now,
      createdByUid: actorUid,
      updatedByUid: actorUid,
    );
  }

  factory MBAdminPermission.standardAdmin({
    required String uid,
    required String actorUid,
  }) {
    final DateTime now = DateTime.now();

    return MBAdminPermission(
      uid: uid,
      role: 'admin',
      isActive: true,
      canAccessAdminPanel: true,
      canManageAdmins: false,
      canManageAdminInvites: false,
      canManageAdminPermissions: false,
      canManageUsers: true,
      canManageCategories: true,
      canManageBrands: true,
      canManageProducts: true,
      canManageBanners: true,
      canManageCoupons: true,
      canManageOffers: true,
      canDeleteProducts: true,
      canRestoreProducts: true,
      canViewActivityLogs: true,
      createdAt: now,
      updatedAt: now,
      createdByUid: actorUid,
      updatedByUid: actorUid,
    );
  }

  MBAdminPermission copyWith({
    String? uid,
    String? role,
    bool? isActive,
    bool? canAccessAdminPanel,
    bool? canManageAdmins,
    bool? canManageAdminInvites,
    bool? canManageAdminPermissions,
    bool? canManageUsers,
    bool? canManageCategories,
    bool? canManageBrands,
    bool? canManageProducts,
    bool? canManageBanners,
    bool? canManageCoupons,
    bool? canManageOffers,
    bool? canDeleteProducts,
    bool? canRestoreProducts,
    bool? canViewActivityLogs,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByUid,
    String? updatedByUid,
  }) {
    return MBAdminPermission(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      canAccessAdminPanel: canAccessAdminPanel ?? this.canAccessAdminPanel,
      canManageAdmins: canManageAdmins ?? this.canManageAdmins,
      canManageAdminInvites:
      canManageAdminInvites ?? this.canManageAdminInvites,
      canManageAdminPermissions:
      canManageAdminPermissions ?? this.canManageAdminPermissions,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canManageCategories: canManageCategories ?? this.canManageCategories,
      canManageBrands: canManageBrands ?? this.canManageBrands,
      canManageProducts: canManageProducts ?? this.canManageProducts,
      canManageBanners: canManageBanners ?? this.canManageBanners,
      canManageCoupons: canManageCoupons ?? this.canManageCoupons,
      canManageOffers: canManageOffers ?? this.canManageOffers,
      canDeleteProducts: canDeleteProducts ?? this.canDeleteProducts,
      canRestoreProducts: canRestoreProducts ?? this.canRestoreProducts,
      canViewActivityLogs: canViewActivityLogs ?? this.canViewActivityLogs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUid: createdByUid ?? this.createdByUid,
      updatedByUid: updatedByUid ?? this.updatedByUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'isActive': isActive,
      'canAccessAdminPanel': canAccessAdminPanel,
      'canManageAdmins': canManageAdmins,
      'canManageAdminInvites': canManageAdminInvites,
      'canManageAdminPermissions': canManageAdminPermissions,
      'canManageUsers': canManageUsers,
      'canManageCategories': canManageCategories,
      'canManageBrands': canManageBrands,
      'canManageProducts': canManageProducts,
      'canManageBanners': canManageBanners,
      'canManageCoupons': canManageCoupons,
      'canManageOffers': canManageOffers,
      'canDeleteProducts': canDeleteProducts,
      'canRestoreProducts': canRestoreProducts,
      'canViewActivityLogs': canViewActivityLogs,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdByUid': createdByUid,
      'updatedByUid': updatedByUid,
    };
  }

  factory MBAdminPermission.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBAdminPermission.empty();

    return MBAdminPermission(
      uid: (map['uid'] ?? '').toString(),
      role: (map['role'] ?? 'admin').toString(),
      isActive: map['isActive'] ?? true,
      canAccessAdminPanel: map['canAccessAdminPanel'] ?? false,
      canManageAdmins: map['canManageAdmins'] ?? false,
      canManageAdminInvites: map['canManageAdminInvites'] ?? false,
      canManageAdminPermissions: map['canManageAdminPermissions'] ?? false,
      canManageUsers: map['canManageUsers'] ?? false,
      canManageCategories: map['canManageCategories'] ?? false,
      canManageBrands: map['canManageBrands'] ?? false,
      canManageProducts: map['canManageProducts'] ?? false,
      canManageBanners: map['canManageBanners'] ?? false,
      canManageCoupons: map['canManageCoupons'] ?? false,
      canManageOffers: map['canManageOffers'] ?? false,
      canDeleteProducts: map['canDeleteProducts'] ?? false,
      canRestoreProducts: map['canRestoreProducts'] ?? false,
      canViewActivityLogs: map['canViewActivityLogs'] ?? false,
      createdAt: map['createdAt'] == null
          ? null
          : DateTime.tryParse(map['createdAt'].toString()),
      updatedAt: map['updatedAt'] == null
          ? null
          : DateTime.tryParse(map['updatedAt'].toString()),
      createdByUid: (map['createdByUid'] ?? '').toString(),
      updatedByUid: (map['updatedByUid'] ?? '').toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBAdminPermission.fromJson(String source) =>
      MBAdminPermission.fromMap(json.decode(source) as Map<String, dynamic>);
}