import 'dart:collection';

class CioCartographicExclusion {
  const CioCartographicExclusion({
    required this.actionId,
    required this.group,
    required this.reason,
  });

  final String actionId;
  final String group;
  final String reason;
}

enum CioCartographicRejection {
  explicitlyExcluded,
  missingOperationalNumber,
  missingRegionalId,
  invalidCoordinates,
  outsideMunicipality,
  multipleNeighborhoods,
  neighborhoodMismatch,
  regionalMismatch,
}

class CioCartographicEligibility {
  const CioCartographicEligibility({
    required this.actionId,
    required this.eligible,
    required this.rejections,
    this.neighborhood,
    this.regional,
  });

  final String actionId;
  final bool eligible;
  final Set<CioCartographicRejection> rejections;
  final String? neighborhood;
  final String? regional;
}

class CioTerritorialAggregate {
  const CioTerritorialAggregate({
    required this.neighborhood,
    required this.regional,
    required this.actionCount,
  });

  final String neighborhood;
  final String regional;
  final int actionCount;
}

class CioCartographicAggregation {
  CioCartographicAggregation({
    required this.totalEvaluated,
    required this.totalEligible,
    required this.totalExcluded,
    required Iterable<CioTerritorialAggregate> neighborhoods,
    required Map<String, int> regionals,
    required Map<CioCartographicRejection, int> rejectionCounts,
  })  : neighborhoods =
            List<CioTerritorialAggregate>.unmodifiable(neighborhoods),
        regionals = UnmodifiableMapView<String, int>(Map.of(regionals)),
        rejectionCounts = UnmodifiableMapView<CioCartographicRejection, int>(
          Map.of(rejectionCounts),
        );

  final int totalEvaluated;
  final int totalEligible;
  final int totalExcluded;
  final List<CioTerritorialAggregate> neighborhoods;
  final Map<String, int> regionals;
  final Map<CioCartographicRejection, int> rejectionCounts;
}
