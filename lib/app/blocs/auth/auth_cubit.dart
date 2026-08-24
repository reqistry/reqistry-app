import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/app/services/auth/auth_token_service.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/notification/fcm_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class AuthCubit extends Cubit<AuthState> {
  /// Nomenclature used for the app's guest display name before the user sets
  /// a real one.
  static const String guestName = 'Guest';
  static const String guestUser = 'Guest User';

  final AuthTokenService _tokenService = AuthTokenService();
  final Dio _dio = DioClient().dio;
  final Dio _unauthDio = DioClient().unauthDio;

  bool _isRegisterMode = false;

  AuthCubit() : super(const AuthInitial()) {
    _init();
  }

  Future<void> _init() async {
    if (_tokenService.isAuthenticated) {
      DioClient().setAccessToken(_tokenService.accessToken);
      if (_tokenService.isTokenExpired) {
        final newToken = await DioClient().refreshAccessToken();
        if (newToken == null) {
          emit(const Unauthenticated());
          return;
        }
      }
      await _fetchProfile();
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _autoLogin({bool retried = false}) async {
    try {
      emit(AuthLoading());
      final deviceFingerprint = _tokenService.deviceFingerprint;
      final refreshToken = _tokenService.refreshToken;
      final response = await _unauthDio.post(
        '/v1/auth/anonymous',
        data: {
          if (deviceFingerprint != null) 'deviceId': deviceFingerprint,
          if (refreshToken != null && refreshToken.isNotEmpty)
            'refreshToken': refreshToken,
        },
        options: Options(
          extra: const {RequestErrorNotifierInterceptor.silentKey: true},
        ),
      );

      final data = response.data;
      await _tokenService.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'] ?? _tokenService.refreshToken ?? '',
        expiresIn: data['expiresIn'] ?? 900,
        deviceId: data['device']?['id'],
        deviceFingerprint: data['device']?['deviceFingerprint'],
      );
      DioClient().setAccessToken(data['accessToken']);
      await _fetchProfile();

      // Enable FCM after successful authentication
      await _enableFcm();
    } on DioException catch (e) {
      if (shouldResetIdentity(
        statusCode: e.response?.statusCode,
        hasDeviceFingerprint: _tokenService.deviceFingerprint != null,
        hasRefreshToken: _tokenService.refreshToken?.isNotEmpty ?? false,
        alreadyRetried: retried,
      )) {
        await _tokenService.clearTokens();
        DioClient().setAccessToken(null);
        return _autoLogin(retried: true);
      }
      emit(const Unauthenticated());
      rethrow;
    } catch (e) {
      emit(const Unauthenticated());
      rethrow;
    }
  }

  /// The backend rejects a deviceId that is already registered when the
  /// request carries no valid refresh token (409), and rejects replayed
  /// refresh tokens. Stored identity is stale in both cases — clear it and
  /// retry once with a clean slate so the user gets a fresh anonymous
  /// session instead of being stuck unauthenticated forever.
  @visibleForTesting
  static bool shouldResetIdentity({
    required int? statusCode,
    required bool hasDeviceFingerprint,
    required bool hasRefreshToken,
    required bool alreadyRetried,
  }) {
    return !alreadyRetried &&
        statusCode != null &&
        (hasDeviceFingerprint || hasRefreshToken);
  }

  bool get isAuthenticated => state is Authenticated;
  bool get hasActiveSession {
    final s = state;
    return s is Authenticated ||
        (s is AuthError && s.profile != null) ||
        _tokenService.isAuthenticated;
  }

  bool get isRegisterMode => _isRegisterMode;

  String get userEmail {
    final s = state;
    if (s is Authenticated) return s.profile.email ?? 'No email';
    return 'No email';
  }

  String get userName {
    final s = state;
    if (s is Authenticated) return s.profile.name ?? guestName;
    return guestName;
  }

  String get userPhotoUrl => '';
  bool get isGuestUser {
    final s = state;
    if (s is Authenticated) return s.profile.authProvider == 'anonymous';
    return true;
  }

  UserProfile? get currentUserProfile {
    final s = state;
    if (s is Authenticated) return s.profile;
    return null;
  }

  void toggleMode() {
    _isRegisterMode = !_isRegisterMode;
    final s = state;
    if (s is Authenticated) {
      emit(Authenticated(profile: s.profile));
    } else if (s is Unauthenticated) {
      emit(const Unauthenticated());
    }
  }

  Future<void> signInOrRegister({
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _showError(l10n.snackbarFillAllFields, l10n);
      return;
    }

    try {
      emit(AuthLoading());
      if (_isRegisterMode) {
        await _linkEmail(email: email, password: password, l10n: l10n);
      } else {
        await _loginEmail(email: email, password: password, l10n: l10n);
      }
    } on DioException catch (e) {
      final msg = _parseError(e);
      final current = currentUserProfile;
      emit(AuthError(
        message: msg,
        isRegisterMode: _isRegisterMode,
        profile: current,
      ));
    } catch (e) {
      final current = currentUserProfile;
      emit(AuthError(
        message: l10n.snackbarSomethingWentWrong,
        isRegisterMode: _isRegisterMode,
        profile: current,
      ));
    }
  }

  Future<void> continueAsGuest({required AppLocalizations l10n}) async {
    try {
      emit(AuthLoading());
      await _autoLogin();
      _showSuccess(l10n.snackbarContinuingAsGuest, l10n);
    } catch (e) {
      emit(AuthError(
        message: l10n.snackbarUnableToContinueAsGuest,
        isRegisterMode: _isRegisterMode,
      ));
    }
  }

  Future<void> _loginEmail({
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    final response = await _unauthDio.post(
      '/v1/auth/login-email',
      data: {'email': email, 'password': password},
      options: Options(
        extra: const {RequestErrorNotifierInterceptor.silentKey: true},
      ),
    );

    final data = response.data;
    await _tokenService.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      expiresIn: data['expiresIn'] ?? 900,
    );
    DioClient().setAccessToken(data['accessToken']);
    await _fetchProfile();

    // Enable FCM after successful authentication
    await _enableFcm();

    _showSuccess(l10n.snackbarSignedIn, l10n);
  }

  Future<void> _linkEmail({
    required String email,
    required String password,
    String? name,
    required AppLocalizations l10n,
  }) async {
    final response = await _dio.post(
      '/v1/auth/link-email',
      data: {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      },
      options: Options(
        extra: const {RequestErrorNotifierInterceptor.silentKey: true},
      ),
    );

    final data = response.data;

    if (data['merged'] == true && data['accessToken'] != null) {
      await _tokenService.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        expiresIn: data['expiresIn'] ?? 900,
      );
      DioClient().setAccessToken(data['accessToken']);
    }

    await _fetchProfile();
    _showSuccess(l10n.snackbarAccountLinkedSuccessfully, l10n);
  }

  Future<void> signOut({required AppLocalizations l10n}) async {
    try {
      // Disable FCM before signing out
      await _disableFcm();

      final refresh = _tokenService.refreshToken;
      if (refresh != null) {
        try {
          await _dio.post(
            '/v1/auth/revoke',
            data: {'refreshToken': refresh},
            options: Options(
              extra: const {RequestErrorNotifierInterceptor.silentKey: true},
            ),
          );
        } catch (_) {}
      }
      await _tokenService.clearTokens();
      DioClient().setAccessToken(null);
      emit(const Unauthenticated());
    } catch (e) {
      _showError(l10n.snackbarSignOutFailed, l10n);
    }
  }

  Future<void> deleteAccount({required AppLocalizations l10n}) async {
    try {
      // Disable FCM before deleting account
      await _disableFcm();

      // Delete account on backend
      final response = await _dio.delete(
        '/v1/auth/me',
        options: Options(
          extra: const {RequestErrorNotifierInterceptor.silentKey: true},
        ),
      );
      if (response.data['success'] != true) {
        _showError(l10n.snackbarFailedToDeleteAccount, l10n);
        return;
      }

      // Clear local state
      await _tokenService.clearTokens();
      DioClient().setAccessToken(null);
      emit(const Unauthenticated());
      _showSuccess(l10n.snackbarAccountDeleted, l10n);
    } catch (e) {
      _showError(l10n.snackbarFailedToDeleteAccount, l10n);
    }
  }

  Future<void> clearLocalSession() async {
    await _disableFcm();
    await _tokenService.clearTokens();
    DioClient().setAccessToken(null);
    emit(const Unauthenticated());
  }

  Future<void> updateUserProfile(String displayName,
      {required AppLocalizations l10n}) async {
    try {
      final s = state;
      if (s is Authenticated) {
        final response = await _dio.put(
          '/v1/auth/me',
          data: {'name': displayName},
          options: Options(
            extra: const {RequestErrorNotifierInterceptor.silentKey: true},
          ),
        );
        final updatedUser =
            UserProfile.fromJson(response.data['user']).copyWith(
          name: displayName,
        );
        emit(Authenticated(profile: updatedUser));
        _showSuccess(l10n.snackbarProfileUpdated, l10n);
      }
    } catch (e) {
      _showError(l10n.snackbarFailedToUpdateProfile, l10n);
    }
  }

  Future<void> linkAnonymousAccountToEmail({
    required String email,
    required String password,
    String? displayName,
    required AppLocalizations l10n,
  }) async {
    await _linkEmail(
        email: email, password: password, name: displayName, l10n: l10n);
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _dio.get('/v1/auth/me');
      final profile = UserProfile.fromJson(response.data['user']);
      emit(Authenticated(profile: profile));
    } catch (e) {
      if (state is! Authenticated) {
        emit(const Unauthenticated());
      }
    }
  }

  Future<UserStats?> fetchStats() async {
    try {
      final response = await _dio.get('/v1/auth/me');
      return UserStats.fromJson(response.data['stats'] ?? {});
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshProfile() => _fetchProfile();

  /// Enable FCM after authentication
  Future<void> _enableFcm() async {
    try {
      await FcmService().enable();
    } catch (e) {
      debugPrint('[Auth] Failed to enable FCM: $e');
    }
  }

  /// Disable FCM before sign out
  Future<void> _disableFcm() async {
    try {
      await FcmService().disable();
    } catch (e) {
      debugPrint('[Auth] Failed to disable FCM: $e');
    }
  }

  String _parseError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['error'] ?? e.message ?? 'Request failed';
    }
    return e.message ?? 'Network error';
  }

  void _showError(String message, AppLocalizations l10n) {
    AppSnackBarHelper.show(
      title: l10n.snackbarAuthenticationTitle,
      message: message,
      isError: true,
    );
  }

  void _showSuccess(String message, AppLocalizations l10n) {
    AppSnackBarHelper.show(
      title: l10n.snackbarAuthenticationTitle,
      message: message,
    );
  }
}
