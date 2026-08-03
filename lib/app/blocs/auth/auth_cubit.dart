import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/app/services/auth/auth_token_service.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/notification/fcm_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';

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

  Future<void> _autoLogin() async {
    try {
      emit(AuthLoading());
      final deviceId = _tokenService.getStoredDeviceId();
      final response = await _unauthDio.post(
        '/v1/auth/anonymous',
        data: {
          if (deviceId != null) 'deviceId': deviceId,
        },
        options: Options(
          extra: const {RequestErrorNotifierInterceptor.silentKey: true},
        ),
      );

      final data = response.data;
      await _tokenService.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'] ?? '',
        expiresIn: data['expiresIn'] ?? 900,
        deviceId: data['device']?['id'],
        deviceFingerprint: data['device']?['deviceFingerprint'],
      );
      DioClient().setAccessToken(data['accessToken']);
      await _fetchProfile();

      // Enable FCM after successful authentication
      await _enableFcm();
    } catch (e) {
      emit(const Unauthenticated());
      rethrow;
    }
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
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    try {
      emit(AuthLoading());
      if (_isRegisterMode) {
        await _linkEmail(email: email, password: password);
      } else {
        await _loginEmail(email: email, password: password);
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
        message: 'Something went wrong, try again',
        isRegisterMode: _isRegisterMode,
        profile: current,
      ));
    }
  }

  Future<void> continueAsGuest() async {
    try {
      emit(AuthLoading());
      await _autoLogin();
      _showSuccess('Continuing as guest');
    } catch (e) {
      emit(AuthError(
        message: 'Unable to continue as guest',
        isRegisterMode: _isRegisterMode,
      ));
    }
  }

  Future<void> _loginEmail({
    required String email,
    required String password,
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

    _showSuccess('Signed in');
  }

  Future<void> _linkEmail({
    required String email,
    required String password,
    String? name,
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
    _showSuccess('Account linked successfully');
  }

  Future<void> signOut() async {
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
      _showError('Sign out failed');
    }
  }

  Future<void> deleteAccount() async {
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
        _showError('Failed to delete account');
        return;
      }

      // Clear local state
      await _tokenService.clearTokens();
      DioClient().setAccessToken(null);
      emit(const Unauthenticated());
      _showSuccess('Account deleted');
    } catch (e) {
      _showError('Failed to delete account');
    }
  }

  Future<void> clearLocalSession() async {
    await _disableFcm();
    await _tokenService.clearTokens();
    DioClient().setAccessToken(null);
    emit(const Unauthenticated());
  }

  Future<void> updateUserProfile(String displayName) async {
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
        _showSuccess('Profile updated');
      }
    } catch (e) {
      _showError('Failed to update profile');
    }
  }

  Future<void> linkAnonymousAccountToEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _linkEmail(email: email, password: password, name: displayName);
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

  void _showError(String message) {
    AppSnackBarHelper.show(
      title: 'Authentication',
      message: message,
      isError: true,
    );
  }

  void _showSuccess(String message) {
    AppSnackBarHelper.show(
      title: 'Authentication',
      message: message,
    );
  }
}
