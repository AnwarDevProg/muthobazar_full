import 'package:customer_app/app/bindings/address_binding.dart';
import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:customer_app/app/shell/customer_app_shell.dart';
import 'package:customer_app/app/startup/customer_launch_router_page.dart';
import 'package:customer_app/app/startup/force_update_page.dart';
import 'package:customer_app/app/startup/onboarding_page.dart';
import 'package:customer_app/features/address/pages/address_form_page.dart';
import 'package:customer_app/features/address/pages/addresses_page.dart';
import 'package:customer_app/features/auth/pages/login_page.dart';
import 'package:customer_app/features/auth/pages/register_page.dart';
import 'package:customer_app/features/auth/pages/welcome_page.dart';
import 'package:customer_app/features/checkout/pages/checkout_page.dart';
import 'package:customer_app/features/orders/pages/my_orders_page.dart';
import 'package:customer_app/features/orders/pages/order_details_page.dart';
import 'package:customer_app/features/profile/pages/app_settings_page.dart';
import 'package:customer_app/features/profile/pages/delete_account_verify_page.dart';
import 'package:customer_app/features/profile/pages/edit_profile_page.dart';
import 'package:customer_app/features/profile/pages/help_center_page.dart';
import 'package:customer_app/features/profile/pages/my_coupons_page.dart';
import 'package:customer_app/features/profile/pages/update_phone_page.dart';
import 'package:customer_app/features/wishlist/pages/wishlist_page.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const AppLaunchRouterPage(),
    ),
    GetPage(
      name: AppRoutes.forceUpdate,
      page: () => const ForceUpdatePage(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const CustomerAppShell(),
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressesPage(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: AppRoutes.addAddress,
      page: () => const AddressFormPage(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: AppRoutes.editAddress,
      page: () => AddressFormPage(address: Get.arguments),
      binding: AddressBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
    ),
    GetPage(
      name: AppRoutes.updatePhone,
      page: () => const UpdatePhonePage(),
    ),
    GetPage(
      name: AppRoutes.deleteAccountVerify,
      page: () => const DeleteAccountVerifyPage(),
    ),
    GetPage(
      name: AppRoutes.myOrders,
      page: () => const MyOrdersPage(),
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const OrderDetailsPage(),
    ),
    GetPage(
      name: AppRoutes.myCoupons,
      page: () => const MyCouponsPage(),
    ),
    GetPage(
      name: AppRoutes.appSettings,
      page: () => const AppSettingsPage(),
    ),
    GetPage(
      name: AppRoutes.helpCenter,
      page: () => const HelpCenterPage(),
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistPage(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () {
        final mode = (Get.arguments ?? 'all').toString();
        return CheckoutPage(checkoutMode: mode);
      },
    ),
  ];
}


