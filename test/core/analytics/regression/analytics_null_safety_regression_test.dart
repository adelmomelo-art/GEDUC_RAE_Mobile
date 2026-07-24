import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_engine.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  const engine = AnalyticsEngine();

  group('OE-003.7.2 — RT-006 Null Safety Regression', () {
    test('processa lista vazia sem lançar exceções', () {
      final result = engine.process(records: const []);

      expect(result.totalRecords, 0);
      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, 0);
      expect(result.metrics.totalRecords, 0);
      expect(result.metrics.hasData, isFalse);
      expect(result.processingTime >= Duration.zero, isTrue);
    });

    test('filtro por dimensão inexistente retorna conjunto vazio', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          dimensions: const {'dimensao_inexistente': 'valor'},
        ),
      );

      expect(result.totalRecords, 24);
      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, 24);
      expect(result.metrics.hasData, isFalse);
    });

    test('datas fora do intervalo da massa retornam vazio', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          startDate: DateTime(2035, 1, 1),
          endDate: DateTime(2035, 12, 31),
        ),
      );

      expect(result.totalRecords, 24);
      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, 24);
      expect(result.metrics.totalRecords, 0);
    });

    test('status inexistente não provoca falha', () {
      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: AnalyticsFilters(
          status: 'status_inexistente',
        ),
      );

      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, result.totalRecords);
      expect(result.metrics.hasData, isFalse);
    });

    test('múltiplas execuções vazias permanecem determinísticas', () {
      for (var i = 0; i < 20; i++) {
        final result = engine.process(records: const []);
        expect(result.totalRecords, 0);
        expect(result.metrics.totalRecords, 0);
        expect(result.processingTime >= Duration.zero, isTrue);
      }
    });
  });
}
