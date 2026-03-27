import 'package:flutter/foundation.dart';

import '../../../models/catalog/mb_brand.dart';
import '../../../models/catalog/mb_category.dart';
import '../../../models/catalog/mb_product.dart';
import '../../../models/home/mb_home_config.dart';
import '../../../models/home/mb_offer.dart';
import '../data/datasources/mb_home_local_data_source.dart';
import '../data/datasources/mb_home_remote_data_source.dart';
import '../data/models/mb_cache_policy.dart';
import '../data/models/mb_cache_state.dart';
import '../data/models/mb_home_cache_bundle.dart';
import '../repositories/mb_home_repository.dart';
import 'mb_offer_overlay_manager.dart';

class MBHomeController extends ChangeNotifier {
  MBHomeController({
    MBHomeRepository? repository,
    MBOfferOverlayManager? overlayManager,
  })  : _repository = repository ??
      MBHomeRepository(
        localDataSource: MBHiveHomeLocalDataSource(),
        remoteDataSource: MBDummyHomeRemoteDataSource(),
        cachePolicy: MBCachePolicy.homeDefault,
      ),
        _overlayManager = overlayManager ?? MBOfferOverlayManager();

  final MBHomeRepository _repository;
  final MBOfferOverlayManager _overlayManager;

  MBHomeConfig _config = MBHomeConfig.empty();
  List<MBCategory> _categories = const [];
  List<MBBrand> _brands = const [];
  List<MBProduct> _products = const [];
  MBOffer? _floatingOffer;

  MBHomeConfig get config => _config;
  List<MBCategory> get categories => _categories;
  List<MBBrand> get brands => _brands;
  List<MBProduct> get products => _products;
  MBOffer? get floatingOffer => _floatingOffer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  bool _isUsingCachedData = false;
  bool get isUsingCachedData => _isUsingCachedData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  MBCacheState _cacheState = MBCacheState.noCache();
  MBCacheState get cacheState => _cacheState;

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _repository.loadCacheFirstThenRefresh(
        onFreshData: (freshBundle) async {
          _applyBundle(
            freshBundle,
            isCached: false,
            cacheState: MBCacheState.fromTimestamp(
              cachedAt: freshBundle.cachedAt,
              isFresh: true,
              isStale: false,
              age: Duration.zero,
            ),
          );
          notifyListeners();
        },
      );

      _applyBundle(
        result.data,
        isCached: result.fromCache,
        cacheState: result.cacheState,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.refreshNow(
        onFreshData: (freshBundle) async {
          _applyBundle(
            freshBundle,
            isCached: false,
            cacheState: MBCacheState.fromTimestamp(
              cachedAt: freshBundle.cachedAt,
              isFresh: true,
              isStale: false,
              age: Duration.zero,
            ),
          );
        },
      );

      _applyBundle(
        result.data,
        isCached: result.fromCache,
        cacheState: result.cacheState,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void closeFloatingOffer({bool showNext = false}) {
    final current = _floatingOffer;
    if (current != null) {
      _overlayManager.markClosed(current.id);
    }

    if (showNext) {
      _floatingOffer = _overlayManager.pickNext(
        _config.floatingOffers,
        currentOfferId: current?.id,
      );
    } else {
      _floatingOffer = null;
    }

    notifyListeners();
  }

  void repickFloatingOffer() {
    _floatingOffer = _overlayManager.pickOne(_config.floatingOffers);
    notifyListeners();
  }

  void resetFloatingOfferSession() {
    _overlayManager.resetSession();
    _floatingOffer = null;
    notifyListeners();
  }

  void onBannerTap(String bannerId) {
    debugPrint('Banner tapped: $bannerId');
  }

  void onOfferTap(String offerId) {
    debugPrint('Offer tapped: $offerId');
  }

  void onCategoryTap(String categoryId) {
    debugPrint('Category tapped: $categoryId');
  }

  void onProductTap(String productId) {
    debugPrint('Product tapped: $productId');
  }

  void onViewAllTap(String sectionId) {
    debugPrint('View all tapped: $sectionId');
  }

  void _applyBundle(
      MBHomeCacheBundle bundle, {
        required bool isCached,
        required MBCacheState cacheState,
      }) {
    _config = bundle.config;
    _categories = bundle.categories;
    _brands = bundle.brands;
    _products = bundle.products;
    _lastSyncedAt = bundle.cachedAt;
    _isUsingCachedData = isCached;
    _cacheState = cacheState;
    _pickFloatingOffer();
  }

  void _pickFloatingOffer() {
    _floatingOffer = _overlayManager.pickOne(_config.floatingOffers);
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }
}

