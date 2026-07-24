import '../analytics_metrics.dart';
import '../analytics_record.dart';

/// Calcula os indicadores básicos de produtividade utilizados
/// pelo Analytics Engine.
///
/// Classe pura e determinística.
/// Não possui dependência de Flutter, Firebase ou qualquer
/// módulo específico da Plataforma Fênix.
final class ProductivityCalculator {
  const ProductivityCalculator();

  AnalyticsMetrics calculate(
    Iterable<AnalyticsRecord> records,
  ) {
    final items = records.toList(growable: false);

    if (items.isEmpty) {
      return const AnalyticsMetrics();
    }

    int totalPeople = 0;
    int totalVehicles = 0;
    int totalHumanResources = 0;

    double totalRating = 0;

    int recordsWithTarget = 0;
    int achievedTargets = 0;

    for (final record in items) {
      totalPeople += record.peopleCount;
      totalVehicles += record.vehicleCount;
      totalHumanResources += record.humanResourcesCount;

      if (record.rating != null) {
        totalRating += record.rating!;
      }

      if (record.targetValue != null &&
          record.achievedValue != null) {
        recordsWithTarget++;

        if (record.hasReachedTarget) {
          achievedTargets++;
        }
      }
    }

    final totalRecords = items.length;

    return AnalyticsMetrics(
      totalRecords: totalRecords,
      totalPeople: totalPeople,
      totalVehicles: totalVehicles,
      totalHumanResources: totalHumanResources,
      averagePeople: totalPeople / totalRecords,
      averageVehicles: totalVehicles / totalRecords,
      averageHumanResources:
          totalHumanResources / totalRecords,
      recordsWithTarget: recordsWithTarget,
      recordsTargetAchieved: achievedTargets,
      targetAchievementRate: recordsWithTarget == 0
          ? 0
          : achievedTargets / recordsWithTarget,
      averageRating: totalRating / totalRecords,
    );
  }
}