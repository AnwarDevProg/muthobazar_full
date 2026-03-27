Final polished MuthoBazar project structure
muthobazar/
├── melos.yaml
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── .gitignore
├── .metadata
├── .github/
│   └── workflows/
│       ├── analyze.yml
│       ├── test.yml
│       ├── firebase-rules.yml
│       ├── firebase-functions.yml
│       └── deploy-admin-web.yml
│
├── apps/
│   ├── customer_app/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── android/
│   │   ├── ios/
│   │   ├── web/
│   │   ├── assets/
│   │   │   ├── animations/
│   │   │   ├── icons/
│   │   │   ├── images/
│   │   │   │   ├── logos/
│   │   │   │   ├── onboarding/
│   │   │   │   └── placeholders/
│   │   │   └── placeholders/
│   │   ├── test/
│   │   │   ├── smoke_test.dart
│   │   │   ├── widget_test.dart
│   │   │   └── features/
│   │   └── lib/
│   │       ├── main.dart
│   │       ├── firebase_options.dart
│   │       ├── app/
│   │       │   ├── app.dart
│   │       │   ├── bindings/
│   │       │   │   ├── customer_app_binding.dart
│   │       │   │   ├── auth_binding.dart
│   │       │   │   ├── home_binding.dart
│   │       │   │   ├── categories_binding.dart
│   │       │   │   ├── product_binding.dart
│   │       │   │   ├── cart_binding.dart
│   │       │   │   ├── checkout_binding.dart
│   │       │   │   ├── orders_binding.dart
│   │       │   │   ├── address_binding.dart
│   │       │   │   ├── profile_binding.dart
│   │       │   │   ├── search_binding.dart
│   │       │   │   ├── wishlist_binding.dart
│   │       │   │   ├── loyalty_binding.dart
│   │       │   │   ├── referrals_binding.dart
│   │       │   │   ├── reviews_binding.dart
│   │       │   │   ├── services_binding.dart
│   │       │   │   ├── support_binding.dart
│   │       │   │   └── notifications_binding.dart
│   │       │   ├── middleware/
│   │       │   │   ├── customer_auth_middleware.dart
│   │       │   │   └── customer_guest_only_middleware.dart
│   │       │   ├── routes/
│   │       │   │   ├── customer_app_routes.dart
│   │       │   │   └── customer_app_pages.dart
│   │       │   ├── services/
│   │       │   │   ├── customer_app_bootstrap_service.dart
│   │       │   │   └── customer_app_session_service.dart
│   │       │   ├── shell/
│   │       │   │   ├── customer_app_shell.dart
│   │       │   │   └── customer_bottom_nav_shell.dart
│   │       │   ├── startup/
│   │       │   │   ├── customer_launch_router_page.dart
│   │       │   │   └── customer_startup_redirect_controller.dart
│   │       │   └── widgets/
│   │       │       ├── common/
│   │       │       ├── overlays/
│   │       │       └── state/
│   │       ├── features/
│   │       │   ├── auth/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── home/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   ├── widgets/
│   │       │   │   │   └── sections/
│   │       │   │   └── presenters/
│   │       │   ├── categories/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── product/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── cart/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── checkout/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── orders/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── address/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── profile/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── search/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── wishlist/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── reviews/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── referrals/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── loyalty/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── services/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── support/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   └── notifications/
│   │       │       ├── controllers/
│   │       │       ├── pages/
│   │       │       └── widgets/
│   │       └── l10n/
│   │           ├── app_en.arb
│   │           └── app_bn.arb
│   │
│   ├── staff_app/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── android/
│   │   ├── ios/
│   │   ├── web/
│   │   ├── assets/
│   │   │   ├── icons/
│   │   │   ├── images/
│   │   │   └── placeholders/
│   │   ├── test/
│   │   │   ├── smoke_test.dart
│   │   │   ├── widget_test.dart
│   │   │   └── features/
│   │   └── lib/
│   │       ├── main.dart
│   │       ├── firebase_options.dart
│   │       ├── app/
│   │       │   ├── app.dart
│   │       │   ├── bindings/
│   │       │   │   ├── staff_app_binding.dart
│   │       │   │   ├── auth_binding.dart
│   │       │   │   ├── rider_binding.dart
│   │       │   │   ├── technician_binding.dart
│   │       │   │   ├── purchase_agent_binding.dart
│   │       │   │   ├── support_staff_binding.dart
│   │       │   │   ├── earnings_binding.dart
│   │       │   │   ├── settlements_binding.dart
│   │       │   │   ├── profile_binding.dart
│   │       │   │   └── notifications_binding.dart
│   │       │   ├── middleware/
│   │       │   │   ├── staff_auth_middleware.dart
│   │       │   │   ├── staff_guest_only_middleware.dart
│   │       │   │   ├── rider_only_middleware.dart
│   │       │   │   ├── technician_only_middleware.dart
│   │       │   │   ├── purchase_agent_only_middleware.dart
│   │       │   │   └── support_staff_only_middleware.dart
│   │       │   ├── routes/
│   │       │   │   ├── staff_app_routes.dart
│   │       │   │   └── staff_app_pages.dart
│   │       │   ├── services/
│   │       │   │   ├── staff_app_bootstrap_service.dart
│   │       │   │   └── staff_app_session_service.dart
│   │       │   ├── shell/
│   │       │   │   ├── staff_app_shell.dart
│   │       │   │   └── staff_bottom_nav_shell.dart
│   │       │   ├── startup/
│   │       │   │   ├── staff_launch_router_page.dart
│   │       │   │   └── staff_startup_redirect_controller.dart
│   │       │   └── widgets/
│   │       │       ├── common/
│   │       │       ├── state/
│   │       │       └── task_cards/
│   │       ├── features/
│   │       │   ├── auth/
│   │       │   │   ├── controllers/
│   │       │   │   ├── pages/
│   │       │   │   └── widgets/
│   │       │   ├── rider_dashboard/
│   │       │   ├── deliveries/
│   │       │   ├── technician_dashboard/
│   │       │   ├── technician_jobs/
│   │       │   ├── purchase_dashboard/
│   │       │   ├── purchase_tasks/
│   │       │   ├── support_dashboard/
│   │       │   ├── support_tasks/
│   │       │   ├── earnings/
│   │       │   ├── settlements/
│   │       │   ├── notifications/
│   │       │   └── profile/
│   │       └── l10n/
│   │           ├── app_en.arb
│   │           └── app_bn.arb
│   │
│   └── admin_web/
│       ├── pubspec.yaml
│       ├── analysis_options.yaml
│       ├── web/
│       ├── assets/
│       │   ├── icons/
│       │   ├── illustrations/
│       │   └── images/
│       ├── test/
│       │   ├── smoke_test.dart
│       │   ├── widget_test.dart
│       │   └── features/
│       └── lib/
│           ├── main.dart
│           ├── firebase_options.dart
│           ├── app/
│           │   ├── app.dart
│           │   ├── bindings/
│           │   │   ├── admin_web_binding.dart
│           │   │   ├── dashboard_binding.dart
│           │   │   ├── categories_binding.dart
│           │   │   ├── products_binding.dart
│           │   │   ├── brands_binding.dart
│           │   │   ├── services_binding.dart
│           │   │   ├── service_categories_binding.dart
│           │   │   ├── inventory_binding.dart
│           │   │   ├── stock_ledger_binding.dart
│           │   │   ├── purchases_binding.dart
│           │   │   ├── purchase_receiving_binding.dart
│           │   │   ├── suppliers_binding.dart
│           │   │   ├── orders_binding.dart
│           │   │   ├── manual_orders_binding.dart
│           │   │   ├── picking_binding.dart
│           │   │   ├── packing_binding.dart
│           │   │   ├── substitutions_binding.dart
│           │   │   ├── delivery_binding.dart
│           │   │   ├── delivery_settlements_binding.dart
│           │   │   ├── riders_binding.dart
│           │   │   ├── technicians_binding.dart
│           │   │   ├── customers_binding.dart
│           │   │   ├── customer_segments_binding.dart
│           │   │   ├── complaints_binding.dart
│           │   │   ├── refunds_binding.dart
│           │   │   ├── returns_binding.dart
│           │   │   ├── finance_binding.dart
│           │   │   ├── expenses_binding.dart
│           │   │   ├── daily_closing_binding.dart
│           │   │   ├── marketing_binding.dart
│           │   │   ├── reports_binding.dart
│           │   │   ├── slots_capacity_binding.dart
│           │   │   ├── zones_binding.dart
│           │   │   ├── settings_binding.dart
│           │   │   ├── admin_access_binding.dart
│           │   │   └── audit_logs_binding.dart
│           │   ├── core/
│           │   │   ├── constants/
│           │   │   ├── extensions/
│           │   │   ├── utils/
│           │   │   └── web_table/
│           │   ├── middleware/
│           │   │   ├── admin_auth_middleware.dart
│           │   │   ├── admin_guest_only_middleware.dart
│           │   │   ├── super_admin_only_middleware.dart
│           │   │   └── permission_guard_middleware.dart
│           │   ├── routes/
│           │   │   ├── admin_web_routes.dart
│           │   │   └── admin_web_pages.dart
│           │   ├── services/
│           │   │   ├── admin_web_bootstrap_service.dart
│           │   │   ├── admin_web_session_service.dart
│           │   │   └── admin_permission_gate_service.dart
│           │   ├── shell/
│           │   │   ├── admin_web_shell.dart
│           │   │   ├── admin_shell_state_controller.dart
│           │   │   ├── admin_sidebar.dart
│           │   │   └── admin_topbar.dart
│           │   ├── startup/
│           │   │   ├── admin_launch_router_page.dart
│           │   │   └── admin_startup_redirect_controller.dart
│           │   └── widgets/
│           │       ├── common/
│           │       ├── form/
│           │       ├── layout/
│           │       └── table/
│           ├── features/
│           │   ├── auth/
│           │   │   ├── controllers/
│           │   │   ├── pages/
│           │   │   ├── repositories/
│           │   │   └── widgets/
│           │   ├── dashboard/
│           │   ├── admin_access/
│           │   ├── audit_logs/
│           │   ├── categories/
│           │   ├── products/
│           │   ├── brands/
│           │   ├── services/
│           │   ├── service_categories/
│           │   ├── inventory/
│           │   ├── stock_ledger/
│           │   ├── purchases/
│           │   ├── purchase_receiving/
│           │   ├── suppliers/
│           │   ├── orders/
│           │   ├── manual_orders/
│           │   ├── picking/
│           │   ├── packing/
│           │   ├── substitutions/
│           │   ├── delivery/
│           │   ├── delivery_settlements/
│           │   ├── riders/
│           │   ├── technicians/
│           │   ├── customers/
│           │   ├── customer_segments/
│           │   ├── complaints/
│           │   ├── refunds/
│           │   ├── returns/
│           │   ├── finance/
│           │   ├── expenses/
│           │   ├── daily_closing/
│           │   ├── marketing/
│           │   ├── reports/
│           │   ├── slots_capacity/
│           │   ├── zones/
│           │   └── settings/
│           └── l10n/
│               └── app_en.arb
│
├── packages/
│   ├── shared_core/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── test/
│   │   │   └── smoke_test.dart
│   │   └── lib/
│   │       ├── shared_core.dart
│   │       ├── auth/
│   │       │   ├── constants/
│   │       │   ├── middleware_helpers/
│   │       │   ├── models/
│   │       │   └── services/
│   │       ├── config/
│   │       ├── constants/
│   │       ├── enums/
│   │       ├── firestore/
│   │       ├── helpers/
│   │       ├── services/
│   │       ├── utils/
│   │       └── validators/
│   │
│   ├── shared_models/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── test/
│   │   │   └── smoke_test.dart
│   │   └── lib/
│   │       ├── shared_models.dart
│   │       ├── admin/
│   │       ├── analytics/
│   │       ├── catalog/
│   │       ├── customer/
│   │       ├── delivery/
│   │       ├── finance/
│   │       ├── inventory/
│   │       ├── loyalty/
│   │       ├── marketing/
│   │       ├── orders/
│   │       ├── referrals/
│   │       ├── reviews/
│   │       ├── search/
│   │       ├── services/
│   │       ├── staff/
│   │       └── support/
│   │
│   ├── shared_contracts/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── test/
│   │   │   └── smoke_test.dart
│   │   └── lib/
│   │       ├── shared_contracts.dart
│   │       ├── auth/
│   │       ├── delivery/
│   │       ├── inventory/
│   │       ├── orders/
│   │       ├── purchases/
│   │       ├── services/
│   │       ├── finance/
│   │       └── support/
│   │
│   ├── shared_repositories/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── test/
│   │   │   └── smoke_test.dart
│   │   └── lib/
│   │       ├── shared_repositories.dart
│   │       ├── base/
│   │       ├── admin/
│   │       ├── analytics/
│   │       ├── catalog/
│   │       ├── customer/
│   │       ├── delivery/
│   │       ├── finance/
│   │       ├── inventory/
│   │       ├── loyalty/
│   │       ├── marketing/
│   │       ├── orders/
│   │       ├── referrals/
│   │       ├── reviews/
│   │       ├── search/
│   │       ├── services/
│   │       ├── staff/
│   │       └── support/
│   │
│   ├── shared_services/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── test/
│   │   │   └── smoke_test.dart
│   │   └── lib/
│   │       ├── shared_services.dart
│   │       ├── analytics/
│   │       ├── export/
│   │       ├── media/
│   │       ├── notifications/
│   │       ├── pricing/
│   │       ├── search/
│   │       └── formatting/
│   │
│   ├── shared_workflows/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── test/
│   │   │   └── smoke_test.dart
│   │   └── lib/
│   │       ├── shared_workflows.dart
│   │       ├── auth/
│   │       ├── orders/
│   │       ├── delivery/
│   │       ├── inventory/
│   │       ├── purchases/
│   │       ├── services/
│   │       ├── loyalty/
│   │       ├── referrals/
│   │       └── reviews/
│   │
│   ├── shared_ui/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── assets/
│   │   │   ├── fonts/
│   │   │   ├── icons/
│   │   │   └── placeholders/
│   │   ├── test/
│   │   │   └── smoke_test.dart
│   │   └── lib/
│   │       ├── shared_ui.dart
│   │       ├── extensions/
│   │       ├── layout/
│   │       ├── responsive/
│   │       ├── scroll/
│   │       ├── theme/
│   │       ├── typography/
│   │       └── widgets/
│   │           ├── common/
│   │           ├── dialogs/
│   │           ├── feedback/
│   │           └── form/
│   │
│   ├── shared_testkit/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── test/
│   │   │   └── smoke_test.dart
│   │   └── lib/
│   │       ├── shared_testkit.dart
│   │       ├── builders/
│   │       ├── fakes/
│   │       ├── fixtures/
│   │       ├── helpers/
│   │       └── mocks/
│   │
│   └── shared_usecases/              # optional but recommended
│       ├── pubspec.yaml
│       ├── analysis_options.yaml
│       ├── test/
│       │   └── smoke_test.dart
│       └── lib/
│           ├── shared_usecases.dart
│           ├── auth/
│           ├── customer/
│           ├── orders/
│           ├── delivery/
│           ├── inventory/
│           ├── purchases/
│           ├── services/
│           ├── marketing/
│           └── reports/
│
├── firebase/
│   ├── firestore.rules
│   ├── storage.rules
│   ├── firestore.indexes.json
│   ├── firebase.json
│   ├── .firebaserc
│   ├── emulators/
│   │   └── README.md
│   ├── functions/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── .eslintrc.js
│   │   └── src/
│   │       ├── index.ts
│   │       ├── auth/
│   │       ├── admin/
│   │       ├── orders/
│   │       ├── inventory/
│   │       ├── purchases/
│   │       ├── delivery/
│   │       ├── services/
│   │       ├── finance/
│   │       ├── support/
│   │       ├── marketing/
│   │       ├── workflows/
│   │       └── utils/
│   └── tests/
│       ├── firestore/
│       ├── functions/
│       └── storage/
│
├── docs/
│   ├── architecture/
│   │   ├── monorepo_overview.md
│   │   ├── dependency_rules.md
│   │   ├── package_boundaries.md
│   │   ├── routing_strategy.md
│   │   ├── state_management_strategy.md
│   │   ├── feature_module_rules.md
│   │   ├── app_split_strategy.md
│   │   └── naming_conventions.md
│   ├── business/
│   │   ├── admin_system_flow.md
│   │   ├── customer_app_flow.md
│   │   ├── staff_app_flow.md
│   │   ├── order_lifecycle.md
│   │   ├── purchase_inventory_flow.md
│   │   ├── delivery_flow.md
│   │   ├── services_flow.md
│   │   ├── finance_flow.md
│   │   ├── customer_support_flow.md
│   │   └── marketing_flow.md
│   ├── firestore/
│   │   ├── collections.md
│   │   ├── data_model.md
│   │   ├── sample_documents.md
│   │   ├── counters_and_aggregates.md
│   │   ├── rules_strategy.md
│   │   └── indexes.md
│   ├── ui/
│   │   ├── customer_design_rules.md
│   │   ├── staff_app_layout_rules.md
│   │   ├── admin_web_layout_rules.md
│   │   ├── responsive_rules.md
│   │   └── shared_ui_tokens.md
│   ├── development/
│   │   ├── getting_started.md
│   │   ├── code_style.md
│   │   ├── testing_strategy.md
│   │   ├── branch_strategy.md
│   │   ├── git_workflow.md
│   │   └── feature_generation_guide.md
│   └── deployment/
│       ├── firebase_envs.md
│       ├── customer_android_release.md
│       ├── customer_ios_release.md
│       ├── staff_android_release.md
│       ├── staff_ios_release.md
│       └── admin_web_deploy.md
│
├── tools/
│   ├── ci/
│   │   ├── README.md
│   │   └── pipeline_notes.md
│   ├── generators/
│   │   ├── README.md
│   │   └── feature_templates/
│   │       ├── customer_feature.md
│   │       ├── staff_feature.md
│   │       └── admin_feature.md
│   └── scripts/
│       ├── bootstrap_all.sh
│       ├── analyze_all.sh
│       ├── test_all.sh
│       ├── format_all.sh
│       ├── run_customer.sh
│       ├── run_staff.sh
│       ├── run_admin_web.sh
│       ├── setup_workspace.sh
│       └── setup_workspace.ps1
