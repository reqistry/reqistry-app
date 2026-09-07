import 'package:equatable/equatable.dart';

class UserActivityState extends Equatable {
  final int totalBookmarks;
  final int totalProjects;
  final int totalProjectItems;
  final int daysSinceCreation;
  final bool isLoading;

  /// Server-side rollup from `GET /v1/stack`. Null/absent while offline
  /// or before the first successful fetch; UI hides the stack row then.
  final int downCount;
  final int? averageTrustScore;

  const UserActivityState({
    this.totalBookmarks = 0,
    this.totalProjects = 0,
    this.totalProjectItems = 0,
    this.daysSinceCreation = 0,
    this.isLoading = false,
    this.downCount = 0,
    this.averageTrustScore,
  });

  UserActivityState copyWith({
    int? totalBookmarks,
    int? totalProjects,
    int? totalProjectItems,
    int? daysSinceCreation,
    bool? isLoading,
    int? downCount,
    int? averageTrustScore,
  }) {
    return UserActivityState(
      totalBookmarks: totalBookmarks ?? this.totalBookmarks,
      totalProjects: totalProjects ?? this.totalProjects,
      totalProjectItems: totalProjectItems ?? this.totalProjectItems,
      daysSinceCreation: daysSinceCreation ?? this.daysSinceCreation,
      isLoading: isLoading ?? this.isLoading,
      downCount: downCount ?? this.downCount,
      averageTrustScore: averageTrustScore ?? this.averageTrustScore,
    );
  }

  @override
  List<Object?> get props => [
        totalBookmarks,
        totalProjects,
        totalProjectItems,
        daysSinceCreation,
        isLoading,
        downCount,
        averageTrustScore,
      ];
}
