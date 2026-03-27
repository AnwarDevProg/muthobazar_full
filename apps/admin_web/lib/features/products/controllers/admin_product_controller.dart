import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../models/catalog/mb_product.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:shared_services/shared_services.dart';
import 'admin_access_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminProductController extends GetxController {
  final AdminProductRepository _repository = AdminProductRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<MBProduct> products = <MBProduct>[].obs;
  final RxList<Map<String, dynamic>> quarantineProducts =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isQuarantineLoading = true.obs;

  StreamSubscription<List<MBProduct>>? _productsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _quarantineSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenProducts();
    _listenQuarantine();
  }

  void _listenProducts() {
    _productsSubscription?.cancel();
    isLoading.value = true;

    _productsSubscription = _repository.watchProducts().listen(
          (items) {
        products.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load products.',
        );
      },
    );
  }

  void _listenQuarantine() {
    _quarantineSubscription?.cancel();
    isQuarantineLoading.value = true;

    _quarantineSubscription = _repository.watchQuarantineProducts().listen(
          (items) {
        quarantineProducts.assignAll(items);
        isQuarantineLoading.value = false;
      },
      onError: (_) {
        isQuarantineLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load quarantine products.',
        );
      },
    );
  }

  Future<void> refreshProducts() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchProductsOnce();
      products.assignAll(items);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh products.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProduct(MBProduct product) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      await _repository.createProduct(product);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'create_product',
        targetType: 'product',
        targetId: product.id,
        targetTitle: product.titleEn,
        summary: 'Created product "${product.titleEn}"',
        afterData: product.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Product created successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to create product.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateProduct(MBProduct product) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final before = products.firstWhereOrNull((e) => e.id == product.id);

      await _repository.updateProduct(product);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_product',
        targetType: 'product',
        targetId: product.id,
        targetTitle: product.titleEn,
        summary: 'Updated product "${product.titleEn}"',
        beforeData: before?.toMap(),
        afterData: product.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Product updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update product.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleProductEnabled(MBProduct product) async {
    try {
      final updated = product.copyWith(
        isEnabled: !product.isEnabled,
        updatedAt: DateTime.now(),
      );

      await _repository.setProductEnabledState(
        productId: product.id,
        isEnabled: !product.isEnabled,
      );

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'toggle_product_enabled',
        targetType: 'product',
        targetId: product.id,
        targetTitle: product.titleEn,
        summary: updated.isEnabled
            ? 'Enabled product "${product.titleEn}"'
            : 'Disabled product "${product.titleEn}"',
        beforeData: product.toMap(),
        afterData: updated.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: product.isEnabled
            ? 'Product disabled successfully.'
            : 'Product enabled successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to change product status.',
      );
    }
  }

  Future<void> moveProductToQuarantine({
    required MBProduct product,
    required String deletedByUid,
    required String deletedByName,
  }) async {
    if (isDeleting.value) return;

    try {
      isDeleting.value = true;

      await _repository.moveToQuarantine(
        product: product,
        deletedByUid: deletedByUid,
        deletedByName: deletedByName,
      );

      await AdminActivityLogger.log(
        adminUid: deletedByUid,
        adminName: deletedByName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'delete_product',
        targetType: 'product',
        targetId: product.id,
        targetTitle: product.titleEn,
        summary: 'Moved product "${product.titleEn}" to quarantine',
        beforeData: product.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Product moved to quarantine.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to quarantine product.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> restoreProduct(String productId) async {
    try {
      final item = quarantineProducts.firstWhereOrNull((e) => e['id'] == productId);
      final productData = item == null
          ? null
          : Map<String, dynamic>.from(
        item['productData'] as Map<String, dynamic>? ?? const {},
      );

      await _repository.restoreFromQuarantine(productId);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'restore_product',
        targetType: 'product',
        targetId: productId,
        targetTitle: (productData?['titleEn'] ?? '').toString(),
        summary:
        'Restored product "${(productData?['titleEn'] ?? productId).toString()}" from quarantine',
        afterData: productData,
      );

      MBNotification.success(
        title: 'Success',
        message: 'Product restored successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to restore product.',
      );
    }
  }

  Future<void> hardDeleteQuarantineProduct(String productId) async {
    try {
      final item = quarantineProducts.firstWhereOrNull((e) => e['id'] == productId);
      final productData = item == null
          ? null
          : Map<String, dynamic>.from(
        item['productData'] as Map<String, dynamic>? ?? const {},
      );

      await _repository.hardDeleteFromQuarantine(productId);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'hard_delete_quarantine_product',
        targetType: 'product',
        targetId: productId,
        targetTitle: (productData?['titleEn'] ?? '').toString(),
        summary:
        'Permanently deleted product "${(productData?['titleEn'] ?? productId).toString()}" from quarantine',
        beforeData: productData,
      );

      MBNotification.success(
        title: 'Success',
        message: 'Quarantine product deleted permanently.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to permanently delete product.',
      );
    }
  }

  @override
  void onClose() {
    _productsSubscription?.cancel();
    _quarantineSubscription?.cancel();
    super.onClose();
  }
}












