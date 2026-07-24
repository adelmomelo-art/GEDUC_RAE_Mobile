import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_engine.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  const engine = AnalyticsEngine();

  group('OE-003.7.2 — RT-002 Engine Snapshot', () {
    test('snapshot do processamento completo permanece estável', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
      );

      expect(result.engineVersion, '2.0.0');
      expect(result.totalRecords, 24);
      expect(result.processedRecords, 24);
      expect(result.ignoredRecords, 0);

      expect(result.metrics.totalRecords, 24);
      expect(result.metrics.totalPeople, 2680);
      expect(result.metrics.totalVehicles, 1103);
      expect(result.metrics.totalHumanResources, 112);

      expect(result.metrics.hasData, isTrue);
      expect(result.processingTime >= Duration.zero, isTrue);
    });

    test('snapshot do domínio Educação permanece estável', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
        ),
      );

      expect(result.engineVersion, '2.0.0');
      expect(result.totalRecords, 24);
      expect(result.processedRecords, 18);
      expect(result.ignoredRecords, 6);

      expect(result.metrics.totalPeople, 2435);
      expect(result.metrics.totalVehicles, 855);
      expect(result.metrics.totalHumanResources, 89);
    });

    test('snapshot RPAS concluído permanece estável', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.rpasDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
        ),
      );

      expect(result.engineVersion, '2.0.0');
      expect(result.processedRecords, 2);
      expect(result.ignoredRecords, 22);

      expect(result.metrics.totalPeople, 55);
      expect(result.metrics.totalVehicles, 3);
      expect(result.metrics.totalHumanResources, 7);
    });

    test('snapshot Fiscalização permanece estável', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.inspectionDomain,
        ),
      );

      expect(result.engineVersion, '2.0.0');
      expect(result.processedRecords, 2);
      expect(result.ignoredRecords, 22);

      expect(result.metrics.totalPeople, 190);
      expect(result.metrics.totalVehicles, 245);
      expect(result.metrics.totalHumanResources, 16);
    });
  });
}
