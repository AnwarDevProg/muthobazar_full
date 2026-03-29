import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/customer/mb_user_profile.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../admin_access/controllers/admin_access_controller.dart';
import '../controllers/admin_user_controller.dart';
import '../widgets/admin_user_form_dialog.dart';

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
              _UsersToolbar(userController: userController),
              MBSpacing.h(MBSpacing.lg),
              if (userController.filteredUsers.isEmpty)
                MBCard(
                  child: Text(
                    'No users found for the current filter.',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                )
              else
                ...userController.filteredUsers.map((user) {
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

    final activeCount = users
        .where((e) => e.accountStatus.trim().toLowerCase() == 'active')
        .length;
    final blockedCount = users
        .where((e) => e.accountStatus.trim().toLowerCase() == 'blocked')
        .length;
    final guestCount = users.where((e) => e.isGuest).length;
    final adminCount = users
        .where((e) {
      final role = e.role.trim().toLowerCase();
      return role == 'admin' || role == 'super_admin';
    })
        .length;

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
        _UserSummaryCard(
          title: 'Admins',
          value: adminCount.toString(),
          icon: Icons.admin_panel_settings_outlined,
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
      width: 220,
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

class _UsersToolbar extends StatelessWidget {
  final AdminUserController userController;

  const _UsersToolbar({
    required this.userController,
  });

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search & Filter',
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          Wrap(
            spacing: MBSpacing.md,
            runSpacing: MBSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: userController.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, phone, role, UID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: userController.searchController.text.isNotEmpty
                        ? IconButton(
                      onPressed: userController.clearSearch,
                      icon: const Icon(Icons.close),
                    )
                        : null,
                  ),
                ),
              ),
              _FilterChipButton(
                label: 'All',
                selected: userController.selectedFilter.value == AdminUserFilter.all,
                onTap: () => userController.updateFilter(AdminUserFilter.all),
              ),
              _FilterChipButton(
                label: 'Active',
                selected: userController.selectedFilter.value == AdminUserFilter.active,
                onTap: () => userController.updateFilter(AdminUserFilter.active),
              ),
              _FilterChipButton(
                label: 'Inactive',
                selected: userController.selectedFilter.value == AdminUserFilter.inactive,
                onTap: () => userController.updateFilter(AdminUserFilter.inactive),
              ),
              _FilterChipButton(
                label: 'Blocked',
                selected: userController.selectedFilter.value == AdminUserFilter.blocked,
                onTap: () => userController.updateFilter(AdminUserFilter.blocked),
              ),
              _FilterChipButton(
                label: 'Guests',
                selected: userController.selectedFilter.value == AdminUserFilter.guest,
                onTap: () => userController.updateFilter(AdminUserFilter.guest),
              ),
              _FilterChipButton(
                label: 'Customers',
                selected: userController.selectedFilter.value == AdminUserFilter.customer,
                onTap: () => userController.updateFilter(AdminUserFilter.customer),
              ),
              _FilterChipButton(
                label: 'Admins',
                selected: userController.selectedFilter.value == AdminUserFilter.admin,
                onTap: () => userController.updateFilter(AdminUserFilter.admin),
              ),
              _FilterChipButton(
                label: 'Super Admin',
                selected: userController.selectedFilter.value == AdminUserFilter.superAdmin,
                onTap: () => userController.updateFilter(AdminUserFilter.superAdmin),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? MBColors.primaryOrange : MBColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MBSpacing.md,
          vertical: MBSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? MBColors.primaryOrange.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: MBTextStyles.caption.copyWith(
            color: selected ? MBColors.primaryOrange : MBColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserIdentitySection(user: user),
                MBSpacing.h(MBSpacing.md),
                _UserMetaSection(user: user),
                MBSpacing.h(MBSpacing.md),
                _UserActionsSection(user: user),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _UserIdentitySection(user: user),
              ),
              MBSpacing.w(MBSpacing.lg),
              Expanded(
                flex: 4,
                child: _UserMetaSection(user: user),
              ),
              MBSpacing.w(MBSpacing.lg),
              Expanded(
                flex: 4,
                child: _UserActionsSection(user: user),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserIdentitySection extends StatelessWidget {
  final UserModel user;

  const _UserIdentitySection({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final initials = user.fullName.trim().isEmpty
        ? '?'
        : user.fullName.trim().substring(0, 1).toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: MBColors.primarySoft,
          child: Text(
            initials,
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
                user.email.isNotEmpty ? user.email : 'No email',
                style: MBTextStyles.body.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                user.phoneNumber.isNotEmpty ? user.phoneNumber : 'No phone',
                style: MBTextStyles.caption.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                'UID: ${user.id}',
                style: MBTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserMetaSection extends StatelessWidget {
  final UserModel user;

  const _UserMetaSection({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: MBSpacing.sm,
      runSpacing: MBSpacing.sm,
      children: [
        _InfoChip(
          label: 'Role',
          value: _prettyValue(user.role),
        ),
        _InfoChip(
          label: 'Status',
          value: _prettyValue(user.accountStatus),
        ),
        _InfoChip(
          label: 'Guest',
          value: user.isGuest ? 'Yes' : 'No',
        ),
        _InfoChip(
          label: 'Created',
          value: _formatTimestamp(user.createdAt),
        ),
        _InfoChip(
          label: 'Last Login',
          value: _formatTimestamp(user.lastLoginAt),
        ),
      ],
    );
  }

  static String _prettyValue(String value) {
    final cleaned = value.trim().replaceAll('_', ' ');
    if (cleaned.isEmpty) return '-';

    return cleaned
        .split(' ')
        .map((e) {
      if (e.isEmpty) return e;
      return '${e[0].toUpperCase()}${e.substring(1)}';
    })
        .join(' ');
  }

  static String _formatTimestamp(dynamic value) {
    if (value == null) return '-';

    try {
      final dateTime = value.toDate();
      final year = dateTime.year.toString().padLeft(4, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$year-$month-$day $hour:$minute';
    } catch (_) {
      return '-';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(color: MBColors.border),
      ),
      child: Text(
        '$label: $value',
        style: MBTextStyles.caption,
      ),
    );
  }
}

class _UserActionsSection extends StatelessWidget {
  final UserModel user;

  const _UserActionsSection({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminUserController>();

    return Wrap(
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
          onPressed: controller.canBlock(user)
              ? () => _confirmAction(
            title: 'Block User',
            message: 'Are you sure you want to block "${user.fullName}"?',
            onConfirm: () => controller.blockUser(user),
          )
              : null,
        ),
        MBSecondaryButton(
          text: 'Deactivate',
          expand: false,
          height: 40,
          onPressed: controller.canDeactivate(user)
              ? () => _confirmAction(
            title: 'Deactivate User',
            message: 'Are you sure you want to deactivate "${user.fullName}"?',
            onConfirm: () => controller.deactivateUser(user),
          )
              : null,
        ),
        MBSecondaryButton(
          text: 'Reactivate',
          expand: false,
          height: 40,
          onPressed: controller.canReactivate(user)
              ? () => _confirmAction(
            title: 'Reactivate User',
            message: 'Are you sure you want to reactivate "${user.fullName}"?',
            onConfirm: () => controller.reactivateUser(user),
          )
              : null,
        ),
      ],
    );
  }

  void _confirmAction({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}