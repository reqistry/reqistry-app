import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserProfile profile;

  const Authenticated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final bool isRegisterMode;
  final UserProfile? profile;

  const AuthError({
    required this.message,
    this.isRegisterMode = false,
    this.profile,
  });

  @override
  List<Object?> get props => [message, isRegisterMode, profile?.id];
}

class UserProfile extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String authProvider;
  final DateTime createdAt;
  final DateTime? memberSince;
  final DateTime? lastUsedAt;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    required this.authProvider,
    required this.createdAt,
    this.memberSince,
    this.lastUsedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'],
      authProvider: json['authProvider'] ?? 'anonymous',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      memberSince: json['memberSince'] != null
          ? DateTime.tryParse(json['memberSince'])
          : null,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.tryParse(json['lastUsedAt'])
          : null,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? authProvider,
    DateTime? createdAt,
    DateTime? memberSince,
    DateTime? lastUsedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      memberSince: memberSince ?? this.memberSince,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, authProvider, createdAt, memberSince, lastUsedAt];
}

class UserStats extends Equatable {
  final int totalBookmarks;
  final int totalProjects;
  final int totalProjectItems;
  final int daysSinceCreation;

  const UserStats({
    this.totalBookmarks = 0,
    this.totalProjects = 0,
    this.totalProjectItems = 0,
    this.daysSinceCreation = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalBookmarks: json['totalBookmarks'] ?? 0,
      totalProjects: json['totalFolders'] ?? 0,
      totalProjectItems: json['totalFolderItems'] ?? 0,
      daysSinceCreation: json['daysSinceCreation'] ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [totalBookmarks, totalProjects, totalProjectItems, daysSinceCreation];
}
