import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../../profile/controllers/profile_controller.dart';
import '../models/mobile_admin_purchase_model.dart';
import '../repositories/mobile_admin_purchase_repository.dart';

class MobileAdminPurchaseController extends GetxController {
  final MobileAdminPurchaseRepository _repository =
      MobileAdminPurchaseRepository.instance;

  final ProfileController _profileController = Get.find<ProfileController>();

  final RxList<MobileAdminPurchaseModel> allPurchases =
      <MobileAdminPurchaseModel>[].obs;
  final RxList<MobileAdminPurchaseModel> filteredPurchases =
      <MobileAdminPurchaseModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;

  StreamSubscription<List<MobileAdminPurchaseModel>>? _purchaseSubscription;

  String get actorUid => _profileController.user.value.id;
  String get actorName => _profileController.fullName;

  int get totalCount => allPurchases.length;

  int get completedCount =>
      allPurchases.where((e) => e.status == 'completed').length;

  int get pendingCount =>
      allPurchases.where((e) => e.status == 'pending').length;

  double get grandTotal => allPurchases.fold(
    0.0,
        (sum, item) => sum + item.totalAmount,
  );

  @override
  void onInit() {
    super.onInit();
    _listenPurchases();

    ever(searchQuery, (_) => applyFilters());
    ever(selectedStatus, (_) => applyFilters());
  }

  void _listenPurchases() {
    _purchaseSubscription?.cancel();

    isLoading.value = true;

    _purchaseSubscription = _repository.watchPurchases().listen(
          (items) {
        allPurchases.assignAll(items);
        applyFilters();
        isLoading.value = false;
      },
      onError: (e) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load purchases.',
        );
        debugPrint('Purchase stream error: $e');
      },
    );
  }

  Future<void> refreshPurchases() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchPurchasesOnce();
      allPurchases.assignAll(items);
      applyFilters();
    } catch (e) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh purchases.',
      );
      debugPrint('Purchase refresh error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
  }

  void setStatusFilter(String value) {
    selectedStatus.value = value.trim().toLowerCase();
  }

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatus.value.trim().toLowerCase();

    final items = allPurchases.where((purchase) {
      final matchesStatus = status == 'all' || purchase.status == status;

      final matchesSearch =
          query.isEmpty ||
              purchase.productName.toLowerCase().contains(query) ||
              purchase.sellerName.toLowerCase().contains(query) ||
              purchase.place.toLowerCase().contains(query) ||
              purchase.purchasedBy.toLowerCase().contains(query) ||
              purchase.sellerNumber.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();

    filteredPurchases.assignAll(items);
  }

  Future<void> createPurchase({
    required MobileAdminPurchaseModel purchase,
  }) async {
    try {
      isSaving.value = true;

      await _repository.createPurchase(
        purchase: purchase,
        actorUid: actorUid,
      );

      MBNotification.success(
        title: 'Success',
        message: 'Purchase created successfully.',
      );
    } catch (e) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to create purchase.',
      );
      debugPrint('Create purchase error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updatePurchase({
    required MobileAdminPurchaseModel purchase,
  }) async {
    try {
      isSaving.value = true;

      await _repository.updatePurchase(
        purchase: purchase,
        actorUid: actorUid,
      );

      MBNotification.success(
        title: 'Success',
        message: 'Purchase updated successfully.',
      );
    } catch (e) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update purchase.',
      );
      debugPrint('Update purchase error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePurchase(String purchaseId) async {
    try {
      isSaving.value = true;

      await _repository.deletePurchase(purchaseId);

      MBNotification.success(
        title: 'Deleted',
        message: 'Purchase deleted successfully.',
      );
    } catch (e) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to delete purchase.',
      );
      debugPrint('Delete purchase error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }
}












