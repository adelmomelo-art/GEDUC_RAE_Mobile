import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

abstract final class FirebaseAppCheckBootstrap {
  static const webSiteKeyEnvironmentName = 'FIREBASE_APP_CHECK_WEB_SITE_KEY';

  static const _configuredWebSiteKey = String.fromEnvironment(
    webSiteKeyEnvironmentName,
  );

  @visibleForTesting
  static AndroidAppCheckProvider resolveAndroidProvider({
    required bool debugMode,
  }) {
    return debugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider();
  }

  @visibleForTesting
  static WebProvider resolveWebProvider({
    required bool debugMode,
    String? configuredSiteKey,
  }) {
    if (debugMode) {
      return WebDebugProvider();
    }

    final siteKey = (configuredSiteKey ?? _configuredWebSiteKey).trim();

    if (siteKey.isEmpty) {
      throw StateError(
        '$webSiteKeyEnvironmentName is required for release web builds.',
      );
    }

    return ReCaptchaEnterpriseProvider(siteKey);
  }

  static Future<void> activate() async {
    if (kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: resolveWebProvider(debugMode: kDebugMode),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: resolveAndroidProvider(debugMode: kDebugMode),
      );
      return;
    }

    throw UnsupportedError(
      'Firebase App Check bootstrap is configured only for Android and Web.',
    );
  }
}
