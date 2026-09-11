import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/version/app_build_info.dart';

void main() {
  test('expoe versao e build recebidos', () {
    const info = AppBuildInfo(version: '1.0.0', buildNumber: '2');

    expect(info.versionLabel, '1.0.0');
    expect(info.buildLabel, '2');
  });

  test('normaliza espacos', () {
    const info = AppBuildInfo(version: ' 1.0.0 ', buildNumber: ' 2 ');

    expect(info.versionLabel, '1.0.0');
    expect(info.buildLabel, '2');
  });

  test('usa fallback para metadado vazio', () {
    const info = AppBuildInfo(version: ' ', buildNumber: '');

    expect(info.versionLabel, 'não disponível');
    expect(info.buildLabel, 'não disponível');
  });
}
