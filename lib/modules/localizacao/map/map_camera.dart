/// Representa o estado da câmera do mapa.
///
/// Esta classe mantém apenas os dados necessários para controlar:
/// - posição central;
/// - nível de zoom;
/// - inclinação;
/// - orientação.
///
/// O controle de movimentação permanece no
/// [MapaLocalizacaoController].
class MapCamera {
  const MapCamera({
    required this.latitude,
    required this.longitude,
    this.zoom = 16,
    this.inclinacao = 0,
    this.orientacao = 0,
  });

  /// Latitude central da câmera.
  final double latitude;

  /// Longitude central da câmera.
  final double longitude;

  /// Nível de aproximação do mapa.
  final double zoom;

  /// Inclinação visual da câmera.
  final double inclinacao;

  /// Orientação da câmera em graus.
  final double orientacao;

  /// Verifica se a posição central é válida.
  bool get possuiCoordenadaValida =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// Verifica se o nível de zoom é válido.
  bool get possuiZoomValido => zoom >= 0 && zoom <= 25;

  /// Verifica se a configuração completa da câmera é válida.
  bool get isValida => possuiCoordenadaValida && possuiZoomValido;

  /// Atualiza parcialmente os dados da câmera.
  MapCamera copyWith({
    double? latitude,
    double? longitude,
    double? zoom,
    double? inclinacao,
    double? orientacao,
  }) {
    return MapCamera(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
      inclinacao: inclinacao ?? this.inclinacao,
      orientacao: orientacao ?? this.orientacao,
    );
  }

  @override
  String toString() {
    return 'MapCamera('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'zoom: $zoom, '
        'inclinacao: $inclinacao, '
        'orientacao: $orientacao'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MapCamera &&
            other.latitude == latitude &&
            other.longitude == longitude &&
            other.zoom == zoom &&
            other.inclinacao == inclinacao &&
            other.orientacao == orientacao;
  }

  @override
  int get hashCode => Object.hash(
        latitude,
        longitude,
        zoom,
        inclinacao,
        orientacao,
      );
}