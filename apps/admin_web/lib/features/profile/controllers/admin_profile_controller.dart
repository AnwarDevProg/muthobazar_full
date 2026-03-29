import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';


class AdminProfileController extends GetxController {
  AdminProfileController({
    AdminUserRepository? repository,
  }) : _repository = repository ?? AdminUserRepository.instance;

  final AdminUserRepository _repository;

  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isRefreshing = false.obs;

  StreamSubscription<UserModel?>? _profileSubscription;

  String get currentUid => currentUser.value?.id.trim() ?? '';

  String get fullName => currentUser.value?.fullName.trim().isNotEmpty == true
      ? currentUser.value!.fullName
      : 'Admin User';

  String get email => currentUser.value?.email.trim() ?? '';

  String get profilePicture => currentUser.value?.profilePicture.trim() ?? '';

  String get role => currentUser.value?.role.trim() ?? 'admin';

  bool get hasProfilePicture =>
      currentUser.value?.profilePicture.trim().isNotEmpty == true;

  @override
  void onInit() {
    super.onInit();
    _listenCurrentAdminProfile();
  }

  void _listenCurrentAdminProfile() {
    _profileSubscription?.cancel();
    isLoading.value = true;

    final String uid = _repository.currentUid.trim();

    if (uid.isEmpty) {
      currentUser.value = null;
      isLoading.value = false;
      return;
    }

    _profileSubscription = _repository.watchUserById(uid).listen(
          (user) {
        if (user == null) {
          currentUser.value = null;
        } else {
          currentUser.value = UserModel.normalized(user);
        }
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load admin profile.',
        );
      },
    );
  }

  Future<void> refreshProfile() async {
    final String uid = _repository.currentUid.trim();
    if (uid.isEmpty) return;

    try {
      isRefreshing.value = true;
      final user = await _repository.fetchUserById(uid);
      currentUser.value = user == null ? null : UserModel.normalized(user);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh admin profile.',
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String profilePicture,
  }) async {
    final UserModel? existing = currentUser.value;
    if (existing == null) {
      MBNotification.error(
        title: 'Error',
        message: 'No admin profile found.',
      );
      return;
    }

    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final updated = UserModel.normalized(
        existing.copyWith(
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          email: email.trim(),
          phoneNumber: phoneNumber.trim(),
          gender: gender.trim(),
          dateOfBirth: dateOfBirth.trim(),
          profilePicture: profilePicture.trim(),
        ),
      );

      await _repository.updateUserBasicInfo(
        uid: updated.id,
        firstName: updated.firstName,
        lastName: updated.lastName,
        email: updated.email,
        phoneNumber: updated.phoneNumber,
        gender: updated.gender,
        dateOfBirth: updated.dateOfBirth,
        role: updated.role,
        accountStatus: updated.accountStatus,
        isGuest: updated.isGuest,
      );

      await _repository.updateUserProfilePicture(
        uid: updated.id,
        profilePicture: updated.profilePicture,
      );

      currentUser.value = updated;

      MBNotification.success(
        title: 'Success',
        message: 'Profile updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update admin profile.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    super.onClose();
  }
}