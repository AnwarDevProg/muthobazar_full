import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';

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

    final products = _mapDocs<MBProduct>(
      results[5],
          (map) => MBProduct.fromMap(map),
    );

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
