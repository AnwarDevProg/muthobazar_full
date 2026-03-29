import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../app/routes/admin_web_routes.dart';
import '../controllers/admin_auth_controller.dart';
import '../widgets/admin_auth_shell.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final AdminAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AdminAuthController());
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminAuthShell(
      title: 'Admin Register',
      subtitle:
      'Create an admin account. Access will still require permission assignment.',
      child: Obx(
            () => Form(
          key: _formKey,
          child: Column(
            children: [
              MBTextField(
                controller: _fullNameController,
                labelText: 'Full Name',
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter your full name';
                  }
                  return null;
                },
              ),
              MBSpacing.h(MBSpacing.md),
              MBTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter your email';
                  }
                  return null;
                },
              ),
              MBSpacing.h(MBSpacing.md),
              MBTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: _controller.obscurePassword.value,
                validator: (value) {
                  if ((value ?? '').trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  onPressed: _controller.togglePasswordVisibility,
                  icon: Icon(
                    _controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              MBSpacing.h(MBSpacing.md),
              MBTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                obscureText: _controller.obscureConfirmPassword.value,
                validator: (value) {
                  if ((value ?? '').trim() != _passwordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  onPressed: _controller.toggleConfirmPasswordVisibility,
                  icon: Icon(
                    _controller.obscureConfirmPassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
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
                  'Important: Registration creates only the authentication account. Admin panel access is granted separately through admin permissions.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              ),
              MBSpacing.h(MBSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: MBPrimaryButton(
                  text: 'Register',
                  isLoading: _controller.isRegisterLoading.value,
                  onPressed: _submit,
                ),
              ),
              MBSpacing.h(MBSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => Get.offNamed(AdminWebRoutes.login),
                  child: const Text('Already have an account? Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await _controller.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }
}