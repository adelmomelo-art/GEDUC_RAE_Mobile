import 'package:geocoding/geocoding.dart';

import 'location_exception.dart';

/// Resultado da conversão de um endereço em coordenadas geográficas.
class CoordenadasEnderecoResult {
  const CoordenadasEnderecoResult({
    required this.enderecoPesquisado,
    required this.latitude,
    required this.longitude,
  });

  final String enderecoPesquisado;
  final double latitude;
  final double longitude;
}

/// Serviço responsável pela geocodificação direta.
///
/// Converte um endereço textual em latitude e longitude utilizando
/// o pacote `geocoding`.
///
/// Nenhuma tela da Plataforma Fênix deve chamar diretamente
/// `locationFromAddress()`.
class EnderecoGeocodingService {
  const EnderecoGeocodingService();

  Future<CoordenadasEnderecoResult> buscarCoordenadas(
    String endereco,
  ) async {
    final enderecoNormalizado = endereco.trim();

    if (enderecoNormalizado.isEmpty) {
      throw LocationException.localizacaoIndisponivel();
    }

    try {
      final resultados = await locationFromAddress(enderecoNormalizado);

      if (resultados.isEmpty) {
        throw LocationException.localizacaoIndisponivel();
      }

      final primeiro = resultados.first;

      _validarCoordenadas(
        latitude: primeiro.latitude,
        longitude: primeiro.longitude,
      );

      return CoordenadasEnderecoResult(
        enderecoPesquisado: enderecoNormalizado,
        latitude: primeiro.latitude,
        longitude: primeiro.longitude,
      );
    } on LocationException {
      rethrow;
    } on NoResultFoundException catch (error, stackTrace) {
      throw LocationException.localizacaoIndisponivel(
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

  void _validarCoordenadas({
    required double latitude,
    required double longitude,
  }) {
    final latitudeValida = latitude >= -90 && latitude <= 90;
    final longitudeValida = longitude >= -180 && longitude <= 180;
    final coordenadaNula = latitude == 0 && longitude == 0;

    if (!latitudeValida || !longitudeValida || coordenadaNula) {
      throw LocationException.localizacaoIndisponivel();
    }
  }
}
