import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/main_shell_controller.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/home_controller/home_categories_controller.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/settings_controllers/settings_controller.dart';
import 'package:public_apis_desktop_client/app/modules/views/categories_view/home_categories_view_new.dart';
import 'package:public_apis_desktop_client/app/modules/views/search_apis_screen.dart';
import 'package:public_apis_desktop_client/app/modules/views/settings_view/settings_view.dart';
import 'package:public_apis_desktop_client/app/modules/views/favorites_view/favorites_view.dart';

class MainShellView extends StatelessWidget {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainShellController());
    Get.put<HomeCategoriesController>(
      HomeCategoriesController(context: Get.context!),
    );

    Get.put(SettingsController());

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.selectedTabIndex.value,
          children: [
            /// Home - Categories
            HomeCategoriesPageNew(
              onSearchTap: () => controller.navigateToSearch(),
            ),

            /// Search/Filter
            const SearchApisScreen(),

            /// Favorites (placeholder)
            const FavoritesView(),

            /// Settings
            const SettingsView(),
          ],
        ),

        /// Floating Bottom Navigation Bar
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: NavigationBar(
              height: 60,
              onDestinationSelected: controller.selectTab,
              selectedIndex: controller.selectedTabIndex.value,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.14),
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_outline),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
