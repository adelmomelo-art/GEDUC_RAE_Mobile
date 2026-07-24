/// Tipos padronizados de falhas relacionadas à localização.
enum LocationExceptionType {
  servicoDesativado,
  permissaoNegada,
  permissaoNegadaPermanentemente,
  tempoEsgotado,
  precisaoInsuficiente,
  localizacaoIndisponivel,
  configuracoesNaoAbertas,
  erroDesconhecido,
}

/// Exceção padronizada da infraestrutura de localização da
/// Plataforma Fênix.
///
/// A interface não deve interpretar diretamente exceções específicas
/// do Geolocator ou do sistema operacional. Todas as falhas de
/// localização devem ser convertidas para esta classe.
class LocationException implements Exception {
  const LocationException({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  final LocationExceptionType type;
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  factory LocationException.servicoDesativado() {
    return const LocationException(
      type: LocationExceptionType.servicoDesativado,
      message:
          'O serviço de localização está desativado. Ative o GPS do aparelho '
          'e tente novamente.',
    );
  }

  factory LocationException.permissaoNegada() {
    return const LocationException(
      type: LocationExceptionType.permissaoNegada,
      message: 'A permissão de localização foi negada. Autorize o acesso para '
          'capturar as coordenadas da ação.',
    );
  }

  factory LocationException.permissaoNegadaPermanentemente() {
    return const LocationException(
      type: LocationExceptionType.permissaoNegadaPermanentemente,
      message: 'A permissão de localização foi bloqueada permanentemente. '
          'Abra as configurações do aplicativo para autorizá-la.',
    );
  }

  factory LocationException.tempoEsgotado({
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return LocationException(
      type: LocationExceptionType.tempoEsgotado,
      message: 'O GPS demorou mais do que o esperado para obter a localização. '
          'Verifique se há visão livre do céu e tente novamente.',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory LocationException.precisaoInsuficiente({
    required double precisaoObtida,
    required double precisaoMaxima,
  }) {
    return LocationException(
      type: LocationExceptionType.precisaoInsuficiente,
      message:
          'A precisão obtida foi de ${precisaoObtida.toStringAsFixed(1)} metros, '
          'acima do limite permitido de '
          '${precisaoMaxima.toStringAsFixed(1)} metros.',
    );
  }

  factory LocationException.localizacaoIndisponivel({
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return LocationException(
      type: LocationExceptionType.localizacaoIndisponivel,
      message: 'Não foi possível obter uma localização válida neste momento.',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory LocationException.configuracoesNaoAbertas() {
    return const LocationException(
      type: LocationExceptionType.configuracoesNaoAbertas,
      message:
          'Não foi possível abrir as configurações do aparelho automaticamente.',
    );
  }

  factory LocationException.erroDesconhecido({
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return LocationException(
      type: LocationExceptionType.erroDesconhecido,
      message:
          'Ocorreu uma falha inesperada durante a obtenção da localização.',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  bool get exigeConfiguracaoManual {
    return type == LocationExceptionType.permissaoNegadaPermanentemente;
  }

  bool get permiteNovaTentativa {
    return switch (type) {
      LocationExceptionType.permissaoNegadaPermanentemente => false,
      LocationExceptionType.configuracoesNaoAbertas => false,
      _ => true,
    };
  }

  @override
  String toString() => 'LocationException(${type.name}): $message';
}
