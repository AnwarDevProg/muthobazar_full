import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../admin_access/controllers/admin_access_controller.dart';
import '../../profile/controllers/admin_profile_controller.dart';

class AdminManagementController extends GetxController {
  AdminManagementController({
    AdminAccessRepository? repository,
  }) : _repository = repository ?? AdminAccessRepository.instance;

  final AdminAccessRepository _repository;
  final AdminProfileController _profileController = Get.find();
  final AdminAccessController _accessController = Get.find();

  final RxList<Map<String, dynamic>> admins = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isRefreshing = false.obs;

  StreamSubscription<List<Map<String, dynamic>>>? _adminsSubscription;

  AdminAccessController get accessController => _accessController;

  String get currentAdminUid =>
      _profileController.currentUser.value?.id.trim() ?? '';

  String get adminName => _profileController.fullName;
  String get adminEmail => _profileController.email;
  String get adminRole => _accessController.permission.value?.role.trim() ?? '-';

  String get greetingLabel {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  bool get canAccessAdminPanel => _accessController.canAccessAdminPanel;
  bool get isSuperAdmin => _accessController.isSuperAdmin;
  bool get canManageAdmins => _accessController.canManageAdmins;
  bool get canManageAdminInvites => _accessController.canManageAdminInvites;
  bool get canManageAdminPermissions =>
      _accessController.canManageAdminPermissions;
  bool get canManageUsers => _accessController.canManageUsers;
  bool get canManageCategories => _accessController.canManageCategories;
  bool get canManageBrands => _accessController.canManageBrands;
  bool get canManageProducts => _accessController.canManageProducts;
  bool get canManageBanners => _accessController.canManageBanners;
  bool get canManageCoupons => _accessController.canManageCoupons;
  bool get canManageOffers => _accessController.canManageOffers;
  bool get canManageHomeSections => _accessController.canManageHomeSections;
  bool get canDeleteProducts => _accessController.canDeleteProducts;
  bool get canRestoreProducts => _accessController.canRestoreProducts;
  bool get canViewActivityLogs => _accessController.canViewActivityLogs;

  int get enabledPermissionCount {
    final flags = <bool>[
      canAccessAdminPanel,
      canManageAdmins,
      canManageAdminInvites,
      canManageAdminPermissions,
      canManageUsers,
      canManageCategories,
      canManageBrands,
      canManageProducts,
      canManageBanners,
      canManageCoupons,
      canManageOffers,
      canManageHomeSections,
      canDeleteProducts,
      canRestoreProducts,
      canViewActivityLogs,
    ];
    return flags.where((e) => e).length;
  }

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
        final normalized = items.map(_normalizeAdminMap).toList()
          ..sort(_sortAdminsForView);
        admins.assignAll(normalized);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        _showError('Failed to load admins.');
      },
    );
  }

  Future<void> refreshAdmins() async {
    if (!_canViewAdminManagement()) return;

    try {
      isRefreshing.value = true;
      final items = await _repository.fetchAdminsOnce();
      final normalized = items.map(_normalizeAdminMap).toList()
        ..sort(_sortAdminsForView);
      admins.assignAll(normalized);
    } catch (_) {
      _showError('Failed to refresh admin list.');
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> saveAdminPermission({
    required String uid,
    required String name,
    required String email,
    required MBAdminPermission permission,
    required String actorUid,
  }) async {
    if (!_canManageAdminPermissionsAction()) return;
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final MBAdminPermission? before = await _repository.fetchPermission(uid);

      await _repository.updateAdminAccess(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        permission: permission,
        actorUid: actorUid,
      );

      await _logAdminAccessAction(
        action: 'update_admin_permission',
        targetId: uid,
        targetTitle: name.trim().isEmpty ? uid : name.trim(),
        summary:
        'Updated admin permission for "${name.trim().isEmpty ? uid : name.trim()}"',
        beforeData: before?.toMap(),
        afterData: permission.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Admin permission updated successfully.',
      );
    } catch (_) {
      _showError('Failed to update admin permission.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> removeAdminAccess({
    required String uid,
  }) async {
    if (!_canManageAdminPermissionsAction()) return;
    if (isSaving.value) return;

    if (uid.trim().isEmpty) {
      _showWarning('Invalid admin uid.');
      return;
    }

    if (uid.trim() == currentAdminUid) {
      _showWarning(
        'You cannot remove your own admin access from this screen.',
      );
      return;
    }

    try {
      isSaving.value = true;

      final Map<String, dynamic>? admin = admins.firstWhereOrNull(
            (e) => (e['uid'] ?? '').toString() == uid,
      );

      final MBAdminPermission? before = await _repository.fetchPermission(uid);

      await _repository.deleteAdminAccess(uid: uid);

      final String targetTitle =
      ((admin?['name'] ?? '').toString().trim().isNotEmpty)
          ? (admin?['name'] ?? '').toString().trim()
          : uid;

      await _logAdminAccessAction(
        action: 'remove_admin_access',
        targetId: uid,
        targetTitle: targetTitle,
        summary: 'Removed admin access for "$targetTitle"',
        beforeData: before?.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Admin access removed successfully.',
      );
    } catch (_) {
      _showError('Failed to remove admin access.');
    } finally {
      isSaving.value = false;
    }
  }

  bool _canViewAdminManagement() {
    if (!canManageAdmins && !canManageAdminPermissions && !isSuperAdmin) {
      _showAccessDenied();
      return false;
    }
    return true;
  }

  bool _canManageAdminPermissionsAction() {
    if (!canManageAdminPermissions && !isSuperAdmin) {
      _showWarning('You do not have permission to manage admin permissions.');
      return false;
    }
    return true;
  }

  Future<void> _logAdminAccessAction({
    required String action,
    required String targetId,
    required String targetTitle,
    required String summary,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
  }) async {
    /// Insert actual logger during development
    /// await AdminActivityLogger.log(...);
  }

  Map<String, dynamic> _normalizeAdminMap(Map raw) {
    return <String, dynamic>{
      ...raw,
      'uid': (raw['uid'] ?? '').toString().trim(),
      'name': (raw['name'] ?? '').toString().trim(),
      'email': (raw['email'] ?? '').toString().trim(),
      'role': (raw['role'] ?? '').toString().trim().toLowerCase(),
      'isActive': raw['isActive'] == true,
    };
  }

  int _sortAdminsForView(Map a, Map b) {
    final String roleA = (a['role'] ?? '').toString().trim().toLowerCase();
    final String roleB = (b['role'] ?? '').toString().trim().toLowerCase();

    final int roleCompare = _roleRank(roleA).compareTo(_roleRank(roleB));
    if (roleCompare != 0) return roleCompare;

    final String nameA = (a['name'] ?? '').toString().trim().toLowerCase();
    final String nameB = (b['name'] ?? '').toString().trim().toLowerCase();
    return nameA.compareTo(nameB);
  }

  int _roleRank(String role) {
    switch (role) {
      case 'super_admin':
        return 0;
      case 'admin':
        return 1;
      default:
        return 9;
    }
  }

  void _showAccessDenied() {
    MBNotification.warning(
      title: 'Access denied',
      message: 'You do not have permission to access this admin area.',
    );
  }

  void _showWarning(String message) {
    MBNotification.warning(
      title: 'Not allowed',
      message: message,
    );
  }

  void _showError(String message) {
    MBNotification.error(
      title: 'Error',
      message: message,
    );
  }

  @override
  void onClose() {
    _adminsSubscription?.cancel();
    super.onClose();
  }
}