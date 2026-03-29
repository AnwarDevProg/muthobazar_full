import 'package:shared_core/helpers/mb_cache_policy.dart';
import 'package:shared_core/helpers/mb_cache_state.dart';
import 'package:shared_core/utils/mb_repository_load_result.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/home/datasources/mb_home_local_data_source.dart';
import 'package:shared_repositories/home/datasources/mb_home_remote_data_source.dart';

// MB Home Repository
// ------------------
// Cache-first repository for MuthoBazar home page.

class MBHomeRepository {
  const MBHomeRepository({
    required this.localDataSource,
    required this.remoteDataSource,
    this.cachePolicy = MBCachePolicy.homeDefault,
  });

  final MBHomeLocalDataSource localDataSource;
  final MBHomeRemoteDataSource remoteDataSource;
  final MBCachePolicy cachePolicy;

  static bool _backgroundRefreshRunning = false;

  Future<MBHomeCacheBundle?> loadCachedBundle() async {
    return localDataSource.readHomeBundle();
  }

  Future<MBHomeCacheBundle> fetchRemoteAndCache() async {
    final MBHomeCacheBundle remoteBundle =
    await remoteDataSource.fetchHomeBundle();

    await localDataSource.saveHomeBundle(remoteBundle);
    return remoteBundle;
  }

  Future<MBRepositoryLoadResult<MBHomeCacheBundle>> loadCacheFirstThenRefresh({
    required Future<void> Function(MBHomeCacheBundle freshBundle) onFreshData,
  }) async {
    final MBHomeCacheBundle? cached = await localDataSource.readHomeBundle();

    if (cached != null && cached.hasData) {
      final MBCacheState cacheState = _buildCacheState(cached.cachedAt);

      if (cacheState.isStale) {
        _refreshInBackground(onFreshData);
      }

      return MBRepositoryLoadResult<MBHomeCacheBundle>(
        data: cached,
        fromCache: true,
        cacheState: cacheState,
      );
    }

    final MBHomeCacheBundle remote = await fetchRemoteAndCache();

    return MBRepositoryLoadResult<MBHomeCacheBundle>(
      data: remote,
      fromCache: false,
      cacheState: MBCacheState.fromTimestamp(
        cachedAt: remote.cachedAt,
        isFresh: true,
        isStale: false,
        age: Duration.zero,
      ),
    );
  }

  Future<MBRepositoryLoadResult<MBHomeCacheBundle>> refreshNow({
    required Future<void> Function(MBHomeCacheBundle freshBundle) onFreshData,
  }) async {
    final MBHomeCacheBundle fresh = await fetchRemoteAndCache();
    await onFreshData(fresh);

    return MBRepositoryLoadResult<MBHomeCacheBundle>(
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
    final DateTime now = DateTime.now();
    final Duration age = now.difference(cachedAt);
    final bool isFresh = cachePolicy.isFresh(cachedAt, now: now);
    final bool isStale = cachePolicy.isStale(cachedAt, now: now);

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
    if (_backgroundRefreshRunning) return;

    _backgroundRefreshRunning = true;

    Future<void>(() async {
      try {
        final MBHomeCacheBundle fresh = await fetchRemoteAndCache();
        await onFreshData(fresh);
      } catch (_) {
        // Silent background refresh failure
      } finally {
        _backgroundRefreshRunning = false;
      }
    });
  }
}