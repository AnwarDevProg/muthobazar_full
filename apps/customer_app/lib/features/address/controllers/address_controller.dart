import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:shared_models/shared_models.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AddressController extends GetxController {
  final AddressRepository _repository = AddressRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();

  final RxBool isAddressProcessing = false.obs;
  final RxString addressProcessingMessage = ''.obs;

  static const List<String> supportedAreas = [
    'Uttara Sector 1',
    'Uttara Sector 2',
    'Uttara Sector 3',
    'Uttara Sector 4',
    'Uttara Sector 5',
    'Uttara Sector 6',
    'Uttara Sector 7',
    'Uttara Sector 8',
    'Uttara Sector 9',
    'Uttara Sector 10',
    'Uttara Sector 11',
    'Uttara Sector 12',
    'Uttara Sector 13',
    'Uttara Sector 14',
    'Uttara Sector 15',
    'Uttara Sector 16',
    'Uttara Sector 17',
    'Uttara Sector 18',
    'Mirpur 1',
    'Mirpur 2',
    'Mirpur 3',
    'Mirpur 4',
    'Mirpur 5',
    'Mirpur 6',
    'Mirpur 7',
    'Mirpur 8',
    'Mirpur 9',
    'Mirpur 10',
    'Mirpur 11',
    'Mirpur 12',
    'Mirpur 13',
    'Mirpur 14',
    'Gulshan',
    'Baridhara',
    'Mirpur DOHS',
    'Banani',
  ];

  bool get isLoggedIn => _profileController.isLoggedIn;
  String get userId => _profileController.user.value.id;
  String get profileFullName =>
      _profileController.fullName == 'Guest User' ? '' : _profileController.fullName;
  String get profilePhoneDigits =>
      _profileController.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  List<UserAddressModel> get addresses => _profileController.user.value.addresses;

  bool isAreaSupported(String area) {
    final normalized = area.trim().toLowerCase();
    return supportedAreas.any((item) => item.toLowerCase() == normalized);
  }

  void _replaceAddresses(List<UserAddressModel> updated) {
    final currentUser = _profileController.user.value;
    _profileController.user.value = currentUser.copyWith(
      addresses: updated,
      defaultAddressId: updated.firstWhereOrNull((e) => e.isDefault)?.id ?? '',
    );
    _profileController.user.refresh();
  }

  List<UserAddressModel> _rebuildOrderedAddresses(
      List<UserAddressModel> input,
      ) {
    if (input.isEmpty) return const <UserAddressModel>[];

    final normalized = _repository.normalizeAddresses(input);

    final defaultAddress = normalized.firstWhereOrNull((e) => e.isDefault);
    if (defaultAddress == null) {
      return normalized;
    }

    return _repository.normalizeReorderedDefault(
      addresses: normalized,
      defaultAddressId: defaultAddress.id,
    );
  }

  Future<void> addAddress(UserAddressModel address) async {
    if (!isLoggedIn) return;

    final updated = [...addresses];

    if (updated.isEmpty) {
      updated.add(address.copyWith(isDefault: true));
    } else {
      if (address.isDefault) {
        for (int i = 0; i < updated.length; i++) {
          updated[i] = updated[i].copyWith(isDefault: false);
        }
      }
      updated.add(address);
    }

    final ordered = _rebuildOrderedAddresses(updated);

    await _repository.saveAddresses(
      uid: userId,
      addresses: ordered,
    );

    _replaceAddresses(ordered);
  }

  Future<void> addAddressWithDelay(UserAddressModel model) async {
    if (isAddressProcessing.value) return;

    try {
      isAddressProcessing.value = true;
      addressProcessingMessage.value = 'Saving new address...';

      await Future.delayed(const Duration(seconds: 1));
      await addAddress(model);
    } finally {
      isAddressProcessing.value = false;
      addressProcessingMessage.value = '';
    }
  }

  Future<void> updateAddress(UserAddressModel address) async {
    if (!isLoggedIn) return;

    final updated = [...addresses];
    final index = updated.indexWhere((e) => e.id == address.id);

    if (index == -1) return;

    if (address.isDefault) {
      for (int i = 0; i < updated.length; i++) {
        updated[i] = updated[i].copyWith(isDefault: false);
      }
    }

    updated[index] = address;

    final ordered = _rebuildOrderedAddresses(updated);

    await _repository.saveAddresses(
      uid: userId,
      addresses: ordered,
    );

    _replaceAddresses(ordered);
  }

  Future<void> updateAddressWithDelay(UserAddressModel model) async {
    if (isAddressProcessing.value) return;

    try {
      isAddressProcessing.value = true;
      addressProcessingMessage.value = 'Updating address...';

      await Future.delayed(const Duration(seconds: 1));
      await updateAddress(model);
    } finally {
      isAddressProcessing.value = false;
      addressProcessingMessage.value = '';
    }
  }

  Future<void> deleteAddress(String addressId) async {
    if (!isLoggedIn) return;

    final updated = addresses.where((e) => e.id != addressId).toList();
    final ordered = _rebuildOrderedAddresses(updated);

    await _repository.saveAddresses(
      uid: userId,
      addresses: ordered,
    );

    _replaceAddresses(ordered);
  }

  Future<void> deleteAddressWithDelay(String addressId) async {
    if (!isLoggedIn || isAddressProcessing.value) return;

    try {
      isAddressProcessing.value = true;
      addressProcessingMessage.value = 'Deleting address...';

      await Future.delayed(const Duration(seconds: 1));
      await deleteAddress(addressId);

      MBNotification.success(
        title: 'Deleted',
        message: 'Address deleted successfully.',
        position: MBNotificationPosition.top,
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to delete address.',
        position: MBNotificationPosition.top,
      );
    } finally {
      isAddressProcessing.value = false;
      addressProcessingMessage.value = '';
    }
  }

  Future<void> setDefaultAddressWithDelay(String addressId) async {
    if (!isLoggedIn || isAddressProcessing.value) return;

    try {
      isAddressProcessing.value = true;
      addressProcessingMessage.value = 'Setting default address...';

      await Future.delayed(const Duration(seconds: 1));

      final updated = _repository.normalizeReorderedDefault(
        addresses: addresses,
        defaultAddressId: addressId,
      );

      await _repository.saveAddresses(
        uid: userId,
        addresses: updated,
      );

      _replaceAddresses(updated);

      MBNotification.success(
        title: 'Success',
        message: 'Default address updated.',
        position: MBNotificationPosition.top,
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to set default address.',
        position: MBNotificationPosition.top,
      );
    } finally {
      isAddressProcessing.value = false;
      addressProcessingMessage.value = '';
    }
  }
}

