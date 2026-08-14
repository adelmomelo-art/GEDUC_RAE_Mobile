import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cartography/cio_cartographic_models.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cartography/cio_geometry_models.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cio_dashboard_filters.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_territorial_aggregation_service.dart';

void main() {
  const service = CioTerritorialAggregationService();
  final dataset = _dataset();

  test('agrega elegíveis e exclui bloqueados sem coordenadas no resultado', () {
    final result = service.aggregate(
      <AcaoModel>[_action('a'), _action('b'), _action('g1')],
      dataset,
      const <CioCartographicExclusion>[
        CioCartographicExclusion(
          actionId: 'g1',
          group: 'G1',
          reason: 'coordenada_nao_homologada',
        ),
      ],
    );

    expect(result.totalEvaluated, 3);
    expect(result.totalEligible, 2);
    expect(result.totalExcluded, 1);
    expect(result.neighborhoods, hasLength(1));
    expect(result.neighborhoods.single.actionCount, 2);
    expect(result.regionals, {'SER 12': 2});
    expect(result.toString(), isNot(contains('2.0')));
  });

  test('aplica o mesmo recorte temporal e territorial do Dashboard', () {
    final result = service.aggregateFiltered(
      <AcaoModel>[
        _action('included'),
        _action('other-regional').copyWith(regional: 'SER 03'),
        _action('old').copyWith(dataAcao: DateTime(2025, 1, 1)),
      ],
      dataset,
      const <CioCartographicExclusion>[],
      filters: const CioDashboardFilters(
        periodo: CioPeriodoRapido.ultimos30Dias,
        comparacao: CioComparacao.nenhuma,
        regional: 'SER 12',
      ),
      reference: DateTime(2026, 8, 13),
    );

    expect(result.totalEvaluated, 1);
    expect(result.totalEligible, 1);
  });
}

CioGeometryDataset _dataset() => CioGeometryDataset(
      manifest: const CioGeometryManifest(
        dataset: 'Teste',
        provider: 'IPLANFOR',
        sourcePage: 'fonte',
        crs: 'EPSG:4326',
        featureCount: 121,
        geoJsonAsset: 'geo.json',
        geoJsonSha256: 'hash',
        attribution: 'Fonte',
      ),
      neighborhoods: <CioNeighborhoodGeometry>[
        CioNeighborhoodGeometry(
          name: 'Centro',
          regional: 'Regional 12',
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

AcaoModel _action(String id) => AcaoModel.fromMap(<String, dynamic>{
      'id': id,
      'numeroRAE': '0001/2026',
      'dataAcao': '2026-08-13T10:00:00.000',
      'regionalId': 'regional-12',
      'regional': 'SER 12',
      'bairro': 'Centro',
      'latitude': 2.0,
      'longitude': 2.0,
      'status': 'enviado',
    });
