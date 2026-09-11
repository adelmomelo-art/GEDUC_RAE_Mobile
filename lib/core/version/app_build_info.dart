import 'package:package_info_plus/package_info_plus.dart';

final class AppBuildInfo {
  const AppBuildInfo({
    required this.version,
    required this.buildNumber,
  });

  final String version;
  final String buildNumber;

  static Future<AppBuildInfo> load() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return AppBuildInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  String get versionLabel {
    final value = version.trim();
    return value.isEmpty ? 'não disponível' : value;
  }

  String get buildLabel {
    final value = buildNumber.trim();
    return value.isEmpty ? 'não disponível' : value;
  }
}
