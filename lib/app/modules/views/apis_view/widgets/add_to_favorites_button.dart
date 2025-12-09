import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/firestore_favorites_controller.dart';
import '../../../../utils/snackbar_helper.dart';

class AddToFavoritesButton extends StatefulWidget {
  final String apiName;
  final String apiLink;
  final String category;
  final String description;

  final String auth;
  final String https;
  final String cors;
  final VoidCallback? onChanged;

  const AddToFavoritesButton({
    super.key,
    required this.apiName,
    required this.apiLink,
    required this.category,
    required this.description,
    required this.auth,
    required this.https,
    required this.cors,
    this.onChanged,
  });

  @override
  State<AddToFavoritesButton> createState() => _AddToFavoritesButtonState();
}

class _AddToFavoritesButtonState extends State<AddToFavoritesButton> {
  late Future<bool> _isFavoritedFuture;

  @override
  void initState() {
    super.initState();
    _refreshFavoriteStatus();
  }

  void _refreshFavoriteStatus() {
    final controller = Get.find<FirestoreFavoritesController>();
    _isFavoritedFuture = controller.isFavorited(widget.apiLink);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FirestoreFavoritesController>(
      builder: (favController) {
        return FutureBuilder<bool>(
          future: _isFavoritedFuture,
          builder: (context, snapshot) {
            final isFavorited = snapshot.data ?? false;

            return Tooltip(
              message:
                  isFavorited ? 'Remove from favorites' : 'Add to favorites',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    try {
                      if (isFavorited) {
                        // Find and remove
                        final allFavs =
                            await favController.favoritesService.getFavorites();
                        final fav = allFavs.firstWhereOrNull(
                          (f) => f.apiLink == widget.apiLink,
                        );
                        if (fav != null) {
                          await favController.removeFavorite(fav.id);
                          AppSnackbar.show(
                            title: 'Removed',
                            message: '${widget.apiName} removed from favorites',
                          );
                        }
                      } else {
                        // Show dialog to add notes (optional)
                        final notes = await _showAddNotesDialog();

                        // Add to favorites
                        await favController.addFavorite(
                          apiName: widget.apiName,
                          apiLink: widget.apiLink,
                          category: widget.category,
                          description: widget.description,
                          auth: widget.auth,
                          https: widget.https,
                          cors: widget.cors,
                          personalNotes: notes,
                        );
                        AppSnackbar.show(
                          title: 'Added',
                          message: '${widget.apiName} added to favorites',
                        );
                      }
                      _refreshFavoriteStatus();
                      setState(() {});
                      widget.onChanged?.call();
                    } catch (e) {
                      AppSnackbar.show(
                        title: 'Error',
                        message: 'Failed to update favorite: $e',
                        isError: true,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFavorited ? Icons.bookmark : Icons.bookmark_outline,
                          color: isFavorited
                              ? Theme.of(context).primaryColor
                              : null,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFavorited ? 'Favorited' : 'Favorite',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isFavorited
                                        ? Theme.of(context).primaryColor
                                        : null,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showAddNotesDialog() async {
    final notesController = TextEditingController();

    return await Get.dialog<String>(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Favorites',
                style: Get.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Add personal notes (optional)',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'e.g., Great for weather data, requires API key...',
                  labelText: 'Personal Notes',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: null),
                    child: const Text('Skip'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back(result: notesController.text.trim());
                    },
                    child: const Text('Add Favorite'),
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
