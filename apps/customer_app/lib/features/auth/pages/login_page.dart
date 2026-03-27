import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/widgets/dialogs/mb_dialogs.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController()..initialize();
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

  Future<void> _showSignupDialog() async {
    final shouldRegister = await MBDialogs.showConfirm(
      context: context,
      title: 'New User',
      message:
      'This number is not registered yet. Would you like to create an account?',
      confirmText: 'Register',
      cancelText: 'Back',
      type: MBDialogType.info,
      icon: Icons.person_add_alt_1_rounded,
      barrierDismissible: false,
    );

    if (shouldRegister == true) {
      Get.toNamed(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Login to MuthoBazar',
      subtitle: 'Fast • Secure • Trusted',
      showGuestButton: true,
      child: LoginForm(
        controller: _controller,
        onShowSignupDialog: _showSignupDialog,
        onShowErrorDialog: _showErrorDialog,
      ),
    );
  }
}