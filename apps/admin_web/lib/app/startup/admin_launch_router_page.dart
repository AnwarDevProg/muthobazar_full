import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import 'admin_startup_redirect_controller.dart';

class AdminLaunchRouterPage extends StatelessWidget {
  const AdminLaunchRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminStartupRedirectController controller =
    Get.put<AdminStartupRedirectController>(
      AdminStartupRedirectController(),
    );

    return Scaffold(
      backgroundColor: MBColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(MBSpacing.xl),
            child: Container(
              padding: const EdgeInsets.all(MBSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MBRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: MBColors.shadow.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Obx(
                    () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    MBSpacing.h(MBSpacing.lg),
                    Text(
                      'Launching admin panel...',
                      style: MBTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    MBSpacing.h(MBSpacing.xs),
                    Text(
                      controller.statusText.value,
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}