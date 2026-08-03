import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:api_scout/app/widgets/app_snackbar.dart';

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
      title: 'NO INTERNET',
      message: 'You are offline. Check your connection and try again.',
      type: AppSnackbarType.error,
      persistent: true,
      actionLabel: 'RETRY',
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
        title: 'BACK ONLINE',
        message: 'Connection restored',
      );
    } catch (e) {
      if (e is DioException && _isConnectivityError(e)) {
        registerFailedRequest(options, dio);
        notifyOffline();
      } else {
        AppSnackbarManager.error(
          title: 'REQUEST FAILED',
          message: 'The request could not be completed. Please try again.',
        );
      }
    }
  }

  bool _isConnectivityError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  void _onBackOnline() {
    AppSnackbarManager.dismissGlobal();
    retryLastFailedRequest();
  }
}
