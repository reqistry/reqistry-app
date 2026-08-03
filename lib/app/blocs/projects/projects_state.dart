import 'package:equatable/equatable.dart';
import 'package:api_scout/app/data/models/project.dart';

class ProjectsState extends Equatable {
  final List<Project> projects;
  final bool isLoading;
  final String errorMessage;

  const ProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  ProjectsState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isEmpty => projects.isEmpty;
  int get count => projects.length;

  @override
  List<Object?> get props => [projects, isLoading, errorMessage];
}
