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
    int peopleCount = 0,
    int vehicleCount = 0,
    int humanResourcesCount = 0,
    double? rating,
  }) {
    return AnalyticsRecord(
      id: id,
      domain: domain,
      occurredAt: occurredAt,
      status: 'concluida',
      peopleCount: peopleCount,
      vehicleCount: vehicleCount,
      humanResourcesCount: humanResourcesCount,
      rating: rating,
    );
  }

  group('AnalyticsEngine — aplicação de limit', () {
    test('sem limit processa todos os registros', () {
      final result = engine.process(
        records: [
          record(id: '1', occurredAt: DateTime(2026, 1, 1)),
          record(id: '2', occurredAt: DateTime(2026, 1, 2)),
          record(id: '3', occurredAt: DateTime(2026, 1, 3)),
        ],
      );

      expect(result.processedRecords, 3);
      expect(result.ignoredRecords, 0);
      expect(result.totalRecords, 3);
    });

    test('limit maior que a quantidade mantém todos os registros', () {
      final result = engine.process(
        records: [
          record(id: '1', occurredAt: DateTime(2026, 1, 1)),
          record(id: '2', occurredAt: DateTime(2026, 1, 2)),
        ],
        filters: AnalyticsFilters(limit: 10),
      );

      expect(result.processedRecords, 2);
      expect(result.ignoredRecords, 0);
      expect(result.totalRecords, 2);
    });

    test('limit igual à quantidade mantém todos os registros', () {
      final result = engine.process(
        records: [
          record(id: '1', occurredAt: DateTime(2026, 1, 1)),
          record(id: '2', occurredAt: DateTime(2026, 1, 2)),
        ],
        filters: AnalyticsFilters(limit: 2),
      );

      expect(result.processedRecords, 2);
      expect(result.ignoredRecords, 0);
    });

    test('limit um mantém somente um registro', () {
      final result = engine.process(
        records: [
          record(
            id: 'old',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
          ),
          record(
            id: 'new',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 20,
          ),
        ],
        filters: AnalyticsFilters(limit: 1),
      );

      expect(result.processedRecords, 1);
      expect(result.ignoredRecords, 1);
      expect(result.metrics.totalPeople, 20);
    });

    test('limit dois mantém somente dois registros', () {
      final result = engine.process(
        records: [
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 20,
          ),
          record(
            id: '3',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 30,
          ),
        ],
        filters: AnalyticsFilters(limit: 2),
      );

      expect(result.processedRecords, 2);
      expect(result.ignoredRecords, 1);
      expect(result.metrics.totalPeople, 50);
    });

    test('coleção vazia permanece vazia com limit', () {
      final result = engine.process(
        records: const <AnalyticsRecord>[],
        filters: AnalyticsFilters(limit: 5),
      );

      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, 0);
      expect(result.totalRecords, 0);
    });
  });

  group('AnalyticsEngine — validação de limit', () {
    test('limit zero é rejeitado por AnalyticsFilters', () {
      expect(
        () => AnalyticsFilters(limit: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('limit negativo é rejeitado por AnalyticsFilters', () {
      expect(
        () => AnalyticsFilters(limit: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('limit positivo é aceito', () {
      final filters = AnalyticsFilters(limit: 1);

      expect(filters.limit, 1);
      expect(filters.hasLimit, isTrue);
    });

    test('limit nulo representa ausência de limitação', () {
      final filters = AnalyticsFilters();

      expect(filters.limit, isNull);
      expect(filters.hasLimit, isFalse);
    });
  });

  group('AnalyticsEngine — limit e ordenação', () {
    test('o limite é aplicado após a ordenação crescente', () {
      final result = engine.process(
        records: [
          record(
            id: '30',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 30,
          ),
          record(
            id: '10',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 10,
          ),
          record(
            id: '20',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 20,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 10);
    });

    test('o limite é aplicado após a ordenação decrescente', () {
      final result = engine.process(
        records: [
          record(
            id: '10',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
          ),
          record(
            id: '30',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 30,
          ),
          record(
            id: '20',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 20,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 30);
    });

    test('limit dois preserva a seleção dos dois maiores', () {
      final result = engine.process(
        records: [
          record(
            id: '10',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
          ),
          record(
            id: '40',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 40,
          ),
          record(
            id: '20',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 20,
          ),
          record(
            id: '30',
            occurredAt: DateTime(2026, 1, 4),
            peopleCount: 30,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 2,
        ),
      );

      expect(result.processedRecords, 2);
      expect(result.metrics.totalPeople, 70);
    });
  });

  group('AnalyticsEngine — limit e filtros de seleção', () {
    test('o limite incide somente sobre registros já filtrados', () {
      final result = engine.process(
        records: [
          record(
            id: 'rpas',
            occurredAt: DateTime(2026, 1, 3),
            domain: 'rpas',
            peopleCount: 100,
          ),
          record(
            id: 'edu-new',
            occurredAt: DateTime(2026, 1, 2),
            domain: 'educacao',
            peopleCount: 20,
          ),
          record(
            id: 'edu-old',
            occurredAt: DateTime(2026, 1, 1),
            domain: 'educacao',
            peopleCount: 10,
          ),
        ],
        filters: AnalyticsFilters(
          domain: 'educacao',
          limit: 1,
        ),
      );

      expect(result.processedRecords, 1);
      expect(result.ignoredRecords, 2);
      expect(result.metrics.totalPeople, 20);
    });

    test('quando o filtro já reduz abaixo do limite, nada mais é removido', () {
      final result = engine.process(
        records: [
          record(
            id: 'rpas-1',
            occurredAt: DateTime(2026, 1, 1),
            domain: 'rpas',
          ),
          record(
            id: 'edu-1',
            occurredAt: DateTime(2026, 1, 2),
            domain: 'educacao',
          ),
          record(
            id: 'rpas-2',
            occurredAt: DateTime(2026, 1, 3),
            domain: 'rpas',
          ),
        ],
        filters: AnalyticsFilters(
          domain: 'educacao',
          limit: 5,
        ),
      );

      expect(result.processedRecords, 1);
      expect(result.ignoredRecords, 2);
    });

    test('nenhum correspondente continua com zero processados', () {
      final result = engine.process(
        records: [
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            domain: 'educacao',
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 2),
            domain: 'educacao',
          ),
        ],
        filters: AnalyticsFilters(
          domain: 'rpas',
          limit: 1,
        ),
      );

      expect(result.processedRecords, 0);
      expect(result.ignoredRecords, 2);
      expect(result.processingEfficiency, 0);
    });
  });

  group('AnalyticsEngine — métricas após limit', () {
    test('todas as métricas são calculadas somente com registros mantidos', () {
      final result = engine.process(
        records: [
          record(
            id: 'low',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
            vehicleCount: 1,
            humanResourcesCount: 2,
            rating: 2,
          ),
          record(
            id: 'high',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 30,
            vehicleCount: 3,
            humanResourcesCount: 4,
            rating: 5,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalRecords, 1);
      expect(result.metrics.totalPeople, 30);
      expect(result.metrics.totalVehicles, 3);
      expect(result.metrics.totalHumanResources, 4);
      expect(result.metrics.averagePeople, 30);
      expect(result.metrics.averageVehicles, 3);
      expect(result.metrics.averageHumanResources, 4);
      expect(result.metrics.averageRating, 5);
    });

    test('processingEfficiency reflete a redução causada pelo limite', () {
      final result = engine.process(
        records: [
          record(id: '1', occurredAt: DateTime(2026, 1, 1)),
          record(id: '2', occurredAt: DateTime(2026, 1, 2)),
          record(id: '3', occurredAt: DateTime(2026, 1, 3)),
          record(id: '4', occurredAt: DateTime(2026, 1, 4)),
        ],
        filters: AnalyticsFilters(limit: 1),
      );

      expect(result.processedRecords, 1);
      expect(result.ignoredRecords, 3);
      expect(result.processingEfficiency, 0.25);
    });

    test('totalRecords reconstrói o total recebido antes do limite', () {
      final result = engine.process(
        records: [
          record(id: '1', occurredAt: DateTime(2026, 1, 1)),
          record(id: '2', occurredAt: DateTime(2026, 1, 2)),
          record(id: '3', occurredAt: DateTime(2026, 1, 3)),
        ],
        filters: AnalyticsFilters(limit: 1),
      );

      expect(result.totalRecords, 3);
      expect(
        result.totalRecords,
        result.processedRecords + result.ignoredRecords,
      );
    });
  });

  group('AnalyticsEngine — integridade da fonte com limit', () {
    test('não remove elementos da lista original', () {
      final source = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1)),
        record(id: '2', occurredAt: DateTime(2026, 1, 2)),
        record(id: '3', occurredAt: DateTime(2026, 1, 3)),
      ];

      engine.process(
        records: source,
        filters: AnalyticsFilters(limit: 1),
      );

      expect(source, hasLength(3));
    });

    test('não reordena a lista original', () {
      final first = record(
        id: 'first',
        occurredAt: DateTime(2026, 1, 1),
        peopleCount: 10,
      );
      final second = record(
        id: 'second',
        occurredAt: DateTime(2026, 1, 2),
        peopleCount: 20,
      );
      final source = [first, second];

      engine.process(
        records: source,
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(source, orderedEquals([first, second]));
    });

    test('aceita Iterable lazy com limit', () {
      Iterable<AnalyticsRecord> source() sync* {
        yield record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          peopleCount: 10,
        );
        yield record(
          id: '2',
          occurredAt: DateTime(2026, 1, 2),
          peopleCount: 20,
        );
        yield record(
          id: '3',
          occurredAt: DateTime(2026, 1, 3),
          peopleCount: 30,
        );
      }

      final result = engine.process(
        records: source(),
        filters: AnalyticsFilters(limit: 2),
      );

      expect(result.processedRecords, 2);
      expect(result.metrics.totalPeople, 50);
    });
  });
}
