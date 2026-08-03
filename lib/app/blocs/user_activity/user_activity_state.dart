import 'package:equatable/equatable.dart';

class UserActivityState extends Equatable {
  final int totalBookmarks;
  final int totalProjects;
  final int totalProjectItems;
  final int daysSinceCreation;
  final bool isLoading;

  const UserActivityState({
    this.totalBookmarks = 0,
    this.totalProjects = 0,
    this.totalProjectItems = 0,
    this.daysSinceCreation = 0,
    this.isLoading = false,
  });

  UserActivityState copyWith({
    int? totalBookmarks,
    int? totalProjects,
    int? totalProjectItems,
    int? daysSinceCreation,
    bool? isLoading,
  }) {
    return UserActivityState(
      totalBookmarks: totalBookmarks ?? this.totalBookmarks,
      totalProjects: totalProjects ?? this.totalProjects,
      totalProjectItems: totalProjectItems ?? this.totalProjectItems,
      daysSinceCreation: daysSinceCreation ?? this.daysSinceCreation,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        totalBookmarks,
        totalProjects,
        totalProjectItems,
        daysSinceCreation,
        isLoading,
      ];
}
