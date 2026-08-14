import '../../../data/models/acao_model.dart';
import '../models/cio_dashboard_filters.dart';
import '../models/cartography/cio_cartographic_models.dart';
import '../models/cartography/cio_geometry_models.dart';
import 'cio_cartographic_eligibility_policy.dart';

class CioTerritorialAggregationService {
  const CioTerritorialAggregationService({
    this.eligibilityPolicy = const CioCartographicEligibilityPolicy(),
  });

  final CioCartographicEligibilityPolicy eligibilityPolicy;

  CioCartographicAggregation aggregateFiltered(
    List<AcaoModel> actions,
    CioGeometryDataset dataset,
    Iterable<CioCartographicExclusion> exclusions, {
    required CioDashboardFilters filters,
    required DateTime reference,
  }) =>
      aggregate(
        filters.aplicar(actions, reference),
        dataset,
        exclusions,
      );

  CioCartographicAggregation aggregate(
    Iterable<AcaoModel> actions,
    CioGeometryDataset dataset,
    Iterable<CioCartographicExclusion> exclusions,
  ) {
    final excludedIds = exclusions.map((item) => item.actionId).toSet();
    final neighborhoodCounts = <(String, String), int>{};
    final regionalCounts = <String, int>{};
    final rejectionCounts = <CioCartographicRejection, int>{};
    var evaluated = 0;
    var eligible = 0;
    for (final action in actions) {
      evaluated++;
      final result = eligibilityPolicy.evaluate(action, dataset, excludedIds);
      if (!result.eligible) {
        for (final rejection in result.rejections) {
          rejectionCounts.update(rejection, (value) => value + 1,
              ifAbsent: () => 1);
        }
        continue;
      }
      eligible++;
      final key = (result.neighborhood!, result.regional!);
      neighborhoodCounts.update(key, (value) => value + 1, ifAbsent: () => 1);
      regionalCounts.update(result.regional!, (value) => value + 1,
          ifAbsent: () => 1);
    }
    final neighborhoods = neighborhoodCounts.entries
        .map((entry) => CioTerritorialAggregate(
              neighborhood: entry.key.$1,
              regional: entry.key.$2,
              actionCount: entry.value,
            ))
        .toList(growable: false)
      ..sort((a, b) {
        final byRegional = a.regional.compareTo(b.regional);
        return byRegional != 0
            ? byRegional
            : a.neighborhood.compareTo(b.neighborhood);
      });
    return CioCartographicAggregation(
      totalEvaluated: evaluated,
      totalEligible: eligible,
      totalExcluded: evaluated - eligible,
      neighborhoods: neighborhoods,
      regionals: regionalCounts,
      rejectionCounts: rejectionCounts,
    );
  }
}
