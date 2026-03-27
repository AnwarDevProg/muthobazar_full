import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../models/user_model.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import '../controllers/admin_user_controller.dart';
import 'widgets/admin_user_form_dialog.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accessController = Get.find<AdminAccessController>();
    final userController = Get.find<AdminUserController>();

    return Obx(() {
      if (!accessController.canManageUsers) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(MBSpacing.xl),
          child: MBCard(
            child: Text(
              'You do not have permission to manage users.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ),
        );
      }

      if (userController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return RefreshIndicator(
        onRefresh: userController.refreshUsers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(MBSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _UsersPageHeader(),
              MBSpacing.h(MBSpacing.lg),
              _UsersSummaryRow(userController: userController),
              MBSpacing.h(MBSpacing.xl),
              if (userController.users.isEmpty)
                MBCard(
                  child: Text(
                    'No users found.',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                )
              else
                ...userController.users.map((user) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: MBSpacing.md),
                    child: _UserListCard(user: user),
                  );
                }),
            ],
          ),
        ),
      );
    });
  }
}

class _UsersPageHeader extends StatelessWidget {
  const _UsersPageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Users',
          style: MBTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        MBSpacing.h(MBSpacing.xxxs),
        Text(
          'Review user accounts, update account info, and manage account status.',
          style: MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _UsersSummaryRow extends StatelessWidget {
  final AdminUserController userController;

  const _UsersSummaryRow({
    required this.userController,
  });

  @override
  Widget build(BuildContext context) {
    final users = userController.users;

    final activeCount =
        users.where((e) => e.accountStatus.trim().toLowerCase() == 'active').length;
    final blockedCount =
        users.where((e) => e.accountStatus.trim().toLowerCase() == 'blocked').length;
    final guestCount = users.where((e) => e.isGuest).length;

    return Wrap(
      spacing: MBSpacing.md,
      runSpacing: MBSpacing.md,
      children: [
        _UserSummaryCard(
          title: 'Total Users',
          value: users.length.toString(),
          icon: Icons.people_alt_outlined,
        ),
        _UserSummaryCard(
          title: 'Active',
          value: activeCount.toString(),
          icon: Icons.verified_user_outlined,
        ),
        _UserSummaryCard(
          title: 'Blocked',
          value: blockedCount.toString(),
          icon: Icons.block_outlined,
        ),
        _UserSummaryCard(
          title: 'Guests',
          value: guestCount.toString(),
          icon: Icons.person_outline,
        ),
      ],
    );
  }
}

class _UserSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _UserSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: MBCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(MBRadius.md),
              ),
              child: Icon(
                icon,
                color: MBColors.primaryOrange,
                size: 22,
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              title,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            MBSpacing.h(MBSpacing.xxs),
            Text(
              value,
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListCard extends StatelessWidget {
  final UserModel user;

  const _UserListCard({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminUserController>();

    return MBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: MBColors.primarySoft,
            child: Text(
              user.fullName.isEmpty ? '?' : user.fullName.substring(0, 1).toUpperCase(),
              style: MBTextStyles.bodyMedium.copyWith(
                color: MBColors.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isEmpty ? 'Unnamed User' : user.fullName,
                  style: MBTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  user.email.isEmpty ? user.phoneNumber : user.email,
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Role: ${user.role} • Status: ${user.accountStatus}',
                  style: MBTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: MBSpacing.md),
          Wrap(
            spacing: MBSpacing.sm,
            runSpacing: MBSpacing.sm,
            alignment: WrapAlignment.end,
            children: [
              MBSecondaryButton(
                text: 'Edit',
                expand: false,
                height: 40,
                onPressed: () {
                  Get.dialog(
                    AdminUserFormDialog(user: user),
                    barrierDismissible: false,
                  );
                },
              ),
              MBSecondaryButton(
                text: 'Block',
                expand: false,
                height: 40,
                foregroundColor: MBColors.error,
                borderColor: MBColors.error,
                onPressed: () => controller.blockUser(user),
              ),
              MBSecondaryButton(
                text: 'Deactivate',
                expand: false,
                height: 40,
                onPressed: () => controller.deactivateUser(user),
              ),
              MBSecondaryButton(
                text: 'Reactivate',
                expand: false,
                height: 40,
                onPressed: () => controller.reactivateUser(user),
              ),
            ],
          ),
        ],
      ),
    );
  }
}












