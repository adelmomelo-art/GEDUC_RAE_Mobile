import '../../../data/models/acao_model.dart';
import '../models/cartography/cio_cartographic_models.dart';
import '../models/cartography/cio_geometry_models.dart';
import 'cio_point_in_polygon_service.dart';

class CioCartographicEligibilityPolicy {
  const CioCartographicEligibilityPolicy({
    this.pointInPolygonService = const CioPointInPolygonService(),
  });

  final CioPointInPolygonService pointInPolygonService;

  CioCartographicEligibility evaluate(
    AcaoModel action,
    CioGeometryDataset dataset,
    Set<String> excludedActionIds,
  ) {
    final rejections = <CioCartographicRejection>{};
    if (excludedActionIds.contains(action.id)) {
      rejections.add(CioCartographicRejection.explicitlyExcluded);
    }
    if (action.numeroRAE.trim().isEmpty) {
      rejections.add(CioCartographicRejection.missingOperationalNumber);
    }
    if (action.regionalId.trim().isEmpty) {
      rejections.add(CioCartographicRejection.missingRegionalId);
    }
    if (!_validCoordinates(action)) {
      rejections.add(CioCartographicRejection.invalidCoordinates);
      return _result(action.id, rejections);
    }
    final containing = pointInPolygonService.containingNeighborhoods(
      CioGeoPoint(longitude: action.longitude, latitude: action.latitude),
      dataset,
    );
    if (containing.isEmpty) {
      rejections.add(CioCartographicRejection.outsideMunicipality);
      return _result(action.id, rejections);
    }
    if (containing.length > 1) {
      rejections.add(CioCartographicRejection.multipleNeighborhoods);
      return _result(action.id, rejections);
    }
    final geometry = containing.single;
    final regional = _regionalCode(geometry.regional);
    if (_normalize(action.bairro) != _normalize(geometry.name)) {
      rejections.add(CioCartographicRejection.neighborhoodMismatch);
    }
    if (_regionalCode(action.regional) != regional) {
      rejections.add(CioCartographicRejection.regionalMismatch);
    }
    return CioCartographicEligibility(
      actionId: action.id,
      eligible: rejections.isEmpty,
      rejections: Set<CioCartographicRejection>.unmodifiable(rejections),
      neighborhood: geometry.name,
      regional: regional,
    );
  }

  CioCartographicEligibility _result(
    String actionId,
    Set<CioCartographicRejection> rejections,
  ) =>
      CioCartographicEligibility(
        actionId: actionId,
        eligible: false,
        rejections: Set<CioCartographicRejection>.unmodifiable(rejections),
      );

  bool _validCoordinates(AcaoModel action) =>
      action.latitude.isFinite &&
      action.longitude.isFinite &&
      action.latitude >= -90 &&
      action.latitude <= 90 &&
      action.longitude >= -180 &&
      action.longitude <= 180 &&
      (action.latitude.abs() > 0.000001 || action.longitude.abs() > 0.000001);

  String _regionalCode(String value) {
    final match = RegExp(r'(\d+)\s*$').firstMatch(value.trim());
    return match == null
        ? ''
        : 'SER ${int.parse(match.group(1)!).toString().padLeft(2, '0')}';
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[áàâãä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[íìîï]'), 'i')
      .replaceAll(RegExp('[óòôõö]'), 'o')
      .replaceAll(RegExp('[úùûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');
}
