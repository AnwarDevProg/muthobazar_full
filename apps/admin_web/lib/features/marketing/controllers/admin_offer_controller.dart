import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';


class AdminOfferController extends GetxController {
  final AdminOfferRepository _repository = AdminOfferRepository.instance;

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

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

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



      await _repository.updateOffer(offer);

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

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


      await _repository.deleteOffer(offerId);

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

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

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

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