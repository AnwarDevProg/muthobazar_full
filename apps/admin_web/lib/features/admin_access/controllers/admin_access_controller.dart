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

  bool get hasPermissionDoc => permission.value != null;

  bool get canAccessAdminPanel =>
      permission.value?.isActive == true &&
      permission.value?.canAccessAdminPanel == true;

  bool get isSuperAdmin =>
      permission.value?.isActive == true &&
      permission.value?.role == 'super_admin';

  bool get canManageAdmins =>
      permission.value?.isActive == true &&
      permission.value?.canManageAdmins == true;

  bool get canManageAdminInvites =>
      permission.value?.isActive == true &&
      permission.value?.canManageAdminInvites == true;

  bool get canManageAdminPermissions =>
      permission.value?.isActive == true &&
      permission.value?.canManageAdminPermissions == true;

  bool get canManageUsers =>
      permission.value?.isActive == true &&
      permission.value?.canManageUsers == true;

  bool get canManageCategories =>
      permission.value?.isActive == true &&
      permission.value?.canManageCategories == true;

  bool get canManageBrands =>
      permission.value?.isActive == true &&
      permission.value?.canManageBrands == true;

  bool get canManageProducts =>
      permission.value?.isActive == true &&
      permission.value?.canManageProducts == true;

  bool get canManageBanners =>
      permission.value?.isActive == true &&
      permission.value?.canManageBanners == true;

  bool get canDeleteProducts =>
      permission.value?.isActive == true &&
      permission.value?.canDeleteProducts == true;

  bool get canRestoreProducts =>
      permission.value?.isActive == true &&
      permission.value?.canRestoreProducts == true;

  bool get canViewActivityLogs =>
      permission.value?.isActive == true &&
      permission.value?.canViewActivityLogs == true;

  @override
  void onInit() {
    super.onInit();
    _listenAuthAndPermission();
  }

  void _listenAuthAndPermission() {
    _authSubscription?.cancel();
    _permissionSubscription?.cancel();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _permissionSubscription?.cancel();

      if (user == null) {
        permission.value = null;
        isLoading.value = false;
        return;
      }

      isLoading.value = true;

      _permissionSubscription = _repository.watchPermission(user.uid).listen((MBAdminPermission? value) {
          permission.value = value;
          isLoading.value = false;
        },
        onError: (_) {
          permission.value = null;
          isLoading.value = false;
        },
      );
    });
  }

  Future<void> refreshPermission() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      permission.value = null;
      return;
    }

    try {
      isLoading.value = true;
      permission.value = await _repository.fetchPermission(uid);
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

      final superPermission = MBAdminPermission.superAdmin(
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
        adminUid: uid,
        adminName: name,
        adminEmail: email,
        adminRole: 'super_admin',
        action: 'create_admin_permission',
        targetType: 'admin_permission',
        targetId: uid,
        targetTitle: name,
        summary: 'Initialized first super admin access for """"',
        afterData: superPermission.toMap(),
      );

      permission.value = superPermission;

      MBNotification.success(
        title: 'Success',
        message: 'Super admin access initialized.',
      );
    } catch (_) {
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


