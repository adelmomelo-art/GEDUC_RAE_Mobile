import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'localizacao_result.dart';
import 'location_exception.dart';
import 'permission_service.dart';

/// Serviço central de captura de coordenadas da Plataforma Fênix.
///
/// Nenhuma página deve chamar diretamente o Geolocator. A captura,
/// validação e conversão dos dados devem passar por este serviço.
class GpsService {
  const GpsService({
    this.permissionService = const PermissionService(),
  });

  final PermissionService permissionService;

  /// Captura a posição atual do dispositivo.
  ///
  /// [timeout] controla por quanto tempo o aplicativo aguardará o GPS.
  ///
  /// [precisaoMaximaAceitavel] é opcional. Quando informado, a captura
  /// será rejeitada se a precisão, em metros, for superior ao limite.
  Future<LocalizacaoResult> capturarLocalizacaoAtual({
    Duration timeout = const Duration(seconds: 25),
    double? precisaoMaximaAceitavel,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      await permissionService.garantirAcesso();

      final settings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: 0,
        timeLimit: timeout,
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );

      final resultado = _converterPosition(
        position,
        origem: LocalizacaoOrigem.gps,
      );

      _validarResultado(
        resultado,
        precisaoMaximaAceitavel: precisaoMaximaAceitavel,
      );

      return resultado;
    } on LocationException {
      rethrow;
    } on TimeoutException catch (error, stackTrace) {
      throw LocationException.tempoEsgotado(
        originalError: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      throw LocationException.erroDesconhecido(
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Obtém a última posição conhecida pelo sistema operacional.
  ///
  /// Este método não substitui a captura atual. Ele pode ser utilizado
  /// futuramente como resposta rápida ou fallback controlado.
  Future<LocalizacaoResult?> obterUltimaLocalizacaoConhecida() async {
    try {
      await permissionService.garantirAcesso();

      final position = await Geolocator.getLastKnownPosition();

      if (position == null) {
        return null;
      }

      final resultado = _converterPosition(
        position,
        origem: LocalizacaoOrigem.ultimaConhecida,
      );

      if (!resultado.possuiCoordenadasValidas) {
        return null;
      }

      return resultado;
    } on LocationException {
      rethrow;
    } catch (error, stackTrace) {
      throw LocationException.localizacaoIndisponivel(
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> gpsAtivo() {
    return permissionService.servicoLocalizacaoAtivo();
  }

  Future<LocalizacaoPermissionStatus> consultarPermissao() {
    return permissionService.consultarStatus();
  }

  Future<void> abrirConfiguracoesDoAplicativo() {
    return permissionService.abrirConfiguracoesDoAplicativoOuFalhar();
  }

  Future<void> abrirConfiguracoesDeLocalizacao() {
    return permissionService.abrirConfiguracoesDeLocalizacaoOuFalhar();
  }

  LocalizacaoResult _converterPosition(
    Position position, {
    required LocalizacaoOrigem origem,
  }) {
    return LocalizacaoResult(
      latitude: position.latitude,
      longitude: position.longitude,
      precisao: position.accuracy,
      altitude: position.altitude,
      velocidade: position.speed,
      direcao: position.heading,
      dataHoraCaptura: position.timestamp,
      origem: origem,
      isMocked: position.isMocked,
    );
  }

  void _validarResultado(
    LocalizacaoResult resultado, {
    required double? precisaoMaximaAceitavel,
  }) {
    if (!resultado.possuiCoordenadasValidas) {
      throw LocationException.localizacaoIndisponivel();
    }

    if (precisaoMaximaAceitavel == null || precisaoMaximaAceitavel <= 0) {
      return;
    }

    if (!resultado.precisaoDentroDoLimite(
      precisaoMaximaAceitavel,
    )) {
      throw LocationException.precisaoInsuficiente(
        precisaoObtida: resultado.precisao,
        precisaoMaxima: precisaoMaximaAceitavel,
      );
    }
  }
}
