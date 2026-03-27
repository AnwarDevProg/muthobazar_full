import '../../../../data/dummy/dummy_catalog_data.dart';
import '../../../../data/dummy/home_dummy_data.dart';
import '../models/mb_home_cache_bundle.dart';

// MB Home Remote Data Source
// --------------------------
// Remote contract for home fetching.
// Current implementation uses dummy data.
// Later replace with Firestore or Laravel API.

abstract class MBHomeRemoteDataSource {
  Future<MBHomeCacheBundle> fetchHomeBundle();
}

class MBDummyHomeRemoteDataSource implements MBHomeRemoteDataSource {
  @override
  Future<MBHomeCacheBundle> fetchHomeBundle() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return MBHomeCacheBundle(
      config: HomeDummyData.config,
      categories: DummyCatalogData.categories,
      brands: DummyCatalogData.brands,
      products: DummyCatalogData.products,
      cachedAt: DateTime.now(),
    );
  }
}











