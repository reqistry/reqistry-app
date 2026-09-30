import 'package:dio/dio.dart';
import 'package:api_scout/app/services/connectivity/connectivity_service.dart';
import 'package:api_scout/app/services/analytics/posthog_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/widgets/app_busy_overlay.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/config/routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'auth_token_service.dart';

class RefreshSingleFlight {
  Future<String?>? _inFlight;

  Future<String?> run(Future<String?> Function() refresh) {
    final current = _inFlight;
    if (current != null) return current;
    final future = _run(refresh);
    _inFlight = future;
    return future;
  }

  Future<String?> _run(Future<String?> Function() refresh) async {
    try {
      return await refresh();
    } finally {
      _inFlight = null;
    }
  }
}

class DioClient {
  static final DioClient _instance = DioClient._();
  factory DioClient() => _instance;

  static const String buildHeader = 'X-Reqistry-App-Build';

  static int buildNumber = 0;

  /// Shared base-options headers applied to both clients so the build rides
  /// on every request.
  static Map<String, dynamic> buildHeadersFor(int buildNumber) =>
      {buildHeader: '$buildNumber'};

  late final Dio dio;
  late final Dio unauthDio;
  final RefreshSingleFlight _refresh = RefreshSingleFlight();

  DioClient._() {
    unauthDio = Dio(BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: buildHeadersFor(buildNumber),
    ));

    dio = Dio(BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: buildHeadersFor(buildNumber),
    ));

    final buildReady = resolveBuildNumber();
    for (final client in [dio, unauthDio]) {
      client.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
        await buildReady;
        options.headers[buildHeader] = '$buildNumber';
        // Links backend events/logs/exceptions to mobile session in replay.
        final tracing = await PostHogService.instance.tracingHeaders();
        for (final entry in tracing.entries) {
          options.headers.putIfAbsent(entry.key, () => entry.value);
        }
        handler.next(options);
      }));
    }
    unauthDio.interceptors.add(BusyInterceptor());
    unauthDio.interceptors.add(ConnectivityInterceptor());
    unauthDio.interceptors.add(RequestErrorNotifierInterceptor());
    dio.interceptors.add(BusyInterceptor());
    dio.interceptors.add(AuthInterceptor(this));
    dio.interceptors.add(ConnectivityInterceptor());
    dio.interceptors.add(RequestErrorNotifierInterceptor());

    if (kDebugMode) {
      unauthDio.interceptors.add(RequestsInspectorInterceptor());
      dio.interceptors.add(RequestsInspectorInterceptor());
    }

  }

  /// Reads the real build number and updates both clients' base options.
  /// Uses zero to fail closed when the platform build is unavailable.
  Future<void> resolveBuildNumber() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final parsed = int.tryParse(info.buildNumber);
      if (parsed == null || parsed <= 0) return;
      buildNumber = parsed;
      dio.options.headers[buildHeader] = '$buildNumber';
      unauthDio.options.headers[buildHeader] = '$buildNumber';
    } catch (_) {}
  }

  void setAccessToken(String? token) {
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  Future<String?> refreshAccessToken() => _refresh.run(_performRefresh);

  Future<String?> _performRefresh() async {
    final tokenService = AuthTokenService();
    final refresh = tokenService.refreshToken;
    if (refresh == null) return null;

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
      return null;
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
          reason: rootNavigatorKey.currentContext != null
              ? (AppLocalizations.of(rootNavigatorKey.currentContext!)
                      ?.snackbarNoInternetMessage ??
                  'No internet connection')
              : 'No internet connection',
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
          AppSnackBarHelper.error(
              title: l10n?.snackbarRequestFailedTitle ?? 'REQUEST FAILED',
              message: message);
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
        return l10n?.errorBadCertificate ??
            'The connection could not be verified securely.';
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        if (status == 429) {
          return l10n?.errorTooManyRequests ??
              'Too many requests. Please wait a moment and try again.';
        }
        if (status >= 500) {
          return l10n?.errorServerError ??
              'The server is having trouble. Please try again later.';
        }
        return l10n?.errorSomethingWentWrong ??
            'Something went wrong. Please try again.';
      default:
        return l10n?.errorSomethingWentWrong ??
            'Something went wrong. Please try again.';
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
