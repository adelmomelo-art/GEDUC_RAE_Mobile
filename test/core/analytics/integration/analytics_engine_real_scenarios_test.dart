import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_engine.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_record.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_result.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  const engine = AnalyticsEngine();

  group('AnalyticsEngine — cenários operacionais reais', () {
    test('consolida as ações de Educação realizadas em julho de 2026', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where(
            (record) =>
                record.domain ==
                    AnalyticsIntegrationFixture.educationDomain &&
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus &&
                record.occurredAt.year == 2026 &&
                record.occurredAt.month == DateTime.july,
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 31, 23, 59, 59),
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(result.processedRecords, 4);
    });

    test('consolida a Regional VI no turno da manhã', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = AnalyticsIntegrationFixture
          .regionalVIMorningCompletedEducationRecords();

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
          dimensions: const {
            'regional': 'VI',
            'turno': 'manha',
          },
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(result.processedRecords, 6);
    });

    test('consolida exclusivamente o projeto AMC nas Escolas', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where(
            (record) =>
                record.domain ==
                    AnalyticsIntegrationFixture.educationDomain &&
                record.dimension('projeto') == 'AMC nas Escolas',
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          dimensions: const {'projeto': 'AMC nas Escolas'},
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(result.processedRecords, 2);
    });

    test('consolida comandos educativos concluídos', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where(
            (record) =>
                record.domain ==
                    AnalyticsIntegrationFixture.educationDomain &&
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus &&
                record.dimension('tipo_acao') ==
                    'comando educativo',
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
          dimensions: const {
            'tipo_acao': 'comando educativo',
          },
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
    });

    test('consolida ações noturnas de todos os domínios', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where((record) => record.dimension('turno') == 'noite')
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          dimensions: const {'turno': 'noite'},
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
    });

    test('consolida missões RPAS concluídas', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where(
            (record) =>
                record.domain == AnalyticsIntegrationFixture.rpasDomain &&
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus,
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.rpasDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(result.processedRecords, 2);
    });

    test('consolida operações de fiscalização', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where(
            (record) =>
                record.domain ==
                AnalyticsIntegrationFixture.inspectionDomain,
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.inspectionDomain,
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(result.processedRecords, 2);
    });

    test('identifica a carteira de ações planejadas', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where(
            (record) =>
                record.status ==
                AnalyticsIntegrationFixture.plannedStatus,
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          status: AnalyticsIntegrationFixture.plannedStatus,
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(result.processedRecords, 3);
      expect(result.metrics.totalPeople, 0);
      expect(result.metrics.totalVehicles, 0);
      expect(result.metrics.totalHumanResources, 0);
    });

    test('identifica os registros cancelados para auditoria', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where(
            (record) =>
                record.status ==
                AnalyticsIntegrationFixture.cancelledStatus,
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          status: AnalyticsIntegrationFixture.cancelledStatus,
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(result.processedRecords, 3);
    });

    test('seleciona as três ações de Educação com maior público', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final selected = records
          .where(
            (record) =>
                record.domain ==
                    AnalyticsIntegrationFixture.educationDomain &&
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus,
          )
          .toList(growable: true)
        ..sort(
          (a, b) => b.peopleCount.compareTo(a.peopleCount),
        );

      final expected = selected.take(3).toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 3,
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(expected.map((record) => record.id), [
        'EDU-016',
        'EDU-008',
        'EDU-011',
      ]);
    });

    test('seleciona as duas ações concluídas mais bem avaliadas', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final selected = records
          .where(
            (record) =>
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus,
          )
          .toList(growable: true)
        ..sort(
          (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
        );

      final expected = selected.take(2).toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          status: AnalyticsIntegrationFixture.completedStatus,
          sortField: AnalyticsSortField.rating,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 2,
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(
        expected.every((record) => record.rating == 5),
        isTrue,
      );
    });

    test('analisa somente o primeiro semestre de 2026', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where(
            (record) =>
                !record.occurredAt.isBefore(DateTime(2026, 1, 1)) &&
                !record.occurredAt.isAfter(
                  DateTime(2026, 6, 30, 23, 59, 59),
                ),
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 6, 30, 23, 59, 59),
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
    });

    test('analisa registros da Regional VI em todos os domínios', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final expected = records
          .where((record) => record.dimension('regional') == 'VI')
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          dimensions: const {'regional': 'VI'},
        ),
      );

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: expected,
      );
      expect(
        expected.map((record) => record.domain).toSet(),
        containsAll({
          AnalyticsIntegrationFixture.educationDomain,
          AnalyticsIntegrationFixture.rpasDomain,
          AnalyticsIntegrationFixture.inspectionDomain,
        }),
      );
    });

    test('cenário parcial não quebra o fluxo analítico', () {
      final records = AnalyticsIntegrationFixture.partialDataRecords();

      final result = engine.process(records: records);

      _expectOperationalSummary(
        result: result,
        source: records,
        expected: records,
      );
      expect(result.processedRecords, 4);
      expect(result.metrics.hasData, isTrue);
    });
  });
}

void _expectOperationalSummary({
  required AnalyticsResult result,
  required Iterable<AnalyticsRecord> source,
  required Iterable<AnalyticsRecord> expected,
}) {
  final sourceList = source.toList(growable: false);
  final expectedList = expected.toList(growable: false);

  final totalPeople = expectedList.fold<int>(
    0,
    (sum, record) => sum + record.peopleCount,
  );
  final totalVehicles = expectedList.fold<int>(
    0,
    (sum, record) => sum + record.vehicleCount,
  );
  final totalHumanResources = expectedList.fold<int>(
    0,
    (sum, record) => sum + record.humanResourcesCount,
  );

  expect(result.processedRecords, expectedList.length);
  expect(result.ignoredRecords, sourceList.length - expectedList.length);
  expect(result.totalRecords, sourceList.length);
  expect(result.metrics.totalRecords, expectedList.length);
  expect(result.metrics.totalPeople, totalPeople);
  expect(result.metrics.totalVehicles, totalVehicles);
  expect(result.metrics.totalHumanResources, totalHumanResources);
  expect(result.engineVersion, '2.0.0');
  expect(result.processingTime >= Duration.zero, isTrue);
}
