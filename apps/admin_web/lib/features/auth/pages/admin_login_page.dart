import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../../app/routes/admin_web_routes.dart';
import '../controllers/admin_auth_controller.dart';
import '../widgets/admin_auth_shell.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AdminAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AdminAuthController());
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminAuthShell(
      title: 'Admin Login',
      subtitle: 'Sign in to access the MuthoBazar admin workspace.',
      child: Obx(
            () => Form(
          key: _formKey,
          child: Column(
            children: [
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
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter your password';
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
              MBSpacing.h(MBSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: MBPrimaryButton(
                  text: 'Login',
                  isLoading: _controller.isLoginLoading.value,
                  onPressed: _submit,
                ),
              ),
              MBSpacing.h(MBSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => Get.toNamed(AdminWebRoutes.register),
                  child: const Text('Create admin account'),
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

    await _controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }
}