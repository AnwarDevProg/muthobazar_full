import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_services/shared_services.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminAccessController extends GetxController {
  final AdminAccessRepository _repository = AdminAccessRepository.instance;

  final Rxn<MBAdminPermission> permission = Rxn<MBAdminPermission>();

  final RxBool isLoading = true.obs;
  final RxBool isAcceptingInvite = false.obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<MBAdminPermission?>? _permissionSubscription;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String get currentAdminUid => _currentUser?.uid ?? '';

  String get currentAdminEmail => _currentUser?.email ?? '';

  String get currentAdminName {
    final String displayName = (_currentUser?.displayName ?? '').trim();
    if (displayName.isNotEmpty) return displayName;

    final String email = (_currentUser?.email ?? '').trim();
    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Admin';
  }

  bool get hasPermissionDoc => permission.value != null;

  bool get isPermissionActive => permission.value?.isActive == true;

  bool get canAccessAdminPanel =>
      isPermissionActive && permission.value?.canAccessAdminPanel == true;

  bool get isSuperAdmin =>
      isPermissionActive && permission.value?.role == 'super_admin';

  bool get canManageAdmins =>
      isPermissionActive && permission.value?.canManageAdmins == true;

  bool get canManageAdminInvites =>
      isPermissionActive && permission.value?.canManageAdminInvites == true;

  bool get canManageAdminPermissions =>
      isPermissionActive && permission.value?.canManageAdminPermissions == true;

  bool get canManageUsers =>
      isPermissionActive && permission.value?.canManageUsers == true;

  bool get canManageCategories =>
      isPermissionActive && permission.value?.canManageCategories == true;

  bool get canManageBrands =>
      isPermissionActive && permission.value?.canManageBrands == true;

  bool get canManageProducts =>
      isPermissionActive && permission.value?.canManageProducts == true;

  bool get canManageBanners =>
      isPermissionActive && permission.value?.canManageBanners == true;

  bool get canManageCoupons =>
      isPermissionActive && permission.value?.canManageCoupons == true;

  bool get canManageOffers =>
      isPermissionActive && permission.value?.canManageOffers == true;

  bool get canDeleteProducts =>
      isPermissionActive && permission.value?.canDeleteProducts == true;

  bool get canRestoreProducts =>
      isPermissionActive && permission.value?.canRestoreProducts == true;

  bool get canViewActivityLogs =>
      isPermissionActive && permission.value?.canViewActivityLogs == true;

  @override
  void onInit() {
    super.onInit();
    _listenAuthAndPermission();
  }

  void _listenAuthAndPermission() {
    _authSubscription?.cancel();
    _permissionSubscription?.cancel();

    isLoading.value = true;

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (User? user) {
        _permissionSubscription?.cancel();

        if (user == null) {
          permission.value = null;
          isLoading.value = false;
          return;
        }

        isLoading.value = true;

        _permissionSubscription = _repository.watchPermission(user.uid).listen(
              (MBAdminPermission? value) {
            permission.value = value;
            isLoading.value = false;
          },
          onError: (_) {
            permission.value = null;
            isLoading.value = false;
          },
        );
      },
      onError: (_) {
        permission.value = null;
        isLoading.value = false;
      },
    );
  }

  Future<void> refreshPermission() async {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      permission.value = null;
      return;
    }

    try {
      isLoading.value = true;
      permission.value = await _repository.fetchPermission(uid);
    } catch (_) {
      permission.value = null;
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh admin permission.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bootstrapFirstSuperAdmin({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      isLoading.value = true;

      final MBAdminPermission superPermission = MBAdminPermission.superAdmin(
        uid: uid,
        actorUid: uid,
      );

      await _repository.savePermission(permission: superPermission);

      await _repository.createAdminProfile(
        uid: uid,
        name: name,
        email: email,
        role: 'super_admin',
        createdByUid: uid,
      );

      await AdminActivityLogger.log(
        actorUid: uid,
        actorName: name,
        actorPhone: '', // not available yet
        actorRole: 'super_admin',
        action: 'admin.bootstrap_super_admin',
        module: 'admin_access',
        targetType: 'admin_permission',
        targetId: uid,
        targetTitle: name,
        afterData: superPermission.toMap(),
        metadata: {
          'email': email,
          'source': 'bootstrap',
        },
        status: 'success',
      );

      permission.value = superPermission;

      MBNotification.success(
        title: 'Success',
        message: 'Super admin access initialized.',
      );
    } catch (e) {
      await AdminActivityLogger.log(
        actorUid: uid,
        actorName: name,
        actorPhone: '',
        actorRole: 'super_admin',
        action: 'admin.bootstrap_super_admin',
        module: 'admin_access',
        targetType: 'admin_permission',
        targetId: uid,
        targetTitle: name,
        status: 'failed',
        reason: e.toString(),
      );

      MBNotification.error(
        title: 'Error',
        message: 'Failed to initialize super admin access.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _permissionSubscription?.cancel();
    super.onClose();
  }
}