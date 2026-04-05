import 'dart:async';

import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/customer/mb_user_profile.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_services/shared_services.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../admin_access/controllers/admin_access_controller.dart';
import '../../profile/controllers/admin_profile_controller.dart';

enum AdminUserFilter {
  all,
  active,
  inactive,
  blocked,
  guest,
  customer,
  admin,
  superAdmin,
}

class AdminUserController extends GetxController {
  AdminUserController({
    AdminUserRepository? repository,
  }) : _repository = repository ?? AdminUserRepository.instance;

  final AdminUserRepository _repository;

  final AdminProfileController _profileController =
  Get.find<AdminProfileController>();

  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isRefreshing = false.obs;

  final Rx<AdminUserFilter> selectedFilter = AdminUserFilter.all.obs;

  final TextEditingController searchController = TextEditingController();

  StreamSubscription<List<UserModel>>? _usersSubscription;

  String get currentAdminUid =>
      _profileController.currentUser.value?.id.trim() ?? '';

  String get currentAdminName => _profileController.fullName;

  String get currentAdminEmail => _profileController.email;

  String get currentAdminRole =>
      _accessController.permission.value?.role ?? '';

  bool get canManageUsers => _accessController.canManageUsers;

  bool get isSuperAdmin => _accessController.isSuperAdmin;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_applyFilters);
    _listenUsers();
  }

  void _listenUsers() {
    _usersSubscription?.cancel();
    isLoading.value = true;

    _usersSubscription = _repository.watchUsers().listen(
          (items) {
        final normalized = items.map(UserModel.normalized).toList()
          ..sort(_sortUsers);

        users.assignAll(normalized);
        _applyFilters();
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        _showError('Failed to load users.');
      },
    );
  }

  Future<void> refreshUsers() async {
    if (!canManageUsers) {
      _showAccessDenied();
      return;
    }

    try {
      isRefreshing.value = true;

      final items = await _repository.fetchUsersOnce();
      final normalized = items.map(UserModel.normalized).toList()
        ..sort(_sortUsers);

      users.assignAll(normalized);
      _applyFilters();
    } catch (_) {
      _showError('Failed to refresh users.');
    } finally {
      isRefreshing.value = false;
    }
  }

  void updateFilter(AdminUserFilter filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    final results = users.where((user) {
      if (!_matchesFilter(user)) return false;

      if (query.isEmpty) return true;

      return [
        user.id,
        user.fullName,
        user.email,
        user.phoneNumber,
        user.role,
        user.accountStatus,
      ].join(' ').toLowerCase().contains(query);
    }).toList();

    filteredUsers.assignAll(results);
  }

  bool _matchesFilter(UserModel user) {
    switch (selectedFilter.value) {
      case AdminUserFilter.all:
        return true;
      case AdminUserFilter.active:
        return user.isActive;
      case AdminUserFilter.inactive:
        return user.isInactive;
      case AdminUserFilter.blocked:
        return user.isBlocked;
      case AdminUserFilter.guest:
        return user.isGuest;
      case AdminUserFilter.customer:
        return user.role == UserRoles.customer;
      case AdminUserFilter.admin:
        return user.role == UserRoles.admin;
      case AdminUserFilter.superAdmin:
        return user.role == UserRoles.superAdmin;
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    if (isSaving.value) return;

    final before = users.firstWhereOrNull((e) => e.id == updatedUser.id);

    if (!_canModifyUser(before)) return;

    try {
      isSaving.value = true;

      final updated = UserModel.normalized(updatedUser);

      await _repository.updateUserBasicInfo(
        uid: updated.id,
        firstName: updated.firstName,
        lastName: updated.lastName,
        email: updated.email,
        phoneNumber: updated.phoneNumber,
        gender: updated.gender,
        dateOfBirth: updated.dateOfBirth,
        role: updated.role,
        accountStatus: updated.accountStatus,
        isGuest: updated.isGuest,
      );

      await _logAction(
        action: 'update_user',
        target: updated,
        summary: 'Updated user "${updated.displayNameForAdmin}"',
        before: before,
        after: updated,
      );

      MBNotification.success(
        title: 'Success',
        message: 'User updated successfully.',
      );
    } catch (_) {
      _showError('Failed to update user.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> blockUser(UserModel user) async {
    if (!_canModifyUser(user)) return;

    try {
      await _repository.softBlockUser(uid: user.id);

      final after = UserModel.normalized(
        user.copyWith(accountStatus: UserStatuses.blocked),
      );

      await _logAction(
        action: 'block_user',
        target: user,
        summary: 'Blocked user "${user.displayNameForAdmin}"',
        before: user,
        after: after,
      );

      MBNotification.success(
        title: 'Success',
        message: 'User blocked.',
      );
    } catch (_) {
      _showError('Failed to block user.');
    }
  }

  Future<void> deactivateUser(UserModel user) async {
    if (!_canModifyUser(user)) return;

    try {
      await _repository.softDeactivateUser(uid: user.id);

      final after = UserModel.normalized(
        user.copyWith(accountStatus: UserStatuses.inactive),
      );

      await _logAction(
        action: 'deactivate_user',
        target: user,
        summary: 'Deactivated user "${user.displayNameForAdmin}"',
        before: user,
        after: after,
      );

      MBNotification.success(
        title: 'Success',
        message: 'User deactivated.',
      );
    } catch (_) {
      _showError('Failed to deactivate user.');
    }
  }

  Future<void> reactivateUser(UserModel user) async {
    if (!_canModifyUser(user)) return;

    try {
      await _repository.reactivateUser(uid: user.id);

      final after = UserModel.normalized(
        user.copyWith(accountStatus: UserStatuses.active),
      );

      await _logAction(
        action: 'reactivate_user',
        target: user,
        summary: 'Reactivated user "${user.displayNameForAdmin}"',
        before: user,
        after: after,
      );

      MBNotification.success(
        title: 'Success',
        message: 'User reactivated.',
      );
    } catch (_) {
      _showError('Failed to reactivate user.');
    }
  }

  bool canBlock(UserModel user) {
    return _canModifyUser(user, notify: false) && !user.isBlocked;
  }

  bool canDeactivate(UserModel user) {
    return _canModifyUser(user, notify: false) && user.isActive;
  }

  bool canReactivate(UserModel user) {
    return _canModifyUser(user, notify: false) &&
        (user.isBlocked || user.isInactive);
  }

  bool _canModifyUser(
      UserModel? user, {
        bool notify = true,
      }) {
    if (!canManageUsers) {
      if (notify) _showAccessDenied();
      return false;
    }

    if (user == null) {
      if (notify) _showWarning('User not found.');
      return false;
    }

    if (user.id == currentAdminUid) {
      if (notify) {
        _showWarning('You cannot modify your own account.');
      }
      return false;
    }

    if (user.isSuperAdmin && !isSuperAdmin) {
      if (notify) {
        _showWarning('Only super admin can manage another super admin.');
      }
      return false;
    }

    if (user.isAdmin && !isSuperAdmin) {
      if (notify) {
        _showWarning('Only super admin can manage admin accounts.');
      }
      return false;
    }

    return true;
  }

  Future<void> _logAction({
    required String action,
    required UserModel target,
    required String summary,
    UserModel? before,
    UserModel? after,
  }) async {
    try {
      final session = Get.find<AdminWebSessionService>();
      final access = Get.find<AdminAccessController>();
      final profile = Get.find<AdminProfileController>();

      final actorUid = session.currentUid.trim();
      final actorName = profile.fullName.trim();
      final actorPhone = (profile.currentUser.value?.phoneNumber ?? '').trim();
      final actorRole = (access.permission.value?.role ?? 'admin').trim();

      await AdminActivityLogger.log(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: action,
        module: 'users',
        targetType: 'user',
        targetId: target.id,
        targetTitle: target.displayNameForAdmin.trim().isEmpty
            ? 'Unnamed User'
            : target.displayNameForAdmin,
        reason: summary,
        beforeData: _buildUserLogData(before),
        afterData: _buildUserLogData(after),
        metadata: {
          'summary': summary,
          'targetEmail': target.email,
          'targetPhone': target.phoneNumber,
          'targetRole': target.role,
          'targetStatus': target.accountStatus,
          'targetIsGuest': target.isGuest,
          'performedByEmail': currentAdminEmail,
        },
        status: 'success',
      );
    } catch (_) {
      // Do not break the main user-management flow if audit logging fails.
    }
  }

  Map<String, dynamic>? _buildUserLogData(UserModel? user) {
    if (user == null) return null;

    return {
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'fullName': user.fullName,
      'displayNameForAdmin': user.displayNameForAdmin,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'gender': user.gender,
      'dateOfBirth': user.dateOfBirth is DateTime
          ? (user.dateOfBirth as DateTime).toIso8601String()
          : user.dateOfBirth,
      'role': user.role,
      'accountStatus': user.accountStatus,
      'isGuest': user.isGuest,
      'isActive': user.isActive,
      'isInactive': user.isInactive,
      'isBlocked': user.isBlocked,
      'profilePicture': user.profilePicture,
    };
  }

  int _sortUsers(UserModel a, UserModel b) {
    return a.displayNameForAdmin
        .toLowerCase()
        .compareTo(b.displayNameForAdmin.toLowerCase());
  }

  void _showAccessDenied() {
    MBNotification.warning(
      title: 'Access denied',
      message: 'You do not have permission.',
    );
  }

  void _showWarning(String msg) {
    MBNotification.warning(
      title: 'Warning',
      message: msg,
    );
  }

  void _showError(String msg) {
    MBNotification.error(
      title: 'Error',
      message: msg,
    );
  }

  @override
  void onClose() {
    _usersSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}