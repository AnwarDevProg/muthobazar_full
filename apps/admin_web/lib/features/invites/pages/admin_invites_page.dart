import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/layout/mb_app_layout.dart';
import 'package:shared_ui/shared_ui.dart';
import '../controllers/admin_invite_controller.dart';

class AdminInvitesPage extends StatefulWidget {
  const AdminInvitesPage({super.key});

  @override
  State<AdminInvitesPage> createState() => _AdminInvitesPageState();
}

class _AdminInvitesPageState extends State<AdminInvitesPage> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminInviteController>();

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      child: Obx(() {
        if (!controller.canManageInvites) {
          return Center(
            child: MBCard(
              child: Text(
                'Only super admin can manage admin invitations.',
                style: MBTextStyles.body,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Invitations',
              style: MBTextStyles.pageTitle,
            ),
            MBSpacing.h(MBSpacing.sm),
            Text(
              'Search a user by phone and send admin invitation.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            MBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search User',
                    style: MBTextStyles.sectionTitle,
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: MBTextField(
                          controller: _phoneController,
                          hintText: '017XXXXXXXX',
                        ),
                      ),
                      MBSpacing.w(MBSpacing.md),
                      SizedBox(
                        width: 180,
                        child: MBPrimaryButton(
                          text: 'Search',
                          isLoading: controller.isSearchingUser.value,
                          onPressed: () {
                            controller.searchUserByPhone(
                              _phoneController.text.trim(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  _SearchedUserPanel(),
                ],
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            Text(
              'Recent Invites',
              style: MBTextStyles.sectionTitle,
            ),
            MBSpacing.h(MBSpacing.md),
            controller.isLoadingInvites.value
                ? const Center(child: CircularProgressIndicator())
                : controller.allInvites.isEmpty
                ? MBCard(
              child: Text(
                'No invites found.',
                style: MBTextStyles.body,
              ),
            )
                : ListView.separated(
              itemCount: controller.allInvites.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => MBSpacing.h(MBSpacing.sm),
              itemBuilder: (context, index) {
                final invite = controller.allInvites[index];
                return MBCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              invite.name,
                              style: MBTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            MBSpacing.h(MBSpacing.xxxs),
                            Text(
                              '${invite.phone} • ${invite.email}',
                              style: MBTextStyles.body.copyWith(
                                color: MBColors.textSecondary,
                              ),
                            ),
                            MBSpacing.h(MBSpacing.xxxs),
                            Text(
                              'Role: ${invite.role} • Status: ${invite.isExpired && invite.status == 'pending' ? 'expired' : invite.status}',
                              style: MBTextStyles.caption.copyWith(
                                color: MBColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (invite.status == 'pending' &&
                          !invite.isExpired)
                        SizedBox(
                          width: 120,
                          child: MBSecondaryButton(
                            text: 'Revoke',
                            foregroundColor: MBColors.error,
                            borderColor: MBColors.error,
                            onPressed: () {
                              controller.revokeInvite(invite);
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            MBSpacing.h(MBSpacing.xxl),
          ],
        );
      }),
    );
  }
}

class _SearchedUserPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminInviteController>();

    final user = controller.searchedUser.value;
    if (user == null) {
      return Text(
        'Search result will appear here.',
        style: MBTextStyles.body.copyWith(
          color: MBColors.textSecondary,
        ),
      );
    }

    final pendingInvite = controller.searchedUserPendingInvite.value;
    final hasEmail = user.email.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.surface,
        border: Border.all(color: MBColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Name', user.fullName),
          MBSpacing.h(MBSpacing.sm),
          _row('Phone', user.phoneNumber),
          MBSpacing.h(MBSpacing.sm),
          _row('Email', hasEmail ? user.email : 'No email added'),
          MBSpacing.h(MBSpacing.sm),
          _row('Role', user.role),
          MBSpacing.h(MBSpacing.md),
          if (!hasEmail)
            Text(
              'User must update profile email before receiving admin invite.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.warning,
              ),
            )
          else if (pendingInvite != null && !pendingInvite.isExpired)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'A pending invite already exists.',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.primaryOrange,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: MBSecondaryButton(
                    text: 'Revoke',
                    foregroundColor: MBColors.error,
                    borderColor: MBColors.error,
                    onPressed: () {
                      controller.revokeInvite(pendingInvite);
                    },
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: 220,
              child: MBPrimaryButton(
                text: 'Send Admin Invitation',
                isLoading: controller.isSendingInvite.value,
                onPressed: controller.sendInviteToSearchedUser,
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
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












