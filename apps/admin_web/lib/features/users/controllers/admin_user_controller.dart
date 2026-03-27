import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../models/user_model.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:shared_services/shared_services.dart';
import 'admin_access_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminUserController extends GetxController {
  final AdminUserRepository _repository = AdminUserRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<UserModel> users = <UserModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  StreamSubscription<List<UserModel>>? _usersSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenUsers();
  }

  void _listenUsers() {
    _usersSubscription?.cancel();
    isLoading.value = true;

    _usersSubscription = _repository.watchUsers().listen(
          (items) {
        users.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load users.',
        );
      },
    );
  }

  Future<void> refreshUsers() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchUsersOnce();
      users.assignAll(items);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh users.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser({
    required UserModel updatedUser,
  }) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final before = users.firstWhereOrNull((e) => e.id == updatedUser.id);

      await _repository.updateUserBasicInfo(
        uid: updatedUser.id,
        firstName: updatedUser.firstName,
        lastName: updatedUser.lastName,
        email: updatedUser.email,
        phoneNumber: updatedUser.phoneNumber,
        gender: updatedUser.gender,
        dateOfBirth: updatedUser.dateOfBirth,
        role: updatedUser.role,
        accountStatus: updatedUser.accountStatus,
        isGuest: updatedUser.isGuest,
      );

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_user',
        targetType: 'user',
        targetId: updatedUser.id,
        targetTitle: updatedUser.fullName,
        summary: 'Updated user "${updatedUser.fullName}"',
        beforeData: before?.toJson(),
        afterData: updatedUser.toJson(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'User updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update user.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> setUserStatus({
    required UserModel user,
    required String newStatus,
  }) async {
    try {
      final updated = user.copyWith(accountStatus: newStatus);

      await _repository.setUserStatus(
        uid: user.id,
        accountStatus: newStatus,
      );

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_user_status',
        targetType: 'user',
        targetId: user.id,
        targetTitle: user.fullName,
        summary: 'Changed user status of "${user.fullName}" to "$newStatus"',
        beforeData: user.toJson(),
        afterData: updated.toJson(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'User status updated.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update user status.',
      );
    }
  }

  Future<void> setUserRole({
    required UserModel user,
    required String newRole,
  }) async {
    try {
      final updated = user.copyWith(role: newRole);

      await _repository.setUserRole(
        uid: user.id,
        role: newRole,
      );

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_user_role',
        targetType: 'user',
        targetId: user.id,
        targetTitle: user.fullName,
        summary: 'Changed user role of "${user.fullName}" to "$newRole"',
        beforeData: user.toJson(),
        afterData: updated.toJson(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'User role updated.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update user role.',
      );
    }
  }

  Future<void> blockUser(UserModel user) async {
    try {
      final updated = user.copyWith(accountStatus: 'blocked');

      await _repository.softBlockUser(uid: user.id);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'block_user',
        targetType: 'user',
        targetId: user.id,
        targetTitle: user.fullName,
        summary: 'Blocked user "${user.fullName}"',
        beforeData: user.toJson(),
        afterData: updated.toJson(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'User blocked successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to block user.',
      );
    }
  }

  Future<void> deactivateUser(UserModel user) async {
    try {
      final updated = user.copyWith(accountStatus: 'inactive');

      await _repository.softDeactivateUser(uid: user.id);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'deactivate_user',
        targetType: 'user',
        targetId: user.id,
        targetTitle: user.fullName,
        summary: 'Deactivated user "${user.fullName}"',
        beforeData: user.toJson(),
        afterData: updated.toJson(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'User deactivated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to deactivate user.',
      );
    }
  }

  Future<void> reactivateUser(UserModel user) async {
    try {
      final updated = user.copyWith(accountStatus: 'active');

      await _repository.reactivateUser(uid: user.id);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'reactivate_user',
        targetType: 'user',
        targetId: user.id,
        targetTitle: user.fullName,
        summary: 'Reactivated user "${user.fullName}"',
        beforeData: user.toJson(),
        afterData: updated.toJson(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'User reactivated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to reactivate user.',
      );
    }
  }

  @override
  void onClose() {
    _usersSubscription?.cancel();
    super.onClose();
  }
}












