import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../services/setup_super_admin_service.dart';

class SetupSuperAdminController extends GetxController {
  SetupSuperAdminController({
    SetupSuperAdminService? service,
  }) : _service = service ?? SetupSuperAdminService();

  final SetupSuperAdminService _service;

  final RxBool isSubmitting = false.obs;

  Future<void> createFirstSuperAdmin({
    required String fullName,
    required String email,
  }) async {
    if (isSubmitting.value) return;

    try {
      isSubmitting.value = true;

      await _service.bootstrapFirstSuperAdmin(
        fullName: fullName,
        email: email,
      );

      MBNotification.success(
        title: 'Success',
        message: 'First super admin created successfully.',
      );
    } catch (e) {
      MBNotification.error(
        title: 'Setup failed',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    } finally {
      isSubmitting.value = false;
    }
  }
}