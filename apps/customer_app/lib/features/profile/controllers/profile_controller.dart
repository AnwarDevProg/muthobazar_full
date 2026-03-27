// Profile Controller
// ------------------
// Handles profile state, profile watch, local updates, and logout sync.

import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository = ProfileRepository.instance;

  final Rx<UserModel> user = UserModel.guest().obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString savingMessage = ''.obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel>? _profileSubscription;

  bool get isGuest => user.value.isGuest;
  bool get isLoggedIn => !user.value.isGuest && user.value.id.isNotEmpty;

  bool get isAdmin {
    if (isGuest) return false;

    final role = user.value.role.trim().toLowerCase();
    debugPrint(role);
    return role == 'admin' || role == 'super_admin';

  }

  bool get isSuperAdmin {
    if (isGuest) return false;

    final role = user.value.role.trim().toLowerCase();
    return role == 'super_admin';

  }

  String get fullName {
    if (user.value.isGuest) return 'Guest User';
    final name = user.value.fullName.trim();
    return name.isEmpty ? 'User' : name;
  }

  String get phoneNumber => user.value.phoneNumber;
  String get profilePicture => user.value.profilePicture;
  String get defaultAddressText => user.value.defaultAddress?.fullAddress ?? '';

  List<_DemoProductModel> get randomSuggestedProducts {
    final list = [..._demoProducts]..shuffle(Random());
    return list.take(8).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _listenAuthAndProfile();
  }

  void _listenAuthAndProfile() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();

    _authSubscription =
        _repository.authStateChanges().listen((firebaseUser) async {
          if (firebaseUser == null) {
            applyLocalGuestState();
            return;
          }

          isLoading.value = true;

          final displayName = (firebaseUser.displayName ?? '').trim();
          final fallbackName = displayName.isEmpty ? 'User' : displayName;

          await _repository.createUserDocIfMissing(
            uid: firebaseUser.uid,
            fullName: fallbackName,
            email: firebaseUser.email ?? '',
            phoneNumber: firebaseUser.phoneNumber ?? '',
            profilePicture: firebaseUser.photoURL ?? '',
          );

          _profileSubscription?.cancel();
          _profileSubscription =
              _repository.watchUser(firebaseUser.uid).listen((profile) {
                user.value = profile.copyWith(isGuest: false);
                isLoading.value = false;
              }, onError: (_) {
                applyLocalGuestState();
              });
        });
  }

  Future<void> updateFullName(String fullName) async {
    if (!isLoggedIn || isSaving.value) return;

    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      MBNotification.warning(
        title: 'Invalid Name',
        message: 'Please enter your full name.',
      );
      return;
    }

    try {
      isSaving.value = true;
      savingMessage.value = 'Updating name...';

      await _repository.updateName(
        uid: user.value.id,
        fullName: trimmed,
      );

      applyLocalNameUpdate(trimmed);

      MBNotification.success(
        title: 'Success',
        message: 'Name updated successfully.',
      );

      await refreshUserFromServer();
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update name.',
      );
    } finally {
      isSaving.value = false;
      savingMessage.value = '';
    }
  }

  Future<void> pickAndUploadProfilePhoto() async {
    if (!isLoggedIn || isSaving.value) return;

    try {
      isSaving.value = true;
      savingMessage.value = 'Uploading profile picture...';

      final picked = await ImageHelper.pickImage();
      if (picked == null) return;

      savingMessage.value = 'Processing image...';
      final compressed = await ImageHelper.compressImage(picked);

      savingMessage.value = 'Saving profile picture...';
      final imageUrl = await _repository.uploadProfilePicture(
        uid: user.value.id,
        imageFile: compressed,
      );

      await _repository.updateProfilePicture(
        uid: user.value.id,
        imageUrl: imageUrl,
      );

      applyLocalProfilePictureUpdate(imageUrl);

      MBNotification.success(
        title: 'Success',
        message: 'Profile photo updated successfully.',
      );

      await refreshUserFromServer();
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to upload profile photo.',
      );
    } finally {
      isSaving.value = false;
      savingMessage.value = '';
    }
  }

  Future<void> logout() async {
    if (!isLoggedIn) return;

    try {
      await _repository.logout();

      // Immediate local refresh so UI reflects logout instantly,
      // even before auth/profile streams finish propagating.
      applyLocalGuestState();

      MBNotification.success(
        title: 'Logged Out',
        message: 'You have been logged out successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to logout.',
      );
    }
  }

  void replaceUser(UserModel newUser) {
    user.value = newUser;
    user.refresh();
  }

  Future<void> refreshUserFromServer() async {
    if (!isLoggedIn) return;

    try {
      final freshUser = await _repository.fetchUserOnce(user.value.id);
      replaceUser(freshUser.copyWith(isGuest: false));
    } catch (_) {
      // Stream can still update later.
    }
  }

  void applyLocalNameUpdate(String fullName) {
    if (!isLoggedIn) return;

    final parts = UserModel.splitFullName(fullName);

    user.value = user.value.copyWith(
      firstName: parts[0],
      lastName: parts[1],
    );
    user.refresh();
  }

  void applyLocalProfilePictureUpdate(String imageUrl) {
    if (!isLoggedIn) return;

    user.value = user.value.copyWith(
      profilePicture: imageUrl,
    );
    user.refresh();
  }

  void applyLocalPhoneUpdate(String phoneNumber) {
    if (!isLoggedIn) return;

    final normalized = _repository.normalizePhoneInput(phoneNumber);

    user.value = user.value.copyWith(
      phoneNumber: normalized,
    );
    user.refresh();
  }

  void applyLocalGuestState() {
    _profileSubscription?.cancel();
    _profileSubscription = null;

    user.value = UserModel.guest();
    user.refresh();

    isLoading.value = false;
    isSaving.value = false;
    savingMessage.value = '';
  }

  Future<void> updateProfileInfo({
    required String fullName,
    required String email,
    required String gender,
    required String dateOfBirth,
  }) async {
    if (!isLoggedIn || isSaving.value) return;

    final trimmedFullName = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    final trimmedEmail = email.trim();
    final trimmedGender = gender.trim();
    final trimmedDob = dateOfBirth.trim();

    final current = user.value;
    final currentFullName =
    current.fullName.trim().replaceAll(RegExp(r'\s+'), ' ');

    final Map<String, dynamic> changedData = {};

    if (trimmedFullName != currentFullName) {
      final parts = UserModel.splitFullName(trimmedFullName);
      changedData['FirstName'] = parts[0];
      changedData['LastName'] = parts[1];
    }

    if (trimmedEmail != current.email.trim()) {
      changedData['Email'] = trimmedEmail;
    }

    if (trimmedGender != current.gender.trim()) {
      changedData['Gender'] = trimmedGender;
    }

    if (trimmedDob != current.dateOfBirth.trim()) {
      changedData['DOB'] = trimmedDob;
    }

    if (changedData.isEmpty) return;

    try {
      isSaving.value = true;
      savingMessage.value = 'Updating profile information...';

      await _repository.updateProfileInfo(
        uid: current.id,
        changedData: changedData,
      );

      applyLocalProfileInfoUpdate(
        fullName: trimmedFullName,
        email: trimmedEmail,
        gender: trimmedGender,
        dateOfBirth: trimmedDob,
      );

      MBNotification.success(
        title: 'Success',
        message: 'Profile information updated successfully.',
      );

      await refreshUserFromServer();
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update profile information.',
      );
    } finally {
      isSaving.value = false;
      savingMessage.value = '';
    }
  }

  void applyLocalProfileInfoUpdate({
    required String fullName,
    required String email,
    required String gender,
    required String dateOfBirth,
  }) {
    if (!isLoggedIn) return;

    final parts = UserModel.splitFullName(fullName);

    user.value = user.value.copyWith(
      firstName: parts[0],
      lastName: parts[1],
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
    user.refresh();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.onClose();
  }
}

class _DemoProductModel {
  final String title;
  final String category;
  final String price;
  final String discountText;

  const _DemoProductModel({
    required this.title,
    required this.category,
    required this.price,
    required this.discountText,
  });
}

const List<_DemoProductModel> _demoProducts = [
  _DemoProductModel(
    title: 'Fresh Orange Juice 1L',
    category: 'Beverages',
    price: '৳ 180',
    discountText: '10% OFF',
  ),
  _DemoProductModel(
    title: 'Premium Basmati Rice 5kg',
    category: 'Groceries',
    price: '৳ 620',
    discountText: '15% OFF',
  ),
  _DemoProductModel(
    title: 'Natural Honey Jar 500g',
    category: 'Health Food',
    price: '৳ 390',
    discountText: '8% OFF',
  ),
  _DemoProductModel(
    title: 'Daily Care Shampoo 340ml',
    category: 'Personal Care',
    price: '৳ 275',
    discountText: '12% OFF',
  ),
  _DemoProductModel(
    title: 'Premium Olive Oil 500ml',
    category: 'Groceries',
    price: '৳ 540',
    discountText: '7% OFF',
  ),
  _DemoProductModel(
    title: 'Baby Skin Lotion 200ml',
    category: 'Baby Care',
    price: '৳ 320',
    discountText: '9% OFF',
  ),
];

