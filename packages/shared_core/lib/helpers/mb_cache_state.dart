// MB Cache State
// --------------
// Structured cache status for repository/controller/UI.

class MBCacheState {
  final bool hasCache;
  final bool isFresh;
  final bool isStale;
  final DateTime? cachedAt;
  final Duration? age;

  const MBCacheState({
    required this.hasCache,
    required this.isFresh,
    required this.isStale,
    this.cachedAt,
    this.age,
  });

  factory MBCacheState.noCache() => const MBCacheState(
    hasCache: false,
    isFresh: false,
    isStale: false,
  );

  factory MBCacheState.fromTimestamp({
    required DateTime cachedAt,
    required bool isFresh,
    required bool isStale,
    required Duration age,
  }) {
    return MBCacheState(
      hasCache: true,
      isFresh: isFresh,
      isStale: isStale,
      cachedAt: cachedAt,
      age: age,
    );
  }
}











