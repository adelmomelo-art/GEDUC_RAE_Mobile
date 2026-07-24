/// Representa o estado operacional do mapa de localização.
///
/// Esta classe mantém apenas os dados necessários para controlar:
/// - carregamento do mapa;
/// - obtenção da localização atual;
/// - seleção manual de coordenadas;
/// - mensagens de erro.
///
/// O [MapaLocalizacaoController] continuará sendo o ponto único
/// de acesso e alteração deste estado.
class MapState {
  const MapState({
    this.latitude,
    this.longitude,
    this.isMapaCarregando = false,
    this.isLocalizacaoCarregando = false,
    this.isPontoSelecionadoManualmente = false,
    this.mensagemErro,
  });

  /// Latitude atualmente selecionada no mapa.
  final double? latitude;

  /// Longitude atualmente selecionada no mapa.
  final double? longitude;

  /// Indica que o componente visual do mapa está sendo carregado.
  final bool isMapaCarregando;

  /// Indica que a localização atual do dispositivo está sendo obtida.
  final bool isLocalizacaoCarregando;

  /// Indica que o ponto atual foi escolhido manualmente pelo usuário.
  final bool isPontoSelecionadoManualmente;

  /// Mensagem de erro relacionada ao mapa ou à localização.
  final String? mensagemErro;

  /// Retorna verdadeiro quando existe uma coordenada válida selecionada.
  bool get possuiCoordenada =>
      latitude != null &&
      longitude != null &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180;

  /// Cria uma nova instância preservando os valores não modificados.
  MapState copyWith({
    double? latitude,
    double? longitude,
    bool? isMapaCarregando,
    bool? isLocalizacaoCarregando,
    bool? isPontoSelecionadoManualmente,
    String? mensagemErro,
    bool limparCoordenada = false,
    bool limparErro = false,
  }) {
    return MapState(
      latitude: limparCoordenada ? null : latitude ?? this.latitude,
      longitude: limparCoordenada ? null : longitude ?? this.longitude,
      isMapaCarregando: isMapaCarregando ?? this.isMapaCarregando,
      isLocalizacaoCarregando:
          isLocalizacaoCarregando ?? this.isLocalizacaoCarregando,
      isPontoSelecionadoManualmente:
          isPontoSelecionadoManualmente ??
          this.isPontoSelecionadoManualmente,
      mensagemErro: limparErro ? null : mensagemErro ?? this.mensagemErro,
    );
  }

  /// Estado inicial utilizado na abertura da tela.
  factory MapState.inicial() {
    return const MapState(
      isMapaCarregando: true,
    );
  }

  @override
  String toString() {
    return 'MapState('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'isMapaCarregando: $isMapaCarregando, '
        'isLocalizacaoCarregando: $isLocalizacaoCarregando, '
        'isPontoSelecionadoManualmente: '
        '$isPontoSelecionadoManualmente, '
        'mensagemErro: $mensagemErro'
        ')';
  }
}