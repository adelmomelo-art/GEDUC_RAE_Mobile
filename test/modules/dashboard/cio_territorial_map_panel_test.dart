import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cartography/cio_cartographic_models.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cartography/cio_geometry_models.dart';
import 'package:geduc_rae_mobile/modules/dashboard/widgets/cio_territorial_map_panel.dart';

void main() {
  testWidgets('permanece protegido por padrão', (tester) async {
    await tester.pumpWidget(_app(const CioTerritorialMapPanel(
      geometry: null,
      aggregation: null,
      online: true,
      foundationUnavailable: false,
    )));

    expect(find.text('Mapa territorial protegido'), findsOneWidget);
    expect(find.text('Mapa territorial oficial'), findsNothing);
  });

  testWidgets('não substitui fundação inválida por mapa simulado',
      (tester) async {
    await tester.pumpWidget(_app(const CioTerritorialMapPanel(
      geometry: null,
      aggregation: null,
      online: true,
      foundationUnavailable: true,
      enabled: true,
    )));

    expect(find.text('Mapa territorial indisponível'), findsOneWidget);
    expect(find.byType(FlutterMap), findsNothing);
  });

  testWidgets('renderiza polígonos agregados offline sem marcadores',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(CioTerritorialMapPanel(
      geometry: _geometry(),
      aggregation: CioCartographicAggregation(
        totalEvaluated: 2,
        totalEligible: 1,
        totalExcluded: 1,
        neighborhoods: const <CioTerritorialAggregate>[
          CioTerritorialAggregate(
            neighborhood: 'Centro',
            regional: 'SER 12',
            actionCount: 1,
          ),
        ],
        regionals: const {'SER 12': 1},
        rejectionCounts: const {
          CioCartographicRejection.explicitlyExcluded: 1,
        },
      ),
      online: false,
      foundationUnavailable: false,
      enabled: true,
    )));
    await tester.pump();

    expect(find.text('Mapa territorial oficial'), findsOneWidget);
    expect(find.byKey(const Key('cio_map_offline_message')), findsOneWidget);
    expect(find.textContaining('IPLANFOR'), findsOneWidget);
    expect(find.textContaining('OpenStreetMap'), findsNothing);
    expect(find.byType(MarkerLayer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in <double>[320, 360, 412, 800]) {
    testWidgets('painel cartográfico sem overflow em ${width.toInt()} px',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_app(CioTerritorialMapPanel(
        geometry: _geometry(),
        aggregation: _aggregation(),
        online: false,
        foundationUnavailable: false,
        enabled: true,
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(MarkerLayer), findsNothing);
    });
  }
}

Widget _app(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

CioCartographicAggregation _aggregation() => CioCartographicAggregation(
      totalEvaluated: 2,
      totalEligible: 1,
      totalExcluded: 1,
      neighborhoods: const <CioTerritorialAggregate>[
        CioTerritorialAggregate(
          neighborhood: 'Centro',
          regional: 'SER 12',
          actionCount: 1,
        ),
      ],
      regionals: const {'SER 12': 1},
      rejectionCounts: const {
        CioCartographicRejection.explicitlyExcluded: 1,
      },
    );

CioGeometryDataset _geometry() => CioGeometryDataset(
      manifest: const CioGeometryManifest(
        dataset: 'Bairros de Fortaleza',
        provider: 'IPLANFOR',
        sourcePage: 'fonte',
        crs: 'EPSG:4326',
        featureCount: 121,
        geoJsonAsset: 'geo.json',
        geoJsonSha256: 'hash',
        attribution: 'Fonte: IPLANFOR — Fortaleza em Mapas',
      ),
      neighborhoods: <CioNeighborhoodGeometry>[
        CioNeighborhoodGeometry(
          name: 'Centro',
          regional: 'Regional 12',
          neighborhoodCode: 1,
          polygons: <CioGeoPolygon>[
            CioGeoPolygon(<List<CioGeoPoint>>[
              const <CioGeoPoint>[
                CioGeoPoint(longitude: -38.55, latitude: -3.75),
                CioGeoPoint(longitude: -38.50, latitude: -3.75),
                CioGeoPoint(longitude: -38.50, latitude: -3.70),
                CioGeoPoint(longitude: -38.55, latitude: -3.70),
                CioGeoPoint(longitude: -38.55, latitude: -3.75),
              ],
            ]),
          ],
        ),
      ],
    );
