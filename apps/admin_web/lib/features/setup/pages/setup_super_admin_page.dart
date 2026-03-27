import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/layout/mb_app_layout.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class SetupSuperAdminPage extends StatefulWidget {
  const SetupSuperAdminPage({super.key});

  @override
  State<SetupSuperAdminPage> createState() => _SetupSuperAdminPageState();
}

class _SetupSuperAdminPageState extends State<SetupSuperAdminPage> {
  bool _isChecking = true;
  bool _hasSuperAdmin = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _checkBootstrapState();
  }

  Future<void> _checkBootstrapState() async {
    try {
      final exists = await AdminSetupRepository.instance.hasAnyActiveSuperAdmin();

      if (!mounted) return;

      setState(() {
        _hasSuperAdmin = exists;
        _isChecking = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasSuperAdmin = false;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();

    final user = profileController.user.value;
    final fullName = profileController.fullName.trim();
    final uid = user.id.trim();
    final email = user.email.trim();
    final phone = user.phoneNumber.trim();

    final bool hasUsableIdentity =
        uid.isNotEmpty && profileController.isLoggedIn;

    final bool canBootstrap = kIsWeb &&
        !_hasSuperAdmin &&
        hasUsableIdentity;

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: MBCard(
            child: _isChecking
                ? const Padding(
              padding: EdgeInsets.all(MBSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin Setup',
                  style: MBTextStyles.pageTitle,
                ),
                MBSpacing.h(MBSpacing.sm),
                Text(
                  'This page can initialize the first super admin only.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                MBSpacing.h(MBSpacing.lg),
                _row('Platform', kIsWeb ? 'Web' : 'Not Web'),
                MBSpacing.h(MBSpacing.sm),
                _row('Login', profileController.isLoggedIn ? 'Yes' : 'No'),
                MBSpacing.h(MBSpacing.sm),
                _row('User ID', uid.isEmpty ? '-' : uid),
                MBSpacing.h(MBSpacing.sm),
                _row('Name', fullName.isEmpty ? 'User' : fullName),
                MBSpacing.h(MBSpacing.sm),
                _row('Email', email.isEmpty ? 'Not set' : email),
                MBSpacing.h(MBSpacing.sm),
                _row('Phone', phone.isEmpty ? 'Not set' : phone),
                MBSpacing.h(MBSpacing.sm),
                _row(
                  'Super Admin Exists',
                  _hasSuperAdmin ? 'Yes' : 'No',
                ),
                MBSpacing.h(MBSpacing.lg),
                if (_hasSuperAdmin)
                  Text(
                    'A super admin already exists. Bootstrap is locked.',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.warning,
                    ),
                  )
                else if (!kIsWeb)
                  Text(
                    'Super admin bootstrap is allowed only from web.',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.warning,
                    ),
                  )
                else if (!profileController.isLoggedIn)
                    Text(
                      'Please login first.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.warning,
                      ),
                    )
                  else
                    Text(
                      'You are eligible to create the first super admin.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.success,
                      ),
                    ),
                MBSpacing.h(MBSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: MBSecondaryButton(
                        text: 'Back',
                        onPressed: () => Get.offAllNamed(
                          kIsWeb ? AppRoutes.welcome : AppRoutes.shell,
                        ),
                      ),
                    ),
                    MBSpacing.w(MBSpacing.md),
                    Expanded(
                      child: MBPrimaryButton(
                        text: 'Create Super Admin',
                        isLoading: _isCreating,
                        onPressed: canBootstrap
                            ? () async {
                          try {
                            setState(() {
                              _isCreating = true;
                            });

                            await accessController
                                .bootstrapFirstSuperAdmin(
                              uid: uid,
                              name: fullName.isEmpty
                                  ? 'Super Admin'
                                  : fullName,
                              email: email,
                            );

                            await accessController.refreshPermission();
                            await _checkBootstrapState();

                            MBNotification.success(
                              title: 'Success',
                              message:
                              'First super admin created successfully.',
                            );

                            Get.offAllNamed(AppRoutes.adminShell);
                          } catch (e) {
                            MBNotification.error(
                              title: 'Error',
                              message:
                              'Failed to create super admin.',
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isCreating = false;
                              });
                            }
                          }
                        }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: MBTextStyles.body,
          ),
        ),
      ],
    );
  }
}












