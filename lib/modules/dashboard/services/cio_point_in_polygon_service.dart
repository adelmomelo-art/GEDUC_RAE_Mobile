import '../models/cartography/cio_geometry_models.dart';

class CioPointInPolygonService {
  const CioPointInPolygonService();

  List<CioNeighborhoodGeometry> containingNeighborhoods(
    CioGeoPoint point,
    CioGeometryDataset dataset,
  ) =>
      dataset.neighborhoods
          .where((neighborhood) => contains(point, neighborhood))
          .toList(growable: false);

  bool contains(CioGeoPoint point, CioNeighborhoodGeometry neighborhood) =>
      neighborhood.polygons.any((polygon) => _inPolygon(point, polygon));

  bool _inPolygon(CioGeoPoint point, CioGeoPolygon polygon) {
    if (polygon.rings.isEmpty || !_inRing(point, polygon.rings.first)) {
      return false;
    }
    return !polygon.rings.skip(1).any((hole) => _inRing(point, hole));
  }

  bool _inRing(CioGeoPoint point, List<CioGeoPoint> ring) {
    var inside = false;
    for (var current = 0, previous = ring.length - 1;
        current < ring.length;
        previous = current++) {
      final a = ring[previous];
      final b = ring[current];
      if (_onSegment(point, a, b)) return true;
      final intersects =
          (b.latitude > point.latitude) != (a.latitude > point.latitude) &&
              point.longitude <
                  (a.longitude - b.longitude) *
                          (point.latitude - b.latitude) /
                          (a.latitude - b.latitude) +
                      b.longitude;
      if (intersects) inside = !inside;
    }
    return inside;
  }

  bool _onSegment(CioGeoPoint point, CioGeoPoint a, CioGeoPoint b) {
    final cross = (point.latitude - a.latitude) * (b.longitude - a.longitude) -
        (point.longitude - a.longitude) * (b.latitude - a.latitude);
    if (cross.abs() > 1e-10) return false;
    return point.longitude >= _min(a.longitude, b.longitude) - 1e-10 &&
        point.longitude <= _max(a.longitude, b.longitude) + 1e-10 &&
        point.latitude >= _min(a.latitude, b.latitude) - 1e-10 &&
        point.latitude <= _max(a.latitude, b.latitude) + 1e-10;
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;
}
