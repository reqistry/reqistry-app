import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/connectivity/connectivity_service.dart';
import 'package:api_scout/app/services/local_db/hive/privacy_cache_db.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/config/env.dart';

part 'privacy_state.dart';

class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState()) {
    ConnectivityService.instance.isOnline.addListener(_onOnlineChanged);
  }

  Future<void> loadPrivacyContent({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = PrivacyCacheDB.instance.content;
      if (cached != null && cached.isNotEmpty) {
        emit(state.copyWith(isLoading: false, content: cached));
      }
    }

    if (state.content.isEmpty) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    await _fetchRemoteContent();
  }

  Future<void> _fetchRemoteContent() async {
    try {
      final response = await DioClient().unauthDio.get(
            Env.privacyMdUrl,
            options: Options(
              responseType: ResponseType.plain,
              headers: {
                'User-Agent': Env.metadataUserAgent,
              },
            ),
          );
      final content = response.data?.toString() ?? '';
      if (content.isNotEmpty) {
        await PrivacyCacheDB.instance.saveContent(content);
        emit(state.copyWith(
          isLoading: false,
          content: content,
          errorMessage: '',
        ));
      }
    } on DioException catch (e) {
      if (state.content.isEmpty) {
        await _loadBundledFallback(e);
      }
    } catch (_) {
      if (state.content.isEmpty) {
        await _loadBundledFallback();
      }
    }
  }

  Future<void> _loadBundledFallback([DioException? error]) async {
    try {
      final content =
          await rootBundle.loadString('assets/md_content/privacy.md');
      if (content.isNotEmpty) {
        await PrivacyCacheDB.instance.saveContent(content);
        emit(state.copyWith(
          isLoading: false,
          content: content,
          errorMessage: '',
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: error != null && _isConnectivityError(error)
            ? 'No internet connection'
            : 'Failed to load privacy content',
      ));
    }
  }

  bool _isConnectivityError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  void _onOnlineChanged() {
    if (ConnectivityService.instance.isOnline.value) {
      loadPrivacyContent(forceRefresh: true);
    }
  }

  Future<void> navigateToPrivacyPage() async {
    try {
      final uri = Uri.parse(Env.privacyPolicyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        emit(state.copyWith(shouldNavigateToPage: true));
      }
    } catch (e) {
      AppSnackBarHelper.show(
        title: 'Error',
        message: 'Unable to open privacy policy',
        isError: true,
      );
      emit(state.copyWith(shouldNavigateToPage: true));
    }
  }

  void resetNavigationFlag() {
    emit(state.copyWith(shouldNavigateToPage: false));
  }

  @override
  Future<void> close() {
    ConnectivityService.instance.isOnline.removeListener(_onOnlineChanged);
    return super.close();
  }
}
