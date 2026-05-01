import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';

class AdminHomeSectionRepository {
  AdminHomeSectionRepository._();

  static final AdminHomeSectionRepository instance =
  AdminHomeSectionRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('home_sections');

  // =========================================================
  // READ
  // =========================================================

  Stream<List<MBHomeSection>> watchSections() {
    return _collection.snapshots().map(_mapSnapshotToSections);
  }

  Future<List<MBHomeSection>> fetchSectionsOnce() async {
    final snapshot = await _collection.get();
    return _mapSnapshotToSections(snapshot);
  }

  List<MBHomeSection> _mapSnapshotToSections(
      QuerySnapshot<Map<String, dynamic>> snapshot,
      ) {
    final List<MBHomeSection> items = snapshot.docs
        .map(_mapDocumentToSection)
        .toList(growable: false)
      ..sort(_sortSections);

    return items;
  }

  MBHomeSection _mapDocumentToSection(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final Map<String, dynamic> data = doc.data();

    return MBHomeSection.fromMap(
      <String, dynamic>{
        ...data,
        'id': (data['id'] ?? doc.id).toString(),
      },
    );
  }

  // =========================================================
  // CREATE
  // =========================================================

  Future<String> createSection(MBHomeSection section) async {
    final DocumentReference<Map<String, dynamic>> docRef =
    section.id.trim().isEmpty
        ? _collection.doc()
        : _collection.doc(section.id.trim());

    final MBHomeSection normalized = _normalizeForWrite(
      section,
      forcedId: docRef.id,
    );

    await docRef.set(normalized.toMap());
    return docRef.id;
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<void> updateSection(MBHomeSection section) async {
    final String id = _requireId(
      section.id,
      message: 'Home section id is required for update.',
    );

    final DocumentReference<Map<String, dynamic>> docRef = _collection.doc(id);
    final DocumentSnapshot<Map<String, dynamic>> existing = await docRef.get();

    if (!existing.exists) {
      throw Exception('Home section not found.');
    }

    final MBHomeSection normalized = _normalizeForWrite(
      section,
      forcedId: id,
    );

    // Full replace is safer here than merge:true, because it prevents stale
    // fields from older document structures from lingering in Firestore.
    await docRef.set(normalized.toMap());
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteSection(
      String sectionId, {
        String? reason,
      }) async {
    final String id = _requireId(
      sectionId,
      message: 'Home section id is required for delete.',
    );

    final DocumentReference<Map<String, dynamic>> docRef = _collection.doc(id);
    final DocumentSnapshot<Map<String, dynamic>> existing = await docRef.get();

    if (!existing.exists) {
      throw Exception('Home section not found.');
    }

    await docRef.delete();
  }

  // =========================================================
  // ACTIVE STATE
  // =========================================================

  Future<void> setSectionActiveState({
    required String sectionId,
    required bool isActive,
    String? reason,
  }) async {
    final String id = _requireId(
      sectionId,
      message: 'Home section id is required.',
    );

    final DocumentReference<Map<String, dynamic>> docRef = _collection.doc(id);
    final DocumentSnapshot<Map<String, dynamic>> existing = await docRef.get();

    if (!existing.exists) {
      throw Exception('Home section not found.');
    }

    await docRef.update(<String, dynamic>{
      'isActive': isActive,
    });
  }

  // =========================================================
  // SORT HELPERS
  // =========================================================

  Future<int> suggestSortOrder({
    String? excludeSectionId,
  }) async {
    final List<MBHomeSection> items = await fetchSectionsOnce();
    final String excluded = (excludeSectionId ?? '').trim();

    final Set<int> usedOrders = items
        .where((item) => item.id.trim() != excluded)
        .map((item) => item.sortOrder)
        .where((value) => value >= 0)
        .toSet();

    int candidate = 0;
    while (usedOrders.contains(candidate)) {
      candidate++;
    }

    return candidate;
  }

  Future<bool> sortExists({
    required int sortOrder,
    String? excludeSectionId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection
        .where('sortOrder', isEqualTo: sortOrder)
        .get();

    final String excluded = (excludeSectionId ?? '').trim();

    for (final doc in snapshot.docs) {
      if (doc.id != excluded) {
        return true;
      }

      final String embeddedId = (doc.data()['id'] ?? '').toString().trim();
      if (embeddedId.isNotEmpty && embeddedId != excluded) {
        return true;
      }
    }

    return false;
  }

  // =========================================================
  // NORMALIZATION
  // =========================================================

  MBHomeSection _normalizeForWrite(
      MBHomeSection section, {
        required String forcedId,
      }) {
    final String sectionType = _normalizeSectionType(section.sectionType);
    final String layoutStyle = _normalizeLayoutStyle(section.layoutStyle);
    final String dataSourceType = _normalizeDataSourceType(
      sectionType: sectionType,
      rawValue: section.dataSourceType,
    );

    final bool isBannerSection =
        sectionType == 'hero_banner' || sectionType == 'promo_banner';
    final bool isOfferSection = sectionType == 'offer_strip';
    final bool isCategorySection = sectionType == 'category_grid';
    final bool isBrandSection = sectionType == 'brand_row';
    final bool isProductSection =
        sectionType == 'product_horizontal' || sectionType == 'product_grid';

    final bool manualProductSource =
        isProductSection && dataSourceType == 'manual';
    final bool categoryProductSource =
        isProductSection && dataSourceType == 'category';
    final bool brandProductSource = isProductSection && dataSourceType == 'brand';

    final String? sourceCategoryId =
    categoryProductSource ? _nullableTrim(section.sourceCategoryId) : null;
    final String? sourceBrandId =
    brandProductSource ? _nullableTrim(section.sourceBrandId) : null;

    return section.copyWith(
      id: forcedId,
      titleEn: section.titleEn.trim(),
      titleBn: section.titleBn.trim(),
      subtitleEn: section.subtitleEn.trim(),
      subtitleBn: section.subtitleBn.trim(),
      sectionType: sectionType,
      layoutStyle: layoutStyle,
      dataSourceType: dataSourceType,
      bannerIds: isBannerSection ? _normalizeIds(section.bannerIds) : const [],
      offerIds: isOfferSection ? _normalizeIds(section.offerIds) : const [],
      productIds: manualProductSource
          ? _normalizeIds(section.productIds)
          : const [],
      categoryIds: isCategorySection || manualProductSource
          ? _normalizeIds(section.categoryIds)
          : const [],
      brandIds: isBrandSection || manualProductSource
          ? _normalizeIds(section.brandIds)
          : const [],
      sourceCategoryId: sourceCategoryId,
      clearSourceCategoryId: sourceCategoryId == null,
      sourceBrandId: sourceBrandId,
      clearSourceBrandId: sourceBrandId == null,
      itemLimit: section.itemLimit < 1 ? 1 : section.itemLimit,
      sortOrder: section.sortOrder < 0 ? 0 : section.sortOrder,
      showViewAll: section.showViewAll,
      isActive: section.isActive,
    );
  }

  String _normalizeSectionType(String value) {
    final String normalized = value.trim().toLowerCase();

    const Set<String> allowed = <String>{
      'hero_banner',
      'category_grid',
      'product_horizontal',
      'product_grid',
      'offer_strip',
      'promo_banner',
      'brand_row',
    };

    if (allowed.contains(normalized)) {
      return normalized;
    }

    return 'product_horizontal';
  }

  String _normalizeLayoutStyle(String value) {
    final String normalized = value.trim().toLowerCase();

    const Set<String> allowed = <String>{
      'compact',
      'standard',
      'large',
      'card',
      'slider',
    };

    if (allowed.contains(normalized)) {
      return normalized;
    }

    return 'standard';
  }

  String _normalizeDataSourceType({
    required String sectionType,
    required String rawValue,
  }) {
    final String normalized = rawValue.trim().toLowerCase();

    if (sectionType == 'hero_banner' ||
        sectionType == 'promo_banner' ||
        sectionType == 'offer_strip' ||
        sectionType == 'category_grid' ||
        sectionType == 'brand_row') {
      return 'manual';
    }

    if (sectionType == 'product_horizontal' || sectionType == 'product_grid') {
      const Set<String> allowed = <String>{
        'manual',
        'featured',
        'flash_sale',
        'new_arrival',
        'best_seller',
        'recommended',
        'category',
        'brand',
      };

      if (allowed.contains(normalized)) {
        return normalized;
      }

      return 'manual';
    }

    return normalized.isEmpty ? 'manual' : normalized;
  }

  List<String> _normalizeIds(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  String? _nullableTrim(String? value) {
    final String normalized = (value ?? '').trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _requireId(
      String value, {
        required String message,
      }) {
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      throw Exception(message);
    }
    return normalized;
  }

  // =========================================================
  // INTERNAL SORT
  // =========================================================

  int _sortSections(MBHomeSection a, MBHomeSection b) {
    final int bySort = a.sortOrder.compareTo(b.sortOrder);
    if (bySort != 0) return bySort;

    final int byType = a.sectionType.trim().toLowerCase().compareTo(
      b.sectionType.trim().toLowerCase(),
    );
    if (byType != 0) return byType;

    return a.titleEn.trim().toLowerCase().compareTo(
      b.titleEn.trim().toLowerCase(),
    );
  }
}