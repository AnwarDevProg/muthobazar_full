import 'package:admin_web/app/bindings/admin_web_binding.dart';
import 'package:admin_web/app/routes/admin_web_pages.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MuthoBazar Admin',
      debugShowCheckedModeBanner: false,
      theme: MBTheme.theme,
      darkTheme: MBTheme.theme,
      themeMode: ThemeMode.light,
      initialBinding: AdminWebBinding(),
      initialRoute: AdminWebRoutes.launch,
      getPages: AdminWebPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 180),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: MBColors.background,
          body: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}