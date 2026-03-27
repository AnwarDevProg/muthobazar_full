import '../data/datasources/mb_home_local_data_source.dart';
import '../data/datasources/mb_home_remote_data_source.dart';
import '../data/models/mb_cache_policy.dart';
import '../data/models/mb_cache_state.dart';
import '../data/models/mb_home_cache_bundle.dart';
import '../data/models/mb_repository_load_result.dart';

// MB Home Repository
// ------------------
// Cache-first repository for MuthoBazar home page.
// Now includes stale/fresh cache decision logic.

class MBHomeRepository {
  final MBHomeLocalDataSource localDataSource;
  final MBHomeRemoteDataSource remoteDataSource;
  final MBCachePolicy cachePolicy;

  const MBHomeRepository({
    required this.localDataSource,
    required this.remoteDataSource,
    this.cachePolicy = MBCachePolicy.homeDefault,
  });

  Future<MBHomeCacheBundle?> loadCachedBundle() async {
    return localDataSource.readHomeBundle();
  }

  Future<MBHomeCacheBundle> fetchRemoteAndCache() async {
    final remoteBundle = await remoteDataSource.fetchHomeBundle();
    await localDataSource.saveHomeBundle(remoteBundle);
    return remoteBundle;
  }

  Future<MBRepositoryLoadResult<MBHomeCacheBundle>> loadCacheFirstThenRefresh({
    required Future<void> Function(MBHomeCacheBundle freshBundle) onFreshData,
  }) async {
    final cached = await localDataSource.readHomeBundle();

    if (cached != null && cached.hasData) {
      final cacheState = _buildCacheState(cached.cachedAt);

      if (cacheState.isFresh) {
        _refreshInBackground(onFreshData);
      } else if (cacheState.isStale) {
        _refreshInBackground(onFreshData);
      }

      return MBRepositoryLoadResult(
        data: cached,
        fromCache: true,
        cacheState: cacheState,
      );
    }

    final remote = await fetchRemoteAndCache();

    return MBRepositoryLoadResult(
      data: remote,
      fromCache: false,
      cacheState: MBCacheState.noCache(),
    );
  }

  Future<MBRepositoryLoadResult<MBHomeCacheBundle>> refreshNow({
    required Future<void> Function(MBHomeCacheBundle freshBundle) onFreshData,
  }) async {
    final fresh = await fetchRemoteAndCache();
    await onFreshData(fresh);

    return MBRepositoryLoadResult(
      data: fresh,
      fromCache: false,
      cacheState: MBCacheState.fromTimestamp(
        cachedAt: fresh.cachedAt,
        isFresh: true,
        isStale: false,
        age: Duration.zero,
      ),
    );
  }

  MBCacheState _buildCacheState(DateTime cachedAt) {
    final now = DateTime.now();
    final age = now.difference(cachedAt);
    final isFresh = cachePolicy.isFresh(cachedAt, now: now);
    final isStale = cachePolicy.isStale(cachedAt, now: now);

    return MBCacheState.fromTimestamp(
      cachedAt: cachedAt,
      isFresh: isFresh,
      isStale: isStale,
      age: age,
    );
  }

  void _refreshInBackground(
      Future<void> Function(MBHomeCacheBundle freshBundle) onFreshData,
      ) {
    Future<void>(() async {
      try {
        final fresh = await fetchRemoteAndCache();
        await onFreshData(fresh);
      } catch (_) {
        // Silent background refresh failure
      }
    });
  }
}











