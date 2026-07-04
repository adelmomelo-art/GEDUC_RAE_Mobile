import 'package:geolocator/geolocator.dart';

class GeolocalizacaoService {
  Future<bool> servicoHabilitado() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> verificarPermissao() async {
    var permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    return permissao;
  }

  Future<Position?> obterPosicaoAtual() async {
    final habilitado = await servicoHabilitado();

    if (!habilitado) {
      return null;
    }

    final permissao = await verificarPermissao();

    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<Map<String, dynamic>?> obterMetadadosLocalizacao() async {
    final posicao = await obterPosicaoAtual();

    if (posicao == null) {
      return null;
    }

    final agora = DateTime.now();

    return {
      'latitude': posicao.latitude,
      'longitude': posicao.longitude,
      'precisao': posicao.accuracy,
      'altitude': posicao.altitude,
      'dataHora': agora.toIso8601String(),
    };
  }
}