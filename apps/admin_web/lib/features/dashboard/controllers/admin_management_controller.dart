import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:shared_models/shared_models.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:shared_services/shared_services.dart';
import 'admin_access_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminManagementController extends GetxController {
  final AdminAccessRepository _repository = AdminAccessRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<Map<String, dynamic>> admins = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  StreamSubscription<List<Map<String, dynamic>>>? _adminsSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenAdmins();
  }

  void _listenAdmins() {
    _adminsSubscription?.cancel();
    isLoading.value = true;

    _adminsSubscription = _repository.watchAdmins().listen(
          (items) {
        admins.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load admins.',
        );
      },
    );
  }

  Future<void> refreshAdmins() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchAdminsOnce();
      admins.assignAll(items);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh admin list.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveAdminPermission({
    required String uid,
    required String name,
    required String email,
    required MBAdminPermission permission,
    required String actorUid,
  }) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final before = await _repository.fetchPermission(uid);

      await _repository.updateAdminAccess(
        uid: uid,
        name: name,
        email: email,
        permission: permission,
        actorUid: actorUid,
      );

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_admin_permission',
        targetType: 'admin_permission',
        targetId: uid,
        targetTitle: name,
        summary: 'Updated admin permission for "$name"',
        beforeData: before?.toMap(),
        afterData: permission.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Admin permission updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update admin permission.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> removeAdminAccess({
    required String uid,
  }) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final admin = admins.firstWhereOrNull((e) => e['uid'] == uid);
      final before = await _repository.fetchPermission(uid);

      await _repository.deleteAdminAccess(uid: uid);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'remove_admin_access',
        targetType: 'admin_permission',
        targetId: uid,
        targetTitle: (admin?['name'] ?? '').toString(),
        summary: 'Removed admin access for "${(admin?['name'] ?? uid).toString()}"',
        beforeData: before?.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Admin access removed successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to remove admin access.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _adminsSubscription?.cancel();
    super.onClose();
  }
}












