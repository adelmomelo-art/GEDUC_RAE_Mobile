import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cartography/cio_cartographic_models.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cartography/cio_geometry_models.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_cartographic_eligibility_policy.dart';

void main() {
  const policy = CioCartographicEligibilityPolicy();
  final dataset = _dataset();

  test('aprova somente identidade, número e geometria coerentes', () {
    final result = policy.evaluate(_action('ok'), dataset, const <String>{});

    expect(result.eligible, isTrue);
    expect(result.neighborhood, 'Centro');
    expect(result.regional, 'SER 12');
    expect(result.rejections, isEmpty);
  });

  test('bloqueia ID explicitamente excluído mesmo com dados coerentes', () {
    final result = policy.evaluate(_action('g1'), dataset, const {'g1'});

    expect(result.eligible, isFalse);
    expect(
      result.rejections,
      contains(CioCartographicRejection.explicitlyExcluded),
    );
  });

  test('bloqueia ausência de número e divergências territoriais', () {
    final result = policy.evaluate(
      _action('bad', number: '', neighborhood: 'Outro', regional: 'SER 03'),
      dataset,
      const <String>{},
    );

    expect(result.eligible, isFalse);
    expect(result.rejections,
        contains(CioCartographicRejection.missingOperationalNumber));
    expect(result.rejections,
        contains(CioCartographicRejection.neighborhoodMismatch));
    expect(
        result.rejections, contains(CioCartographicRejection.regionalMismatch));
  });
}

CioGeometryDataset _dataset() => CioGeometryDataset(
      manifest: const CioGeometryManifest(
        dataset: 'Teste',
        provider: 'IPLANFOR',
        sourcePage: 'https://example.invalid',
        crs: 'EPSG:4326',
        featureCount: 121,
        geoJsonAsset: 'teste.json',
        geoJsonSha256: 'hash',
        attribution: 'Fonte',
      ),
      neighborhoods: <CioNeighborhoodGeometry>[
        CioNeighborhoodGeometry(
          name: 'Centro',
          regional: 'Secretaria Executiva Regional 12',
          neighborhoodCode: 1,
          polygons: <CioGeoPolygon>[
            CioGeoPolygon(<List<CioGeoPoint>>[
              const <CioGeoPoint>[
                CioGeoPoint(longitude: 0, latitude: 0),
                CioGeoPoint(longitude: 10, latitude: 0),
                CioGeoPoint(longitude: 10, latitude: 10),
                CioGeoPoint(longitude: 0, latitude: 10),
                CioGeoPoint(longitude: 0, latitude: 0),
              ],
            ]),
          ],
        ),
      ],
    );

AcaoModel _action(
  String id, {
  String number = '0001/2026',
  String neighborhood = 'Centro',
  String regional = 'SER 12',
}) =>
    AcaoModel.fromMap(<String, dynamic>{
      'id': id,
      'numeroRAE': number,
      'dataAcao': '2026-08-13T10:00:00.000',
      'regionalId': 'regional-12',
      'regional': regional,
      'bairro': neighborhood,
      'latitude': 2.0,
      'longitude': 2.0,
      'status': 'enviado',
    });
