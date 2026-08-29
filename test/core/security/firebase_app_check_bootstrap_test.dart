import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/firebase_app_check_bootstrap.dart';

void main() {
  group('FirebaseAppCheckBootstrap', () {
    test('usa AndroidDebugProvider em debug', () {
      final provider = FirebaseAppCheckBootstrap.resolveAndroidProvider(
        debugMode: true,
      );

      expect(provider, isA<AndroidDebugProvider>());
    });

    test('usa Play Integrity em release Android', () {
      final provider = FirebaseAppCheckBootstrap.resolveAndroidProvider(
        debugMode: false,
      );

      expect(provider, isA<AndroidPlayIntegrityProvider>());
    });

    test('usa WebDebugProvider em debug web', () {
      final provider = FirebaseAppCheckBootstrap.resolveWebProvider(
        debugMode: true,
      );

      expect(provider, isA<WebDebugProvider>());
    });

    test('usa reCAPTCHA Enterprise em release web com site key', () {
      final provider = FirebaseAppCheckBootstrap.resolveWebProvider(
        debugMode: false,
        configuredSiteKey: 'site-key-teste',
      );

      expect(provider, isA<ReCaptchaEnterpriseProvider>());
      expect(provider.siteKey, 'site-key-teste');
    });

    test('falha fechado em release web sem site key', () {
      expect(
        () => FirebaseAppCheckBootstrap.resolveWebProvider(
          debugMode: false,
          configuredSiteKey: '   ',
        ),
        throwsStateError,
      );
    });
  });
}
