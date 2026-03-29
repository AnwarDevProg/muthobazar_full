import 'package:admin_web/features/users/controllers/admin_user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/customer/mb_user_profile.dart';
import 'package:shared_ui/shared_ui.dart';
import '../../admin_access/controllers/admin_access_controller.dart';

class AdminUserFormDialog extends StatefulWidget {
  const AdminUserFormDialog({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<AdminUserFormDialog> createState() => _AdminUserFormDialogState();
}

class _AdminUserFormDialogState extends State<AdminUserFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _genderController;
  late final TextEditingController _dobController;

  late String _role;
  late String _accountStatus;
  late bool _isGuest;

  late final AdminUserController _controller;
  late final AdminAccessController _accessController;

  @override
  void initState() {
    super.initState();

    _controller = Get.find<AdminUserController>();
    _accessController = Get.find<AdminAccessController>();

    final UserModel normalized = UserModel.normalized(widget.user);

    _firstNameController = TextEditingController(text: normalized.firstName);
    _lastNameController = TextEditingController(text: normalized.lastName);
    _emailController = TextEditingController(text: normalized.email);
    _phoneController = TextEditingController(text: normalized.phoneNumber);
    _genderController = TextEditingController(text: normalized.gender);
    _dobController = TextEditingController(text: normalized.dateOfBirth);

    _role = normalized.role;
    _accountStatus = normalized.accountStatus;
    _isGuest = normalized.isGuest;
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
    final bool canAssignAdminRoles = _accessController.isSuperAdmin;

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
              MBSpacing.h(MBSpacing.xxs),
              Text(
                'Update user profile details, role, and account status.',
                style: MBTextStyles.body.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
              MBSpacing.h(MBSpacing.lg),
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
                                validator: (value) {
                                  final email = (value ?? '').trim();
                                  if (email.isEmpty) return null;

                                  final isValid = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(email);

                                  if (!isValid) {
                                    return 'Enter a valid email';
                                  }

                                  return null;
                                },
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
                                items: [
                                  const DropdownMenuItem(
                                    value: UserRoles.customer,
                                    child: Text('Customer'),
                                  ),
                                  if (canAssignAdminRoles)
                                    const DropdownMenuItem(
                                      value: UserRoles.admin,
                                      child: Text('Admin'),
                                    ),
                                  if (canAssignAdminRoles)
                                    const DropdownMenuItem(
                                      value: UserRoles.superAdmin,
                                      child: Text('Super Admin'),
                                    ),
                                  const DropdownMenuItem(
                                    value: UserRoles.guest,
                                    child: Text('Guest'),
                                  ),
                                ],
                                onChanged: _controller.isSaving.value
                                    ? null
                                    : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _role = value;
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
                                    value: UserStatuses.active,
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: UserStatuses.inactive,
                                    child: Text('Inactive'),
                                  ),
                                  DropdownMenuItem(
                                    value: UserStatuses.blocked,
                                    child: Text('Blocked'),
                                  ),
                                  DropdownMenuItem(
                                    value: UserStatuses.guest,
                                    child: Text('Guest'),
                                  ),
                                ],
                                onChanged: _controller.isSaving.value
                                    ? null
                                    : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _accountStatus = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        SwitchListTile(
                          value: _isGuest,
                          onChanged: _controller.isSaving.value
                              ? null
                              : (value) {
                            setState(() {
                              _isGuest = value;
                              if (_isGuest) {
                                _role = UserRoles.guest;
                                _accountStatus = UserStatuses.guest;
                              }
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
                      isLoading: _controller.isSaving.value,
                      onPressed:
                      _controller.isSaving.value ? null : () => Get.back(),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: MBPrimaryButton(
                      text: 'Update User',
                      isLoading: _controller.isSaving.value,
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

    final updated = widget.user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gender: _genderController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      role: UserModel.normalizeRole(_role),
      accountStatus: UserModel.normalizeStatus(_accountStatus),
      isGuest: _isGuest,
    );

    await _controller.updateUser(updated);

    if (mounted && !_controller.isSaving.value) {
      Get.back();
    }
  }
}