import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_engine.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_result.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  const engine = AnalyticsEngine();

  group('OE-003.7.2 — RT-005 Stress Regression', () {
    test('100 execuções consecutivas produzem resultados idênticos', () {
      final records = AnalyticsIntegrationFixture.largeDataset();

      AnalyticsResult? baseline;

      for (var i = 0; i < 100; i++) {
        final result = engine.process(records: records);

        baseline ??= result;

        expect(result.engineVersion, baseline.engineVersion);
        expect(result.totalRecords, baseline.totalRecords);
        expect(result.processedRecords, baseline.processedRecords);
        expect(result.ignoredRecords, baseline.ignoredRecords);

        expect(result.metrics.totalRecords, baseline.metrics.totalRecords);
        expect(result.metrics.totalPeople, baseline.metrics.totalPeople);
        expect(result.metrics.totalVehicles, baseline.metrics.totalVehicles);
        expect(result.metrics.totalHumanResources,
            baseline.metrics.totalHumanResources);

        expect(result.processingTime >= Duration.zero, isTrue);
      }
    });

    test('grande volume com filtros permanece consistente', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.largeDataset(),
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
        ),
      );

      expect(result.engineVersion, '2.0.0');
      expect(result.totalRecords, greaterThan(0));
      expect(result.processedRecords, greaterThan(0));
      expect(result.processedRecords + result.ignoredRecords,
          result.totalRecords);

      expect(result.metrics.totalRecords, result.processedRecords);
      expect(result.processingTime >= Duration.zero, isTrue);
    });

    test('execuções repetidas com ordenação permanecem determinísticas', () {
      AnalyticsResult? previous;

      for (var i = 0; i < 25; i++) {
        final result = engine.process(
          records: AnalyticsIntegrationFixture.largeDataset(),
          filters: AnalyticsFilters(
            sortField: AnalyticsSortField.peopleCount,
            sortDirection: AnalyticsSortDirection.descending,
            limit: 50,
          ),
        );

        previous ??= result;

        expect(result.processedRecords, previous.processedRecords);
        expect(result.metrics.totalPeople, previous.metrics.totalPeople);
        expect(result.metrics.totalVehicles, previous.metrics.totalVehicles);
        expect(result.metrics.totalHumanResources,
            previous.metrics.totalHumanResources);
      }
    });
  });
}
