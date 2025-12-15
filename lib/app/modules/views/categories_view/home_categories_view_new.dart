import 'package:flutter/material.dart';
import 'package:flutter_animate_border/flutter_animate_border.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/home_controller/home_categories_controller.dart';
import 'package:public_apis_desktop_client/app/data/models/category.dart';

class HomeCategoriesPageNew extends GetView<HomeCategoriesController> {
  final VoidCallback? onSearchTap;

  const HomeCategoriesPageNew({
    super.key,
    this.onSearchTap,
  });

  /// Map category names to asset image file names
  String _getCategoryImageAsset(String categoryName) {
    final nameMap = {
      'AI': 'Ai.jpg',
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

/// Beautiful Category Card Widget with Animated Gradient Border
class _CategoryCard extends StatefulWidget {
  final Category category;
  final String imagePath;

  const _CategoryCard({
    required this.category,
    required this.imagePath,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  late final FlutterAnimateBorderController _borderController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with animation settings
    // isLoading: true starts the animation immediately
    // doFreeze: false allows animation to run continuously
    _borderController = FlutterAnimateBorderController(
      loopDuration: const Duration(milliseconds: 3000),
      loopCurve: Curves.linear,
      isLoading: widget.category.hasTrendyBorder,
      doFreeze: false,
    );
  }

  @override
  void dispose() {
    _borderController.isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: widget.category.hasTrendyBorder ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
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
                    Colors.black.withOpacity(
                        widget.category.hasTrendyBorder ? 0.5 : 0.6),
                  ],
                ),
              ),
            ),
          ),

          /// Featured Badge - Only for special categories
          if (widget.category.hasTrendyBorder)
            Positioned(
              top: 8,
              right: 8,
              child: _buildFeaturedChip(context),
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
                    Colors.black.withOpacity(
                        widget.category.hasTrendyBorder ? 0.85 : 0.7),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.category.hasTrendyBorder ? 16 : 15,
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
    );

    // Wrap card with animated border only if hasTrendyBorder is true
    if (widget.category.hasTrendyBorder) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FlutterAnimateBorder(
          controller: _borderController,
          lineThickness: 3,
          lineWidth: 100,
          linePadding: 2,
          cornerRadius: 16.0,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.5),
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).primaryColor.withOpacity(0.5),
              Theme.of(context).primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildFeaturedChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Featured',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}
