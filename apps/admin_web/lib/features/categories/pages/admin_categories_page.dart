import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:admin_web/features/categories/controllers/admin_category_controller.dart';
import 'package:admin_web/features/categories/widgets/admin_category_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCategoryController>();

    return AdminWebShell(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(MBSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MBSpacing.lg),
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(MBRadius.lg),
                border: Border.all(
                  color: MBColors.primaryOrange.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                'Categories module is active.',
                style: MBTextStyles.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: MBColors.primaryOrange,
                ),
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MBSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MBRadius.xl),
                border: Border.all(
                  color: MBColors.border.withValues(alpha: 0.90),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MBColors.shadow.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Category Management',
                          style: MBTextStyles.sectionTitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.dialog(
                            const AdminCategoryFormDialog(),
                            barrierDismissible: false,
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Category'),
                      ),
                      MBSpacing.w(MBSpacing.md),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await controller.loadCategories();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  Text(
                    'Create and edit are active. Live reactive list is paused for now.',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Text(
                    'Controller status',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text('isLoading: ${controller.isLoading.value}'),
                  MBSpacing.h(MBSpacing.xs),
                  Text('categories length: ${controller.categories.length}'),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    'filteredCategories length: ${controller.filteredCategories.length}',
                  ),
                  if (controller.loadError.value.trim().isNotEmpty) ...[
                    MBSpacing.h(MBSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(MBSpacing.md),
                      decoration: BoxDecoration(
                        color: MBColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(MBRadius.lg),
                        border: Border.all(
                          color: MBColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: SelectableText(
                        controller.loadError.value,
                        style: MBTextStyles.body.copyWith(
                          color: MBColors.error,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MBColors.background,
                  borderRadius: BorderRadius.circular(MBRadius.xl),
                  border: Border.all(
                    color: MBColors.border.withValues(alpha: 0.90),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Categories list area will be reconnected after create/edit is verified.',
                    textAlign: TextAlign.center,
                    style: MBTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MBColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}