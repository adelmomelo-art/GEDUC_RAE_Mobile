import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cartography/cio_geometry_models.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_point_in_polygon_service.dart';

void main() {
  const service = CioPointInPolygonService();
  final neighborhood = CioNeighborhoodGeometry(
    name: 'Teste',
    regional: 'SER 01',
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
        const <CioGeoPoint>[
          CioGeoPoint(longitude: 4, latitude: 4),
          CioGeoPoint(longitude: 6, latitude: 4),
          CioGeoPoint(longitude: 6, latitude: 6),
          CioGeoPoint(longitude: 4, latitude: 6),
          CioGeoPoint(longitude: 4, latitude: 4),
        ],
      ]),
    ],
  );

  test('aceita ponto interno e ponto na borda', () {
    expect(
        service.contains(
            const CioGeoPoint(longitude: 2, latitude: 2), neighborhood),
        isTrue);
    expect(
        service.contains(
            const CioGeoPoint(longitude: 0, latitude: 5), neighborhood),
        isTrue);
  });

  test('rejeita ponto externo e ponto dentro de furo', () {
    expect(
        service.contains(
            const CioGeoPoint(longitude: 12, latitude: 2), neighborhood),
        isFalse);
    expect(
        service.contains(
            const CioGeoPoint(longitude: 5, latitude: 5), neighborhood),
        isFalse);
  });
}
