import 'package:flutter_test/flutter_test.dart';
import 'package:rolevia/core/config/app_config.dart';
import 'package:rolevia/data/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    test('enforces exact duplicate email error string contract', () {
      expect(
        AuthRepository.duplicateEmail,
        equals('An account with this email already exists. Please sign in instead.'),
      );
    });

    test('unconfigured repository reports unauthenticated and null user', () {
      AppConfig.configuredOverride = false;
      addTearDown(() => AppConfig.configuredOverride = null);
      final repo = AuthRepository();
      expect(repo.user, isNull);
      expect(repo.authenticated, isFalse);
    });

    test('accessing client on unconfigured repository throws StateError with setup message', () {
      AppConfig.configuredOverride = false;
      addTearDown(() => AppConfig.configuredOverride = null);
      final repo = AuthRepository();
      expect(
        () => repo.client,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Set SUPABASE_URL and SUPABASE_ANON_KEY'),
          ),
        ),
      );
    });
  });
}
