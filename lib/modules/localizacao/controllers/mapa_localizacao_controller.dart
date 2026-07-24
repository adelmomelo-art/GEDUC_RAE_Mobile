import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Origem da posição atualmente exibida no mapa.
enum MapaLocalizacaoOrigem {
  inicial,
  gps,
  endereco,
  selecaoManual,
}

/// Estado e comandos do mapa de localização.
///
/// Este controller pertence ao módulo de interface porque depende
/// diretamente do [MapController] do flutter_map.
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
        _coordenada = centroInicial;

  final MapController _mapController;
  final LatLng _centroInicial;
  final double _zoomInicial;
  final double _zoomLocalizacao;

  LatLng _coordenada;
  MapaLocalizacaoOrigem _origem = MapaLocalizacaoOrigem.inicial;
  bool _possuiLocalizacao = false;
  bool _mapaPronto = false;

  MapController get mapController => _mapController;
  LatLng get coordenada => _coordenada;
  MapaLocalizacaoOrigem get origem => _origem;
  bool get possuiLocalizacao => _possuiLocalizacao;
  bool get mapaPronto => _mapaPronto;

  double get zoomAtual {
    return _possuiLocalizacao ? _zoomLocalizacao : _zoomInicial;
  }

  void marcarMapaComoPronto() {
    if (_mapaPronto) {
      return;
    }

    _mapaPronto = true;

    if (_possuiLocalizacao) {
      centralizar();
    }

    notifyListeners();
  }

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

  void centralizar() {
    if (!_mapaPronto) {
      return;
    }

    _mapController.move(
      _coordenada,
      zoomAtual,
    );
  }

  void restaurarCentroInicial() {
    _coordenada = _centroInicial;
    _origem = MapaLocalizacaoOrigem.inicial;
    _possuiLocalizacao = false;

    if (_mapaPronto) {
      _mapController.move(
        _centroInicial,
        _zoomInicial,
      );
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
      return;
    }

    _coordenada = LatLng(latitude, longitude);
    _origem = origem;
    _possuiLocalizacao = true;

    if (centralizarMapa && _mapaPronto) {
      _mapController.move(
        _coordenada,
        _zoomLocalizacao,
      );
    }

    notifyListeners();
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
