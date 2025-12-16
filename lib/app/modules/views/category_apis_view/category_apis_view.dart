import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/category_apis_controller/category_apis_controller.dart';
import '../apis_view/widgets/api_card.dart';

class CategoryApisView extends GetView<CategoryApisController> {
  const CategoryApisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.category.title),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.retryFetch(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.apis.isEmpty) {
          return Center(
            child: Text(
              'No APIs available in this category',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.retryFetch(),
          child: ListView.separated(
            itemCount: controller.apis.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final api = controller.apis[index];
              return ApiCard(
                api: api,
                category: controller.category.title,
              );
            },
          ),
        );
      }),
    );
  }
}
