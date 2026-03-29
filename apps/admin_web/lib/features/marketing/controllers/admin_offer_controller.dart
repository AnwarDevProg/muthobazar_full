import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_services/shared_services.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../admin_access/controllers/admin_access_controller.dart';

class AdminOfferController extends GetxController {
  final AdminOfferRepository _repository = AdminOfferRepository.instance;
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<MBOffer> offers = <MBOffer>[].obs;
  final RxList<MBOffer> filteredOffers = <MBOffer>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString typeFilter = 'all'.obs;
  final RxString presentationFilter = 'all'.obs;

  StreamSubscription<List<MBOffer>>? _offersSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenOffers();
  }

  void _listenOffers() {
    _offersSubscription?.cancel();
    isLoading.value = true;

    _offersSubscription = _repository.watchOffers().listen(
          (items) {
        offers.assignAll(items);
        applyFilters();
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load offers.',
        );
      },
    );
  }

  Future<void> refreshOffers() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchOffersOnce();
      offers.assignAll(items);
      applyFilters();
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh offers.',
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

  void setPresentationFilter(String value) {
    presentationFilter.value = value;
    applyFilters();
  }

  void resetFilters() {
    searchQuery.value = '';
    statusFilter.value = 'all';
    typeFilter.value = 'all';
    presentationFilter.value = 'all';
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value;
    final status = statusFilter.value;
    final type = typeFilter.value;
    final presentation = presentationFilter.value;

    final result = offers.where((offer) {
      final matchesQuery = query.isEmpty ||
          offer.titleEn.toLowerCase().contains(query) ||
          offer.titleBn.toLowerCase().contains(query) ||
          offer.subtitleEn.toLowerCase().contains(query) ||
          offer.subtitleBn.toLowerCase().contains(query);

      final matchesStatus = switch (status) {
        'active' => offer.isActive && offer.isWithinSchedule,
        'inactive' => !offer.isActive,
        'scheduledOut' => !offer.isWithinSchedule,
        'featured' => offer.isFeatured,
        'floating' => offer.showAsFloating,
        _ => true,
      };

      final matchesType = type == 'all' || offer.offerType == type;
      final matchesPresentation =
          presentation == 'all' || offer.presentationType == presentation;

      return matchesQuery &&
          matchesStatus &&
          matchesType &&
          matchesPresentation;
    }).toList();

    filteredOffers.assignAll(result);
  }

  Future<void> createOffer(MBOffer offer) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      await _repository.createOffer(offer);

      await AdminActivityLogger.log(
        adminUid: _accessController.currentAdminUid,
        adminName: _accessController.currentAdminName,
        adminEmail: _accessController.currentAdminEmail,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'create_offer',
        targetType: 'offer',
        targetId: offer.id,
        targetTitle: offer.titleEn,
        summary: 'Created offer "${offer.titleEn.isEmpty ? offer.id : offer.titleEn}"',
        afterData: offer.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Offer created successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to create offer.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateOffer(MBOffer offer) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final before = offers.firstWhereOrNull((e) => e.id == offer.id);

      await _repository.updateOffer(offer);

      await AdminActivityLogger.log(
        adminUid: _accessController.currentAdminUid,
        adminName: _accessController.currentAdminName,
        adminEmail: _accessController.currentAdminEmail,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_offer',
        targetType: 'offer',
        targetId: offer.id,
        targetTitle: offer.titleEn,
        summary: 'Updated offer "${offer.titleEn.isEmpty ? offer.id : offer.titleEn}"',
        beforeData: before?.toMap(),
        afterData: offer.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Offer updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update offer.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteOffer(String offerId) async {
    if (isDeleting.value) return;

    try {
      isDeleting.value = true;

      final before = offers.firstWhereOrNull((e) => e.id == offerId);

      await _repository.deleteOffer(offerId);

      await AdminActivityLogger.log(
        adminUid: _accessController.currentAdminUid,
        adminName: _accessController.currentAdminName,
        adminEmail: _accessController.currentAdminEmail,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'delete_offer',
        targetType: 'offer',
        targetId: offerId,
        targetTitle: before?.titleEn ?? '',
        summary: 'Deleted offer "${before?.titleEn.isEmpty ?? true ? offerId : before!.titleEn}"',
        beforeData: before?.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Offer deleted successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to delete offer.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> toggleOfferActive(MBOffer offer) async {
    try {
      final updated = offer.copyWith(
        isActive: !offer.isActive,
        updatedAt: DateTime.now(),
      );

      await _repository.setOfferActiveState(
        offerId: offer.id,
        isActive: updated.isActive,
      );

      await AdminActivityLogger.log(
        adminUid: _accessController.currentAdminUid,
        adminName: _accessController.currentAdminName,
        adminEmail: _accessController.currentAdminEmail,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'toggle_offer_active',
        targetType: 'offer',
        targetId: offer.id,
        targetTitle: offer.titleEn,
        summary: updated.isActive
            ? 'Activated offer "${offer.titleEn.isEmpty ? offer.id : offer.titleEn}"'
            : 'Deactivated offer "${offer.titleEn.isEmpty ? offer.id : offer.titleEn}"',
        beforeData: offer.toMap(),
        afterData: updated.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: updated.isActive ? 'Offer activated.' : 'Offer deactivated.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update offer state.',
      );
    }
  }

  @override
  void onClose() {
    _offersSubscription?.cancel();
    super.onClose();
  }
}