import 'package:cloud_firestore/cloud_firestore.dart';

class AdminWebBootstrapService {
  AdminWebBootstrapService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _systemCollection = 'system';
  static const String _bootstrapDocId = 'bootstrap';

  DocumentReference<Map<String, dynamic>> get _bootstrapRef =>
      _firestore.collection(_systemCollection).doc(_bootstrapDocId);

  // ==========================================================
  // BOOTSTRAP-ONLY: FIRST SUPER ADMIN SETUP CHECK
  // ----------------------------------------------------------
  // This service is intentionally limited to "read/check" logic.
  //
  // It does NOT:
  // - create admin_permissions
  // - create admins
  // - finalize bootstrap
  //
  // That write logic must remain only inside:
  // feature/setup_super_admin/services/setup_super_admin_service.dart
  //
  // Safe future removal:
  // - remove this file
  // - remove shouldShowSuperAdminSetup() calls from startup/auth
  // ==========================================================

  Future<bool> shouldShowSuperAdminSetup() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _bootstrapRef.get();

      if (!snapshot.exists) {
        return false;
      }

      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};

      final bool allowFirstSuperAdminSetup =
          data['allowFirstSuperAdminSetup'] == true;
      final bool bootstrapCompleted = data['bootstrapCompleted'] == true;

      return allowFirstSuperAdminSetup && !bootstrapCompleted;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getBootstrapStatus() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _bootstrapRef.get();

      if (!snapshot.exists) {
        return null;
      }

      return snapshot.data();
    } catch (_) {
      return null;
    }
  }

  Future<bool> isBootstrapCompleted() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _bootstrapRef.get();

      if (!snapshot.exists) {
        return false;
      }

      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
      return data['bootstrapCompleted'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getFirstSuperAdminUid() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _bootstrapRef.get();

      if (!snapshot.exists) {
        return null;
      }

      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
      final String uid = (data['firstSuperAdminUid'] ?? '').toString().trim();

      return uid.isEmpty ? null : uid;
    } catch (_) {
      return null;
    }
  }
}