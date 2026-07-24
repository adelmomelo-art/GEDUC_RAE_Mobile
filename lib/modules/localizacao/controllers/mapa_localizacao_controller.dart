import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../map/map_camera.dart' as local_map;
import '../map/map_marker.dart';
import '../map/map_state.dart';

/// Origem da posição atualmente exibida no mapa.
enum MapaLocalizacaoOrigem {
  inicial,
  gps,
  endereco,
  selecaoManual,
}

/// Estado e comandos do mapa de localização.
///
/// O controller continua sendo o ponto único de acesso ao mapa.
///
/// Responsabilidades:
/// - integrar a aplicação com o [MapController] do flutter_map;
/// - controlar a coordenada selecionada;
/// - controlar o marcador principal;
/// - controlar a câmera do mapa;
/// - registrar a origem da localização;
/// - notificar a interface sobre mudanças.
class MapaLocalizacaoController extends ChangeNotifier {
  MapaLocalizacaoController({
    MapController? mapController,
    LatLng centroInicial = const LatLng(-3.7319, -38.5267),
    double zoomInicial = 12,
    double zoomLocalizacao = 17,
  })  : _mapController = mapController ?? MapController(),
        _centroInicial = centroInicial,
        _zoomInicial = zoomInicial,
        _zoomLocalizacao = zoomLocalizacao,
        _state = MapState(
          latitude: centroInicial.latitude,
          longitude: centroInicial.longitude,
          isMapaCarregando: true,
        ),
        _camera = local_map.MapCamera(
          latitude: centroInicial.latitude,
          longitude: centroInicial.longitude,
          zoom: zoomInicial,
        );

  final MapController _mapController;
  final LatLng _centroInicial;
  final double _zoomInicial;
  final double _zoomLocalizacao;

  MapState _state;
  MapMarker? _marker;
  local_map.MapCamera _camera;

  MapaLocalizacaoOrigem _origem = MapaLocalizacaoOrigem.inicial;
  bool _mapaPronto = false;
  bool _possuiLocalizacao = false;

  /// Controller nativo utilizado pelo flutter_map.
  MapController get mapController => _mapController;

  /// Estado geral do mapa.
  MapState get state => _state;

  /// Marcador atualmente exibido.
  MapMarker? get marker => _marker;

  /// Configuração atual da câmera da Plataforma Fênix.
  local_map.MapCamera get camera => _camera;

  /// Origem da coordenada atualmente selecionada.
  MapaLocalizacaoOrigem get origem => _origem;

  /// Indica se existe uma localização efetivamente selecionada.
  bool get possuiLocalizacao => _possuiLocalizacao;

  /// Indica se o mapa já concluiu sua inicialização visual.
  bool get mapaPronto => _mapaPronto;

  /// Coordenada atualmente controlada pelo mapa.
  ///
  /// Preserva o contrato anterior do controller, permitindo que
  /// os widgets existentes continuem utilizando [LatLng].
  LatLng get coordenada {
    return LatLng(
      _state.latitude ?? _centroInicial.latitude,
      _state.longitude ?? _centroInicial.longitude,
    );
  }

  /// Zoom atualmente utilizado pela câmera.
  double get zoomAtual => _camera.zoom;

  /// Indica se a posição atual foi selecionada manualmente.
  bool get selecionadoManualmente {
    return _state.isPontoSelecionadoManualmente;
  }

  /// Indica se o mapa está sendo carregado.
  bool get mapaCarregando => _state.isMapaCarregando;

  /// Mensagem de erro atualmente registrada.
  String? get mensagemErro => _state.mensagemErro;

  /// Marca o mapa como pronto para receber comandos de movimentação.
  void marcarMapaComoPronto() {
    if (_mapaPronto) {
      return;
    }

    _mapaPronto = true;

    _state = _state.copyWith(
      isMapaCarregando: false,
      limparErro: true,
    );

    if (_possuiLocalizacao) {
      _moverCamera();
    }

    notifyListeners();
  }

  /// Atualiza a localização com coordenadas obtidas pelo GPS.
  void atualizarPorGps({
    required double latitude,
    required double longitude,
    bool centralizarMapa = true,
  }) {
    _atualizarCoordenada(
      latitude: latitude,
      longitude: longitude,
      origem: MapaLocalizacaoOrigem.gps,
      centralizarMapa: centralizarMapa,
    );
  }

  /// Atualiza a localização com coordenadas obtidas por um endereço.
  void atualizarPorEndereco({
    required double latitude,
    required double longitude,
    bool centralizarMapa = true,
  }) {
    _atualizarCoordenada(
      latitude: latitude,
      longitude: longitude,
      origem: MapaLocalizacaoOrigem.endereco,
      centralizarMapa: centralizarMapa,
    );
  }

  /// Atualiza a localização após seleção manual no mapa.
  void atualizarPorSelecaoManual({
    required double latitude,
    required double longitude,
    bool centralizarMapa = false,
  }) {
    _atualizarCoordenada(
      latitude: latitude,
      longitude: longitude,
      origem: MapaLocalizacaoOrigem.selecaoManual,
      centralizarMapa: centralizarMapa,
    );
  }

  /// Centraliza o mapa na coordenada atualmente selecionada.
  void centralizar() {
    if (!_mapaPronto) {
      return;
    }

    _moverCamera();
  }

  /// Atualiza o nível de zoom controlado pela aplicação.
  void atualizarZoom(double zoom) {
    final novaCamera = _camera.copyWith(zoom: zoom);

    if (!novaCamera.possuiZoomValido) {
      return;
    }

    _camera = novaCamera;

    if (_mapaPronto) {
      _moverCamera();
    }

    notifyListeners();
  }

  /// Informa que uma operação de localização foi iniciada.
  void iniciarCarregamentoLocalizacao() {
    if (_state.isLocalizacaoCarregando) {
      return;
    }

    _state = _state.copyWith(
      isLocalizacaoCarregando: true,
      limparErro: true,
    );

    notifyListeners();
  }

  /// Informa que uma operação de localização foi finalizada.
  void finalizarCarregamentoLocalizacao() {
    if (!_state.isLocalizacaoCarregando) {
      return;
    }

    _state = _state.copyWith(
      isLocalizacaoCarregando: false,
    );

    notifyListeners();
  }

  /// Registra uma mensagem de erro relacionada ao mapa ou à localização.
  void registrarErro(String mensagem) {
    final mensagemTratada = mensagem.trim();

    if (mensagemTratada.isEmpty) {
      return;
    }

    _state = _state.copyWith(
      isLocalizacaoCarregando: false,
      mensagemErro: mensagemTratada,
    );

    notifyListeners();
  }

  /// Remove a mensagem de erro atualmente registrada.
  void limparErro() {
    if (_state.mensagemErro == null) {
      return;
    }

    _state = _state.copyWith(
      limparErro: true,
    );

    notifyListeners();
  }

  /// Restaura a posição e o zoom iniciais do mapa.
  void restaurarCentroInicial() {
    _origem = MapaLocalizacaoOrigem.inicial;
    _possuiLocalizacao = false;
    _marker = null;

    _state = MapState(
      latitude: _centroInicial.latitude,
      longitude: _centroInicial.longitude,
      isMapaCarregando: !_mapaPronto,
    );

    _camera = local_map.MapCamera(
      latitude: _centroInicial.latitude,
      longitude: _centroInicial.longitude,
      zoom: _zoomInicial,
    );

    if (_mapaPronto) {
      _moverCamera();
    }

    notifyListeners();
  }

  void _atualizarCoordenada({
    required double latitude,
    required double longitude,
    required MapaLocalizacaoOrigem origem,
    required bool centralizarMapa,
  }) {
    if (!_coordenadasValidas(
      latitude: latitude,
      longitude: longitude,
    )) {
      registrarErro('As coordenadas informadas são inválidas.');
      return;
    }

    final selecaoManual = origem == MapaLocalizacaoOrigem.selecaoManual;

    _origem = origem;
    _possuiLocalizacao = true;

    _state = _state.copyWith(
      latitude: latitude,
      longitude: longitude,
      isLocalizacaoCarregando: false,
      isPontoSelecionadoManualmente: selecaoManual,
      limparErro: true,
    );

    _marker = MapMarker(
      latitude: latitude,
      longitude: longitude,
      selecionadoManualmente: selecaoManual,
    );

    _camera = _camera.copyWith(
      latitude: latitude,
      longitude: longitude,
      zoom: _zoomLocalizacao,
    );

    if (centralizarMapa && _mapaPronto) {
      _moverCamera();
    }

    notifyListeners();
  }

  void _moverCamera() {
    if (!_mapaPronto || !_camera.isValida) {
      return;
    }

    _mapController.move(
      LatLng(
        _camera.latitude,
        _camera.longitude,
      ),
      _camera.zoom,
    );
  }

  bool _coordenadasValidas({
    required double latitude,
    required double longitude,
  }) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 && longitude == 0);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}