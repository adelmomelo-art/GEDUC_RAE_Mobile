import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_engine.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_record.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_result.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  const engine = AnalyticsEngine();

  group('AnalyticsEngine — fluxo integrado completo', () {
    test('processa toda a massa oficial sem filtros de seleção', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      final result = engine.process(records: records);

      _expectResultMatchesRecords(
        result: result,
        sourceRecords: records,
        expectedRecords: records,
      );
      expect(result.filters.hasSelectionCriteria, isFalse);
      expect(result.engineVersion, '2.0.0');
      expect(result.processedAt, isNotNull);
      expect(
  result.processingTime >= Duration.zero,
  isTrue,
);
    });

    test('filtro vazio produz o mesmo resultado estrutural da ausência de filtro', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      final withoutFilters = engine.process(records: records);
      final withEmptyFilters = engine.process(
        records: records,
        filters: AnalyticsFilters.empty(),
      );

      _expectMetricsEqual(
        withEmptyFilters,
        withoutFilters,
      );
      expect(withEmptyFilters.processedRecords, withoutFilters.processedRecords);
      expect(withEmptyFilters.ignoredRecords, withoutFilters.ignoredRecords);
    });

    test('aplica domínio, status, período e dimensões no mesmo fluxo', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final filters = AnalyticsFilters(
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 31, 23, 59, 59),
        domain: AnalyticsIntegrationFixture.educationDomain,
        status: AnalyticsIntegrationFixture.completedStatus,
        dimensions: const {
          'regional': 'VI',
          'turno': 'manha',
        },
      );

      final expected = records
          .where(
            (record) =>
                record.domain ==
                    AnalyticsIntegrationFixture.educationDomain &&
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus &&
                !record.occurredAt.isBefore(DateTime(2026, 7, 1)) &&
                !record.occurredAt.isAfter(
                  DateTime(2026, 7, 31, 23, 59, 59),
                ) &&
                record.dimension('regional') == 'VI' &&
                record.dimension('turno') == 'manha',
          )
          .toList(growable: false);

      final result = engine.process(
        records: records,
        filters: filters,
      );

      _expectResultMatchesRecords(
        result: result,
        sourceRecords: records,
        expectedRecords: expected,
      );
      expect(result.filters, same(filters));
      expect(result.filters.criteriaCount, 4);
    });

    test('datas inicial e final são inclusivas', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final filters = AnalyticsFilters(
        startDate: DateTime(2026, 7, 1, 8),
        endDate: DateTime(2026, 7, 22, 9),
        domain: AnalyticsIntegrationFixture.educationDomain,
        status: AnalyticsIntegrationFixture.completedStatus,
      );

      final result = engine.process(
        records: records,
        filters: filters,
      );

      final expected = records
          .where(
            (record) =>
                record.domain ==
                    AnalyticsIntegrationFixture.educationDomain &&
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus &&
                !record.occurredAt.isBefore(DateTime(2026, 7, 1, 8)) &&
                !record.occurredAt.isAfter(DateTime(2026, 7, 22, 9)),
          )
          .toList(growable: false);

      _expectResultMatchesRecords(
        result: result,
        sourceRecords: records,
        expectedRecords: expected,
      );
      expect(expected.map((record) => record.id), contains('EDU-013'));
      expect(expected.map((record) => record.id), contains('EDU-016'));
    });

    test('ordenação e limite ocorrem após todos os filtros de seleção', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final filters = AnalyticsFilters(
        domain: AnalyticsIntegrationFixture.educationDomain,
        status: AnalyticsIntegrationFixture.completedStatus,
        dimensions: const {'regional': 'VI'},
        sortField: AnalyticsSortField.peopleCount,
        sortDirection: AnalyticsSortDirection.descending,
        limit: 3,
      );

      final selected = records
          .where(
            (record) =>
                record.domain ==
                    AnalyticsIntegrationFixture.educationDomain &&
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus &&
                record.dimension('regional') == 'VI',
          )
          .toList(growable: true)
        ..sort(
          (a, b) => b.peopleCount.compareTo(a.peopleCount),
        );

      final expected = selected.take(3).toList(growable: false);

      final result = engine.process(
        records: records,
        filters: filters,
      );

      _expectResultMatchesRecords(
        result: result,
        sourceRecords: records,
        expectedRecords: expected,
      );
      expect(expected.map((record) => record.id), [
        'EDU-016',
        'EDU-008',
        'EDU-011',
      ]);
    });

    test('limit contabiliza como ignorados os registros não selecionados', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.occurredAt,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 5,
        ),
      );

      expect(result.processedRecords, 5);
      expect(result.ignoredRecords, records.length - 5);
      expect(result.totalRecords, records.length);
      expect(result.hasIgnoredRecords, isTrue);
      expect(result.processingEfficiency, closeTo(5 / records.length, 1e-12));
    });

    test('filtro sem correspondência produz resultado vazio auditável', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final filters = AnalyticsFilters(
        domain: 'dominio-inexistente',
        dimensions: const {'regional': 'SEM-REGISTROS'},
      );

      final result = engine.process(
        records: records,
        filters: filters,
      );

      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, records.length);
      expect(result.totalRecords, records.length);
      expect(result.metrics.hasData, isFalse);
      expect(result.metrics.totalPeople, 0);
      expect(result.metrics.totalVehicles, 0);
      expect(result.metrics.totalHumanResources, 0);
      expect(result.processingEfficiency, 0);
      expect(result.filters, same(filters));
    });

    test('aceita Iterable preguiçoso como fonte de registros', () {
      final source = AnalyticsIntegrationFixture.operationalRecords();
      final iterable = source.where(
        (record) =>
            record.domain ==
            AnalyticsIntegrationFixture.educationDomain,
      );

      final result = engine.process(records: iterable);

      final expected = source
          .where(
            (record) =>
                record.domain ==
                AnalyticsIntegrationFixture.educationDomain,
          )
          .toList(growable: false);

      _expectResultMatchesRecords(
        result: result,
        sourceRecords: expected,
        expectedRecords: expected,
      );
    });

    test('não altera a massa original durante filtro, ordenação e limite', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final before = records.map(_snapshot).toList(growable: false);

      engine.process(
        records: records,
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 4,
        ),
      );

      expect(records.map(_snapshot), orderedEquals(before));
    });

    test('o resultado preserva exatamente o filtro utilizado', () {
      final filters = AnalyticsFilters(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31, 23, 59, 59),
        domain: AnalyticsIntegrationFixture.educationDomain,
        status: AnalyticsIntegrationFixture.completedStatus,
        dimensions: const {
          'regional': 'VI',
          'turno': 'manha',
        },
        sortField: AnalyticsSortField.rating,
        sortDirection: AnalyticsSortDirection.descending,
        limit: 2,
      );

      final result = engine.process(
        records: AnalyticsIntegrationFixture.operationalRecords(),
        filters: filters,
      );

      expect(result.filters, same(filters));
      expect(result.filters.startDate, filters.startDate);
      expect(result.filters.endDate, filters.endDate);
      expect(result.filters.domain, filters.domain);
      expect(result.filters.status, filters.status);
      expect(result.filters.dimensions, filters.dimensions);
      expect(result.filters.sortField, filters.sortField);
      expect(result.filters.sortDirection, filters.sortDirection);
      expect(result.filters.limit, filters.limit);
    });

    test('processamentos repetidos são determinísticos nas métricas', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final filters = AnalyticsFilters(
        domain: AnalyticsIntegrationFixture.educationDomain,
        status: AnalyticsIntegrationFixture.completedStatus,
        dimensions: const {'turno': 'manha'},
        sortField: AnalyticsSortField.peopleCount,
        sortDirection: AnalyticsSortDirection.descending,
        limit: 5,
      );

      final first = engine.process(records: records, filters: filters);
      final second = engine.process(records: records, filters: filters);

      _expectMetricsEqual(first, second);
      expect(first.processedRecords, second.processedRecords);
      expect(first.ignoredRecords, second.ignoredRecords);
      expect(first.engineVersion, second.engineVersion);
    });

    test('processa a massa de volume sem perda de contabilização', () {
      final records =
          AnalyticsIntegrationFixture.largeDataset(count: 1000);
      const limit = 100;

      final eligible = records
          .where(
            (record) =>
                record.domain ==
                    AnalyticsIntegrationFixture.educationDomain &&
                record.status ==
                    AnalyticsIntegrationFixture.completedStatus &&
                record.dimension('regional') == 'VI',
          )
          .toList(growable: true)
        ..sort(
          (a, b) => b.peopleCount.compareTo(a.peopleCount),
        );

      final expected = eligible.take(limit).toList(growable: false);

      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          domain: AnalyticsIntegrationFixture.educationDomain,
          status: AnalyticsIntegrationFixture.completedStatus,
          dimensions: const {'regional': 'VI'},
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: limit,
        ),
      );

      _expectResultMatchesRecords(
        result: result,
        sourceRecords: records,
        expectedRecords: expected,
      );
      expect(result.totalRecords, records.length);
      expect(
        result.processingEfficiency,
        closeTo(expected.length / records.length, 1e-12),
      );
    });
  });
}

void _expectResultMatchesRecords({
  required AnalyticsResult result,
  required Iterable<AnalyticsRecord> sourceRecords,
  required Iterable<AnalyticsRecord> expectedRecords,
}) {
  final source = sourceRecords.toList(growable: false);
  final expected = expectedRecords.toList(growable: false);

  final totalPeople = expected.fold<int>(
    0,
    (sum, record) => sum + record.peopleCount,
  );
  final totalVehicles = expected.fold<int>(
    0,
    (sum, record) => sum + record.vehicleCount,
  );
  final totalHumanResources = expected.fold<int>(
    0,
    (sum, record) => sum + record.humanResourcesCount,
  );
  final totalRating = expected.fold<double>(
    0,
    (sum, record) => sum + (record.rating ?? 0),
  );
  final recordsWithTarget = expected.where(
    (record) =>
        record.targetValue != null &&
        record.achievedValue != null,
  );
  final targetAchieved = recordsWithTarget.where(
    (record) => record.hasReachedTarget,
  );

  expect(result.processedRecords, expected.length);
  expect(result.ignoredRecords, source.length - expected.length);
  expect(result.totalRecords, source.length);
  expect(result.metrics.totalRecords, expected.length);
  expect(result.metrics.totalPeople, totalPeople);
  expect(result.metrics.totalVehicles, totalVehicles);
  expect(result.metrics.totalHumanResources, totalHumanResources);

  if (expected.isEmpty) {
    expect(result.metrics.averagePeople, 0);
    expect(result.metrics.averageVehicles, 0);
    expect(result.metrics.averageHumanResources, 0);
    expect(result.metrics.averageRating, 0);
  } else {
    expect(
      result.metrics.averagePeople,
      closeTo(totalPeople / expected.length, 1e-12),
    );
    expect(
      result.metrics.averageVehicles,
      closeTo(totalVehicles / expected.length, 1e-12),
    );
    expect(
      result.metrics.averageHumanResources,
      closeTo(totalHumanResources / expected.length, 1e-12),
    );
    expect(
      result.metrics.averageRating,
      closeTo(totalRating / expected.length, 1e-12),
    );
  }

  expect(
    result.metrics.recordsWithTarget,
    recordsWithTarget.length,
  );
  expect(
    result.metrics.recordsTargetAchieved,
    targetAchieved.length,
  );

  if (recordsWithTarget.isEmpty) {
    expect(result.metrics.targetAchievementRate, 0);
  } else {
    expect(
      result.metrics.targetAchievementRate,
      closeTo(
        targetAchieved.length / recordsWithTarget.length,
        1e-12,
      ),
    );
  }
}

void _expectMetricsEqual(
  AnalyticsResult actual,
  AnalyticsResult expected,
) {
  expect(actual.metrics.totalRecords, expected.metrics.totalRecords);
  expect(actual.metrics.totalPeople, expected.metrics.totalPeople);
  expect(actual.metrics.totalVehicles, expected.metrics.totalVehicles);
  expect(
    actual.metrics.totalHumanResources,
    expected.metrics.totalHumanResources,
  );
  expect(actual.metrics.averagePeople, expected.metrics.averagePeople);
  expect(actual.metrics.averageVehicles, expected.metrics.averageVehicles);
  expect(
    actual.metrics.averageHumanResources,
    expected.metrics.averageHumanResources,
  );
  expect(
    actual.metrics.recordsWithTarget,
    expected.metrics.recordsWithTarget,
  );
  expect(
    actual.metrics.recordsTargetAchieved,
    expected.metrics.recordsTargetAchieved,
  );
  expect(
    actual.metrics.targetAchievementRate,
    expected.metrics.targetAchievementRate,
  );
  expect(actual.metrics.averageRating, expected.metrics.averageRating);
}

String _snapshot(AnalyticsRecord record) {
  final dimensions = record.dimensions.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return [
    record.id,
    record.domain,
    record.occurredAt.toIso8601String(),
    record.status,
    record.peopleCount,
    record.vehicleCount,
    record.humanResourcesCount,
    record.targetValue,
    record.achievedValue,
    record.rating,
    dimensions.map((entry) => '${entry.key}=${entry.value}').join('|'),
  ].join('::');
}
