import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/home_controller/home_categories_controller.dart';

class HomeCategoriesPageNew extends GetView<HomeCategoriesController> {
  final VoidCallback? onSearchTap;

  const HomeCategoriesPageNew({
    super.key,
    this.onSearchTap,
  });

  /// Map category names to asset image file names
  String _getCategoryImageAsset(String categoryName) {
    final nameMap = {
      'Animals': 'animals.jpg',
      'Anime': 'anime.jpg',
      'Anti-Malware': 'anti-malware.jpg',
      'Art & Design': 'art.jpg',
      'Authentication & Authorization': 'authentication.jpg',
      'Blockchain': 'blockchain.jpg',
      'Books': 'books.jpg',
      'Business': 'business.jpg',
      'Calendar': 'calendar.jpg',
      'Cloud Storage & File Sharing': 'cloud.jpg',
      'Continuous Integration': 'continuous.jpg',
      'Cryptocurrency': 'cryptocurrency.jpg',
      'Currency Exchange': 'currency.jpg',
      'Data Validation': 'data.jpg',
      'Development': 'development.jpg',
      'Dictionaries': 'dictionaries.jpg',
      'Documents & Productivity': 'documents.jpg',
      'Email': 'email.jpg',
      'Entertainment': 'entertainment.jpg',
      'Environment': 'environment.jpg',
      'Events': 'events.jpg',
      'Finance': 'finance.jpg',
      'Food & Drink': 'food.jpg',
      'Games & Comics': 'games.jpg',
      'Geocoding': 'geocoding.jpg',
      'Government': 'government.jpg',
      'Health': 'health.jpg',
      'Jobs': 'jobs.jpg',
      'Machine Learning': 'machine.jpg',
      'Music': 'music.jpg',
      'News': 'news.jpg',
      'Open Data': 'openData.jpg',
      'Open Source Projects': 'open.jpg',
      'Patent': 'patent.jpg',
      'Personality': 'personality.jpg',
      'Phone': 'phone.jpg',
      'Photography': 'photography.jpg',
      'Podcasts': 'entertainment.jpg',
      'Programming': 'programming.jpg',
      'Science & Math': 'science.jpg',
      'Security': 'security.jpg',
      'Shopping': 'shopping.jpg',
      'Social': 'social.jpg',
      'Sports & Fitness': 'sports.jpg',
      'Test Data': 'test.jpg',
      'Text Analysis': 'text.jpg',
      'Tracking': 'tracking.jpg',
      'Transportation': 'transportation.jpg',
      'URL Shorteners': 'url.jpg',
      'Vehicle': 'vehicle.jpg',
      'Video': 'video.jpg',
      'Weather': 'weather.jpg',
    };
    return nameMap[categoryName] ?? 'development.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'API Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// Search Bar with enhanced styling
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.white,
                ),
              ),
            ),
          ),

          /// Categories Grid
          Expanded(
            child: Obx(() {
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
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => controller.retryFetch(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredCategories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchController.text.isEmpty
                            ? 'No categories available'
                            : 'No categories match your search',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = controller.filteredCategories[index];
                  final imagePath = _getCategoryImageAsset(category.name);

                  return GestureDetector(
                    onTap: () => controller.navigateToCategoryApis(category),
                    child: _CategoryCard(
                      category: category,
                      imagePath: imagePath,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Beautiful Category Card Widget
class _CategoryCard extends StatefulWidget {
  final dynamic category;
  final String imagePath;

  const _CategoryCard({
    required this.category,
    required this.imagePath,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            /// Background Image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:
                      AssetImage('assets/categoriesImages/${widget.imagePath}'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),

            /// Category Name Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
