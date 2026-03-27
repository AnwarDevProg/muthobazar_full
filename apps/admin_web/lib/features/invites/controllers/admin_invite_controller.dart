import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:shared_models/shared_models.dart';
import '../../../models/user_model.dart';
import '../../profile/controllers/profile_controller.dart';

import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_services/shared_services.dart';
import 'admin_access_controller.dart';



class AdminInviteController extends GetxController {
  final AdminInviteRepository _repository = AdminInviteRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxBool isSearchingUser = false.obs;
  final RxBool isSendingInvite = false.obs;
  final RxBool isDecisionBusy = false.obs;
  final RxBool isLoadingInvites = true.obs;

  final Rxn<UserModel> searchedUser = Rxn<UserModel>();
  final Rxn<MBAdminInvite> searchedUserPendingInvite = Rxn<MBAdminInvite>();

  final RxList<MBAdminInvite> allInvites = <MBAdminInvite>[].obs;
  final RxList<MBAdminInvite> myPendingInvites = <MBAdminInvite>[].obs;

  StreamSubscription<List<MBAdminInvite>>? _allInvitesSub;
  StreamSubscription<List<MBAdminInvite>>? _myInvitesSub;

  bool get canManageInvites =>
      _accessController.isSuperAdmin &&
          _accessController.canManageAdminInvites;

  @override
  void onInit() {
    super.onInit();
    _listenAllInvites();
    _listenMyPendingInvites();
  }

  void _listenAllInvites() {
    _allInvitesSub?.cancel();

    if (!canManageInvites) {
      allInvites.clear();
      isLoadingInvites.value = false;
      return;
    }

    isLoadingInvites.value = true;

    _allInvitesSub = _repository.watchAllInvites().listen(
          (items) {
        allInvites.assignAll(items);
        isLoadingInvites.value = false;
      },
      onError: (_) {
        isLoadingInvites.value = false;
      },
    );
  }

  void _listenMyPendingInvites() {
    _myInvitesSub?.cancel();

    final uid = _profileController.user.value.id;
    if (uid.trim().isEmpty) {
      myPendingInvites.clear();
      return;
    }

    _myInvitesSub = _repository.watchPendingInvitesForUid(uid).listen(
          (items) {
        myPendingInvites.assignAll(items);
      },
    );
  }

  Future<void> searchUserByPhone(String phone) async {
    if (!canManageInvites) {
      MBNotification.error(
        title: 'Permission Denied',
        message: 'Only super admin can create invites.',
      );
      return;
    }

    final input = phone.trim();
    if (input.isEmpty) {
      searchedUser.value = null;
      searchedUserPendingInvite.value = null;
      return;
    }

    try {
      isSearchingUser.value = true;
      searchedUser.value = null;
      searchedUserPendingInvite.value = null;

      final user = await _repository.findUserByPhone(input);

      if (user == null) {
        MBNotification.warning(
          title: 'Not Found',
          message: 'No user found with this phone number.',
        );
        return;
      }

      searchedUser.value = user;
      searchedUserPendingInvite.value =
      await _repository.getPendingInviteByUid(user.id);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to search user.',
      );
    } finally {
      isSearchingUser.value = false;
    }
  }

  Future<void> sendInviteToSearchedUser() async {
    final user = searchedUser.value;
    if (user == null) return;

    if (!canManageInvites) {
      MBNotification.error(
        title: 'Permission Denied',
        message: 'Only super admin can send invites.',
      );
      return;
    }

    try {
      isSendingInvite.value = true;

      final invite = await _repository.createInvite(
        targetUser: user,
        role: 'admin',
        invitedByUid: _profileController.user.value.id,
        invitedByName: _profileController.fullName,
      );

      searchedUserPendingInvite.value = invite;

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'create_admin_invite',
        targetType: 'admin_invite',
        targetId: invite.id,
        targetTitle: user.fullName,
        summary: 'Created admin invite for "${user.fullName}"',
        afterData: invite.toMap(),
      );

      MBNotification.success(
        title: 'Invite Sent',
        message: 'Admin invitation has been created.',
      );
    } catch (e) {
      MBNotification.error(
        title: 'Invite Failed',
        message: e.toString(),
      );
    } finally {
      isSendingInvite.value = false;
    }
  }

  Future<void> revokeInvite(MBAdminInvite invite) async {
    if (!canManageInvites) {
      MBNotification.error(
        title: 'Permission Denied',
        message: 'Only super admin can revoke invites.',
      );
      return;
    }

    try {
      await _repository.revokeInvite(invite.id);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'revoke_admin_invite',
        targetType: 'admin_invite',
        targetId: invite.id,
        targetTitle: invite.name,
        summary: 'Revoked admin invite for "${invite.name}"',
        beforeData: invite.toMap(),
      );

      if (searchedUserPendingInvite.value?.id == invite.id) {
        searchedUserPendingInvite.value = null;
      }

      MBNotification.success(
        title: 'Invite Revoked',
        message: 'Invitation revoked successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to revoke invite.',
      );
    }
  }

  Future<void> acceptInvite(MBAdminInvite invite) async {
    final user = _profileController.user.value;
    if (user.id.trim().isEmpty) return;

    try {
      isDecisionBusy.value = true;

      await _repository.acceptInvite(
        invite: invite,
        user: user,
      );

      await _accessController.refreshPermission();

      await AdminActivityLogger.log(
        adminUid: user.id,
        adminName: user.fullName,
        adminEmail: user.email,
        adminRole: invite.role,
        action: 'accept_admin_invite',
        targetType: 'admin_invite',
        targetId: invite.id,
        targetTitle: invite.name,
        summary: 'Accepted admin invite for "${invite.name}"',
        beforeData: invite.toMap(),
      );

      MBNotification.success(
        title: 'Invite Accepted',
        message: 'You now have admin access.',
      );
    } catch (e) {
      MBNotification.error(
        title: 'Accept Failed',
        message: e.toString(),
      );
    } finally {
      isDecisionBusy.value = false;
    }
  }

  Future<void> rejectInvite(MBAdminInvite invite) async {
    final uid = _profileController.user.value.id;
    if (uid.trim().isEmpty) return;

    try {
      isDecisionBusy.value = true;

      await _repository.rejectInvite(
        inviteId: invite.id,
        uid: uid,
      );

      await AdminActivityLogger.log(
        adminUid: uid,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? 'customer',
        action: 'reject_admin_invite',
        targetType: 'admin_invite',
        targetId: invite.id,
        targetTitle: invite.name,
        summary: 'Rejected admin invite for "${invite.name}"',
        beforeData: invite.toMap(),
      );

      MBNotification.info(
        title: 'Invite Rejected',
        message: 'Invitation rejected.',
      );
    } catch (e) {
      MBNotification.error(
        title: 'Reject Failed',
        message: e.toString(),
      );
    } finally {
      isDecisionBusy.value = false;
    }
  }

  @override
  void onClose() {
    _allInvitesSub?.cancel();
    _myInvitesSub?.cancel();
    super.onClose();
  }
}












