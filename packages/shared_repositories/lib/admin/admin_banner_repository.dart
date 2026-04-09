import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_models/marketing/mb_banner.dart';

import 'core/mb_admin_callable_repository_base.dart';

class AdminBannerRepository extends MBAdminCallableRepositoryBase<MBBanner> {
  AdminBannerRepository._() : super();

  static final AdminBannerRepository instance = AdminBannerRepository._();

  @override
  String get collectionPath => 'banners';

  CollectionReference<Map<String, dynamic>> get bannersCollection => collection;

  @override
  MBBanner fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    final Map<String, dynamic> map = <String, dynamic>{
      ...data,
      'id': (data['id'] ?? doc.id).toString(),
    };

    try {
      return MBBanner.fromMap(map);
    } catch (error) {
      throw Exception(
        'Failed to parse banner document "${doc.id}". '
            'Please check Firestore field names and types. '
            'Original error: $error',
      );
    }
  }

  @override
  List<MBBanner> sortItems(List<MBBanner> items) {
    items.sort((a, b) {
      final int bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;

      final int byPosition = a.position.trim().toLowerCase().compareTo(
        b.position.trim().toLowerCase(),
      );
      if (byPosition != 0) return byPosition;

      return a.titleEn.trim().toLowerCase().compareTo(
        b.titleEn.trim().toLowerCase(),
      );
    });
    return items;
  }

  Map<String, dynamic> _bannerPayload(MBBanner banner) {
    return <String, dynamic>{
      'titleEn': banner.titleEn.trim(),
      'titleBn': banner.titleBn.trim(),
      'subtitleEn': banner.subtitleEn.trim(),
      'subtitleBn': banner.subtitleBn.trim(),
      'buttonTextEn': banner.buttonTextEn.trim(),
      'buttonTextBn': banner.buttonTextBn.trim(),
      'imageUrl': banner.imageUrl.trim(),
      'mobileImageUrl': banner.mobileImageUrl.trim(),
      'targetType': banner.targetType.trim().toLowerCase(),
      'targetId': parseString(banner.targetId),
      'targetRoute': parseString(banner.targetRoute),
      'externalUrl': parseString(banner.externalUrl),
      'isActive': banner.isActive,
      'showOnHome': banner.showOnHome,
      'position': banner.position.trim().isEmpty
          ? 'home_hero'
          : banner.position.trim(),
      'sortOrder': banner.sortOrder,
      'startAt': banner.startAt?.toIso8601String(),
      'endAt': banner.endAt?.toIso8601String(),
    };
  }

  Stream<List<MBBanner>> watchBanners() {
    return watchAll();
  }

  Future<List<MBBanner>> fetchBannersOnce() {
    return fetchAll(
      timeoutMessage:
      'Timed out while loading banners from Firestore. '
          'Check internet connection, Firebase config, or browser console.',
    );
  }

  Future<int> suggestSortOrder({
    String? excludeBannerId,
  }) {
    return suggestLowestMissingNonNegativeInt(
      selector: (item) => item.sortOrder,
      excludeId: excludeBannerId,
      idSelector: (item) => item.id,
    );
  }

  Future<bool> sortExists({
    required int sortOrder,
    String? excludeBannerId,
  }) {
    return intFieldExists(
      value: sortOrder,
      fieldName: 'sortOrder',
      excludeId: excludeBannerId,
      timeoutMessage: 'Timed out while checking banner sort order.',
    );
  }

  Future<String> createBanner(MBBanner banner) async {
    return guardCallable(() async {
      final HttpsCallable callableRef = callable('createBanner');
      final HttpsCallableResult<Map<String, dynamic>> result =
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'banner': _bannerPayload(banner),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while creating banner.');
        },
      );

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(result.data);
      final String bannerId = (data['bannerId'] ?? '').toString().trim();
      if (bannerId.isEmpty) {
        throw Exception('Banner was created but no bannerId was returned.');
      }
      return bannerId;
    }, fallback: 'Cloud Function error while creating banner.');
  }

  Future<void> updateBanner(MBBanner banner) async {
    final String bannerId = banner.id.trim();
    if (bannerId.isEmpty) {
      throw Exception('Banner id is required for update.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('updateBanner');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'bannerId': bannerId,
          'banner': _bannerPayload(banner),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating banner.');
        },
      );
    }, fallback: 'Cloud Function error while updating banner.');
  }

  Future<void> deleteBanner(String bannerId, {String? reason}) async {
    final String id = bannerId.trim();
    if (id.isEmpty) {
      throw Exception('Banner id is required for delete.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('deleteBanner');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'bannerId': id,
          'reason': reason?.trim(),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while deleting banner.');
        },
      );
    }, fallback: 'Cloud Function error while deleting banner.');
  }

  Future<void> setBannerActiveState({
    required String bannerId,
    required bool isActive,
    String? reason,
  }) async {
    final String id = bannerId.trim();
    if (id.isEmpty) {
      throw Exception('Banner id is required for status update.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('setBannerActiveState');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'bannerId': id,
          'isActive': isActive,
          'reason': reason?.trim(),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating banner status.');
        },
      );
    }, fallback: 'Cloud Function error while updating banner status.');
  }
}
