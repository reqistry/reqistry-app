import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/data/models/project_detail.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit() : super(const ProjectsState());

  Future<void> loadProjects({required AppLocalizations l10n}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final response = await DioClient().dio.get('/v1/folders');
      final data = response.data;
      final projects = (data['folders'] as List)
          .whereType<Map<String, dynamic>>()
          .map((f) => Project.fromJson(f))
          .toList();
      emit(state.copyWith(projects: projects, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: l10n.snackbarFailedToLoadProjects,
      ));
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.snackbarFailedToLoadProjects,
        isError: true,
      );
    }
  }

  Future<void> createProject(String title, {IconData? icon, required AppLocalizations l10n}) async {
    try {
      final response = await DioClient().dio.post('/v1/folders',
          data: {
            'title': title,
            'iconCodePoint': icon?.codePoint ?? 0,
          },
          options: Options(
            extra: const {RequestErrorNotifierInterceptor.silentKey: true},
          ));
      final newProject = Project.fromJson(response.data);
      emit(state.copyWith(projects: [...state.projects, newProject]));
      AppSnackBarHelper.show(
        title: l10n.snackbarProjectCreatedTitle,
        message: l10n.snackbarProjectCreatedMessage(title),
      );
    } catch (e) {
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.snackbarFailedToCreateProject,
        isError: true,
      );
    }
  }

  Future<void> updateProject(
    String id, {
    String? title,
    IconData? icon,
    required AppLocalizations l10n,
  }) async {
    try {
      final response = await DioClient().dio.put('/v1/folders/$id',
          data: {
            if (title != null) 'title': title,
            if (icon != null) 'iconCodePoint': icon.codePoint,
          },
          options: Options(
            extra: const {RequestErrorNotifierInterceptor.silentKey: true},
          ));
      final updatedProject = Project.fromJson(response.data);
      final updated = state.projects.map((project) {
        return project.id == id
            ? project.copyWith(
                title: updatedProject.title,
                iconCodePoint: updatedProject.iconCodePoint,
                sortOrder: updatedProject.sortOrder,
                updatedAt: updatedProject.updatedAt,
              )
            : project;
      }).toList();
      emit(state.copyWith(projects: updated));
      AppSnackBarHelper.success(
        title: l10n.snackbarUpdatedTitle,
        message: l10n.snackbarProjectUpdated,
      );
    } catch (_) {
      AppSnackBarHelper.error(
        title: l10n.stateError,
        message: l10n.snackbarFailedToUpdateProject,
      );
    }
  }

  Future<void> deleteProject(String id, {required AppLocalizations l10n}) async {
    try {
      await DioClient().dio.delete('/v1/folders/$id',
          options: Options(
            extra: const {RequestErrorNotifierInterceptor.silentKey: true},
          ));
      final updated = state.projects.where((p) => p.id != id).toList();
      emit(state.copyWith(projects: updated));
      AppSnackBarHelper.show(
        title: l10n.snackbarDeletedTitle,
        message: l10n.snackbarProjectDeleted,
      );
    } catch (e) {
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.snackbarFailedToDeleteProject,
        isError: true,
      );
    }
  }

  Future<bool> addApiToProject(
    String projectId, {
    required String apiId,
    required String apiLink,
    required AppLocalizations l10n,
  }) async {
    final previous = state.projects;
    Project? project;
    for (final item in state.projects) {
      if (item.id == projectId) {
        project = item;
        break;
      }
    }
    if (project == null) return false;
    if (apiId.trim().isEmpty) {
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.snackbarCannotAddToProject,
        isError: true,
      );
      return false;
    }
    final alreadyAdded = project.apiLinks.contains(apiLink);
    if (alreadyAdded) return true;
    emit(state.copyWith(
      projects: state.projects.map((item) {
        if (item.id != projectId) return item;
        return item.copyWith(
          apiLinks: [...item.apiLinks, apiLink],
          apiCount: item.apiCount + 1,
          updatedAt: DateTime.now(),
        );
      }).toList(),
    ));
    try {
      await DioClient().dio.post(
            '/v1/projects/$projectId/apis',
            data: {'apiId': apiId},
            options: Options(extra: const {
              'silentLoader': true,
              RequestErrorNotifierInterceptor.silentKey: true,
            }),
          );
      AppSnackBarHelper.success(
        title: l10n.snackbarAddedTitle,
        message: l10n.snackbarAddedToProject(project.title),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(projects: previous));
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.snackbarCouldNotAddToProject(project.title),
        isError: true,
      );
      return false;
    }
  }

  Future<void> removeApiFromProject(String projectId, String apiLink, {required AppLocalizations l10n}) async {
    try {
      final encodedLink = Uri.encodeComponent(apiLink);
      await DioClient().dio.delete(
            '/v1/folders/$projectId/api-links/$encodedLink',
            options: Options(
              extra: const {RequestErrorNotifierInterceptor.silentKey: true},
            ),
          );
      await loadProjects(l10n: l10n);
      AppSnackBarHelper.success(
        title: l10n.snackbarRemovedTitle,
        message: l10n.snackbarApiRemovedFromProject,
      );
    } catch (e) {
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.snackbarFailedToRemoveFromProject,
        isError: true,
      );
    }
  }

  Future<ProjectDetail> getProject(String id) async {
    final response = await DioClient().dio.get('/v1/folders/$id');
    return ProjectDetail.fromJson(response.data);
  }

  Future<ProjectMetadata> getProjectMetadata(String id) async {
    final response = await DioClient().dio.get('/v1/folders/$id/metadata');
    return ProjectMetadata.fromJson(response.data);
  }
}
