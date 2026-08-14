import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/cartography/cio_geometry_models.dart';
import 'cio_sha256.dart';

class CioGeometryException implements Exception {
  const CioGeometryException(this.message);

  final String message;

  @override
  String toString() => 'CioGeometryException: $message';
}

class CioGeometryRepository {
  CioGeometryRepository({
    AssetBundle? bundle,
    this.manifestAsset = 'assets/geo/manifesto_bairros_fortaleza.json',
  }) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;
  final String manifestAsset;
  Future<CioGeometryDataset>? _cached;

  Future<CioGeometryDataset> load() => _cached ??= _load();

  Future<CioGeometryDataset> _load() async {
    final manifestMap =
        _map(jsonDecode(await bundle.loadString(manifestAsset)));
    final manifest = CioGeometryManifest(
      dataset: _text(manifestMap['dataset']),
      provider: _text(manifestMap['provider']),
      sourcePage: _text(manifestMap['sourcePage']),
      crs: _text(manifestMap['crs']),
      featureCount: _integer(manifestMap['featureCount']),
      geoJsonAsset: _text(manifestMap['geoJsonAsset']),
      geoJsonSha256: _text(manifestMap['geoJsonSha256']).toLowerCase(),
      attribution: _text(manifestMap['attribution']),
    );
    if (manifest.featureCount != 121 || manifest.crs != 'EPSG:4326') {
      throw const CioGeometryException('Manifesto territorial inválido.');
    }

    final byteData = await bundle.load(manifest.geoJsonAsset);
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    if (CioSha256.digest(bytes) != manifest.geoJsonSha256) {
      throw const CioGeometryException('SHA-256 do GeoJSON divergiu.');
    }
    final root = _map(jsonDecode(utf8.decode(bytes)));
    if (_text(root['type']) != 'FeatureCollection') {
      throw const CioGeometryException('GeoJSON não é uma FeatureCollection.');
    }
    final features = _list(root['features']);
    if (features.length != manifest.featureCount) {
      throw const CioGeometryException('Quantidade de feições divergente.');
    }
    final neighborhoods = features.map(_feature).toList(growable: false);
    final uniqueNames =
        neighborhoods.map((item) => _normalize(item.name)).toSet();
    final uniqueCodes =
        neighborhoods.map((item) => item.neighborhoodCode).toSet();
    if (uniqueNames.length != 121 || uniqueCodes.length != 121) {
      throw const CioGeometryException('Bairros ou códigos duplicados.');
    }
    return CioGeometryDataset(manifest: manifest, neighborhoods: neighborhoods);
  }

  CioNeighborhoodGeometry _feature(dynamic value) {
    final feature = _map(value);
    final properties = _map(feature['properties']);
    final geometry = _map(feature['geometry']);
    final type = _text(geometry['type']);
    final coordinates = _list(geometry['coordinates']);
    final polygonCoordinates = type == 'Polygon'
        ? <dynamic>[coordinates]
        : type == 'MultiPolygon'
            ? coordinates
            : throw const CioGeometryException('Geometria não suportada.');
    final polygons = polygonCoordinates.map((polygonValue) {
      final rings = _list(polygonValue).map((ringValue) {
        return _list(ringValue).map((pointValue) {
          final point = _list(pointValue);
          if (point.length < 2) {
            throw const CioGeometryException('Coordenada incompleta.');
          }
          return CioGeoPoint(
            longitude: _number(point[0]),
            latitude: _number(point[1]),
          );
        }).toList(growable: false);
      }).toList(growable: false);
      if (rings.isEmpty || rings.first.length < 4) {
        throw const CioGeometryException('Polígono territorial inválido.');
      }
      return CioGeoPolygon(rings);
    }).toList(growable: false);
    return CioNeighborhoodGeometry(
      name: _text(properties['Nome']),
      regional: _text(properties['Regional Atual']),
      neighborhoodCode: _integer(properties['Código do  Bairro']),
      polygons: polygons,
    );
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : throw const CioGeometryException('Objeto JSON inválido.');

  static List<dynamic> _list(dynamic value) => value is List
      ? value
      : throw const CioGeometryException('Lista JSON inválida.');

  static String _text(dynamic value) {
    final result = value?.toString().trim() ?? '';
    if (result.isEmpty) {
      throw const CioGeometryException('Texto obrigatório ausente.');
    }
    return result;
  }

  static int _integer(dynamic value) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ??
          (throw const CioGeometryException('Inteiro inválido.'));

  static double _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ??
          (throw const CioGeometryException('Número inválido.'));

  static String _normalize(String value) => value.trim().toLowerCase();
}
