import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_ui/shared_ui.dart';

class AccountBlockedPage extends StatelessWidget {
  const AccountBlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MBSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block_rounded,
                size: 72,
                color: MBColors.error,
              ),
              const SizedBox(height: MBSpacing.lg),
              Text(
                'Account Restricted',
                style: MBTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MBSpacing.md),
              Text(
                'Your customer account is currently blocked or inactive. Please contact support.',
                style: MBTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MBSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService.signOut();
                    Get.offAllNamed('/welcome');
                  },
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}