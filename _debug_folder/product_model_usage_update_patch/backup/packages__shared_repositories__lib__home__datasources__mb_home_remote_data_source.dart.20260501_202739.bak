import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

// MB Home Remote Data Source
// --------------------------
// Fetches the full home bundle from Firestore.
//
// Development debug added:
// - Logs raw Firestore cardConfig for each product.
// - Logs parsed MBProduct.cardConfig.
// - Logs parsed MBProduct.effectiveCardConfig.
//
// Purpose of the debug:
// We already proved Admin Save writes full cardConfig.settings.
// If Home renderer still receives settings={}, this file tells us whether:
// 1) Firestore raw data has settings,
// 2) MBProduct.fromMap loses settings,
// 3) or data is lost later after this remote fetch.
//

abstract class MBHomeRemoteDataSource {
  Future<MBHomeCacheBundle> fetchHomeBundle();
}

class MBDummyHomeRemoteDataSource implements MBHomeRemoteDataSource {
  MBDummyHomeRemoteDataSource({
    required MBHomeCacheBundle Function() bundleBuilder,
    Duration delay = const Duration(milliseconds: 350),
  })  : _bundleBuilder = bundleBuilder,
        _delay = delay;

  final MBHomeCacheBundle Function() _bundleBuilder;
  final Duration _delay;

  @override
  Future<MBHomeCacheBundle> fetchHomeBundle() async {
    await Future.delayed(_delay);
    final bundle = _bundleBuilder();
    return bundle.copyWith(cachedAt: DateTime.now());
  }
}

class MBFirestoreHomeRemoteDataSource implements MBHomeRemoteDataSource {
  MBFirestoreHomeRemoteDataSource({
    FirebaseFirestore? firestore,
    this.bannersCollection = 'banners',
    this.offersCollection = 'offers',
    this.sectionsCollection = 'home_sections',
    this.categoriesCollection = 'categories',
    this.brandsCollection = 'brands',
    this.productsCollection = 'products',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  final String bannersCollection;
  final String offersCollection;
  final String sectionsCollection;
  final String categoriesCollection;
  final String brandsCollection;
  final String productsCollection;

  @override
  Future<MBHomeCacheBundle> fetchHomeBundle() async {
    final results = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      _firestore.collection(bannersCollection).get(),
      _firestore.collection(offersCollection).get(),
      _firestore.collection(sectionsCollection).get(),
      _firestore.collection(categoriesCollection).get(),
      _firestore.collection(brandsCollection).get(),
      _firestore.collection(productsCollection).get(),
    ]);

    final banners = _mapDocs<MBBanner>(
      results[0],
          (map) => MBBanner.fromMap(map),
    );

    final offers = _mapDocs<MBOffer>(
      results[1],
          (map) => MBOffer.fromMap(map),
    );

    final sections = _mapDocs<MBHomeSection>(
      results[2],
          (map) => MBHomeSection.fromMap(map),
    );

    final categories = _mapDocs<MBCategory>(
      results[3],
          (map) => MBCategory.fromMap(map),
    );

    final brands = _mapDocs<MBBrand>(
      results[4],
          (map) => MBBrand.fromMap(map),
    );

    final products = _mapProductDocsWithCardConfigDebug(results[5]);

    return MBHomeCacheBundle(
      config: MBHomeConfig(
        banners: banners,
        offers: offers,
        sections: sections,
      ),
      categories: categories,
      brands: brands,
      products: products,
      cachedAt: DateTime.now(),
    );
  }

  List<MBProduct> _mapProductDocsWithCardConfigDebug(
      QuerySnapshot<Map<String, dynamic>> snapshot,
      ) {
    return snapshot.docs.map((doc) {
      final raw = Map<String, dynamic>.from(doc.data());
      final id = (raw['id'] ?? '').toString().trim();

      if (id.isEmpty) {
        raw['id'] = doc.id;
      }

      final rawCardConfig = raw['cardConfig'];
      final product = MBProduct.fromMap(raw);


      return product;
    }).toList(growable: false);
  }

  void _debugProductCardConfig({
    required MBProduct product,
    required Object? rawCardConfig,
  }) {
    final parsedCardConfig = product.cardConfig.toMap();
    final effectiveCardConfig = product.effectiveCardConfig.toMap();

    final rawSettings = _extractSettings(rawCardConfig);
    final parsedSettings = _extractSettings(parsedCardConfig);
    final effectiveSettings = _extractSettings(effectiveCardConfig);

    debugPrint(
      '[HOME_REMOTE_CARD_DEBUG_SUMMARY] '
          'id=${product.id}, '
          'title=${product.titleEn}, '
          'layout=${product.cardLayoutType}, '
          'rawHasSettings=${_hasNonEmptySettings(rawCardConfig)}, '
          'parsedHasSettings=${_hasNonEmptySettings(parsedCardConfig)}, '
          'effectiveHasSettings=${_hasNonEmptySettings(effectiveCardConfig)}, '
          'rawSettingsKeys=${rawSettings.keys.toList()}, '
          'parsedSettingsKeys=${parsedSettings.keys.toList()}, '
          'effectiveSettingsKeys=${effectiveSettings.keys.toList()}',
    );

    debugPrint(
      '[HOME_REMOTE_CARD_DEBUG_RAW] '
          'title=${product.titleEn}, '
          'rawCardConfig=$rawCardConfig',
    );

    debugPrint(
      '[HOME_REMOTE_CARD_DEBUG_PARSED] '
          'title=${product.titleEn}, '
          'parsedCardConfig=$parsedCardConfig',
    );

    debugPrint(
      '[HOME_REMOTE_CARD_DEBUG_EFFECTIVE] '
          'title=${product.titleEn}, '
          'effectiveCardConfig=$effectiveCardConfig',
    );
  }

  Map<String, dynamic> _extractSettings(Object? cardConfig) {
    if (cardConfig is! Map) {
      return const <String, dynamic>{};
    }

    final rawSettings = cardConfig['settings'];

    if (rawSettings is! Map) {
      return const <String, dynamic>{};
    }

    return Map<String, dynamic>.from(
      rawSettings.map(
            (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }

  bool _hasNonEmptySettings(Object? cardConfig) {
    return _extractSettings(cardConfig).isNotEmpty;
  }

  List<T> _mapDocs<T>(
      QuerySnapshot<Map<String, dynamic>> snapshot,
      T Function(Map<String, dynamic> map) fromMap,
      ) {
    return snapshot.docs.map((doc) {
      final raw = Map<String, dynamic>.from(doc.data());
      final id = (raw['id'] ?? '').toString().trim();

      if (id.isEmpty) {
        raw['id'] = doc.id;
      }

      return fromMap(raw);
    }).toList(growable: false);
  }
}
