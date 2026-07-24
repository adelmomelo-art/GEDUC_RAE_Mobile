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
    double? rating,
  }) {
    return AnalyticsRecord(
      id: id,
      domain: domain,
      occurredAt: occurredAt,
      status: status,
      peopleCount: peopleCount,
      vehicleCount: vehicleCount,
      humanResourcesCount: humanResourcesCount,
      rating: rating,
    );
  }

  group('AnalyticsEngine — ordenação por occurredAt', () {
    test('ordena por data crescente antes de aplicar o limite', () {
      final result = engine.process(
        records: [
          record(
            id: 'middle',
            occurredAt: DateTime(2026, 7, 15),
            peopleCount: 20,
          ),
          record(
            id: 'latest',
            occurredAt: DateTime(2026, 7, 31),
            peopleCount: 30,
          ),
          record(
            id: 'earliest',
            occurredAt: DateTime(2026, 7, 1),
            peopleCount: 10,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.occurredAt,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.processedRecords, 1);
      expect(result.metrics.totalPeople, 10);
    });

    test('ordena por data decrescente antes de aplicar o limite', () {
      final result = engine.process(
        records: [
          record(
            id: 'middle',
            occurredAt: DateTime(2026, 7, 15),
            peopleCount: 20,
          ),
          record(
            id: 'earliest',
            occurredAt: DateTime(2026, 7, 1),
            peopleCount: 10,
          ),
          record(
            id: 'latest',
            occurredAt: DateTime(2026, 7, 31),
            peopleCount: 30,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.occurredAt,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.processedRecords, 1);
      expect(result.metrics.totalPeople, 30);
    });

    test('a ordenação padrão é por data decrescente', () {
      final result = engine.process(
        records: [
          record(
            id: 'earliest',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
          ),
          record(
            id: 'latest',
            occurredAt: DateTime(2026, 12, 31),
            peopleCount: 90,
          ),
        ],
        filters: AnalyticsFilters(limit: 1),
      );

      expect(result.metrics.totalPeople, 90);
    });

    test('mantém todos os registros quando não há limite', () {
      final result = engine.process(
        records: [
          record(
            id: '2',
            occurredAt: DateTime(2026, 2, 1),
            peopleCount: 20,
          ),
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.occurredAt,
          sortDirection: AnalyticsSortDirection.ascending,
        ),
      );

      expect(result.processedRecords, 2);
      expect(result.metrics.totalPeople, 30);
    });
  });

  group('AnalyticsEngine — ordenação por domain', () {
    test('ordena domínio em ordem crescente', () {
      final result = engine.process(
        records: [
          record(
            id: 'z',
            occurredAt: DateTime(2026, 1, 1),
            domain: 'rpas',
            peopleCount: 30,
          ),
          record(
            id: 'a',
            occurredAt: DateTime(2026, 1, 2),
            domain: 'educacao',
            peopleCount: 10,
          ),
          record(
            id: 'm',
            occurredAt: DateTime(2026, 1, 3),
            domain: 'fiscalizacao',
            peopleCount: 20,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.domain,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 10);
    });

    test('ordena domínio em ordem decrescente', () {
      final result = engine.process(
        records: [
          record(
            id: 'a',
            occurredAt: DateTime(2026, 1, 1),
            domain: 'educacao',
            peopleCount: 10,
          ),
          record(
            id: 'm',
            occurredAt: DateTime(2026, 1, 2),
            domain: 'fiscalizacao',
            peopleCount: 20,
          ),
          record(
            id: 'z',
            occurredAt: DateTime(2026, 1, 3),
            domain: 'rpas',
            peopleCount: 30,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.domain,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 30);
    });

    test('comparação de domínio segue compareTo nativo', () {
      final result = engine.process(
        records: [
          record(
            id: 'lower',
            occurredAt: DateTime(2026, 1, 1),
            domain: 'educacao',
            peopleCount: 20,
          ),
          record(
            id: 'upper',
            occurredAt: DateTime(2026, 1, 2),
            domain: 'Educacao',
            peopleCount: 10,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.domain,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 10);
    });
  });

  group('AnalyticsEngine — ordenação por status', () {
    test('ordena status em ordem crescente', () {
      final result = engine.process(
        records: [
          record(
            id: '3',
            occurredAt: DateTime(2026, 1, 1),
            status: 'planejada',
            peopleCount: 30,
          ),
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 2),
            status: 'cancelada',
            peopleCount: 10,
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 3),
            status: 'concluida',
            peopleCount: 20,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.status,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 10);
    });

    test('ordena status em ordem decrescente', () {
      final result = engine.process(
        records: [
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            status: 'cancelada',
            peopleCount: 10,
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 2),
            status: 'concluida',
            peopleCount: 20,
          ),
          record(
            id: '3',
            occurredAt: DateTime(2026, 1, 3),
            status: 'planejada',
            peopleCount: 30,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.status,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 30);
    });
  });

  group('AnalyticsEngine — ordenação por peopleCount', () {
    test('ordena pessoas em ordem crescente', () {
      final result = engine.process(
        records: [
          record(
            id: '30',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 30,
            vehicleCount: 3,
          ),
          record(
            id: '10',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 10,
            vehicleCount: 1,
          ),
          record(
            id: '20',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 20,
            vehicleCount: 2,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 10);
      expect(result.metrics.totalVehicles, 1);
    });

    test('ordena pessoas em ordem decrescente', () {
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
  });

  group('AnalyticsEngine — ordenação por vehicleCount', () {
    test('ordena veículos em ordem crescente', () {
      final result = engine.process(
        records: [
          record(
            id: '3',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 30,
            vehicleCount: 3,
          ),
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 10,
            vehicleCount: 1,
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 20,
            vehicleCount: 2,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.vehicleCount,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalVehicles, 1);
      expect(result.metrics.totalPeople, 10);
    });

    test('ordena veículos em ordem decrescente', () {
      final result = engine.process(
        records: [
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            vehicleCount: 1,
          ),
          record(
            id: '3',
            occurredAt: DateTime(2026, 1, 2),
            vehicleCount: 3,
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 3),
            vehicleCount: 2,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.vehicleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalVehicles, 3);
    });
  });

  group('AnalyticsEngine — ordenação por humanResourcesCount', () {
    test('ordena recursos humanos em ordem crescente', () {
      final result = engine.process(
        records: [
          record(
            id: '3',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 30,
            humanResourcesCount: 3,
          ),
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 10,
            humanResourcesCount: 1,
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 20,
            humanResourcesCount: 2,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.humanResourcesCount,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalHumanResources, 1);
      expect(result.metrics.totalPeople, 10);
    });

    test('ordena recursos humanos em ordem decrescente', () {
      final result = engine.process(
        records: [
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            humanResourcesCount: 1,
          ),
          record(
            id: '3',
            occurredAt: DateTime(2026, 1, 2),
            humanResourcesCount: 3,
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 3),
            humanResourcesCount: 2,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.humanResourcesCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalHumanResources, 3);
    });
  });

  group('AnalyticsEngine — ordenação por rating', () {
    test('ordena avaliações preenchidas em ordem crescente', () {
      final result = engine.process(
        records: [
          record(
            id: '5',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 50,
            rating: 5,
          ),
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 20,
            rating: 2,
          ),
          record(
            id: '4',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 40,
            rating: 4,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.rating,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 20);
      expect(result.metrics.averageRating, 2);
    });

    test('ordena avaliações preenchidas em ordem decrescente', () {
      final result = engine.process(
        records: [
          record(
            id: '2',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 20,
            rating: 2,
          ),
          record(
            id: '5',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 50,
            rating: 5,
          ),
          record(
            id: '4',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 40,
            rating: 4,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.rating,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 50);
      expect(result.metrics.averageRating, 5);
    });

    test('rating nulo vem antes dos preenchidos na ordem crescente', () {
      final result = engine.process(
        records: [
          record(
            id: 'filled',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 50,
            rating: 5,
          ),
          record(
            id: 'null',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 10,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.rating,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 10);
      expect(result.metrics.averageRating, 0);
    });

    test('rating nulo vem depois dos preenchidos na ordem decrescente', () {
      final result = engine.process(
        records: [
          record(
            id: 'null',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
          ),
          record(
            id: 'filled',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 50,
            rating: 5,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.rating,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.metrics.totalPeople, 50);
      expect(result.metrics.averageRating, 5);
    });

    test('dois ratings nulos são considerados equivalentes', () {
      final result = engine.process(
        records: [
          record(
            id: 'first-null',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 10,
          ),
          record(
            id: 'second-null',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 20,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.rating,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 2,
        ),
      );

      expect(result.processedRecords, 2);
      expect(result.metrics.totalPeople, 30);
      expect(result.metrics.averageRating, 0);
    });
  });

  group('AnalyticsEngine — ordenação combinada com filtros', () {
    test('filtra antes de ordenar e limitar', () {
      final result = engine.process(
        records: [
          record(
            id: 'rpas-high',
            occurredAt: DateTime(2026, 1, 1),
            domain: 'rpas',
            peopleCount: 100,
          ),
          record(
            id: 'edu-low',
            occurredAt: DateTime(2026, 1, 2),
            domain: 'educacao',
            peopleCount: 10,
          ),
          record(
            id: 'edu-high',
            occurredAt: DateTime(2026, 1, 3),
            domain: 'educacao',
            peopleCount: 50,
          ),
        ],
        filters: AnalyticsFilters(
          domain: 'educacao',
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.descending,
          limit: 1,
        ),
      );

      expect(result.processedRecords, 1);
      expect(result.ignoredRecords, 2);
      expect(result.metrics.totalPeople, 50);
    });

    test('direção crescente e limite dois selecionam os dois menores', () {
      final result = engine.process(
        records: [
          record(
            id: '40',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 40,
          ),
          record(
            id: '10',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 10,
          ),
          record(
            id: '30',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 30,
          ),
          record(
            id: '20',
            occurredAt: DateTime(2026, 1, 4),
            peopleCount: 20,
          ),
        ],
        filters: AnalyticsFilters(
          sortField: AnalyticsSortField.peopleCount,
          sortDirection: AnalyticsSortDirection.ascending,
          limit: 2,
        ),
      );

      expect(result.processedRecords, 2);
      expect(result.metrics.totalPeople, 30);
    });

    test('direção decrescente e limite dois selecionam os dois maiores', () {
      final result = engine.process(
        records: [
          record(
            id: '40',
            occurredAt: DateTime(2026, 1, 1),
            peopleCount: 40,
          ),
          record(
            id: '10',
            occurredAt: DateTime(2026, 1, 2),
            peopleCount: 10,
          ),
          record(
            id: '30',
            occurredAt: DateTime(2026, 1, 3),
            peopleCount: 30,
          ),
          record(
            id: '20',
            occurredAt: DateTime(2026, 1, 4),
            peopleCount: 20,
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
}
