import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminActivityLogController extends GetxController {
  final AdminActivityLogRepository _repository =
      AdminActivityLogRepository.instance;

  final RxList<MBAdminActivityLog> logs = <MBAdminActivityLog>[].obs;

  final RxBool isLoading = true.obs;

  StreamSubscription<List<MBAdminActivityLog>>? _logsSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenLogs();
  }

  void _listenLogs() {
    _logsSubscription?.cancel();
    isLoading.value = true;

    _logsSubscription = _repository.watchLogs().listen(
          (items) {
        logs.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load activity logs.',
        );
      },
    );
  }

  Future<void> refreshLogs() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchLogsOnce();
      logs.assignAll(items);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh activity logs.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _logsSubscription?.cancel();
    super.onClose();
  }
}












