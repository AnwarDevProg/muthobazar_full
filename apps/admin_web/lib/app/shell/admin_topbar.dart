import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../features/profile/controllers/admin_profile_controller.dart';

class AdminTopbar extends StatelessWidget {
  const AdminTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminProfileController profileController =
    Get.find<AdminProfileController>();

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: MBSpacing.xl),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: MBColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            'MuthoBazar Admin',
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Obx(() {
            final user = profileController.currentUser.value;
            final name = profileController.fullName;
            final role = user?.prettyRole ?? 'Admin';
            final initials = user?.initials ?? 'A';

            return InkWell(
              onTap: () => Get.toNamed(AdminWebRoutes.profile),
              borderRadius: BorderRadius.circular(MBRadius.lg),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MBSpacing.md,
                  vertical: MBSpacing.sm,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MBRadius.lg),
                  border: Border.all(color: MBColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                      MBColors.primaryOrange.withValues(alpha: 0.10),
                      backgroundImage: user?.profilePicture.trim().isNotEmpty ==
                          true
                          ? NetworkImage(user!.profilePicture)
                          : null,
                      child: user?.profilePicture.trim().isEmpty != false
                          ? Text(
                        initials,
                        style: MBTextStyles.caption.copyWith(
                          color: MBColors.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                          : null,
                    ),
                    MBSpacing.w(MBSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: MBTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          role,
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}