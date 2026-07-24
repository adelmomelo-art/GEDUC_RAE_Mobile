import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_engine.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_filters.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_record.dart';

void main() {
  const engine = AnalyticsEngine();

  AnalyticsRecord record({
    required String id,
    required DateTime occurredAt,
    String domain = 'educacao',
    String status = 'concluida',
    int peopleCount = 0,
    int vehicleCount = 0,
    int humanResourcesCount = 0,
    double? targetValue,
    double? achievedValue,
    double? rating,
    Map<String, Object?> dimensions = const {},
  }) {
    return AnalyticsRecord(
      id: id,
      domain: domain,
      occurredAt: occurredAt,
      status: status,
      peopleCount: peopleCount,
      vehicleCount: vehicleCount,
      humanResourcesCount: humanResourcesCount,
      targetValue: targetValue,
      achievedValue: achievedValue,
      rating: rating,
      dimensions: dimensions,
    );
  }

  group('AnalyticsEngine.process — resultado básico', () {
    test('processa coleção vazia sem lançar exceção', () {
      final result = engine.process(records: const <AnalyticsRecord>[]);
      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, 0);
      expect(result.totalRecords, 0);
      expect(result.hasIgnoredRecords, isFalse);
      expect(result.processingEfficiency, 0);
    });

    test('produz métricas zeradas para coleção vazia', () {
      final result = engine.process(records: const <AnalyticsRecord>[]);
      expect(result.metrics.totalRecords, 0);
      expect(result.metrics.totalPeople, 0);
      expect(result.metrics.totalVehicles, 0);
      expect(result.metrics.totalHumanResources, 0);
      expect(result.metrics.averagePeople, 0);
      expect(result.metrics.averageVehicles, 0);
      expect(result.metrics.averageHumanResources, 0);
      expect(result.metrics.recordsWithTarget, 0);
      expect(result.metrics.recordsTargetAchieved, 0);
      expect(result.metrics.targetAchievementRate, 0);
      expect(result.metrics.averageRating, 0);
    });

    test('utiliza AnalyticsFilters.empty quando filters é nulo', () {
      final result = engine.process(records: const <AnalyticsRecord>[]);
      expect(result.filters, AnalyticsFilters.empty());
      expect(result.filters.hasSelectionCriteria, isFalse);
      expect(result.filters.sortField, AnalyticsSortField.occurredAt);
      expect(result.filters.sortDirection, AnalyticsSortDirection.descending);
    });

    test('preserva a instância explícita de filtros no resultado', () {
      final filters = AnalyticsFilters(domain: 'educacao', status: 'concluida');
      final result = engine.process(
        records: const <AnalyticsRecord>[],
        filters: filters,
      );
      expect(identical(result.filters, filters), isTrue);
    });

    test('informa a versão oficial 2.0.0 do engine', () {
      final result = engine.process(records: const <AnalyticsRecord>[]);
      expect(result.engineVersion, '2.0.0');
    });

    test('produz processingTime não negativo', () {
      final result = engine.process(records: const <AnalyticsRecord>[]);
      expect(result.processingTime, greaterThanOrEqualTo(Duration.zero));
    });

    test('processedAt fica entre o início e o fim da chamada', () {
      final before = DateTime.now();
      final result = engine.process(records: const <AnalyticsRecord>[]);
      final after = DateTime.now();
      expect(result.processedAt.isBefore(before), isFalse);
      expect(result.processedAt.isAfter(after), isFalse);
    });

    test('metadata permanece vazio no resultado produzido pelo engine', () {
      final result = engine.process(records: const <AnalyticsRecord>[]);
      expect(result.metadata, isEmpty);
      expect(result.hasMetadata, isFalse);
    });
  });

  group('AnalyticsEngine.process — contadores', () {
    test('processa todos os registros quando não existem critérios', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1)),
        record(id: '2', occurredAt: DateTime(2026, 1, 2)),
        record(id: '3', occurredAt: DateTime(2026, 1, 3)),
      ];
      final result = engine.process(records: records);
      expect(result.processedRecords, 3);
      expect(result.ignoredRecords, 0);
      expect(result.totalRecords, 3);
      expect(result.processingEfficiency, 1);
    });

    test('contabiliza registros ignorados por filtro', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), domain: 'educacao'),
        record(id: '2', occurredAt: DateTime(2026, 1, 2), domain: 'rpas'),
        record(id: '3', occurredAt: DateTime(2026, 1, 3), domain: 'educacao'),
      ];
      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(domain: 'educacao'),
      );
      expect(result.processedRecords, 2);
      expect(result.ignoredRecords, 1);
      expect(result.totalRecords, 3);
      expect(result.hasIgnoredRecords, isTrue);
      expect(result.processingEfficiency, closeTo(2 / 3, 0.000001));
    });

    test('considera o limite como descarte no contador ignoredRecords', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1)),
        record(id: '2', occurredAt: DateTime(2026, 1, 2)),
        record(id: '3', occurredAt: DateTime(2026, 1, 3)),
      ];
      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(limit: 2),
      );
      expect(result.processedRecords, 2);
      expect(result.ignoredRecords, 1);
      expect(result.totalRecords, 3);
    });

    test('quando nenhum registro corresponde, todos são ignorados', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1)),
        record(id: '2', occurredAt: DateTime(2026, 1, 2)),
      ];
      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(domain: 'rpas'),
      );
      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, 2);
      expect(result.processingEfficiency, 0);
    });
  });

  group('AnalyticsEngine.process — métricas de produtividade', () {
    test('soma pessoas, veículos e recursos humanos', () {
      final records = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          peopleCount: 10,
          vehicleCount: 3,
          humanResourcesCount: 2,
        ),
        record(
          id: '2',
          occurredAt: DateTime(2026, 1, 2),
          peopleCount: 20,
          vehicleCount: 7,
          humanResourcesCount: 4,
        ),
      ];
      final result = engine.process(records: records);
      expect(result.metrics.totalRecords, 2);
      expect(result.metrics.totalPeople, 30);
      expect(result.metrics.totalVehicles, 10);
      expect(result.metrics.totalHumanResources, 6);
    });

    test('calcula médias por registro', () {
      final records = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          peopleCount: 10,
          vehicleCount: 2,
          humanResourcesCount: 1,
        ),
        record(
          id: '2',
          occurredAt: DateTime(2026, 1, 2),
          peopleCount: 20,
          vehicleCount: 6,
          humanResourcesCount: 3,
        ),
      ];
      final result = engine.process(records: records);
      expect(result.metrics.averagePeople, 15);
      expect(result.metrics.averageVehicles, 4);
      expect(result.metrics.averageHumanResources, 2);
    });

    test('calcula alcance de metas', () {
      final records = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          targetValue: 100,
          achievedValue: 100,
        ),
        record(
          id: '2',
          occurredAt: DateTime(2026, 1, 2),
          targetValue: 100,
          achievedValue: 80,
        ),
        record(id: '3', occurredAt: DateTime(2026, 1, 3)),
      ];
      final result = engine.process(records: records);
      expect(result.metrics.recordsWithTarget, 2);
      expect(result.metrics.recordsTargetAchieved, 1);
      expect(result.metrics.targetAchievementRate, 0.5);
    });

    test('meta superada é contabilizada como atingida', () {
      final result = engine.process(
        records: [
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            targetValue: 100,
            achievedValue: 150,
          ),
        ],
      );
      expect(result.metrics.recordsWithTarget, 1);
      expect(result.metrics.recordsTargetAchieved, 1);
      expect(result.metrics.targetAchievementRate, 1);
    });

    test('calcula averageRating conforme contrato atual do calculator', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), rating: 4),
        record(id: '2', occurredAt: DateTime(2026, 1, 2), rating: 2),
      ];
      final result = engine.process(records: records);
      expect(result.metrics.averageRating, 3);
    });

    test('rating nulo participa do divisor conforme contrato atual', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), rating: 4),
        record(id: '2', occurredAt: DateTime(2026, 1, 2)),
      ];
      final result = engine.process(records: records);
      expect(result.metrics.averageRating, 2);
    });

    test('métricas consideram apenas registros após os filtros', () {
      final records = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          domain: 'educacao',
          peopleCount: 10,
        ),
        record(
          id: '2',
          occurredAt: DateTime(2026, 1, 2),
          domain: 'rpas',
          peopleCount: 100,
        ),
      ];
      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(domain: 'educacao'),
      );
      expect(result.metrics.totalRecords, 1);
      expect(result.metrics.totalPeople, 10);
    });

    test('métricas consideram somente registros mantidos pelo limite', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), peopleCount: 10),
        record(id: '2', occurredAt: DateTime(2026, 1, 2), peopleCount: 20),
        record(id: '3', occurredAt: DateTime(2026, 1, 3), peopleCount: 30),
      ];
      final result = engine.process(
        records: records,
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.occurredAt,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 2,
        ),
      );
      expect(result.metrics.totalRecords, 2);
      expect(result.metrics.totalPeople, 50);
    });
  });

  group('AnalyticsEngine.process — materialização e integridade', () {
    test('itera a fonte lazy somente uma vez', () {
      final source = CountingIterable<AnalyticsRecord>([
        record(id: '1', occurredAt: DateTime(2026, 1, 1)),
        record(id: '2', occurredAt: DateTime(2026, 1, 2)),
      ]);
      final result = engine.process(records: source);
      expect(result.processedRecords, 2);
      expect(source.iteratorAccessCount, 1);
    });

    test('não altera a ordem da lista original', () {
      final first = record(id: '1', occurredAt: DateTime(2026, 1, 1));
      final second = record(id: '2', occurredAt: DateTime(2026, 1, 2));
      final source = [first, second];
      engine.process(records: source);
      expect(source, orderedEquals([first, second]));
    });

    test('aceita Set como fonte de registros', () {
      final source = <AnalyticsRecord>{
        record(id: '1', occurredAt: DateTime(2026, 1, 1)),
        record(id: '2', occurredAt: DateTime(2026, 1, 2)),
      };
      final result = engine.process(records: source);
      expect(result.processedRecords, 2);
    });

    test('aceita Iterable gerado por sync*', () {
      Iterable<AnalyticsRecord> source() sync* {
        yield record(id: '1', occurredAt: DateTime(2026, 1, 1));
        yield record(id: '2', occurredAt: DateTime(2026, 1, 2));
      }
      final result = engine.process(records: source());
      expect(result.processedRecords, 2);
    });
  });
}

final class CountingIterable<T> extends IterableBase<T> {
  CountingIterable(this._items);

  final List<T> _items;
  int iteratorAccessCount = 0;

  @override
  Iterator<T> get iterator {
    iteratorAccessCount++;
    return _items.iterator;
  }
}
