import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_engine.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_result.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  const engine = AnalyticsEngine();

  group('OE-003.7.2 — RT-003 Ordering Snapshot', () {
    test('mantém as três ações de Educação com maior público', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 3,
        ),
      );

      _expectSnapshot(
        result: result,
        processedRecords: 3,
        ignoredRecords: 21,
        totalPeople: 880,
        totalVehicles: 295,
        totalHumanResources: 27,
      );
    });

    test('mantém os três registros com mais veículos abordados', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.vehicleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 3,
        ),
      );

      _expectSnapshot(
        result: result,
        processedRecords: 3,
        ignoredRecords: 21,
        totalPeople: 510,
        totalVehicles: 365,
        totalHumanResources: 26,
      );
    });

    test('mantém os dois registros com maior mobilização de equipe', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.humanResourcesCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 2,
        ),
      );

      _expectSnapshot(
        result: result,
        processedRecords: 2,
        ignoredRecords: 22,
        totalPeople: 620,
        totalVehicles: 195,
        totalHumanResources: 19,
      );
    });

    test('mantém os dois registros concluídos mais bem avaliados', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          status: AnalyticsIntegrationFixture.completedStatus,
          sortField: AnalyticsSortField.rating,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 2,
        ),
      );

      _expectSnapshot(
        result: result,
        processedRecords: 2,
        ignoredRecords: 22,
        totalPeople: 530,
        totalVehicles: 175,
        totalHumanResources: 17,
      );
    });

    test('mantém os três primeiros registros em ordem cronológica', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.occurredAt,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 3,
        ),
      );

      _expectSnapshot(
        result: result,
        processedRecords: 3,
        ignoredRecords: 21,
        totalPeople: 410,
        totalVehicles: 110,
        totalHumanResources: 16,
      );
    });

    test('mantém os três registros mais recentes', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.occurredAt,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 3,
        ),
      );

      _expectSnapshot(
        result: result,
        processedRecords: 3,
        ignoredRecords: 21,
        totalPeople: 280,
        totalVehicles: 175,
        totalHumanResources: 14,
      );
    });
  });
}

void _expectSnapshot({
  required AnalyticsResult result,
  required int processedRecords,
  required int ignoredRecords,
  required int totalPeople,
  required int totalVehicles,
  required int totalHumanResources,
}) {
  expect(result.engineVersion, '2.0.0');
  expect(result.totalRecords, 24);
  expect(result.processedRecords, processedRecords);
  expect(result.ignoredRecords, ignoredRecords);

  expect(result.metrics.totalRecords, processedRecords);
  expect(result.metrics.totalPeople, totalPeople);
  expect(result.metrics.totalVehicles, totalVehicles);
  expect(
    result.metrics.totalHumanResources,
    totalHumanResources,
  );

  expect(result.metrics.hasData, isTrue);
  expect(result.processingTime >= Duration.zero, isTrue);
}
