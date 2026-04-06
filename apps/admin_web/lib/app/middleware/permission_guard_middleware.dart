import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_bootstrap_service.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_repositories/shared_repositories.dart';

class PermissionGuardMiddleware extends GetMiddleware {
  PermissionGuardMiddleware({
    required this.permissionKey,
    int? priority,
  }) {
    this.priority = priority ?? 2;
  }

  final String permissionKey;

  AdminWebSessionService get _sessionService =>
      Get.find<AdminWebSessionService>();

  AdminWebBootstrapService get _bootstrapService =>
      Get.find<AdminWebBootstrapService>();

  AdminAccessRepository get _accessRepository =>
      AdminAccessRepository.instance;

  @override
  RouteSettings? redirect(String? route) {
    if (!_sessionService.isSignedIn) {
      return const RouteSettings(name: AdminWebRoutes.login);
    }
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final bool isSignedIn = _sessionService.isSignedIn;
    if (!isSignedIn) {
      return GetNavConfig.fromRoute(AdminWebRoutes.login);
    }

    final bool needsSetup =
    await _bootstrapService.shouldShowSuperAdminSetup();
    if (needsSetup) {
      return GetNavConfig.fromRoute(AdminWebRoutes.setupSuperAdmin);
    }

    final bool hasAdminAccess =
    await _sessionService.hasCurrentUserAdminAccess();
    if (!hasAdminAccess) {
      await _sessionService.signOut();
      return GetNavConfig.fromRoute(AdminWebRoutes.login);
    }

    final String uid = _sessionService.currentUid.trim();
    if (uid.isEmpty) {
      await _sessionService.signOut();
      return GetNavConfig.fromRoute(AdminWebRoutes.login);
    }

    final dynamic permission = await _loadPermissionByUid(uid);
    if (permission == null) {
      return GetNavConfig.fromRoute(AdminWebRoutes.dashboard);
    }

    final bool allowed = _hasPermission(permissionKey, permission);
    if (!allowed) {
      return GetNavConfig.fromRoute(AdminWebRoutes.dashboard);
    }

    return await super.redirectDelegate(route);
  }

  Future<dynamic> _loadPermissionByUid(String uid) async {
    final dynamic repo = _accessRepository;

    try {
      return await repo.getPermissionByUid(uid);
    } catch (_) {}

    try {
      return await repo.fetchPermissionByUid(uid);
    } catch (_) {}

    try {
      return await repo.getByUid(uid);
    } catch (_) {}

    try {
      return await repo.fetchByUid(uid);
    } catch (_) {}

    try {
      return await repo.getPermission(uid);
    } catch (_) {}

    try {
      return await repo.fetchPermission(uid);
    } catch (_) {}

    return null;
  }

  bool _hasPermission(String key, dynamic permission) {
    switch (key) {
      case AdminPermissionKeys.accessAdminPanel:
        return _readBool(permission, 'canAccessAdminPanel');

      case AdminPermissionKeys.viewDashboard:
      case AdminPermissionKeys.viewProfile:
        return _readBool(permission, 'canAccessAdminPanel');

      case AdminPermissionKeys.manageCategories:
        return _readBool(permission, 'canManageCategories');

      case AdminPermissionKeys.manageBrands:
        return _readBool(permission, 'canManageBrands');

      case AdminPermissionKeys.manageProducts:
        return _readBool(permission, 'canManageProducts');

      case AdminPermissionKeys.restoreProducts:
        return _readBool(permission, 'canRestoreProducts');

      case AdminPermissionKeys.manageBanners:
        return _readBool(permission, 'canManageBanners');

      case AdminPermissionKeys.manageOffers:
      case AdminPermissionKeys.managePromos:
        return _readBool(permission, 'canManageBanners');

      case AdminPermissionKeys.manageUsers:
        return _readBool(permission, 'canManageUsers');

      case AdminPermissionKeys.manageAdmins:
        return _readBool(permission, 'canManageAdmins');

      case AdminPermissionKeys.manageStuffs:
        return _readBool(permission, 'canManageAdmins');

      case AdminPermissionKeys.viewActivityLogs:
        return _readBool(permission, 'canViewActivityLogs');

      case AdminPermissionKeys.manageAdminPermissions:
        return _readBool(permission, 'canManageAdminPermissions');

      case AdminPermissionKeys.manageAdminInvites:
        return _readBool(permission, 'canManageAdminInvites');

      case AdminPermissionKeys.manageOrders:
      case AdminPermissionKeys.manageManualOrders:
      case AdminPermissionKeys.managePicking:
      case AdminPermissionKeys.managePacking:
      case AdminPermissionKeys.manageSubstitutions:
      case AdminPermissionKeys.manageRefunds:
      case AdminPermissionKeys.manageReturns:
      case AdminPermissionKeys.manageInventory:
      case AdminPermissionKeys.viewStockLedger:
      case AdminPermissionKeys.managePurchaseReceiving:
      case AdminPermissionKeys.managePurchases:
      case AdminPermissionKeys.manageSuppliers:
      case AdminPermissionKeys.manageFinance:
      case AdminPermissionKeys.manageExpenses:
      case AdminPermissionKeys.manageDailyClosing:
      case AdminPermissionKeys.manageDeliverySettlements:
      case AdminPermissionKeys.manageDelivery:
      case AdminPermissionKeys.manageRiders:
      case AdminPermissionKeys.manageZones:
      case AdminPermissionKeys.manageSlotsCapacity:
      case AdminPermissionKeys.manageDeliveryComplaints:
      case AdminPermissionKeys.manageServices:
      case AdminPermissionKeys.manageServiceCategories:
      case AdminPermissionKeys.manageTechnicians:
      case AdminPermissionKeys.manageServiceComplaints:
      case AdminPermissionKeys.viewCustomers:
      case AdminPermissionKeys.manageCustomerSegments:
      case AdminPermissionKeys.manageCustomerComplaints:
      case AdminPermissionKeys.viewReports:
      case AdminPermissionKeys.manageSettings:
        return _readBool(permission, 'canAccessAdminPanel');

      default:
        return false;
    }
  }

  bool _readBool(dynamic permission, String fieldName) {
    try {
      final dynamic value = permission.toMap()[fieldName];
      return value is bool ? value : false;
    } catch (_) {}

    try {
      final dynamic value = permission.toJsonMap()[fieldName];
      return value is bool ? value : false;
    } catch (_) {}

    try {
      final dynamic value = permission[fieldName];
      return value is bool ? value : false;
    } catch (_) {}

    return false;
  }
}