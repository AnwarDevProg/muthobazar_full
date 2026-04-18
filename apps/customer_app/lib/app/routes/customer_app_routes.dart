class AppRoutes {
  AppRoutes._();

  static const appLaunchRoute = '/';
  static const forceUpdate = '/force-update';

  static const String accountBlocked = '/account-blocked';
  static const String completeProfile = '/complete-profile';

  static const onboarding = '/onboarding';
  static const shell = '/shell';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';

  static const addresses = '/addresses';
  static const addAddress = '/address-add';
  static const editAddress = '/address-edit';

  static const editProfile = '/profile/edit';
  static const updatePhone = '/profile/update-phone';
  static const deleteAccountVerify = '/profile/delete-account-verify';
  static const myOrders = '/profile/my-orders';
  static const myCoupons = '/profile/my-coupons';
  static const appSettings = '/profile/app-settings';
  static const helpCenter = '/profile/help-center';
  static const wishlist = '/profile/wishlist';

  static const orderDetails = '/order-details';
  static const checkout = '/checkout';

  // Product
  static const productDetails = '/product-details';
}