import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/features/setup_super_admin/controllers/setup_super_admin_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

class SetupSuperAdminPage extends StatefulWidget {
  const SetupSuperAdminPage({super.key});

  @override
  State<SetupSuperAdminPage> createState() => _SetupSuperAdminPageState();
}

class _SetupSuperAdminPageState extends State<SetupSuperAdminPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final SetupSuperAdminController _setupController;

  @override
  void initState() {
    super.initState();

    _setupController = Get.put(SetupSuperAdminController());

    final User? user = FirebaseAuth.instance.currentUser;
    final PhoneAuthRepository phoneHelper = PhoneAuthRepository();

    final String localPhone = phoneHelper.normalizePhoneInput(
      (user?.phoneNumber ?? '').trim(),
    );

    _fullNameController = TextEditingController(
      text: (user?.displayName ?? '').trim(),
    );

    _phoneController = TextEditingController(
      text: localPhone,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      body: Center(
        child: Container(
          width: 560,
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
                () => Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setup First Super Admin',
                    style: MBTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  Text(
                    'Bootstrap is open. This step can only be completed once.',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  MBTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter full name';
                      }
                      return null;
                    },
                  ),
                  MBSpacing.h(MBSpacing.md),
                  MBTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    enabled: false,
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(MBSpacing.md),
                    decoration: BoxDecoration(
                      color: MBColors.primarySoft,
                      borderRadius: BorderRadius.circular(MBRadius.lg),
                    ),
                    child: Text(
                      'The currently verified phone number will become the first super admin account.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: MBPrimaryButton(
                      text: 'Create Super Admin',
                      isLoading: _setupController.isSubmitting.value,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _setupController.createFirstSuperAdmin(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      Get.offAllNamed(AdminWebRoutes.dashboard);
    } catch (_) {
      // Controller already shows notification.
    }
  }
}