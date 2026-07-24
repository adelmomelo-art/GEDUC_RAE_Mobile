import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_metrics.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_result.dart';

/// Fixture institucional para testes do módulo Analytics.
///
/// Centraliza a criação de AnalyticsResult utilizados nos testes.
final class AnalyticsResultFixture {
  const AnalyticsResultFixture._();

  /// Resultado vazio.
  static AnalyticsResult empty() {
    return AnalyticsResult(
      metrics: const AnalyticsMetrics(),
      filters: AnalyticsFilters.empty(),
      processedAt: DateTime(2026, 1, 1),
    );
  }

  /// Resultado padrão utilizado pela maioria dos testes.
  static AnalyticsResult sample() {
    return AnalyticsResult(
      metrics: const AnalyticsMetrics(
        totalRecords: 120,
        totalPeople: 860,
        totalVehicles: 215,
        totalHumanResources: 34,
        averagePeople: 7.16,
        averageVehicles: 1.79,
        averageHumanResources: 0.28,
        recordsWithTarget: 100,
        recordsTargetAchieved: 92,
        targetAchievementRate: 92,
        averageRating: 4.7,
      ),
      filters: AnalyticsFilters(
        domain: 'educacao',
        status: 'concluida',
      ),
      processedAt: DateTime(2026, 7, 13, 10, 30),
      processingTime: const Duration(milliseconds: 420),
      processedRecords: 120,
      ignoredRecords: 4,
      engineVersion: '1.0.0',
      metadata: const {
        'environment': 'test',
        'source': 'fixture',
      },
    );
  }

  /// Resultado contendo metadados.
  static AnalyticsResult withMetadata() {
    return empty().copyWith(
      metadata: const {
        'environment': 'test',
      },
    );
  }

  /// Resultado sem metadados.
  static AnalyticsResult withoutMetadata() {
    return empty();
  }

  /// Resultado contendo registros ignorados.
  static AnalyticsResult withIgnoredRecords({
    int processedRecords = 100,
    int ignoredRecords = 5,
  }) {
    return empty().copyWith(
      processedRecords: processedRecords,
      ignoredRecords: ignoredRecords,
    );
  }

  /// Resultado com tempo de processamento personalizado.
  static AnalyticsResult withProcessingTime(
    Duration duration,
  ) {
    return empty().copyWith(
      processingTime: duration,
    );
  }

  /// Resultado com filtros personalizados.
  static AnalyticsResult withFilters(
    AnalyticsFilters filters,
  ) {
    return empty().copyWith(
      filters: filters,
    );
  }

  /// Resultado com métricas personalizadas.
  static AnalyticsResult withMetrics(
    AnalyticsMetrics metrics,
  ) {
    return empty().copyWith(
      metrics: metrics,
    );
  }
}