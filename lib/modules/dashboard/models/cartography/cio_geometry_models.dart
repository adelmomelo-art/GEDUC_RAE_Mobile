import 'dart:collection';

class CioGeoPoint {
  const CioGeoPoint({required this.longitude, required this.latitude});

  final double longitude;
  final double latitude;
}

class CioGeoPolygon {
  CioGeoPolygon(Iterable<List<CioGeoPoint>> rings)
      : rings = UnmodifiableListView<List<CioGeoPoint>>(
          rings.map((ring) => List<CioGeoPoint>.unmodifiable(ring)),
        );

  final List<List<CioGeoPoint>> rings;
}

class CioNeighborhoodGeometry {
  CioNeighborhoodGeometry({
    required this.name,
    required this.regional,
    required this.neighborhoodCode,
    required Iterable<CioGeoPolygon> polygons,
  }) : polygons = List<CioGeoPolygon>.unmodifiable(polygons);

  final String name;
  final String regional;
  final int neighborhoodCode;
  final List<CioGeoPolygon> polygons;
}

class CioGeometryManifest {
  const CioGeometryManifest({
    required this.dataset,
    required this.provider,
    required this.sourcePage,
    required this.crs,
    required this.featureCount,
    required this.geoJsonAsset,
    required this.geoJsonSha256,
    required this.attribution,
  });

  final String dataset;
  final String provider;
  final String sourcePage;
  final String crs;
  final int featureCount;
  final String geoJsonAsset;
  final String geoJsonSha256;
  final String attribution;
}

class CioGeometryDataset {
  CioGeometryDataset({
    required this.manifest,
    required Iterable<CioNeighborhoodGeometry> neighborhoods,
  }) : neighborhoods =
            List<CioNeighborhoodGeometry>.unmodifiable(neighborhoods);

  final CioGeometryManifest manifest;
  final List<CioNeighborhoodGeometry> neighborhoods;
}
