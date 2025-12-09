import 'package:get/get.dart';

import '../../data/models/firestore_favorite.dart';
import '../../services/firestore/firestore_favorites_service.dart';
import '../../utils/snackbar_helper.dart';

class FirestoreFavoritesController extends GetxController {
  final FirestoreFavoritesService _favoritesService =
      FirestoreFavoritesService();

  // Public getter for the service
  FirestoreFavoritesService get favoritesService => _favoritesService;

  final RxList<FirestoreFavorite> favorites = <FirestoreFavorite>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<String> selectedNoteId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _loadFavoritesStream();
  }

  /// Listen to real-time favorites updates
  void _loadFavoritesStream() {
    _favoritesService.getFavoritesStream().listen((favs) {
      favorites.value = favs;
    });
  }

  /// Add an API to favorites
  Future<void> addFavorite({
    required String apiName,
    required String apiLink,
    required String category,
    required String description,
    required String auth,
    required String https,
    required String cors,
    String? personalNotes,
  }) async {
    try {
      isLoading.value = true;
      await _favoritesService.addFavorite(
        apiName: apiName,
        apiLink: apiLink,
        category: category,
        description: description,
        auth: auth,
        https: https,
        cors: cors,
        personalNotes: personalNotes,
      );
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Failed to add favorite: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove a favorite
  Future<void> removeFavorite(String favoriteId) async {
    try {
      isLoading.value = true;
      await _favoritesService.removeFavorite(favoriteId);
      favorites.removeWhere((fav) => fav.id == favoriteId);
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Failed to remove favorite: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update personal notes for a favorite
  Future<void> updatePersonalNotes({
    required String favoriteId,
    required String? personalNotes,
  }) async {
    try {
      isLoading.value = true;
      await _favoritesService.updatePersonalNotes(
        favoriteId: favoriteId,
        personalNotes: personalNotes,
      );

      // Update local list
      final index = favorites.indexWhere((fav) => fav.id == favoriteId);
      if (index >= 0) {
        favorites[index] = favorites[index].copyWith(
          personalNotes: personalNotes,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Failed to update notes: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if an API is favorited
  Future<bool> isFavorited(String apiLink) async {
    return await _favoritesService.isFavorited(apiLink);
  }

  /// Get favorite count
  int get favoriteCount => favorites.length;

  /// Get favorites by category
  List<FirestoreFavorite> getFavoritesByCategory(String category) {
    return favorites.where((fav) => fav.category == category).toList();
  }
}
