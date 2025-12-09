import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/firestore_favorite.dart';

class FirestoreFavoritesService {
  static final FirestoreFavoritesService _instance =
      FirestoreFavoritesService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory FirestoreFavoritesService() {
    return _instance;
  }

  FirestoreFavoritesService._internal();

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  /// Get collection reference for current user's favorites
  CollectionReference<Map<String, dynamic>> get _userFavoritesCollection =>
      _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites');

  /// Add an API to favorites with optional personal notes
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
    if (_currentUserId.isEmpty) throw Exception('User not authenticated');

    final favorite = FirestoreFavorite(
      id: const Uuid().v4(),
      userId: _currentUserId,
      apiName: apiName,
      apiLink: apiLink,
      category: category,
      description: description,
      auth: auth,
      https: https,
      cors: cors,
      personalNotes: personalNotes,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _userFavoritesCollection.doc(favorite.id).set(favorite.toFirestore());
  }

  /// Get all favorites for current user
  Future<List<FirestoreFavorite>> getFavorites() async {
    if (_currentUserId.isEmpty) return [];

    final snapshot = await _userFavoritesCollection.get();
    return snapshot.docs
        .map((doc) => FirestoreFavorite.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ))
        .toList();
  }

  /// Stream of favorites for real-time updates
  Stream<List<FirestoreFavorite>> getFavoritesStream() {
    if (_currentUserId.isEmpty) {
      return Stream.value([]);
    }

    return _userFavoritesCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => FirestoreFavorite.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ))
        .toList());
  }

  /// Update personal notes for a favorite
  Future<void> updatePersonalNotes({
    required String favoriteId,
    required String? personalNotes,
  }) async {
    if (_currentUserId.isEmpty) throw Exception('User not authenticated');

    await _userFavoritesCollection.doc(favoriteId).update({
      'personalNotes': personalNotes,
      'updatedAt': DateTime.now(),
    });
  }

  /// Remove a favorite
  Future<void> removeFavorite(String favoriteId) async {
    if (_currentUserId.isEmpty) throw Exception('User not authenticated');

    await _userFavoritesCollection.doc(favoriteId).delete();
  }

  /// Check if an API is favorited
  Future<bool> isFavorited(String apiLink) async {
    if (_currentUserId.isEmpty) return false;

    final snapshot = await _userFavoritesCollection
        .where('apiLink', isEqualTo: apiLink)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get a specific favorite by API link
  Future<FirestoreFavorite?> getFavoriteByLink(String apiLink) async {
    if (_currentUserId.isEmpty) return null;

    final snapshot = await _userFavoritesCollection
        .where('apiLink', isEqualTo: apiLink)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return FirestoreFavorite.fromFirestore(
      snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>,
    );
  }

  /// Clear all favorites for current user (admin/debug only)
  Future<void> clearAllFavorites() async {
    if (_currentUserId.isEmpty) throw Exception('User not authenticated');

    final snapshot = await _userFavoritesCollection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
