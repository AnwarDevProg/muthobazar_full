import 'package:admin_web/features/dashboard/controllers/admin_management_controller.dart';
import 'package:admin_web/features/profile/controllers/admin_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:shared_models/shared_models.dart';

import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminPermissionsPage extends StatelessWidget {
  const AdminPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminManagementController managementController =
    Get.find<AdminManagementController>();

    return Obx(() {
      if (!accessController.isSuperAdmin) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(MBSpacing.xl),
          child: MBCard(
            child: Text(
              'Only super admin can manage admin permissions.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ),
        );
      }

      if (managementController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(MBSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PermissionsPageHeader(),
            MBSpacing.h(MBSpacing.lg),
            _PermissionsSummaryRow(
              managementController: managementController,
            ),
            MBSpacing.h(MBSpacing.xl),
            if (managementController.admins.isEmpty)
              MBCard(
                child: Text(
                  'No admins found.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              )
            else
              ...managementController.admins.map((admin) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: MBSpacing.md),
                  child: _AdminPermissionListCard(admin: admin),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _PermissionsPageHeader extends StatelessWidget {
  const _PermissionsPageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Permissions',
          style: MBTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        MBSpacing.h(MBSpacing.xxxs),
        Text(
          'Control admin roles, access rights, and panel permissions.',
          style: MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PermissionsSummaryRow extends StatelessWidget {
  final AdminManagementController managementController;

  const _PermissionsSummaryRow({
    required this.managementController,
  });

  @override
  Widget build(BuildContext context) {
    final admins = managementController.admins;
    final activeCount = admins.where((e) => e['isActive'] == true).length;
    final superCount = admins
        .where((e) => (e['role'] ?? '').toString() == 'super_admin')
        .length;

    return Wrap(
      spacing: MBSpacing.md,
      runSpacing: MBSpacing.md,
      children: [
        _PermissionSummaryCard(
          title: 'Total Admins',
          value: admins.length.toString(),
          icon: Icons.admin_panel_settings_outlined,
        ),
        _PermissionSummaryCard(
          title: 'Active Admins',
          value: activeCount.toString(),
          icon: Icons.verified_user_outlined,
        ),
        _PermissionSummaryCard(
          title: 'Super Admins',
          value: superCount.toString(),
          icon: Icons.shield_outlined,
        ),
      ],
    );
  }
}

class _PermissionSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _PermissionSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
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

class _AdminPermissionListCard extends StatelessWidget {
  final Map<String, dynamic> admin;

  const _AdminPermissionListCard({
    required this.admin,
  });

  @override
  Widget build(BuildContext context) {
    final uid = (admin['uid'] ?? '').toString();
    final name = (admin['name'] ?? '').toString();
    final email = (admin['email'] ?? '').toString();
    final role = (admin['role'] ?? 'admin').toString();
    final isActive = admin['isActive'] == true;

    return MBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: MBColors.primarySoft,
            child: Text(
              name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
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
                  name.isEmpty ? 'Unnamed Admin' : name,
                  style: MBTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  email.isEmpty ? '-' : email,
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Role: $role • ${isActive ? 'Active' : 'Inactive'}',
                  style: MBTextStyles.caption,
                ),
              ],
            ),
          ),
          MBSecondaryButton(
            text: 'Edit',
            expand: false,
            height: 42,
            onPressed: () {
              Get.dialog(
                _AdminPermissionEditorDialog(
                  uid: uid,
                  name: name,
                  email: email,
                ),
                barrierDismissible: false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminPermissionEditorDialog extends StatefulWidget {
  final String uid;
  final String name;
  final String email;

  const _AdminPermissionEditorDialog({
    required this.uid,
    required this.name,
    required this.email,
  });

  @override
  State<_AdminPermissionEditorDialog> createState() =>
      _AdminPermissionEditorDialogState();
}

class _AdminPermissionEditorDialogState
    extends State<_AdminPermissionEditorDialog> {
  MBAdminPermission? _permission;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPermission();
  }

  Future<void> _loadPermission() async {
    final permission =
    await AdminAccessRepository.instance.fetchPermission(widget.uid);

    if (!mounted) return;

    setState(() {
      _permission = permission ??
          MBAdminPermission.standardAdmin(
            uid: widget.uid,
            actorUid: widget.uid,
          );
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AdminProfileController profileController = Get.find<AdminProfileController>();
    final AdminManagementController managementController =
    Get.find<AdminManagementController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(
          maxHeight: 760,
        ),
        padding: const EdgeInsets.all(MBSpacing.xl),
        child: _loading
            ? const SizedBox(
          height: 220,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Admin Permission',
              style: MBTextStyles.sectionTitle,
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              '${widget.name} • ${widget.email}',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _permission!.role,
              decoration: const InputDecoration(
                labelText: 'Role',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'admin',
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: 'super_admin',
                  child: Text('Super Admin'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _permission = _permission!.copyWith(
                    role: value ?? 'admin',
                  );
                });
              },
            ),
            MBSpacing.h(MBSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _SwitchTile(
                      label: 'Active',
                      value: _permission!.isActive,
                      onChanged: (value) {
                        setState(() {
                          _permission =
                              _permission!.copyWith(isActive: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Access admin panel',
                      value: _permission!.canAccessAdminPanel,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canAccessAdminPanel: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Manage admins',
                      value: _permission!.canManageAdmins,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canManageAdmins: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Manage admin invites',
                      value: _permission!.canManageAdminInvites,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canManageAdminInvites: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Manage admin permissions',
                      value: _permission!.canManageAdminPermissions,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!.copyWith(
                            canManageAdminPermissions: value,
                          );
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Manage users',
                      value: _permission!.canManageUsers,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canManageUsers: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Manage categories',
                      value: _permission!.canManageCategories,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canManageCategories: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Manage brands',
                      value: _permission!.canManageBrands,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canManageBrands: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Manage products',
                      value: _permission!.canManageProducts,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canManageProducts: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Manage banners',
                      value: _permission!.canManageBanners,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canManageBanners: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Delete products',
                      value: _permission!.canDeleteProducts,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canDeleteProducts: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'Restore products',
                      value: _permission!.canRestoreProducts,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canRestoreProducts: value);
                        });
                      },
                    ),
                    _SwitchTile(
                      label: 'View activity logs',
                      value: _permission!.canViewActivityLogs,
                      onChanged: (value) {
                        setState(() {
                          _permission = _permission!
                              .copyWith(canViewActivityLogs: value);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: MBSecondaryButton(
                    text: 'Remove Access',
                    isLoading: _saving,
                    foregroundColor: MBColors.error,
                    borderColor: MBColors.error,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Remove Admin Access'),
                          content: const Text(
                            'This will remove admin profile and permission documents for this user.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      setState(() {
                        _saving = true;
                      });

                      await managementController.removeAdminAccess(
                        uid: widget.uid,
                      );

                      if (mounted) {
                        Get.back();
                      }
                    },
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: MBSecondaryButton(
                    text: 'Cancel',
                    isLoading: _saving,
                    onPressed: () => Get.back(),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: MBPrimaryButton(
                    text: 'Save',
                    isLoading: _saving,
                    onPressed: () async {
                      setState(() {
                        _saving = true;
                      });

                      await managementController.saveAdminPermission(
                        uid: widget.uid,
                        name: widget.name,
                        email: widget.email,
                        permission: _permission!,
                        actorUid: profileController.currentUser.value!.id.trim(),
                      );

                      if (mounted) {
                        setState(() {
                          _saving = false;
                        });
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MBSpacing.xxs),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          label,
          style: MBTextStyles.body,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}












