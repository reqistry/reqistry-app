import 'dart:async';

import 'package:api_scout/app/data/models/api.dart' as legacy;
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/services/api_detail/api_detail_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'api_detail_state.dart';

class ApiDetailCubit extends Cubit<ApiDetailState> {
  ApiDetailCubit({
    required this.slug,
    this.seed,
    ApiDetailRepository? repository,
  })  : _repository = repository ?? CachedApiDetailRepository.instance,
        super(
          _initialState(
            slug,
            seed,
            repository ?? CachedApiDetailRepository.instance,
          ),
        ) {
    unawaited(load());
  }

  final String slug;
  final legacy.Api? seed;
  final ApiDetailRepository _repository;

  static ApiDetailState _initialState(
    String slug,
    legacy.Api? seed,
    ApiDetailRepository repository,
  ) {
    final detail = repository.readCached(slug) ??
        (seed == null ? null : ApiDetail.fromApi(seed, routeSlug: slug));
    return ApiDetailState(
      detail: detail,
      isLoadingCore: detail == null,
      isRefreshingCore: detail != null,
    );
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (state.detail == null) {
      emit(state.copyWith(isLoadingCore: true, clearCoreError: true));
    } else {
      emit(state.copyWith(isRefreshingCore: true, clearCoreError: true));
    }

    try {
      final detail = await _repository.load(
        slug: slug,
        seed: seed,
        forceRefresh: forceRefresh,
      );
      if (isClosed) return;
      emit(state.copyWith(
        detail: detail,
        isLoadingCore: false,
        isRefreshingCore: false,
        clearCoreError: true,
      ));
      if (!detail.health.isFresh) {
        unawaited(forceRefresh ? refreshHealth() : _refreshStaleHealth(detail));
      }
      unawaited(loadAlternatives(forceRefresh: forceRefresh));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingCore: false,
        isRefreshingCore: false,
        coreError: state.detail == null
            ? 'This API could not be loaded.'
            : 'Fresh API information is temporarily unavailable.',
      ));
    }
  }

  Future<void> refresh() async {
    await load(forceRefresh: true);
  }

  Future<void> loadAlternatives({bool forceRefresh = false}) async {
    final detail = state.detail;
    if (detail == null || state.isLoadingAlternatives) return;
    if (!forceRefresh && detail.areAlternativesFresh) return;
    emit(state.copyWith(
      isLoadingAlternatives: true,
      clearAlternativesError: true,
    ));
    try {
      final updated = await _repository.loadAlternatives(detail);
      if (isClosed) return;
      final current = state.detail ?? detail;
      emit(state.copyWith(
        detail: current.copyWith(
          alternatives: updated.alternatives,
          alternativesUpdatedAt: updated.alternativesUpdatedAt,
        ),
        isLoadingAlternatives: false,
        clearAlternativesError: true,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingAlternatives: false,
        alternativesError: 'Similar APIs are unavailable.',
      ));
    }
  }

  Future<void> refreshHealth() async {
    final detail = state.detail;
    if (detail == null || state.isRefreshingHealth) return;
    emit(state.copyWith(
      isRefreshingHealth: true,
      clearHealthError: true,
      clearTransientMessage: true,
    ));
    try {
      final health = await _repository.refreshHealth(detail);
      if (isClosed) return;
      final current = state.detail ?? detail;
      emit(state.copyWith(
        detail: current.copyWith(health: health),
        isRefreshingHealth: false,
        transientMessage: 'Latest platform health result loaded.',
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        isRefreshingHealth: false,
        healthError: 'Health could not be refreshed.',
      ));
    }
  }

  Future<void> _refreshStaleHealth(ApiDetail detail) async {
    if (state.isRefreshingHealth) return;
    emit(state.copyWith(isRefreshingHealth: true, clearHealthError: true));
    try {
      final health = await _repository.refreshHealth(detail);
      if (isClosed) return;
      final current = state.detail ?? detail;
      emit(state.copyWith(
        detail: current.copyWith(health: health),
        isRefreshingHealth: false,
      ));
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
          isRefreshingHealth: false,
          healthError: 'Health could not be refreshed.',
        ));
      }
    }
  }

  Future<bool> reportIssue({
    required String reason,
    String? note,
  }) async {
    final detail = state.detail;
    if (detail == null || state.isReportingIssue) return false;
    emit(state.copyWith(isReportingIssue: true));
    try {
      await _repository.submitReport(
        apiId: detail.id,
        slug: detail.slug,
        reason: reason,
        note: note,
      );
      if (!isClosed) emit(state.copyWith(isReportingIssue: false));
      return true;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isReportingIssue: false));
      return false;
    }
  }
}
