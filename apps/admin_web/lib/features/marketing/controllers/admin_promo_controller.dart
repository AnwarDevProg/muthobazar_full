import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';


class AdminPromoController extends GetxController {
  final AdminPromoRepository _repository = AdminPromoRepository.instance;


  final RxList<MBPromoCode> promos = <MBPromoCode>[].obs;
  final RxList<MBPromoCode> filteredPromos = <MBPromoCode>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString typeFilter = 'all'.obs;

  StreamSubscription<List<MBPromoCode>>? _promosSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenPromos();
  }

  void _listenPromos() {
    _promosSubscription?.cancel();
    isLoading.value = true;

    _promosSubscription = _repository.watchPromos().listen(
          (items) {
        promos.assignAll(items);
        applyFilters();
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load promo codes.',
        );
      },
    );
  }

  Future<void> refreshPromos() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchPromosOnce();
      promos.assignAll(items);
      applyFilters();
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh promo codes.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
    applyFilters();
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    applyFilters();
  }

  void setTypeFilter(String value) {
    typeFilter.value = value;
    applyFilters();
  }

  void resetFilters() {
    searchQuery.value = '';
    statusFilter.value = 'all';
    typeFilter.value = 'all';
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value;
    final status = statusFilter.value;
    final type = typeFilter.value;

    final result = promos.where((promo) {
      final matchesQuery = query.isEmpty ||
          promo.code.toLowerCase().contains(query) ||
          (promo.campaignName ?? '').toLowerCase().contains(query);

      final matchesStatus = switch (status) {
        'active' => promo.isActive && !promo.isExpired && !promo.isArchived,
        'inactive' => !promo.isActive,
        'expired' => promo.isExpired,
        'archived' => promo.isArchived,
        _ => true,
      };

      final matchesType = type == 'all' || promo.discountType == type;

      return matchesQuery && matchesStatus && matchesType;
    }).toList();

    filteredPromos.assignAll(result);
  }

  Future<void> createPromo(MBPromoCode promo) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      await _repository.createPromo(promo);

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

      MBNotification.success(
        title: 'Success',
        message: 'Promo created successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to create promo.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updatePromo(MBPromoCode promo) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;


      await _repository.updatePromo(promo);

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

      MBNotification.success(
        title: 'Success',
        message: 'Promo updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update promo.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePromo(String promoId) async {
    if (isDeleting.value) return;

    try {
      isDeleting.value = true;


      await _repository.deletePromo(promoId);

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

      MBNotification.success(
        title: 'Success',
        message: 'Promo deleted successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to delete promo.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> togglePromoActive(MBPromoCode promo) async {
    try {
      final updated = promo.copyWith(isActive: !promo.isActive);

      await _repository.setPromoActiveState(
        promoId: promo.id,
        isActive: updated.isActive,
      );

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

      MBNotification.success(
        title: 'Success',
        message: updated.isActive ? 'Promo activated.' : 'Promo deactivated.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update promo state.',
      );
    }
  }

  @override
  void onClose() {
    _promosSubscription?.cancel();
    super.onClose();
  }
}