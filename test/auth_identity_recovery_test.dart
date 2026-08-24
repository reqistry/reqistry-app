import 'package:flutter_test/flutter_test.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';

void main() {
  group('AuthCubit.shouldResetIdentity', () {
    test('resets on 409 when a stale device fingerprint exists', () {
      expect(
        AuthCubit.shouldResetIdentity(
          statusCode: 409,
          hasDeviceFingerprint: true,
          hasRefreshToken: false,
          alreadyRetried: false,
        ),
        isTrue,
      );
    });

    test('resets on 401 when a stale refresh token exists (replay)', () {
      expect(
        AuthCubit.shouldResetIdentity(
          statusCode: 401,
          hasDeviceFingerprint: false,
          hasRefreshToken: true,
          alreadyRetried: false,
        ),
        isTrue,
      );
    });

    test('never resets twice — prevents infinite retry loop', () {
      expect(
        AuthCubit.shouldResetIdentity(
          statusCode: 409,
          hasDeviceFingerprint: true,
          hasRefreshToken: true,
          alreadyRetried: true,
        ),
        isFalse,
      );
    });

    test('network errors without status do not wipe the session', () {
      expect(
        AuthCubit.shouldResetIdentity(
          statusCode: null,
          hasDeviceFingerprint: true,
          hasRefreshToken: true,
          alreadyRetried: false,
        ),
        isFalse,
      );
    });

    test('server 5xx with no stored identity does not reset', () {
      expect(
        AuthCubit.shouldResetIdentity(
          statusCode: 503,
          hasDeviceFingerprint: false,
          hasRefreshToken: false,
          alreadyRetried: false,
        ),
        isFalse,
      );
    });
  });
}
