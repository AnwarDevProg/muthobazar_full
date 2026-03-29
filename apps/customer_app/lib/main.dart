import 'package:customer_app/app/bindings/customer_app_binding.dart';
import 'package:customer_app/app/routes/customer_app_pages.dart';
import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:customer_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_ui/shared_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await AppInitializer.initialize();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  runApp(const MuthoBazarCustomerApp());
}

class MuthoBazarCustomerApp extends StatelessWidget {
  const MuthoBazarCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MuthoBazar',
      debugShowCheckedModeBanner: false,
      theme: MBTheme.theme,
      darkTheme: MBTheme.theme,
      themeMode: ThemeMode.light,
      scrollBehavior: const MBScrollBehavior(),
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.appLaunchRoute,
      getPages: AppPages.routes,
      builder: (context, child) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}