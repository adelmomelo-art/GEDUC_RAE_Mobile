import 'package:geocoding/geocoding.dart';

import 'location_exception.dart';

/// Endereço obtido a partir de uma coordenada geográfica.
class EnderecoGeocodificado {
  const EnderecoGeocodificado({
    required this.latitude,
    required this.longitude,
    this.logradouro = '',
    this.numero = '',
    this.bairro = '',
    this.cep = '',
    this.municipio = '',
    this.estado = '',
    this.pais = '',
    this.codigoPais = '',
  });

  final double latitude;
  final double longitude;

  final String logradouro;
  final String numero;
  final String bairro;
  final String cep;
  final String municipio;
  final String estado;
  final String pais;
  final String codigoPais;

  bool get possuiEndereco {
    return logradouro.trim().isNotEmpty ||
        bairro.trim().isNotEmpty ||
        municipio.trim().isNotEmpty;
  }

  String get enderecoFormatado {
    final partes = <String>[];

    if (logradouro.trim().isNotEmpty) {
      if (numero.trim().isNotEmpty) {
        partes.add('$logradouro, $numero');
      } else {
        partes.add(logradouro);
      }
    }

    if (bairro.trim().isNotEmpty) {
      partes.add(bairro);
    }

    if (municipio.trim().isNotEmpty) {
      partes.add(municipio);
    }

    if (estado.trim().isNotEmpty) {
      partes.add(estado);
    }

    return partes.join(' - ');
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cep': cep,
      'municipio': municipio,
      'estado': estado,
      'pais': pais,
      'codigoPais': codigoPais,
    };
  }

  @override
  String toString() {
    return 'EnderecoGeocodificado('
        'endereco: $enderecoFormatado, '
        'cep: $cep, '
        'latitude: $latitude, '
        'longitude: $longitude'
        ')';
  }
}

/// Serviço responsável pela geocodificação reversa.
///
/// Converte latitude/longitude em endereço utilizando o pacote
/// geocoding.
///
/// Nenhuma tela da Plataforma Fênix deve chamar diretamente
/// placemarkFromCoordinates().
class ReverseGeocodingService {
  const ReverseGeocodingService();

  Future<EnderecoGeocodificado> buscarEndereco({
    required double latitude,
    required double longitude,
  }) async {
    _validarCoordenadas(
      latitude: latitude,
      longitude: longitude,
    );

    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        throw LocationException.localizacaoIndisponivel();
      }

      return _converterPlacemark(
        placemarks.first,
        latitude: latitude,
        longitude: longitude,
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

  EnderecoGeocodificado _converterPlacemark(
    Placemark placemark, {
    required double latitude,
    required double longitude,
  }) {
    return EnderecoGeocodificado(
      latitude: latitude,
      longitude: longitude,
      logradouro: _primeiroValorValido([
        placemark.street,
        placemark.thoroughfare,
        placemark.name,
      ]),
      numero: _normalizar(placemark.subThoroughfare),
      bairro: _primeiroValorValido([
        placemark.subLocality,
        placemark.locality,
      ]),
      cep: _normalizar(placemark.postalCode),
      municipio: _primeiroValorValido([
        placemark.subAdministrativeArea,
        placemark.locality,
        placemark.administrativeArea,
      ]),
      estado: _normalizar(placemark.administrativeArea),
      pais: _normalizar(placemark.country),
      codigoPais: _normalizar(placemark.isoCountryCode),
    );
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

  String _primeiroValorValido(List<String?> valores) {
    for (final valor in valores) {
      final texto = _normalizar(valor);

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return '';
  }

  String _normalizar(String? valor) {
    return valor?.trim() ?? '';
  }
}
