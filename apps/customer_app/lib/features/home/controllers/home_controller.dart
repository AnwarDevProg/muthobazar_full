import 'package:customer_app/features/home/controllers/offer_overlay_manager.dart';
import 'package:customer_app/features/home/data/dummy_catalog_data.dart';
import 'package:customer_app/features/home/data/home_dummy_data.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_core/helpers/mb_cache_policy.dart';
import 'package:shared_core/helpers/mb_cache_state.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/home/datasources/mb_home_local_data_source.dart';
import 'package:shared_repositories/home/datasources/mb_home_remote_data_source.dart';
import 'package:shared_repositories/home/mb_home_repository.dart';

class MBHomeController extends ChangeNotifier {
  MBHomeController({
    MBHomeRepository? repository,
    MBOfferOverlayManager? overlayManager,
  })  : _repository = repository ?? _buildDefaultRepository(),
        _overlayManager = overlayManager ?? MBOfferOverlayManager();

  final MBHomeRepository _repository;
  final MBOfferOverlayManager _overlayManager;

  MBHomeConfig _config = MBHomeConfig.empty();
  List<MBCategory> _categories = const <MBCategory>[];
  List<MBBrand> _brands = const <MBBrand>[];
  List<MBProduct> _products = const <MBProduct>[];
  MBOffer? _floatingOffer;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isUsingCachedData = false;
  String? _errorMessage;
  DateTime? _lastSyncedAt;
  MBCacheState _cacheState = MBCacheState.noCache();

  MBHomeConfig get config => _config;
  List<MBCategory> get categories => _categories;
  List<MBBrand> get brands => _brands;
  List<MBProduct> get products => _products;
  MBOffer? get floatingOffer => _floatingOffer;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isUsingCachedData => _isUsingCachedData;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  MBCacheState get cacheState => _cacheState;

  static MBHomeRepository _buildDefaultRepository() {
    return MBHomeRepository(
      localDataSource: MBHiveHomeLocalDataSource(),
      remoteDataSource: MBDummyHomeRemoteDataSource(
        bundleBuilder: _buildDummyBundle,
      ),
      cachePolicy: MBCachePolicy.homeDefault,
    );
  }

  static MBHomeCacheBundle _buildDummyBundle() {
    return MBHomeCacheBundle(
      config: HomeDummyData.config,
      categories: DummyCatalogData.categories,
      brands: DummyCatalogData.brands,
      products: DummyCatalogData.products,
      cachedAt: DateTime.now(),
    );
  }

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.loadCacheFirstThenRefresh(
        onFreshData: (MBHomeCacheBundle freshBundle) async {
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
    } catch (e, st) {
      _errorMessage = e.toString();
      debugPrint('MBHomeController.load error: $e');
      debugPrint('$st');
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
        onFreshData: (MBHomeCacheBundle freshBundle) async {
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
    } catch (e, st) {
      _errorMessage = e.toString();
      debugPrint('MBHomeController.refresh error: $e');
      debugPrint('$st');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void closeFloatingOffer({bool showNext = false}) {
    final MBOffer? current = _floatingOffer;

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