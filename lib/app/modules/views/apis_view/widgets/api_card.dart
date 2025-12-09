import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/AllApis.dart';
import '../../../../data/models/api.dart' as new_api;
import '../../../../services/metadata/metadata_service.dart';
import '../../../controllers/firestore_favorites_controller.dart';
import '../../../../utils/snackbar_helper.dart';

class ApiCard extends StatefulWidget {
  const ApiCard({
    Key? key,
    required this.api,
    required this.category,
  }) : super(key: key);

  final Api api;
  final String category;

  @override
  State<ApiCard> createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  final MetadataService _metadataService = MetadataService();
  ApiMetadata? _metadata;
  bool _loadingMetadata = false;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _fetchMetadata();
    _checkFavoriteStatus();
  }

  Future<void> _fetchMetadata() async {
    if (!mounted) return;
    setState(() => _loadingMetadata = true);

    try {
      final metadata = await _metadataService.fetchMetadata(widget.api.link);
      if (mounted && metadata != null) {
        setState(() => _metadata = metadata);
      }
    } catch (e) {
      // Silently fail
    } finally {
      if (mounted) {
        setState(() => _loadingMetadata = false);
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final controller = Get.find<FirestoreFavoritesController>();
      final isFav = await controller.isFavorited(widget.api.link);
      if (mounted) {
        setState(() => _isFavorited = isFav);
      }
    } catch (e) {
      // Controller might not be ready yet
    }
  }

  void _navigateToDetail() {
    // Convert legacy Api to new Api model
    final newApiModel = new_api.Api(
      id: '${widget.category}-${widget.api.name}',
      name: widget.api.name,
      description: _metadata?.description ?? widget.api.description,
      auth: widget.api.auth,
      https: widget.api.https.toLowerCase() == 'yes',
      cors: widget.api.cors.toLowerCase() == 'yes',
      link: widget.api.link,
      categoryId: widget.category,
    );

    Get.toNamed('/api-detail', arguments: newApiModel);
  }

  Future<void> _toggleFavorite() async {
    final controller = Get.find<FirestoreFavoritesController>();
    final description = _metadata?.description ?? widget.api.description;

    try {
      if (_isFavorited) {
        // Remove from favorites
        final allFavs = await controller.favoritesService.getFavorites();
        final fav = allFavs.firstWhereOrNull(
          (f) => f.apiLink == widget.api.link,
        );
        if (fav != null) {
          await controller.removeFavorite(fav.id);
          setState(() => _isFavorited = false);
          AppSnackbar.show(
            title: 'Removed',
            message: '${widget.api.name} removed from favorites',
          );
        }
      } else {
        // Show dialog to add notes (optional)
        final notes = await _showAddNotesDialog();
        if (notes == null) return; // User cancelled

        // Add to favorites
        await controller.addFavorite(
          apiName: widget.api.name,
          apiLink: widget.api.link,
          category: widget.category,
          description: description,
          auth: widget.api.auth,
          https: widget.api.https,
          cors: widget.api.cors,
          personalNotes: notes,
        );
        setState(() => _isFavorited = true);
        AppSnackbar.show(
          title: 'Added',
          message: '${widget.api.name} added to favorites',
        );
      }
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Failed to update favorite',
        isError: true,
      );
    }
  }

  Future<String?> _showAddNotesDialog() async {
    final notesController = TextEditingController();

    return await Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Favorites',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add personal notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: null),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Get.back(result: notesController.text),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final description = _metadata?.description ?? widget.api.description;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: InkWell(
        onTap: _navigateToDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with favicon, name and favorite button
              Row(
                children: [
                  // Favicon
                  if (_metadata?.favicon != null)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _metadata!.favicon!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.api,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.primaryContainer,
                      ),
                      child: Icon(
                        Icons.api,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: 12),
                  // API Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.api.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_metadata?.banner != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _metadata!.banner!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Favorite button
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorited ? Icons.bookmark : Icons.bookmark_border,
                      color: _isFavorited
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: _isFavorited
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Chips row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (widget.api.https.toLowerCase() == 'yes')
                    _buildChip(
                      context,
                      Icons.lock_outline,
                      'HTTPS',
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.onPrimaryContainer,
                    )
                  else
                    _buildChip(
                      context,
                      Icons.lock_open,
                      'HTTP',
                      theme.colorScheme.errorContainer,
                      theme.colorScheme.onErrorContainer,
                    ),
                  if (widget.api.auth.toLowerCase() != 'no' &&
                      widget.api.auth.isNotEmpty)
                    _buildChip(
                      context,
                      Icons.key_outlined,
                      widget.api.auth.toLowerCase() == 'apikey'
                          ? 'API Key'
                          : 'Auth',
                      theme.colorScheme.secondaryContainer,
                      theme.colorScheme.onSecondaryContainer,
                    ),
                  if (widget.api.cors.toLowerCase() == 'yes')
                    _buildChip(
                      context,
                      Icons.public,
                      'CORS',
                      theme.colorScheme.tertiaryContainer,
                      theme.colorScheme.onTertiaryContainer,
                    ),
                ],
              ),
              // Loading indicator
              if (_loadingMetadata)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}
