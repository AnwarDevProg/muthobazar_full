import 'package:shared_core/shared_core.dart';



// MB Repository Load Result
// -------------------------
// Wraps repository load response so controller can know:
// - whether data came from cache
// - current cache freshness/staleness state

class MBRepositoryLoadResult<T> {
  final T data;
  final bool fromCache;
  final MBCacheState cacheState;

  const MBRepositoryLoadResult({
    required this.data,
    required this.fromCache,
    required this.cacheState,
  });
}











