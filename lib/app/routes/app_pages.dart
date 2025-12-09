import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/views/privacy_view/privacy_view.dart';
import 'package:public_apis_desktop_client/app/modules/views/app_settings_view/app_settings_view.dart';
import 'package:public_apis_desktop_client/app/modules/views/submit_api_view/submit_api_view.dart';
import 'package:public_apis_desktop_client/app/modules/views/contact_view/contact_view.dart';

import '../modules/bindings/main_shell_binding.dart';
import '../modules/bindings/category_apis_binding.dart';

import '../modules/bindings/home_binding.dart';
import '../modules/bindings/privacy_bindings.dart';
import '../modules/bindings/api_detail_binding.dart';
import '../modules/bindings/settings_binding.dart';
import '../modules/bindings/auth_binding.dart';
import '../modules/bindings/app_settings_binding.dart';
import '../modules/bindings/submit_api_binding.dart';
import '../modules/views/main_shell_view.dart';
import '../modules/views/categories_view/home_categories_view_new.dart';
import '../modules/views/category_apis_view/category_apis_view.dart';

import '../modules/views/settings_view/settings_view.dart';
import '../modules/views/api_detail_view/api_detail_view.dart';
import '../modules/views/auth/auth_view.dart';
import '../modules/views/account_settings_view/account_settings_view.dart';
import 'auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: _Paths.authPath,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.mainShellPath,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.homeCategoriesPagePath,
      page: () => const HomeCategoriesPageNew(),
      binding: HomeCategoriesPageBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.categoryApisPath,
      page: () => const CategoryApisView(),
      binding: CategoryApisBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.apiDetailPath,
      page: () => const ApiDetailView(),
      binding: ApiDetailBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.settingsViewPath,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.privacyPath,
      page: () => const PrivacyView(),
      binding: PrivacyBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.accountSettingsPath,
      page: () => const AccountSettingsView(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.appSettingsPath,
      page: () => const AppSettingsView(),
      binding: AppSettingsBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.submitApiPath,
      page: () => const SubmitApiView(),
      binding: SubmitApiBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.contactPath,
      page: () => const ContactView(),
      middlewares: [AuthGuardMiddleware()],
    ),
  ];

  AppPages._();
}
