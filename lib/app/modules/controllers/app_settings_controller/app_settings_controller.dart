import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/routes/app_pages.dart';
import 'package:public_apis_desktop_client/app/services/local_db/hive/constants/boxes.dart';
import 'package:public_apis_desktop_client/app/services/local_db/hive/favorites_db.dart';
import 'package:public_apis_desktop_client/app/services/share/share_plus/share_plus.dart';
import 'package:public_apis_desktop_client/app/utils/snackbar_helper.dart';
import 'package:public_apis_desktop_client/app/utils/themes.dart';
import 'package:public_apis_desktop_client/app/services/firestore/firestore_favorites_service.dart';

import '../../../data/models/favoriteApi.dart';

class AppSettingsController extends GetxController {
  final FavoritesDB favorites = FavoritesDB.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<Color> selectedColor = AppThemes().lastSavedThemeColor.obs;

  Future<void> deleteAllBookmarks() async {
    try {
      await favorites.clear();
      final user = _auth.currentUser;
      if (user != null) {
        // Also clear the remote favorites for the signed-in user.
        await FirestoreFavoritesService().clearAllFavorites();
      }
      AppSnackbar.show(
        title: 'Bookmarks deleted',
        message: _auth.currentUser != null
            ? 'All saved APIs have been removed locally and from your account.'
            : 'All saved APIs have been removed locally.',
      );
    } catch (_) {
      AppSnackbar.show(
        title: 'Delete failed',
        message: 'Unable to delete bookmarks right now.',
        isError: true,
      );
    }
  }

  Future<void> setThemeColor(Color color) async {
    try {
      if (color.value == selectedColor.value) {
        return;
      }
      selectedColor.value = color;
      await AppThemes()
          .locals
          .putWithKey('lastSavedThemeColorValue', color.value);
      final updatedTheme = AppThemes.themeDataBasedOnColor(color);
      Get.changeTheme(updatedTheme);
      Get.changeThemeMode(ThemeMode.light);
      Get.forceAppUpdate();
      AppSnackbar.show(
        title: 'Theme updated',
        message: 'Base color updated for the app.',
      );
    } catch (_) {
      AppSnackbar.show(
        title: 'Update failed',
        message: 'Could not apply the selected color.',
        isError: true,
      );
    }
  }

  Future<void> exportFavorites() async {
    final values = HiveBoxes.favoritesBox.values.toList(growable: false);
    if (values.isEmpty) {
      AppSnackbar.show(
        title: 'No favorites',
        message: 'You have no favorites to export.',
      );
      return;
    }

    final buffer = StringBuffer()
      ..writeln('Favorite APIs')
      ..writeln('--------------------');

    for (final FavoriteApi fav in values) {
      buffer
        ..writeln('- ${fav.name}')
        ..writeln('  ${fav.description}')
        ..writeln('  ${fav.link}')
        ..writeln();
    }

    try {
      await ShareService.instance.shareText(buffer.toString());
    } catch (_) {
      AppSnackbar.show(
        title: 'Export failed',
        message: 'Could not export favorites. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      AppSnackbar.show(
        title: 'No account',
        message: 'You need to be signed in to delete your account.',
      );
      return;
    }

    try {
      await user.delete();
      await _auth.signOut();
      Get.offAllNamed(Routes.auth);
      AppSnackbar.show(
        title: 'Account deleted',
        message: 'Your account has been deleted.',
      );
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? 'Please reauthenticate before deleting your account.'
          : 'Account deletion failed.';
      AppSnackbar.show(
        title: 'Delete failed',
        message: message,
        isError: true,
      );
    } catch (_) {
      AppSnackbar.show(
        title: 'Delete failed',
        message: 'Unable to delete the account right now.',
        isError: true,
      );
    }
  }
}
