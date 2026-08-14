import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_geometry_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('carrega as 121 feições oficiais e valida o manifesto', () async {
    final dataset = await CioGeometryRepository().load();

    expect(dataset.neighborhoods, hasLength(121));
    expect(
        dataset.neighborhoods.map((item) => item.name).toSet(), hasLength(121));
    expect(dataset.neighborhoods.map((item) => item.neighborhoodCode).toSet(),
        hasLength(121));
    expect(dataset.manifest.crs, 'EPSG:4326');
    expect(dataset.manifest.provider, contains('IPLANFOR'));
  });

  test('corresponde exatamente aos 121 bairros do catálogo canônico', () async {
    final dataset = await CioGeometryRepository().load();
    final catalogLines = await File(
      'docs/catalogo_territorial_fortaleza_lc307.csv',
    ).readAsLines();
    final catalogNames = catalogLines
        .skip(1)
        .map(_parseCsvLine)
        .map((columns) => columns[2])
        .toSet();
    final geometryNames =
        dataset.neighborhoods.map((item) => item.name).toSet();

    expect(catalogNames, hasLength(121));
    expect(geometryNames, catalogNames);
  });

  test('mantém a geometria validada em cache durante o ciclo do serviço',
      () async {
    final repository = CioGeometryRepository();
    final first = await repository.load();
    final second = await repository.load();

    expect(identical(first, second), isTrue);
  });

  test('rejeita GeoJSON cujo hash diverge do manifesto', () async {
    final manifest = jsonEncode(<String, Object>{
      'dataset': 'Bairros de Fortaleza',
      'provider': 'IPLANFOR',
      'sourcePage': 'https://example.invalid',
      'crs': 'EPSG:4326',
      'featureCount': 121,
      'geoJsonAsset': 'geo.json',
      'geoJsonSha256': List.filled(64, '0').join(),
      'attribution': 'Fonte: IPLANFOR',
    });
    final bundle = _MemoryBundle(<String, Uint8List>{
      'manifest.json': Uint8List.fromList(utf8.encode(manifest)),
      'geo.json': Uint8List.fromList(utf8.encode('{}')),
    });

    expect(
      () => CioGeometryRepository(
        bundle: bundle,
        manifestAsset: 'manifest.json',
      ).load(),
      throwsA(isA<CioGeometryException>()),
    );
  });
}

List<String> _parseCsvLine(String line) {
  final columns = <String>[];
  final buffer = StringBuffer();
  var quoted = false;
  for (var index = 0; index < line.length; index++) {
    final character = line[index];
    if (character == '"' &&
        quoted &&
        index + 1 < line.length &&
        line[index + 1] == '"') {
      buffer.write('"');
      index++;
    } else if (character == '"') {
      quoted = !quoted;
    } else if (character == ',' && !quoted) {
      columns.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(character);
    }
  }
  columns.add(buffer.toString());
  return columns;
}

class _MemoryBundle extends CachingAssetBundle {
  _MemoryBundle(this.assets);

  final Map<String, Uint8List> assets;

  @override
  Future<ByteData> load(String key) async {
    final bytes = assets[key];
    if (bytes == null) throw StateError('Asset ausente: $key');
    return ByteData.sublistView(bytes);
  }
}
