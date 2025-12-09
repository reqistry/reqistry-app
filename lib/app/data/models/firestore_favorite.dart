import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreFavorite {
  final String id; // Unique favorite ID
  final String userId;
  final String apiName;
  final String apiLink;
  final String category;
  final String description;
  final String auth;
  final String https;
  final String cors;
  final String? personalNotes; // User's personal notes about the API
  final DateTime addedAt;
  final DateTime? updatedAt;

  FirestoreFavorite({
    required this.id,
    required this.userId,
    required this.apiName,
    required this.apiLink,
    required this.category,
    required this.description,
    required this.auth,
    required this.https,
    required this.cors,
    this.personalNotes,
    required this.addedAt,
    this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'apiName': apiName,
      'apiLink': apiLink,
      'category': category,
      'description': description,
      'auth': auth,
      'https': https,
      'cors': cors,
      'personalNotes': personalNotes,
      'addedAt': addedAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  // Create from Firestore document
  factory FirestoreFavorite.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FirestoreFavorite(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      apiName: data['apiName'] ?? '',
      apiLink: data['apiLink'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      auth: data['auth'] ?? '',
      https: data['https'] ?? '',
      cors: data['cors'] ?? '',
      personalNotes: data['personalNotes'],
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Copy with for updates
  FirestoreFavorite copyWith({
    String? id,
    String? userId,
    String? apiName,
    String? apiLink,
    String? category,
    String? description,
    String? auth,
    String? https,
    String? cors,
    String? personalNotes,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return FirestoreFavorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      apiName: apiName ?? this.apiName,
      apiLink: apiLink ?? this.apiLink,
      category: category ?? this.category,
      description: description ?? this.description,
      auth: auth ?? this.auth,
      https: https ?? this.https,
      cors: cors ?? this.cors,
      personalNotes: personalNotes ?? this.personalNotes,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
