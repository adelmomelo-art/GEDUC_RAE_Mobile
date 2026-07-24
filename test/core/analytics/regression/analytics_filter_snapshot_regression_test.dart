import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_engine.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_result.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  const engine = AnalyticsEngine();

  group('OE-003.7.2 — RT-004 Filter Snapshot', () {
    test('domínio + status', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
        ),
      );
      _expect(result, 14, 10);
    });

    test('período julho/2026 + Educação + concluída', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
          startDate: DateTime(2026,7,1),
          endDate: DateTime(2026,7,31,23,59,59),
        ),
      );
      _expect(result,4,20);
    });

    test('Regional VI + turno manhã', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          dimensions: const {
            'regional':'VI',
            'turno':'manha',
          },
        ),
      );
      _expect(result,6,18);
    });

    test('Projeto AMC nas Escolas', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          dimensions: const {
            'projeto':'AMC nas Escolas',
          },
        ),
      );
      _expect(result,2,22);
    });

    test('Filtro sem resultados', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          dimensions: const {
            'regional':'XX',
          },
        ),
      );
      expect(result.totalRecords,24);
      expect(result.processedRecords,0);
      expect(result.ignoredRecords,24);
      expect(result.metrics.totalRecords,0);
      expect(result.metrics.hasData,isFalse);
    });

    test('Combinação máxima de filtros', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
          startDate: DateTime(2026,7,1),
          endDate: DateTime(2026,7,31,23,59,59),
          dimensions: const {
            'regional':'VI',
            'turno':'manha',
            'tipo_acao':'palestra',
          },
        ),
      );
      _expect(result,1,23);
    });
  });
}

void _expect(AnalyticsResult result,int processed,int ignored){
  expect(result.engineVersion,'2.0.0');
  expect(result.totalRecords,24);
  expect(result.processedRecords,processed);
  expect(result.ignoredRecords,ignored);
  expect(result.metrics.totalRecords,processed);
  expect(result.processingTime>=Duration.zero,isTrue);
}
