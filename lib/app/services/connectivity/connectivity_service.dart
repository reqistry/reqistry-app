import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/app/utils/dio_connectivity_ext.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  static ConnectivityService get instance => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> isOnline = ValueNotifier(true);
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  RequestOptions? _lastFailedOptions;
  Dio? _lastFailedDio;
  AppLocalizations? _l10n;

  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  void init() {
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online != isOnline.value) {
        isOnline.value = online;
        if (online) {
          _onBackOnline();
        } else {
          notifyOffline();
        }
      }
    });
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final online = results.any((r) => r != ConnectivityResult.none);
      isOnline.value = online;
      if (!online) notifyOffline();
    } catch (_) {}
  }

  void registerFailedRequest(RequestOptions options, Dio dio) {
    _lastFailedOptions = options;
    _lastFailedDio = dio;
  }

  void notifyOffline() {
    AppSnackbarManager.showGlobal(
      title: _l10n?.snackbarNoInternetTitle ?? 'NO INTERNET',
      message: _l10n?.snackbarNoInternetMessage ?? 'You are offline. Check your connection and try again.',
      type: AppSnackbarType.error,
      persistent: true,
      actionLabel: _l10n?.actionRetry ?? 'RETRY',
      onAction: retryLastFailedRequest,
    );
  }

  Future<void> retryLastFailedRequest() async {
    final options = _lastFailedOptions;
    final dio = _lastFailedDio;
    _lastFailedOptions = null;
    _lastFailedDio = null;

    if (options == null || dio == null) {
      AppSnackbarManager.dismissGlobal();
      checkConnectivity();
      return;
    }

    try {
      await dio.fetch(options);
      AppSnackbarManager.success(
        title: _l10n?.snackbarBackOnlineTitle ?? 'BACK ONLINE',
        message: _l10n?.snackbarBackOnlineMessage ?? 'Connection restored',
      );
    } catch (e) {
      if (e is DioException && e.isConnectivityError) {
        registerFailedRequest(options, dio);
        notifyOffline();
      } else {
        AppSnackbarManager.error(
          title: _l10n?.snackbarRequestFailedTitle ?? 'REQUEST FAILED',
          message: _l10n?.snackbarRequestFailedMessage ?? 'The request could not be completed. Please try again.',
        );
      }
    }
  }

  void _onBackOnline() {
    AppSnackbarManager.dismissGlobal();
    retryLastFailedRequest();
  }
}
