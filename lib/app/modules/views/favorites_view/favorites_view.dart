import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/firestore_favorites_controller.dart';
import '../../../utils/snackbar_helper.dart';

class FavoritesView extends GetView<FirestoreFavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 64,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorite APIs yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add APIs from the search tab',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            final favorite = controller.favorites[index];
            return _FavoriteFavoriteCard(favorite: favorite);
          },
        );
      }),
    );
  }
}

class _FavoriteFavoriteCard extends GetView<FirestoreFavoritesController> {
  final favorite;

  const _FavoriteFavoriteCard({required this.favorite});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          favorite.apiName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          favorite.category,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.primaryColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  'Description',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  favorite.description,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),

                // Personal Notes Section
                Text(
                  'Personal Notes',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _NotesSection(favorite: favorite),
                const SizedBox(height: 16),

                // API Details
                Row(
                  children: [
                    if (favorite.auth.toLowerCase() != 'no')
                      _DetailChip(label: 'Auth', theme: theme),
                    if (favorite.https.toLowerCase() == 'yes')
                      _DetailChip(label: 'HTTPS', theme: theme),
                    if (favorite.cors.toLowerCase() == 'yes')
                      _DetailChip(label: 'CORS', theme: theme),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _launchUrl(favorite.apiLink);
                      },
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Visit API'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await controller.removeFavorite(favorite.id);
                        AppSnackbar.show(
                          title: 'Removed',
                          message: '${favorite.apiName} removed from favorites',
                        );
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Remove'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    // Implementation to launch URL - can use url_launcher package
    try {
      // For now, just copy to clipboard as placeholder
      AppSnackbar.show(
        title: 'Visit',
        message: 'Opening: $url',
      );
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Could not open URL: $e',
        isError: true,
      );
    }
  }
}

class _NotesSection extends GetView<FirestoreFavoritesController> {
  final favorite;

  const _NotesSection({required this.favorite});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (favorite.personalNotes == null || favorite.personalNotes!.isEmpty) {
      return GestureDetector(
        onTap: () => _editNotes(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Add personal notes...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _editNotes(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.05),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              favorite.personalNotes ?? '',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to edit',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editNotes(BuildContext context) {
    final textController = TextEditingController(
      text: favorite.personalNotes ?? '',
    );

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Personal Notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Add your notes about this API...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.updatePersonalNotes(
                        favoriteId: favorite.id,
                        personalNotes: textController.text.isNotEmpty
                            ? textController.text
                            : null,
                      );
                      Get.back();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _DetailChip({
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
