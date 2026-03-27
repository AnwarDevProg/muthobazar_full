import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/widgets/dialogs/mb_dialogs.dart';

import '../controllers/register_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;

    _controller = RegisterController(
      isSuperAdminRegistration: args?['isSuperAdmin'] == true,
      requestedRole: (args?['role'] ?? 'customer').toString(),
      bootstrapSuperAdmin: args?['bootstrapSuperAdmin'] == true,
    )..initialize();

    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(String title, String message) async {
    await MBDialogs.showInfo(
      context: context,
      title: title,
      message: message,
      buttonText: 'OK',
      type: MBDialogType.warning,
      icon: Icons.error_outline_rounded,
    );
  }

  Future<void> _showAlreadyRegisteredDialog() async {
    final shouldLogin = await MBDialogs.showConfirm(
      context: context,
      title: 'Already Registered',
      message: 'This number is already registered. Please login instead.',
      confirmText: 'Login',
      cancelText: 'Back',
      type: MBDialogType.info,
      icon: Icons.verified_user_outlined,
      barrierDismissible: false,
    );

    if (shouldLogin == true) {
      Get.toNamed(AppRoutes.login);
    }
  }

  Future<void> _showSuccessDialog() async {
    await MBDialogs.showInfo(
      context: context,
      title: 'Success',
      message: _controller.isSuperAdminRegistration
          ? 'Super admin account created successfully!'
          : 'Account created successfully!',
      buttonText: 'Continue',
      type: MBDialogType.success,
      icon: Icons.check_circle_outline_rounded,
    );

    await _controller.continueAfterSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: _controller.isSuperAdminRegistration
          ? 'Create Super Admin'
          : 'Create Account',
      subtitle: _controller.isSuperAdminRegistration
          ? 'Admin Setup • Secure • Controlled'
          : 'Fast • Secure • Trusted',
      showGuestButton: false,
      child: RegisterForm(
        controller: _controller,
        onAlreadyRegisteredDialog: _showAlreadyRegisteredDialog,
        onShowErrorDialog: _showErrorDialog,
        onShowSuccessDialog: _showSuccessDialog,
      ),
    );
  }
}