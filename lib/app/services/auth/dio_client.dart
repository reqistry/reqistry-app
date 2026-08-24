import 'dart:async';
import 'package:dio/dio.dart';
import 'package:api_scout/app/services/connectivity/connectivity_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/widgets/app_busy_overlay.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/config/routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'auth_token_service.dart';

class DioClient {
  static final DioClient _instance = DioClient._();
  factory DioClient() => _instance;

  late final Dio dio;
  late final Dio unauthDio;
  bool _isRefreshing = false;
  final List<Completer<String?>> _pendingRequests = [];

  DioClient._() {
    unauthDio = Dio(BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    dio = Dio(BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    unauthDio.interceptors.add(BusyInterceptor());
    unauthDio.interceptors.add(ConnectivityInterceptor(unauthDio));
    unauthDio.interceptors.add(RequestErrorNotifierInterceptor());
    dio.interceptors.add(BusyInterceptor());
    dio.interceptors.add(AuthInterceptor(this));
    dio.interceptors.add(ConnectivityInterceptor(dio));
    dio.interceptors.add(RequestErrorNotifierInterceptor());

    if (kDebugMode) {
      unauthDio.interceptors.add(RequestsInspectorInterceptor());
      dio.interceptors.add(RequestsInspectorInterceptor());
    }
  }

  void setAccessToken(String? token) {
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  Future<String?> refreshAccessToken() async {
    final tokenService = AuthTokenService();
    final refresh = tokenService.refreshToken;
    if (refresh == null) return null;

    if (_isRefreshing) {
      final completer = Completer<String?>();
      _pendingRequests.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final response = await unauthDio.post(
        '/v1/auth/refresh',
        data: {'refreshToken': refresh},
        options: Options(
            extra: const {RequestErrorNotifierInterceptor.silentKey: true}),
      );

      final data = response.data;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;
      final expiresIn = data['expiresIn'] as int;

      await tokenService.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiresIn: expiresIn,
      );

      setAccessToken(newAccessToken);

      for (final c in _pendingRequests) {
        if (!c.isCompleted) c.complete(newAccessToken);
      }
      _pendingRequests.clear();

      return newAccessToken;
    } on DioException catch (e) {
      // Only discard the session when the server explicitly rejected the
      // refresh token (replay protection, revoked device). Network timeouts
      // and 5xx are transient — keep tokens so the next request retries.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403 || status == 404) {
        await tokenService.clearTokens();
        setAccessToken(null);
      }
      for (final c in _pendingRequests) {
        if (!c.isCompleted) c.complete(null);
      }
      _pendingRequests.clear();
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}

class BusyInterceptor extends Interceptor {
  bool _shouldShow(RequestOptions options) {
    return options.method.toUpperCase() != 'GET' &&
        options.extra['silentLoader'] != true;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldShow(options)) {
      AppBusyOverlay.show();
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_shouldShow(response.requestOptions)) {
      AppBusyOverlay.hide();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldShow(err.requestOptions)) {
      AppBusyOverlay.hide();
    }
    handler.next(err);
  }
}

class ConnectivityInterceptor extends Interceptor {
  final Dio _dio;

  ConnectivityInterceptor(this._dio);

  bool _shouldHandle(RequestOptions options) {
    return options.extra['skipOfflineHandling'] != true;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldHandle(options) &&
        !ConnectivityService.instance.isOnline.value) {
      handler.reject(
        DioException.connectionError(
          requestOptions: options,
          reason: rootNavigatorKey.currentContext != null ? (AppLocalizations.of(rootNavigatorKey.currentContext!)?.snackbarNoInternetMessage ?? 'No internet connection') : 'No internet connection',
        ),
      );
      return;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final service = ConnectivityService.instance;
    final isConnectivityError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (_shouldHandle(err.requestOptions) && isConnectivityError) {
      service.registerFailedRequest(err.requestOptions, _dio);
      service.notifyOffline();
    }
    handler.next(err);
  }
}

class RequestErrorNotifierInterceptor extends Interceptor {
  /// Extra flag that suppresses the automatic error toast for a request that
  /// already communicates its own failure to the user.
  static const String silentKey = 'silentErrorToast';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final method = options.method.toUpperCase();
    final isNonGet = method != 'GET' && method != 'HEAD' && method != 'OPTIONS';

    if (isNonGet && options.extra[silentKey] != true) {
      final isConnectivityError =
          err.type == DioExceptionType.connectionError ||
              err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.sendTimeout ||
              err.type == DioExceptionType.receiveTimeout;

      if (!isConnectivityError && err.type != DioExceptionType.cancel) {
        final context = rootNavigatorKey.currentContext;
        final l10n = context != null ? AppLocalizations.of(context) : null;
        final message = _friendlyMessage(err, l10n);
        if (message != null) {
          AppSnackBarHelper.error(title: l10n?.snackbarRequestFailedTitle ?? 'REQUEST FAILED', message: message);
        }
      }
    }
    handler.next(err);
  }

  String? _friendlyMessage(DioException err, AppLocalizations? l10n) {
    final data = err.response?.data;
    if (data is Map) {
      final error = data['error'];
      final message = data['message'];
      if (error is String && error.trim().isNotEmpty) return error;
      if (message is String && message.trim().isNotEmpty) return message;
    }

    switch (err.type) {
      case DioExceptionType.cancel:
        return null;
      case DioExceptionType.badCertificate:
        return l10n?.errorBadCertificate ?? 'The connection could not be verified securely.';
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        if (status == 429) {
          return l10n?.errorTooManyRequests ?? 'Too many requests. Please wait a moment and try again.';
        }
        if (status >= 500) {
          return l10n?.errorServerError ?? 'The server is having trouble. Please try again later.';
        }
        return l10n?.errorSomethingWentWrong ?? 'Something went wrong. Please try again.';
      default:
        return l10n?.errorSomethingWentWrong ?? 'Something went wrong. Please try again.';
    }
  }
}

class AuthInterceptor extends Interceptor {
  final DioClient _client;

  AuthInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthTokenService().accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final newToken = await _client.refreshAccessToken();
      if (newToken != null && newToken.isNotEmpty) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await _client.dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
    }
    handler.next(err);
  }
}
