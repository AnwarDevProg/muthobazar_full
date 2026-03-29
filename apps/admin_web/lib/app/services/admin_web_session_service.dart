import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminWebSessionService {
  AdminWebSessionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _adminsCollection = 'admins';
  static const String _adminPermissionsCollection = 'admin_permissions';

  User? get currentUser => _auth.currentUser;

  String get currentUid => _auth.currentUser?.uid ?? '';

  bool get isSignedIn => _auth.currentUser != null;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==========================================================
  // NORMAL ADMIN SESSION / ACCESS LOGIC
  // ----------------------------------------------------------
  // This service is for reusable admin session and permission checks.
  //
  // It does NOT handle:
  // - first super admin bootstrap writes
  // - setup completion
  //
  // Those must remain inside:
  // feature/setup_super_admin/services/setup_super_admin_service.dart
  // ==========================================================

  Future<bool> hasCurrentUserAdminAccess() async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    final Map<String, dynamic>? adminProfile = await _getAdminProfile(user.uid);
    if (!_isActiveAdminProfile(adminProfile)) return false;

    final Map<String, dynamic>? permissionData =
    await _getAdminPermission(user.uid);
    if (!_isActivePermission(permissionData)) return false;

    final String role =
    (adminProfile?['role'] ?? permissionData?['role'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    return role == 'admin' || role == 'super_admin';
  }

  Future<bool> isCurrentUserSuperAdmin() async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    final Map<String, dynamic>? adminProfile = await _getAdminProfile(user.uid);
    if (!_isActiveAdminProfile(adminProfile)) return false;

    final Map<String, dynamic>? permissionData =
    await _getAdminPermission(user.uid);
    if (!_isActivePermission(permissionData)) return false;

    final String role =
    (permissionData?['role'] ?? adminProfile?['role'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    return role == 'super_admin';
  }

  Future<bool> isCurrentUserAdmin() async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    final Map<String, dynamic>? adminProfile = await _getAdminProfile(user.uid);
    if (!_isActiveAdminProfile(adminProfile)) return false;

    final Map<String, dynamic>? permissionData =
    await _getAdminPermission(user.uid);
    if (!_isActivePermission(permissionData)) return false;

    final String role =
    (permissionData?['role'] ?? adminProfile?['role'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    return role == 'admin' || role == 'super_admin';
  }

  Future<bool> hasPermission(String permissionKey) async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    final Map<String, dynamic>? adminProfile = await _getAdminProfile(user.uid);
    if (!_isActiveAdminProfile(adminProfile)) return false;

    final Map<String, dynamic>? permissionData =
    await _getAdminPermission(user.uid);
    if (!_isActivePermission(permissionData)) return false;

    final String role =
    (permissionData?['role'] ?? adminProfile?['role'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    if (role == 'super_admin') {
      return true;
    }

    if (role != 'admin') {
      return false;
    }

    return _asBool(permissionData?[permissionKey]);
  }

  Future<Map<String, dynamic>?> getCurrentAdminProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    return _getAdminProfile(user.uid);
  }

  Future<Map<String, dynamic>?> getCurrentAdminPermissions() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    return _getAdminPermission(user.uid);
  }

  Future<String?> getCurrentAdminRole() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final Map<String, dynamic>? adminProfile = await _getAdminProfile(user.uid);
    final Map<String, dynamic>? permissionData =
    await _getAdminPermission(user.uid);

    final String role =
    (permissionData?['role'] ?? adminProfile?['role'] ?? '')
        .toString()
        .trim();

    return role.isEmpty ? null : role;
  }

  // ==========================================================
  // Internal helpers
  // ==========================================================

  Future<Map<String, dynamic>?> _getAdminProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> adminDoc =
    await _firestore.collection(_adminsCollection).doc(uid).get();
    return adminDoc.data();
  }

  Future<Map<String, dynamic>?> _getAdminPermission(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> permissionDoc =
    await _firestore.collection(_adminPermissionsCollection).doc(uid).get();
    return permissionDoc.data();
  }

  bool _isActiveAdminProfile(Map<String, dynamic>? adminProfile) {
    if (adminProfile == null) return false;
    return _asBool(adminProfile['isActive'], defaultValue: true);
  }

  bool _isActivePermission(Map<String, dynamic>? permissionData) {
    if (permissionData == null) return false;

    final bool isActive =
    _asBool(permissionData['isActive'], defaultValue: true);
    final bool canAccessAdminPanel =
    _asBool(permissionData['canAccessAdminPanel']);

    return isActive && canAccessAdminPanel;
  }

  bool _asBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;

    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }

    if (value is num) {
      return value != 0;
    }

    return defaultValue;
  }
}