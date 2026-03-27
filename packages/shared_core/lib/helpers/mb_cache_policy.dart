// MB Cache Policy
// ---------------
// Controls how long cached data is considered fresh.

class MBCachePolicy {
  final Duration maxAge;

  const MBCachePolicy({
    required this.maxAge,
  });

  static const MBCachePolicy homeDefault = MBCachePolicy(
    maxAge: Duration(minutes: 30),
  );

  static const MBCachePolicy aggressiveRefresh = MBCachePolicy(
    maxAge: Duration(minutes: 10),
  );

  static const MBCachePolicy relaxedRefresh = MBCachePolicy(
    maxAge: Duration(hours: 2),
  );

  bool isFresh(DateTime cachedAt, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    return currentTime.difference(cachedAt) <= maxAge;
  }

  bool isStale(DateTime cachedAt, {DateTime? now}) {
    return !isFresh(cachedAt, now: now);
  }
}











