/// Origem técnica da coordenada registrada.
enum LocalizacaoOrigem {
  gps,
  ultimaConhecida,
  manual,
  mapa,
}

/// Resultado padronizado de uma captura de localização.
///
/// Este modelo é independente do pacote Geolocator. Dessa forma,
/// as camadas superiores da aplicação não precisam conhecer a
/// implementação usada para obter as coordenadas.
class LocalizacaoResult {
  const LocalizacaoResult({
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.dataHoraCaptura,
    required this.origem,
    this.altitude = 0,
    this.velocidade = 0,
    this.direcao = 0,
    this.isMocked = false,
  });

  final double latitude;
  final double longitude;

  /// Precisão horizontal estimada, em metros.
  ///
  /// Quanto menor o valor, maior a precisão da captura.
  final double precisao;

  /// Altitude em relação ao nível do mar, em metros.
  final double altitude;

  /// Velocidade estimada, em metros por segundo.
  final double velocidade;

  /// Direção do deslocamento, em graus.
  final double direcao;

  final DateTime dataHoraCaptura;
  final LocalizacaoOrigem origem;

  /// Indica se o sistema operacional informou que a localização
  /// foi simulada.
  final bool isMocked;

  bool get possuiCoordenadasValidas {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 && longitude == 0);
  }

  bool precisaoDentroDoLimite(double limiteEmMetros) {
    return precisao > 0 && precisao <= limiteEmMetros;
  }

  String get coordenadasFormatadas {
    return '${latitude.toStringAsFixed(6)}, '
        '${longitude.toStringAsFixed(6)}';
  }

  String get precisaoFormatada {
    if (precisao <= 0) {
      return 'Não informada';
    }

    return '${precisao.toStringAsFixed(1)} m';
  }

  LocalizacaoResult copyWith({
    double? latitude,
    double? longitude,
    double? precisao,
    double? altitude,
    double? velocidade,
    double? direcao,
    DateTime? dataHoraCaptura,
    LocalizacaoOrigem? origem,
    bool? isMocked,
  }) {
    return LocalizacaoResult(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      precisao: precisao ?? this.precisao,
      altitude: altitude ?? this.altitude,
      velocidade: velocidade ?? this.velocidade,
      direcao: direcao ?? this.direcao,
      dataHoraCaptura: dataHoraCaptura ?? this.dataHoraCaptura,
      origem: origem ?? this.origem,
      isMocked: isMocked ?? this.isMocked,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'precisao': precisao,
      'altitude': altitude,
      'velocidade': velocidade,
      'direcao': direcao,
      'dataHoraCaptura': dataHoraCaptura.toIso8601String(),
      'origem': origem.name,
      'isMocked': isMocked,
    };
  }

  factory LocalizacaoResult.fromMap(Map<String, dynamic> map) {
    return LocalizacaoResult(
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      precisao: _toDouble(map['precisao']),
      altitude: _toDouble(map['altitude']),
      velocidade: _toDouble(map['velocidade']),
      direcao: _toDouble(map['direcao']),
      dataHoraCaptura: _toDateTime(map['dataHoraCaptura']),
      origem: _origemFromValue(map['origem']),
      isMocked: map['isMocked'] == true,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static LocalizacaoOrigem _origemFromValue(dynamic value) {
    final nome = value?.toString();

    return LocalizacaoOrigem.values.firstWhere(
      (origem) => origem.name == nome,
      orElse: () => LocalizacaoOrigem.gps,
    );
  }

  @override
  String toString() {
    return 'LocalizacaoResult('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'precisao: $precisao, '
        'origem: ${origem.name}, '
        'dataHoraCaptura: $dataHoraCaptura'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LocalizacaoResult &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.precisao == precisao &&
        other.altitude == altitude &&
        other.velocidade == velocidade &&
        other.direcao == direcao &&
        other.dataHoraCaptura == dataHoraCaptura &&
        other.origem == origem &&
        other.isMocked == isMocked;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      precisao,
      altitude,
      velocidade,
      direcao,
      dataHoraCaptura,
      origem,
      isMocked,
    );
  }
}
