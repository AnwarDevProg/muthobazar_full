import 'package:flutter/material.dart';

import 'package:shared_ui/shared_ui.dart';
import '../data/models/mb_cache_state.dart';

// MB Home Cache Debug Section
// ---------------------------
// Development-only cache status panel for HomePage.
// Safe to remove later without affecting main home architecture.

class MBHomeCacheDebugSection extends StatelessWidget {
  final bool isUsingCachedData;
  final bool isLoading;
  final bool isRefreshing;
  final DateTime? lastSyncedAt;
  final MBCacheState cacheState;

  const MBHomeCacheDebugSection({
    super.key,
    required this.isUsingCachedData,
    required this.isLoading,
    required this.isRefreshing,
    required this.lastSyncedAt,
    required this.cacheState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        MBScreenPadding.page(context).left,
        MBSpacing.md,
        MBScreenPadding.page(context).right,
        MBSpacing.lg,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Home Cache Debug',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: MBSpacing.sm),
              _row('Using cached data', isUsingCachedData.toString()),
              _row('Is loading', isLoading.toString()),
              _row('Is refreshing', isRefreshing.toString()),
              _row('Has cache', cacheState.hasCache.toString()),
              _row('Cache fresh', cacheState.isFresh.toString()),
              _row('Cache stale', cacheState.isStale.toString()),
              _row(
                'Cached at',
                cacheState.cachedAt?.toIso8601String() ?? '-',
              ),
              _row(
                'Cache age',
                cacheState.age == null
                    ? '-'
                    : '${cacheState.age!.inMinutes} min',
              ),
              _row(
                'Last synced at',
                lastSyncedAt?.toIso8601String() ?? '-',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

