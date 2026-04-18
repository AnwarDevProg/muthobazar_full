import 'dart:convert';

// MB Admin Permission Model
// -------------------------
// Must stay aligned with Firestore rules.
//
// Important:
// - field names are camelCase
// - superAdmin() must set every required permission to true
// - uid, role, isActive, canAccessAdminPanel are mandatory for bootstrap

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
  final bool canManageHomeSections;

  final bool canDeleteProducts;
  final bool canRestoreProducts;
  final bool canViewActivityLogs;

  final String createdByUid;
  final String updatedByUid;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MBAdminPermission({
    required this.uid,
    required this.role,
    this.isActive = true,
    this.canAccessAdminPanel = false,
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
    this.canManageHomeSections = false,
    this.canDeleteProducts = false,
    this.canRestoreProducts = false,
    this.canViewActivityLogs = false,
    this.createdByUid = '',
    this.updatedByUid = '',
    this.createdAt,
    this.updatedAt,
  });

  factory MBAdminPermission.empty() {
    return const MBAdminPermission(
      uid: '',
      role: 'admin',
      isActive: false,
      canAccessAdminPanel: false,
    );
  }

  factory MBAdminPermission.superAdmin({
    required String uid,
    required String actorUid,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      canManageHomeSections: true,
      canDeleteProducts: true,
      canRestoreProducts: true,
      canViewActivityLogs: true,
      createdByUid: actorUid,
      updatedByUid: actorUid,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  factory MBAdminPermission.admin({
    required String uid,
    required String actorUid,
    bool isActive = true,
    bool canAccessAdminPanel = true,
    bool canManageAdmins = false,
    bool canManageAdminInvites = false,
    bool canManageAdminPermissions = false,
    bool canManageUsers = false,
    bool canManageCategories = false,
    bool canManageBrands = false,
    bool canManageProducts = false,
    bool canManageBanners = false,
    bool canManageCoupons = false,
    bool canManageOffers = false,
    bool canManageHomeSections = false,
    bool canDeleteProducts = false,
    bool canRestoreProducts = false,
    bool canViewActivityLogs = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final DateTime now = DateTime.now();

    return MBAdminPermission(
      uid: uid,
      role: 'admin',
      isActive: isActive,
      canAccessAdminPanel: canAccessAdminPanel,
      canManageAdmins: canManageAdmins,
      canManageAdminInvites: canManageAdminInvites,
      canManageAdminPermissions: canManageAdminPermissions,
      canManageUsers: canManageUsers,
      canManageCategories: canManageCategories,
      canManageBrands: canManageBrands,
      canManageProducts: canManageProducts,
      canManageBanners: canManageBanners,
      canManageCoupons: canManageCoupons,
      canManageOffers: canManageOffers,
      canManageHomeSections: canManageHomeSections,
      canDeleteProducts: canDeleteProducts,
      canRestoreProducts: canRestoreProducts,
      canViewActivityLogs: canViewActivityLogs,
      createdByUid: actorUid,
      updatedByUid: actorUid,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
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
    bool? canManageHomeSections,
    bool? canDeleteProducts,
    bool? canRestoreProducts,
    bool? canViewActivityLogs,
    String? createdByUid,
    String? updatedByUid,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      canManageHomeSections:
      canManageHomeSections ?? this.canManageHomeSections,
      canDeleteProducts: canDeleteProducts ?? this.canDeleteProducts,
      canRestoreProducts: canRestoreProducts ?? this.canRestoreProducts,
      canViewActivityLogs: canViewActivityLogs ?? this.canViewActivityLogs,
      createdByUid: createdByUid ?? this.createdByUid,
      updatedByUid: updatedByUid ?? this.updatedByUid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      'canManageHomeSections': canManageHomeSections,
      'canDeleteProducts': canDeleteProducts,
      'canRestoreProducts': canRestoreProducts,
      'canViewActivityLogs': canViewActivityLogs,
      'createdByUid': createdByUid,
      'updatedByUid': updatedByUid,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBAdminPermission.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return MBAdminPermission.empty();
    }

    return MBAdminPermission(
      uid: (map['uid'] ?? '').toString(),
      role: (map['role'] ?? 'admin').toString(),
      isActive: _asBool(map['isActive'], defaultValue: true),
      canAccessAdminPanel:
      _asBool(map['canAccessAdminPanel'], defaultValue: false),
      canManageAdmins: _asBool(map['canManageAdmins']),
      canManageAdminInvites: _asBool(map['canManageAdminInvites']),
      canManageAdminPermissions: _asBool(map['canManageAdminPermissions']),
      canManageUsers: _asBool(map['canManageUsers']),
      canManageCategories: _asBool(map['canManageCategories']),
      canManageBrands: _asBool(map['canManageBrands']),
      canManageProducts: _asBool(map['canManageProducts']),
      canManageBanners: _asBool(map['canManageBanners']),
      canManageCoupons: _asBool(map['canManageCoupons']),
      canManageOffers: _asBool(map['canManageOffers']),
      canManageHomeSections: _asBool(map['canManageHomeSections']),
      canDeleteProducts: _asBool(map['canDeleteProducts']),
      canRestoreProducts: _asBool(map['canRestoreProducts']),
      canViewActivityLogs: _asBool(map['canViewActivityLogs']),
      createdByUid: (map['createdByUid'] ?? '').toString(),
      updatedByUid: (map['updatedByUid'] ?? '').toString(),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBAdminPermission.fromJson(String source) {
    return MBAdminPermission.fromMap(
      json.decode(source) as Map<String, dynamic>,
    );
  }

  static bool _asBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }

    return defaultValue;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
