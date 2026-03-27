import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';

import '../../controllers/admin_invite_controller.dart';


class AdminInviteAcceptDialog extends StatelessWidget {
  const AdminInviteAcceptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminInviteController>();

    return Obx(() {
      final invite = controller.myPendingInvites.isEmpty
          ? null
          : controller.myPendingInvites.first;

      if (invite == null) {
        return const SizedBox.shrink();
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: MBCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 52,
                    color: MBColors.primaryOrange,
                  ),
                  MBSpacing.h(MBSpacing.md),
                  const Text(
                    'Admin Invitation',
                    style: MBTextStyles.sectionTitle,
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  Text(
                    'You have been invited as ${invite.role}.',
                    textAlign: TextAlign.center,
                    style: MBTextStyles.body,
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    'Email: ${invite.email}',
                    textAlign: TextAlign.center,
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: MBSecondaryButton(
                          text: 'Reject',
                          isLoading: controller.isDecisionBusy.value,
                          foregroundColor: MBColors.error,
                          borderColor: MBColors.error,
                          onPressed: () async {
                            await controller.rejectInvite(invite);
                            if (Get.isDialogOpen ?? false) {
                              Get.back();
                            }
                          },
                        ),
                      ),
                      MBSpacing.w(MBSpacing.md),
                      Expanded(
                        child: MBPrimaryButton(
                          text: 'Accept',
                          isLoading: controller.isDecisionBusy.value,
                          onPressed: () async {
                            await controller.acceptInvite(invite);
                            if (Get.isDialogOpen ?? false) {
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
          ),
        ),
      );
    });
  }
}












