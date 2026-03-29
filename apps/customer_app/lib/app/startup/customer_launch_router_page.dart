import 'dart:async';

import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:customer_app/app/startup/customer_auth_redirect_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_ui/shared_ui.dart';

class AppLaunchRouterPage extends StatefulWidget {
  const AppLaunchRouterPage({super.key});

  @override
  State<AppLaunchRouterPage> createState() => _AppLaunchRouterPageState();
}

class _AppLaunchRouterPageState extends State<AppLaunchRouterPage> {
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();
    _routeApp();
  }

  Future<void> _routeApp() async {
    if (_isRouting) return;
    _isRouting = true;

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final bool requiresUpdate = await UpdateService.checkForUpdate()
          .timeout(const Duration(seconds: 6), onTimeout: () => false);

      if (!mounted) return;

      if (requiresUpdate) {
        Get.offAllNamed(AppRoutes.forceUpdate);
        return;
      }

      final bool isFirstRun = StorageService.isFirstRun;
      if (isFirstRun) {
        Get.offAllNamed(AppRoutes.onboarding);
        return;
      }

      final CustomerAuthRedirectService authUserRedirect =
      CustomerAuthRedirectService();

      await authUserRedirect.screenRedirect();
    } catch (e, st) {
      debugPrint('AppLaunchRouterPage._routeApp error: $e');
      debugPrint('$st');

      if (!mounted) return;
      Get.offAllNamed(AppRoutes.welcome);
    } finally {
      _isRouting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: MBGradients.headerGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(MBSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: MBSpacing.xl),
                Text(
                  'MuthoBazar',
                  style: MBTextStyles.hero.copyWith(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: MBSpacing.sm),
                Text(
                  'Smart shopping, simplified.',
                  style: MBTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const Spacer(),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: MBSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}