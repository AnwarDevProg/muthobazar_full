import 'package:flutter/material.dart';

class AdminWebRoutes {
  AdminWebRoutes._();

  // Startup / Auth
  static const String launch = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String setupSuperAdmin = '/setup-super-admin';

  // Overview
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';

  // Catalog
  static const String categories = '/categories';
  static const String brands = '/brands';
  static const String products = '/products';
  static const String quarantineProducts = '/products/quarantine';
  static const String banners = '/banners';

  // Marketing
  static const String offers = '/offers';
  static const String homeSections = '/home-sections';
  static const String promos = '/promos';

  // Administration
  static const String users = '/users';
  static const String admins = '/admins';
  static const String stuffs = '/stuffs';
  static const String auditLogs = '/audit-logs';
  static const String adminAccess = '/admin-access';
  static const String invites = '/invites';

  // Orders
  static const String orders = '/orders';
  static const String manualOrders = '/orders/manual';
  static const String picking = '/orders/picking';
  static const String packing = '/orders/packing';
  static const String substitutions = '/orders/substitutions';
  static const String refunds = '/orders/refunds';
  static const String returns = '/orders/returns';

  // Inventory & Procurement
  static const String inventory = '/inventory';
  static const String stockLedger = '/inventory/stock-ledger';
  static const String purchaseReceiving = '/inventory/purchase-receiving';
  static const String purchases = '/purchases';
  static const String suppliers = '/suppliers';

  // Finance
  static const String finance = '/finance';
  static const String expenses = '/expenses';
  static const String dailyClosing = '/finance/daily-closing';
  static const String deliverySettlements = '/finance/delivery-settlements';

  // Delivery
  static const String delivery = '/delivery';
  static const String riders = '/delivery/riders';
  static const String zones = '/delivery/zones';
  static const String slotsCapacity = '/delivery/slots-capacity';
  static const String deliveryComplaints = '/delivery/complaints';

  // Services
  static const String services = '/services';
  static const String serviceCategories = '/services/categories';
  static const String technicians = '/services/technicians';
  static const String serviceComplaints = '/services/complaints';

  // Customers
  static const String customers = '/customers';
  static const String customerSegments = '/customers/segments';
  static const String customerComplaints = '/customers/complaints';

  // Reporting & Config
  static const String reports = '/reports';
  static const String settings = '/settings';
}

class AdminSidebarGroups {
  AdminSidebarGroups._();

  static const String overview = 'Overview';
  static const String catalog = 'Catalog';
  static const String marketing = 'Marketing';
  static const String administration = 'Administration';
  static const String orders = 'Orders';
  static const String inventoryProcurement = 'Inventory & Procurement';
  static const String finance = 'Finance';
  static const String delivery = 'Delivery';
  static const String services = 'Services';
  static const String customers = 'Customers';
  static const String reportingConfig = 'Reporting & Config';

  static const List<String> ordered = <String>[
    overview,
    catalog,
    marketing,
    administration,
    orders,
    inventoryProcurement,
    finance,
    delivery,
    services,
    customers,
    reportingConfig,
  ];
}

class AdminPermissionKeys {
  AdminPermissionKeys._();

  static const String accessAdminPanel = 'accessAdminPanel';

  // Overview
  static const String viewDashboard = 'viewDashboard';
  static const String viewProfile = 'viewProfile';

  // Catalog
  static const String manageCategories = 'manageCategories';
  static const String manageBrands = 'manageBrands';
  static const String manageProducts = 'manageProducts';
  static const String restoreProducts = 'restoreProducts';
  static const String manageBanners = 'manageBanners';
  static const String deleteProducts = 'deleteProducts';

  // Marketing
  static const String manageOffers = 'manageOffers';
  static const String manageHomeSections = 'manageHomeSections';
  static const String managePromos = 'managePromos';
  static const String manageCoupons = 'manageCoupons';

  // Administration
  static const String manageUsers = 'manageUsers';
  static const String manageAdmins = 'manageAdmins';
  static const String manageStuffs = 'manageStuffs';
  static const String viewActivityLogs = 'viewActivityLogs';
  static const String manageAdminPermissions = 'manageAdminPermissions';
  static const String manageAdminInvites = 'manageAdminInvites';

  // Orders
  static const String manageOrders = 'manageOrders';
  static const String manageManualOrders = 'manageManualOrders';
  static const String managePicking = 'managePicking';
  static const String managePacking = 'managePacking';
  static const String manageSubstitutions = 'manageSubstitutions';
  static const String manageRefunds = 'manageRefunds';
  static const String manageReturns = 'manageReturns';

  // Inventory & Procurement
  static const String manageInventory = 'manageInventory';
  static const String viewStockLedger = 'viewStockLedger';
  static const String managePurchaseReceiving = 'managePurchaseReceiving';
  static const String managePurchases = 'managePurchases';
  static const String manageSuppliers = 'manageSuppliers';

  // Finance
  static const String manageFinance = 'manageFinance';
  static const String manageExpenses = 'manageExpenses';
  static const String manageDailyClosing = 'manageDailyClosing';
  static const String manageDeliverySettlements = 'manageDeliverySettlements';

  // Delivery
  static const String manageDelivery = 'manageDelivery';
  static const String manageRiders = 'manageRiders';
  static const String manageZones = 'manageZones';
  static const String manageSlotsCapacity = 'manageSlotsCapacity';
  static const String manageDeliveryComplaints = 'manageDeliveryComplaints';

  // Services
  static const String manageServices = 'manageServices';
  static const String manageServiceCategories = 'manageServiceCategories';
  static const String manageTechnicians = 'manageTechnicians';
  static const String manageServiceComplaints = 'manageServiceComplaints';

  // Customers
  static const String viewCustomers = 'viewCustomers';
  static const String manageCustomerSegments = 'manageCustomerSegments';
  static const String manageCustomerComplaints = 'manageCustomerComplaints';

  // Reporting & Config
  static const String viewReports = 'viewReports';
  static const String manageSettings = 'manageSettings';
}

class AdminRouteMeta {
  const AdminRouteMeta({
    required this.route,
    required this.title,
    required this.sidebarGroup,
    required this.icon,
    required this.breadcrumbs,
    this.permissionKey,
    this.showInSidebar = true,
    this.isGroupLanding = false,
    this.description = '',
    this.commandKeywords = const <String>[],
  });

  final String route;
  final String title;
  final String sidebarGroup;
  final IconData icon;
  final List<String> breadcrumbs;
  final String? permissionKey;
  final bool showInSidebar;
  final bool isGroupLanding;
  final String description;
  final List<String> commandKeywords;

  bool matchesRoute(String currentRoute) {
    return currentRoute == route || currentRoute.startsWith('$route/');
  }
}

class AdminRouteRegistry {
  AdminRouteRegistry._();

  static const List<AdminRouteMeta> all = <AdminRouteMeta>[
    // Startup / Auth
    AdminRouteMeta(
      route: AdminWebRoutes.launch,
      title: 'Launch',
      sidebarGroup: '',
      icon: Icons.rocket_launch_outlined,
      breadcrumbs: <String>['Launch'],
      showInSidebar: false,
      description: 'Admin app launch router.',
      commandKeywords: <String>['launch', 'startup'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.login,
      title: 'Login',
      sidebarGroup: '',
      icon: Icons.login_rounded,
      breadcrumbs: <String>['Login'],
      showInSidebar: false,
      description: 'Admin login page.',
      commandKeywords: <String>['login', 'signin', 'auth'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.register,
      title: 'Register',
      sidebarGroup: '',
      icon: Icons.app_registration_rounded,
      breadcrumbs: <String>['Register'],
      showInSidebar: false,
      description: 'Admin register page.',
      commandKeywords: <String>['register', 'signup'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.setupSuperAdmin,
      title: 'Setup Super Admin',
      sidebarGroup: '',
      icon: Icons.admin_panel_settings_outlined,
      breadcrumbs: <String>['Setup Super Admin'],
      showInSidebar: false,
      description: 'Initial super admin setup page.',
      commandKeywords: <String>['setup', 'super admin', 'bootstrap'],
    ),

    // Overview
    AdminRouteMeta(
      route: AdminWebRoutes.dashboard,
      title: 'Dashboard',
      sidebarGroup: AdminSidebarGroups.overview,
      icon: Icons.dashboard_outlined,
      breadcrumbs: <String>['Overview', 'Dashboard'],
      permissionKey: AdminPermissionKeys.viewDashboard,
      description: 'Admin dashboard overview.',
      commandKeywords: <String>['dashboard', 'overview', 'home'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.profile,
      title: 'Profile',
      sidebarGroup: AdminSidebarGroups.overview,
      icon: Icons.person_outline_rounded,
      breadcrumbs: <String>['Overview', 'Profile'],
      permissionKey: AdminPermissionKeys.viewProfile,
      description: 'Current admin profile.',
      commandKeywords: <String>['profile', 'account', 'me'],
    ),

    // Catalog
    AdminRouteMeta(
      route: AdminWebRoutes.categories,
      title: 'Categories',
      sidebarGroup: AdminSidebarGroups.catalog,
      icon: Icons.category_outlined,
      breadcrumbs: <String>['Catalog', 'Categories'],
      permissionKey: AdminPermissionKeys.manageCategories,
      description: 'Manage categories.',
      commandKeywords: <String>['categories', 'catalog'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.brands,
      title: 'Brands',
      sidebarGroup: AdminSidebarGroups.catalog,
      icon: Icons.store_outlined,
      breadcrumbs: <String>['Catalog', 'Brands'],
      permissionKey: AdminPermissionKeys.manageBrands,
      description: 'Manage brands.',
      commandKeywords: <String>['brands'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.products,
      title: 'Products',
      sidebarGroup: AdminSidebarGroups.catalog,
      icon: Icons.inventory_2_outlined,
      breadcrumbs: <String>['Catalog', 'Products'],
      permissionKey: AdminPermissionKeys.manageProducts,
      description: 'Manage products.',
      commandKeywords: <String>['products', 'items'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.quarantineProducts,
      title: 'Quarantine Products',
      sidebarGroup: AdminSidebarGroups.catalog,
      icon: Icons.restore_from_trash_outlined,
      breadcrumbs: <String>['Catalog', 'Quarantine Products'],
      permissionKey: AdminPermissionKeys.restoreProducts,
      description: 'Review quarantined products.',
      commandKeywords: <String>['quarantine', 'deleted products', 'restore'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.banners,
      title: 'Banners',
      sidebarGroup: AdminSidebarGroups.catalog,
      icon: Icons.image_outlined,
      breadcrumbs: <String>['Catalog', 'Banners'],
      permissionKey: AdminPermissionKeys.manageBanners,
      description: 'Manage banners.',
      commandKeywords: <String>['banners', 'hero images'],
    ),

    // Marketing
    AdminRouteMeta(
      route: AdminWebRoutes.offers,
      title: 'Offers',
      sidebarGroup: AdminSidebarGroups.marketing,
      icon: Icons.local_offer_outlined,
      breadcrumbs: <String>['Marketing', 'Offers'],
      permissionKey: AdminPermissionKeys.manageOffers,
      description: 'Manage offers.',
      commandKeywords: <String>['offers', 'discount offers'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.homeSections,
      title: 'Home Sections',
      sidebarGroup: AdminSidebarGroups.marketing,
      icon: Icons.view_quilt_outlined,
      breadcrumbs: <String>['Marketing', 'Home Sections'],
      permissionKey: AdminPermissionKeys.manageHomeSections,
      description: 'Manage homepage section layout and content rules.',
      commandKeywords: <String>['home sections', 'homepage', 'home cms', 'landing sections'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.promos,
      title: 'Promos / Coupons',
      sidebarGroup: AdminSidebarGroups.marketing,
      icon: Icons.confirmation_number_outlined,
      breadcrumbs: <String>['Marketing', 'Promos / Coupons'],
      permissionKey: AdminPermissionKeys.managePromos,
      description: 'Manage promos and coupons.',
      commandKeywords: <String>['promos', 'coupons', 'promo codes'],
    ),

    // Administration
    AdminRouteMeta(
      route: AdminWebRoutes.users,
      title: 'Users',
      sidebarGroup: AdminSidebarGroups.administration,
      icon: Icons.people_alt_outlined,
      breadcrumbs: <String>['Administration', 'Users'],
      permissionKey: AdminPermissionKeys.manageUsers,
      description: 'Manage customer users only.',
      commandKeywords: <String>['users', 'customers users'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.admins,
      title: 'Admins',
      sidebarGroup: AdminSidebarGroups.administration,
      icon: Icons.admin_panel_settings_outlined,
      breadcrumbs: <String>['Administration', 'Admins'],
      permissionKey: AdminPermissionKeys.manageAdmins,
      description: 'Manage admin accounts.',
      commandKeywords: <String>['admins', 'admin accounts'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.stuffs,
      title: 'Stuffs',
      sidebarGroup: AdminSidebarGroups.administration,
      icon: Icons.badge_outlined,
      breadcrumbs: <String>['Administration', 'Stuffs'],
      permissionKey: AdminPermissionKeys.manageStuffs,
      description: 'Manage stuffs accounts.',
      commandKeywords: <String>['stuffs', 'staff', 'employees'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.auditLogs,
      title: 'Audit Logs',
      sidebarGroup: AdminSidebarGroups.administration,
      icon: Icons.history_rounded,
      breadcrumbs: <String>['Administration', 'Audit Logs'],
      permissionKey: AdminPermissionKeys.viewActivityLogs,
      description: 'View activity and audit logs.',
      commandKeywords: <String>['audit logs', 'activity logs', 'history'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.adminAccess,
      title: 'Admin Permissions',
      sidebarGroup: AdminSidebarGroups.administration,
      icon: Icons.shield_outlined,
      breadcrumbs: <String>['Administration', 'Admin Permissions'],
      permissionKey: AdminPermissionKeys.manageAdminPermissions,
      description: 'Create, edit, and delete admin permissions.',
      commandKeywords: <String>['permissions', 'admin access', 'roles'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.invites,
      title: 'Invites',
      sidebarGroup: AdminSidebarGroups.administration,
      icon: Icons.mail_outline_rounded,
      breadcrumbs: <String>['Administration', 'Invites'],
      permissionKey: AdminPermissionKeys.manageAdminInvites,
      description: 'Manage invites.',
      commandKeywords: <String>['invites', 'admin invites'],
    ),

    // Orders
    AdminRouteMeta(
      route: AdminWebRoutes.orders,
      title: 'Orders',
      sidebarGroup: AdminSidebarGroups.orders,
      icon: Icons.receipt_long_outlined,
      breadcrumbs: <String>['Orders', 'Orders'],
      permissionKey: AdminPermissionKeys.manageOrders,
      description: 'Manage all orders.',
      commandKeywords: <String>['orders'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.manualOrders,
      title: 'Manual Orders',
      sidebarGroup: AdminSidebarGroups.orders,
      icon: Icons.edit_note_outlined,
      breadcrumbs: <String>['Orders', 'Manual Orders'],
      permissionKey: AdminPermissionKeys.manageManualOrders,
      description: 'Manage manual orders.',
      commandKeywords: <String>['manual orders'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.picking,
      title: 'Picking',
      sidebarGroup: AdminSidebarGroups.orders,
      icon: Icons.playlist_add_check_circle_outlined,
      breadcrumbs: <String>['Orders', 'Picking'],
      permissionKey: AdminPermissionKeys.managePicking,
      description: 'Manage picking workflow.',
      commandKeywords: <String>['picking'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.packing,
      title: 'Packing',
      sidebarGroup: AdminSidebarGroups.orders,
      icon: Icons.inventory_outlined,
      breadcrumbs: <String>['Orders', 'Packing'],
      permissionKey: AdminPermissionKeys.managePacking,
      description: 'Manage packing workflow.',
      commandKeywords: <String>['packing'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.substitutions,
      title: 'Substitutions',
      sidebarGroup: AdminSidebarGroups.orders,
      icon: Icons.swap_horiz_outlined,
      breadcrumbs: <String>['Orders', 'Substitutions'],
      permissionKey: AdminPermissionKeys.manageSubstitutions,
      description: 'Manage substitutions.',
      commandKeywords: <String>['substitutions'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.refunds,
      title: 'Refunds',
      sidebarGroup: AdminSidebarGroups.orders,
      icon: Icons.reply_all_rounded,
      breadcrumbs: <String>['Orders', 'Refunds'],
      permissionKey: AdminPermissionKeys.manageRefunds,
      description: 'Manage refunds.',
      commandKeywords: <String>['refunds'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.returns,
      title: 'Returns',
      sidebarGroup: AdminSidebarGroups.orders,
      icon: Icons.assignment_return_outlined,
      breadcrumbs: <String>['Orders', 'Returns'],
      permissionKey: AdminPermissionKeys.manageReturns,
      description: 'Manage returns.',
      commandKeywords: <String>['returns'],
    ),

    // Inventory & Procurement
    AdminRouteMeta(
      route: AdminWebRoutes.inventory,
      title: 'Inventory',
      sidebarGroup: AdminSidebarGroups.inventoryProcurement,
      icon: Icons.warehouse_outlined,
      breadcrumbs: <String>['Inventory & Procurement', 'Inventory'],
      permissionKey: AdminPermissionKeys.manageInventory,
      description: 'Manage inventory.',
      commandKeywords: <String>['inventory', 'stock'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.stockLedger,
      title: 'Stock Ledger',
      sidebarGroup: AdminSidebarGroups.inventoryProcurement,
      icon: Icons.library_books_outlined,
      breadcrumbs: <String>['Inventory & Procurement', 'Stock Ledger'],
      permissionKey: AdminPermissionKeys.viewStockLedger,
      description: 'View stock ledger.',
      commandKeywords: <String>['stock ledger', 'ledger'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.purchaseReceiving,
      title: 'Purchase Receiving',
      sidebarGroup: AdminSidebarGroups.inventoryProcurement,
      icon: Icons.move_to_inbox_outlined,
      breadcrumbs: <String>['Inventory & Procurement', 'Purchase Receiving'],
      permissionKey: AdminPermissionKeys.managePurchaseReceiving,
      description: 'Manage purchase receiving.',
      commandKeywords: <String>['purchase receiving', 'receiving'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.purchases,
      title: 'Purchases',
      sidebarGroup: AdminSidebarGroups.inventoryProcurement,
      icon: Icons.shopping_cart_checkout_outlined,
      breadcrumbs: <String>['Inventory & Procurement', 'Purchases'],
      permissionKey: AdminPermissionKeys.managePurchases,
      description: 'Manage purchases.',
      commandKeywords: <String>['purchases', 'procurement'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.suppliers,
      title: 'Suppliers',
      sidebarGroup: AdminSidebarGroups.inventoryProcurement,
      icon: Icons.store_mall_directory_outlined,
      breadcrumbs: <String>['Inventory & Procurement', 'Suppliers'],
      permissionKey: AdminPermissionKeys.manageSuppliers,
      description: 'Manage suppliers.',
      commandKeywords: <String>['suppliers', 'vendors'],
    ),

    // Finance
    AdminRouteMeta(
      route: AdminWebRoutes.finance,
      title: 'Finance',
      sidebarGroup: AdminSidebarGroups.finance,
      icon: Icons.account_balance_wallet_outlined,
      breadcrumbs: <String>['Finance', 'Finance'],
      permissionKey: AdminPermissionKeys.manageFinance,
      description: 'Finance dashboard.',
      commandKeywords: <String>['finance'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.expenses,
      title: 'Expenses',
      sidebarGroup: AdminSidebarGroups.finance,
      icon: Icons.money_off_csred_outlined,
      breadcrumbs: <String>['Finance', 'Expenses'],
      permissionKey: AdminPermissionKeys.manageExpenses,
      description: 'Manage expenses.',
      commandKeywords: <String>['expenses'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.dailyClosing,
      title: 'Daily Closing',
      sidebarGroup: AdminSidebarGroups.finance,
      icon: Icons.event_available_outlined,
      breadcrumbs: <String>['Finance', 'Daily Closing'],
      permissionKey: AdminPermissionKeys.manageDailyClosing,
      description: 'Manage daily closing.',
      commandKeywords: <String>['daily closing'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.deliverySettlements,
      title: 'Delivery Settlements',
      sidebarGroup: AdminSidebarGroups.finance,
      icon: Icons.payments_outlined,
      breadcrumbs: <String>['Finance', 'Delivery Settlements'],
      permissionKey: AdminPermissionKeys.manageDeliverySettlements,
      description: 'Manage delivery settlements.',
      commandKeywords: <String>['delivery settlements', 'settlements'],
    ),

    // Delivery
    AdminRouteMeta(
      route: AdminWebRoutes.delivery,
      title: 'Delivery',
      sidebarGroup: AdminSidebarGroups.delivery,
      icon: Icons.local_shipping_outlined,
      breadcrumbs: <String>['Delivery', 'Delivery'],
      permissionKey: AdminPermissionKeys.manageDelivery,
      description: 'Manage delivery.',
      commandKeywords: <String>['delivery'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.riders,
      title: 'Riders',
      sidebarGroup: AdminSidebarGroups.delivery,
      icon: Icons.pedal_bike_outlined,
      breadcrumbs: <String>['Delivery', 'Riders'],
      permissionKey: AdminPermissionKeys.manageRiders,
      description: 'Manage riders.',
      commandKeywords: <String>['riders'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.zones,
      title: 'Zones',
      sidebarGroup: AdminSidebarGroups.delivery,
      icon: Icons.map_outlined,
      breadcrumbs: <String>['Delivery', 'Zones'],
      permissionKey: AdminPermissionKeys.manageZones,
      description: 'Manage zones.',
      commandKeywords: <String>['zones', 'areas'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.slotsCapacity,
      title: 'Slots Capacity',
      sidebarGroup: AdminSidebarGroups.delivery,
      icon: Icons.schedule_outlined,
      breadcrumbs: <String>['Delivery', 'Slots Capacity'],
      permissionKey: AdminPermissionKeys.manageSlotsCapacity,
      description: 'Manage slots capacity.',
      commandKeywords: <String>['slots', 'capacity'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.deliveryComplaints,
      title: 'Complaints',
      sidebarGroup: AdminSidebarGroups.delivery,
      icon: Icons.report_problem_outlined,
      breadcrumbs: <String>['Delivery', 'Complaints'],
      permissionKey: AdminPermissionKeys.manageDeliveryComplaints,
      description: 'Manage delivery complaints.',
      commandKeywords: <String>['delivery complaints', 'complaints'],
    ),

    // Services
    AdminRouteMeta(
      route: AdminWebRoutes.services,
      title: 'Services',
      sidebarGroup: AdminSidebarGroups.services,
      icon: Icons.home_repair_service_outlined,
      breadcrumbs: <String>['Services', 'Services'],
      permissionKey: AdminPermissionKeys.manageServices,
      description: 'Manage services.',
      commandKeywords: <String>['services'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.serviceCategories,
      title: 'Service Categories',
      sidebarGroup: AdminSidebarGroups.services,
      icon: Icons.design_services_outlined,
      breadcrumbs: <String>['Services', 'Service Categories'],
      permissionKey: AdminPermissionKeys.manageServiceCategories,
      description: 'Manage service categories.',
      commandKeywords: <String>['service categories'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.technicians,
      title: 'Technicians',
      sidebarGroup: AdminSidebarGroups.services,
      icon: Icons.engineering_outlined,
      breadcrumbs: <String>['Services', 'Technicians'],
      permissionKey: AdminPermissionKeys.manageTechnicians,
      description: 'Manage technicians.',
      commandKeywords: <String>['technicians'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.serviceComplaints,
      title: 'Complaints',
      sidebarGroup: AdminSidebarGroups.services,
      icon: Icons.report_gmailerrorred_outlined,
      breadcrumbs: <String>['Services', 'Complaints'],
      permissionKey: AdminPermissionKeys.manageServiceComplaints,
      description: 'Manage service complaints.',
      commandKeywords: <String>['service complaints', 'complaints'],
    ),

    // Customers
    AdminRouteMeta(
      route: AdminWebRoutes.customers,
      title: 'Customers',
      sidebarGroup: AdminSidebarGroups.customers,
      icon: Icons.groups_outlined,
      breadcrumbs: <String>['Customers', 'Customers'],
      permissionKey: AdminPermissionKeys.viewCustomers,
      description: 'View customers.',
      commandKeywords: <String>['customers'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.customerSegments,
      title: 'Customer Segments',
      sidebarGroup: AdminSidebarGroups.customers,
      icon: Icons.group_work_outlined,
      breadcrumbs: <String>['Customers', 'Customer Segments'],
      permissionKey: AdminPermissionKeys.manageCustomerSegments,
      description: 'Manage customer segments.',
      commandKeywords: <String>['customer segments', 'segments'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.customerComplaints,
      title: 'Complaints',
      sidebarGroup: AdminSidebarGroups.customers,
      icon: Icons.support_agent_outlined,
      breadcrumbs: <String>['Customers', 'Complaints'],
      permissionKey: AdminPermissionKeys.manageCustomerComplaints,
      description: 'Manage customer complaints.',
      commandKeywords: <String>['customer complaints', 'complaints'],
    ),

    // Reporting & Config
    AdminRouteMeta(
      route: AdminWebRoutes.reports,
      title: 'Reports',
      sidebarGroup: AdminSidebarGroups.reportingConfig,
      icon: Icons.bar_chart_outlined,
      breadcrumbs: <String>['Reporting & Config', 'Reports'],
      permissionKey: AdminPermissionKeys.viewReports,
      description: 'View reports.',
      commandKeywords: <String>['reports', 'analytics'],
    ),
    AdminRouteMeta(
      route: AdminWebRoutes.settings,
      title: 'Settings',
      sidebarGroup: AdminSidebarGroups.reportingConfig,
      icon: Icons.settings_outlined,
      breadcrumbs: <String>['Reporting & Config', 'Settings'],
      permissionKey: AdminPermissionKeys.manageSettings,
      description: 'Manage system settings.',
      commandKeywords: <String>['settings', 'configurations'],
    ),
  ];

  static final Map<String, AdminRouteMeta> byRoute = <String, AdminRouteMeta>{
    for (final item in all) item.route: item,
  };

  static AdminRouteMeta? find(String route) {
    if (byRoute.containsKey(route)) {
      return byRoute[route];
    }

    for (final item in all) {
      if (item.matchesRoute(route)) {
        return item;
      }
    }

    return null;
  }

  static String titleOf(String route) {
    return find(route)?.title ?? 'Admin Panel';
  }

  static List<String> breadcrumbsOf(String route) {
    return find(route)?.breadcrumbs ?? <String>['Admin Panel'];
  }

  static List<AdminRouteMeta> sidebarItemsForGroup(String group) {
    return all
        .where(
          (item) => item.showInSidebar && item.sidebarGroup == group,
    )
        .toList();
  }

  static List<AdminRouteMeta> commandPaletteItems() {
    return all.where((item) => item.showInSidebar).toList();
  }
}