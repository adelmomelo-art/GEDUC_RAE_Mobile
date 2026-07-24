import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import 'location_exception.dart';

/// Situação consolidada do acesso à localização.
enum LocalizacaoPermissionStatus {
  concedidaDuranteUso,
  concedidaSempre,
  negada,
  negadaPermanentemente,
  servicoDesativado,
}

/// Serviço responsável exclusivamente pela disponibilidade do GPS
/// e pelas permissões de localização.
///
/// As telas e controladores não devem chamar diretamente:
///
/// - Geolocator.checkPermission;
/// - Geolocator.requestPermission;
/// - Geolocator.isLocationServiceEnabled;
/// - openAppSettings.
class PermissionService {
  const PermissionService();

  Future<bool> servicoLocalizacaoAtivo() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocalizacaoPermissionStatus> consultarStatus() async {
    final servicoAtivo = await servicoLocalizacaoAtivo();

    if (!servicoAtivo) {
      return LocalizacaoPermissionStatus.servicoDesativado;
    }

    final permission = await Geolocator.checkPermission();

    return _converterStatus(permission);
  }

  Future<LocalizacaoPermissionStatus> solicitarPermissao() async {
    final servicoAtivo = await servicoLocalizacaoAtivo();

    if (!servicoAtivo) {
      return LocalizacaoPermissionStatus.servicoDesativado;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return _converterStatus(permission);
  }

  /// Garante que o GPS está ativo e que a permissão foi concedida.
  ///
  /// Quando isso não ocorre, lança uma [LocationException]
  /// padronizada.
  Future<void> garantirAcesso() async {
    final status = await solicitarPermissao();

    switch (status) {
      case LocalizacaoPermissionStatus.concedidaDuranteUso:
      case LocalizacaoPermissionStatus.concedidaSempre:
        return;

      case LocalizacaoPermissionStatus.servicoDesativado:
        throw LocationException.servicoDesativado();

      case LocalizacaoPermissionStatus.negada:
        throw LocationException.permissaoNegada();

      case LocalizacaoPermissionStatus.negadaPermanentemente:
        throw LocationException.permissaoNegadaPermanentemente();
    }
  }

  Future<bool> abrirConfiguracoesDoAplicativo() {
    return openAppSettings();
  }

  Future<void> abrirConfiguracoesDoAplicativoOuFalhar() async {
    final abriu = await abrirConfiguracoesDoAplicativo();

    if (!abriu) {
      throw LocationException.configuracoesNaoAbertas();
    }
  }

  Future<bool> abrirConfiguracoesDeLocalizacao() {
    return Geolocator.openLocationSettings();
  }

  Future<void> abrirConfiguracoesDeLocalizacaoOuFalhar() async {
    final abriu = await abrirConfiguracoesDeLocalizacao();

    if (!abriu) {
      throw LocationException.configuracoesNaoAbertas();
    }
  }

  LocalizacaoPermissionStatus _converterStatus(
    LocationPermission permission,
  ) {
    return switch (permission) {
      LocationPermission.always => LocalizacaoPermissionStatus.concedidaSempre,
      LocationPermission.whileInUse =>
        LocalizacaoPermissionStatus.concedidaDuranteUso,
      LocationPermission.denied => LocalizacaoPermissionStatus.negada,
      LocationPermission.deniedForever =>
        LocalizacaoPermissionStatus.negadaPermanentemente,
      LocationPermission.unableToDetermine =>
        LocalizacaoPermissionStatus.negada,
    };
  }
}
