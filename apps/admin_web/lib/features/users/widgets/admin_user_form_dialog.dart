import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../../models/user_model.dart';
import '../../controllers/admin_user_controller.dart';

class AdminUserFormDialog extends StatefulWidget {
  final UserModel user;

  const AdminUserFormDialog({
    super.key,
    required this.user,
  });

  @override
  State<AdminUserFormDialog> createState() => _AdminUserFormDialogState();
}

class _AdminUserFormDialogState extends State<AdminUserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _genderController;
  late final TextEditingController _dobController;

  late String _role;
  late String _accountStatus;
  late bool _isGuest;

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.user.firstName);
    _lastNameController =
        TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _genderController = TextEditingController(text: widget.user.gender);
    _dobController = TextEditingController(text: widget.user.dateOfBirth);

    _role = widget.user.role;
    _accountStatus = widget.user.accountStatus;
    _isGuest = widget.user.isGuest;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminUserController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(MBSpacing.xl),
        child: Obx(
              () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit User',
                style: MBTextStyles.sectionTitle,
              ),
              MBSpacing.h(MBSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _firstNameController,
                                labelText: 'First Name',
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'Enter first name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _lastNameController,
                                labelText: 'Last Name',
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _phoneController,
                                labelText: 'Phone Number',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _genderController,
                                labelText: 'Gender',
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _dobController,
                                labelText: 'Date of Birth',
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _role,
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'customer',
                                    child: Text('Customer'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'admin',
                                    child: Text('Admin'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'super_admin',
                                    child: Text('Super Admin'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'guest',
                                    child: Text('Guest'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _role = value ?? 'customer';
                                  });
                                },
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _accountStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Account Status',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'inactive',
                                    child: Text('Inactive'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'blocked',
                                    child: Text('Blocked'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'guest',
                                    child: Text('Guest'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _accountStatus = value ?? 'active';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        SwitchListTile(
                          value: _isGuest,
                          onChanged: (value) {
                            setState(() {
                              _isGuest = value;
                            });
                          },
                          title: const Text('Is Guest'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MBSpacing.h(MBSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: MBSecondaryButton(
                      text: 'Cancel',
                      isLoading: controller.isSaving.value,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: MBPrimaryButton(
                      text: 'Update User',
                      isLoading: controller.isSaving.value,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<AdminUserController>();

    final updated = widget.user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gender: _genderController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      role: _role,
      accountStatus: _accountStatus,
      isGuest: _isGuest,
    );

    await controller.updateUser(updatedUser: updated);

    if (mounted) {
      Get.back();
    }
  }
}












