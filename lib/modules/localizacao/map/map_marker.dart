/// Representa o marcador utilizado no mapa.
///
/// Esta classe contém apenas o estado necessário para identificar
/// a posição atual do marcador e sua origem.
///
/// Toda a lógica de movimentação permanece no
/// [MapaLocalizacaoController].
class MapMarker {
  const MapMarker({
    required this.latitude,
    required this.longitude,
    this.id = 'localizacao_principal',
    this.arrastavel = true,
    this.visivel = true,
    this.selecionadoManualmente = false,
  });

  /// Identificador único do marcador.
  final String id;

  /// Latitude.
  final double latitude;

  /// Longitude.
  final double longitude;

  /// Permite arrastar o marcador.
  final bool arrastavel;

  /// Controla a visibilidade.
  final bool visivel;

  /// Indica se a posição foi definida manualmente.
  final bool selecionadoManualmente;

  /// Verifica se a coordenada é válida.
  bool get possuiCoordenadaValida =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// Atualiza parcialmente o marcador.
  MapMarker copyWith({
    String? id,
    double? latitude,
    double? longitude,
    bool? arrastavel,
    bool? visivel,
    bool? selecionadoManualmente,
  }) {
    return MapMarker(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      arrastavel: arrastavel ?? this.arrastavel,
      visivel: visivel ?? this.visivel,
      selecionadoManualmente:
          selecionadoManualmente ?? this.selecionadoManualmente,
    );
  }

  @override
  String toString() {
    return 'MapMarker('
        'id: $id, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'arrastavel: $arrastavel, '
        'visivel: $visivel, '
        'selecionadoManualmente: $selecionadoManualmente'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MapMarker &&
            other.id == id &&
            other.latitude == latitude &&
            other.longitude == longitude &&
            other.arrastavel == arrastavel &&
            other.visivel == visivel &&
            other.selecionadoManualmente == selecionadoManualmente;
  }

  @override
  int get hashCode => Object.hash(
        id,
        latitude,
        longitude,
        arrastavel,
        visivel,
        selecionadoManualmente,
      );
}