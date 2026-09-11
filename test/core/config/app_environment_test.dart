import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/config/app_environment.dart';

void main() {
  group('AppEnvironmentConfig.resolve', () {
    test('resolve nomes oficiais', () {
      expect(AppEnvironmentConfig.resolve('development'),
          AppEnvironment.development);
      expect(AppEnvironmentConfig.resolve('homologacao'),
          AppEnvironment.homologacao);
      expect(AppEnvironmentConfig.resolve('production'),
          AppEnvironment.production);
    });

    test('resolve aliases conhecidos', () {
      expect(AppEnvironmentConfig.resolve(' DEV '), AppEnvironment.development);
      expect(AppEnvironmentConfig.resolve('HML'), AppEnvironment.homologacao);
      expect(
          AppEnvironmentConfig.resolve('staging'), AppEnvironment.homologacao);
      expect(AppEnvironmentConfig.resolve('PROD'), AppEnvironment.production);
    });

    test('ausente ou desconhecido fica nao definido', () {
      expect(AppEnvironmentConfig.resolve(null), AppEnvironment.undefined);
      expect(AppEnvironmentConfig.resolve(''), AppEnvironment.undefined);
      expect(AppEnvironmentConfig.resolve('qualquer-coisa'),
          AppEnvironment.undefined);
    });
  });

  test('labels institucionais sao estaveis', () {
    expect(AppEnvironmentConfig.label(AppEnvironment.development),
        'DESENVOLVIMENTO');
    expect(
        AppEnvironmentConfig.label(AppEnvironment.homologacao), 'HOMOLOGAÇÃO');
    expect(AppEnvironmentConfig.label(AppEnvironment.production), 'PRODUÇÃO');
    expect(
        AppEnvironmentConfig.label(AppEnvironment.undefined), 'NÃO DEFINIDO');
  });
}
