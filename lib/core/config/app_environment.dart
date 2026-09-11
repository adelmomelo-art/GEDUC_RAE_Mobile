enum AppEnvironment {
  development,
  homologacao,
  production,
  undefined,
}

abstract final class AppEnvironmentConfig {
  static const String environmentName = 'APP_ENV';

  static const String _configuredEnvironment = String.fromEnvironment(
    environmentName,
  );

  static AppEnvironment get current => resolve(_configuredEnvironment);

  static AppEnvironment resolve(String? rawValue) {
    final normalized = rawValue?.trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'development':
      case 'dev':
        return AppEnvironment.development;

      case 'homologacao':
      case 'homologação':
      case 'hml':
      case 'staging':
        return AppEnvironment.homologacao;

      case 'production':
      case 'prod':
        return AppEnvironment.production;

      default:
        return AppEnvironment.undefined;
    }
  }

  static String label(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return 'DESENVOLVIMENTO';
      case AppEnvironment.homologacao:
        return 'HOMOLOGAÇÃO';
      case AppEnvironment.production:
        return 'PRODUÇÃO';
      case AppEnvironment.undefined:
        return 'NÃO DEFINIDO';
    }
  }

  static String description(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return 'Compilação destinada a desenvolvimento e validações locais.';
      case AppEnvironment.homologacao:
        return 'Compilação destinada à homologação e validação controlada.';
      case AppEnvironment.production:
        return 'Compilação identificada para uso em produção.';
      case AppEnvironment.undefined:
        return 'Ambiente de compilação não informado.';
    }
  }
}
