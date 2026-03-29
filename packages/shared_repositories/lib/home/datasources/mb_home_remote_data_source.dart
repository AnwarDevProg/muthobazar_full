import 'package:shared_models/home/mb_home_cache_bundle.dart';

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
    await Future<void>.delayed(_delay);

    final MBHomeCacheBundle bundle = _bundleBuilder();

    return bundle.copyWith(
      cachedAt: DateTime.now(),
    );
  }
}