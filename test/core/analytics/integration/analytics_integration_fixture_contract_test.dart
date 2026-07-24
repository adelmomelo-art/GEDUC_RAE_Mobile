import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_record.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  group('AnalyticsIntegrationFixture — contrato estrutural', () {
    test('possui exatamente 24 registros', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(records, hasLength(24));
    });

    test('possui identificadores únicos', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final ids = records.map((record) => record.id).toSet();

      expect(ids, hasLength(records.length));
    });

    test('não possui identificadores vazios', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(
        records.every((record) => record.id.trim().isNotEmpty),
        isTrue,
      );
    });

    test('distribui corretamente os registros por domínio', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(
        records
            .where(
              (record) =>
                  record.domain ==
                  AnalyticsIntegrationFixture.educationDomain,
            )
            .length,
        18,
      );
      expect(
        records
            .where(
              (record) =>
                  record.domain == AnalyticsIntegrationFixture.rpasDomain,
            )
            .length,
        4,
      );
      expect(
        records
            .where(
              (record) =>
                  record.domain ==
                  AnalyticsIntegrationFixture.inspectionDomain,
            )
            .length,
        2,
      );
    });

    test('utiliza apenas os domínios oficiais da fixture', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      final domains = records.map((record) => record.domain).toSet();

      expect(
        domains,
        equals({
          AnalyticsIntegrationFixture.educationDomain,
          AnalyticsIntegrationFixture.rpasDomain,
          AnalyticsIntegrationFixture.inspectionDomain,
        }),
      );
    });

    test('distribui corretamente os registros por status', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(
        records
            .where(
              (record) =>
                  record.status ==
                  AnalyticsIntegrationFixture.completedStatus,
            )
            .length,
        18,
      );
      expect(
        records
            .where(
              (record) =>
                  record.status ==
                  AnalyticsIntegrationFixture.plannedStatus,
            )
            .length,
        3,
      );
      expect(
        records
            .where(
              (record) =>
                  record.status ==
                  AnalyticsIntegrationFixture.cancelledStatus,
            )
            .length,
        3,
      );
    });

    test('utiliza apenas os status oficiais da fixture', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      final statuses = records.map((record) => record.status).toSet();

      expect(
        statuses,
        equals({
          AnalyticsIntegrationFixture.completedStatus,
          AnalyticsIntegrationFixture.plannedStatus,
          AnalyticsIntegrationFixture.cancelledStatus,
        }),
      );
    });

    test('todos os registros possuem data operacional em 2026', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(
        records.every((record) => record.occurredAt.year == 2026),
        isTrue,
      );
    });

    test('todos os registros possuem dimensões operacionais principais', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      for (final record in records) {
        expect(record.dimension('regional'), isNotNull);
        expect(record.dimension('turno'), isNotNull);
        expect(record.dimension('projeto'), isNotNull);
        expect(record.dimension('tipo_acao'), isNotNull);
      }
    });

    test('nenhuma dimensão operacional principal é vazia', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      for (final record in records) {
        _expectNonEmptyStringDimension(record, 'regional');
        _expectNonEmptyStringDimension(record, 'turno');
        _expectNonEmptyStringDimension(record, 'projeto');
        _expectNonEmptyStringDimension(record, 'tipo_acao');
      }
    });

    test('a lista principal é imutável', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(
        () => records.add(
          AnalyticsRecord(
            id: 'INVALID-MUTATION',
            domain: AnalyticsIntegrationFixture.educationDomain,
            occurredAt: DateTime(2026, 1, 1),
            status: AnalyticsIntegrationFixture.completedStatus,
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('cada chamada retorna uma nova lista independente', () {
      final first = AnalyticsIntegrationFixture.operationalRecords();
      final second = AnalyticsIntegrationFixture.operationalRecords();

      expect(identical(first, second), isFalse);
      expect(
        first.map(_snapshot),
        orderedEquals(second.map(_snapshot)),
      );
    });

    test('cada chamada retorna novas instâncias dos registros', () {
      final first = AnalyticsIntegrationFixture.operationalRecords();
      final second = AnalyticsIntegrationFixture.operationalRecords();

      expect(identical(first.first, second.first), isFalse);
      expect(_snapshot(first.first), equals(_snapshot(second.first)));
    });
  });

  group('AnalyticsIntegrationFixture — subconjuntos oficiais', () {
    test('educationRecords retorna 18 registros', () {
      final records = AnalyticsIntegrationFixture.educationRecords();

      expect(records, hasLength(18));
      expect(
        records.every(
          (record) =>
              record.domain ==
              AnalyticsIntegrationFixture.educationDomain,
        ),
        isTrue,
      );
    });

    test('completedEducationRecords retorna 14 registros', () {
      final records =
          AnalyticsIntegrationFixture.completedEducationRecords();

      expect(records, hasLength(14));
      expect(
        records.every(
          (record) =>
              record.domain ==
                  AnalyticsIntegrationFixture.educationDomain &&
              record.status ==
                  AnalyticsIntegrationFixture.completedStatus,
        ),
        isTrue,
      );
    });

    test('julyEducationRecords retorna 5 registros', () {
      final records =
          AnalyticsIntegrationFixture.julyEducationRecords();

      expect(records, hasLength(5));
      expect(
        records.every(
          (record) =>
              record.domain ==
                  AnalyticsIntegrationFixture.educationDomain &&
              record.occurredAt.year == 2026 &&
              record.occurredAt.month == DateTime.july,
        ),
        isTrue,
      );
    });

    test('Regional VI, manhã e concluída retorna 6 registros', () {
      final records = AnalyticsIntegrationFixture
          .regionalVIMorningCompletedEducationRecords();

      expect(records, hasLength(6));
      expect(
        records.every(
          (record) =>
              record.domain ==
                  AnalyticsIntegrationFixture.educationDomain &&
              record.status ==
                  AnalyticsIntegrationFixture.completedStatus &&
              record.dimension('regional') == 'VI' &&
              record.dimension('turno') == 'manha',
        ),
        isTrue,
      );
    });

    test('subconjuntos também são imutáveis', () {
      final records = AnalyticsIntegrationFixture.educationRecords();

      expect(
        () => records.clear(),
        throwsUnsupportedError,
      );
    });

    test('subconjuntos são novas listas a cada chamada', () {
      final first = AnalyticsIntegrationFixture.educationRecords();
      final second = AnalyticsIntegrationFixture.educationRecords();

      expect(identical(first, second), isFalse);
      expect(
        first.map(_snapshot),
        orderedEquals(second.map(_snapshot)),
      );
    });
  });

  group('AnalyticsIntegrationFixture — dados parciais', () {
    test('possui quatro cenários de campos opcionais ausentes', () {
      final records =
          AnalyticsIntegrationFixture.partialDataRecords();

      expect(records, hasLength(4));
    });

    test('inclui registro sem avaliação e sem meta', () {
      final record = AnalyticsIntegrationFixture.partialDataRecords()
          .firstWhere((item) => item.id == 'PARTIAL-001');

      expect(record.hasRating, isFalse);
      expect(record.hasTarget, isFalse);
      expect(record.hasAchievedValue, isFalse);
    });

    test('inclui meta sem valor realizado', () {
      final record = AnalyticsIntegrationFixture.partialDataRecords()
          .firstWhere((item) => item.id == 'PARTIAL-002');

      expect(record.hasTarget, isTrue);
      expect(record.hasAchievedValue, isFalse);
      expect(record.hasReachedTarget, isFalse);
    });

    test('inclui valor realizado sem meta', () {
      final record = AnalyticsIntegrationFixture.partialDataRecords()
          .firstWhere((item) => item.id == 'PARTIAL-003');

      expect(record.hasTarget, isFalse);
      expect(record.hasAchievedValue, isTrue);
      expect(record.hasReachedTarget, isFalse);
    });

    test('inclui registro sem dimensões', () {
      final record = AnalyticsIntegrationFixture.partialDataRecords()
          .firstWhere((item) => item.id == 'PARTIAL-004');

      expect(record.dimensions, isEmpty);
    });

    test('a lista de dados parciais é imutável', () {
      final records =
          AnalyticsIntegrationFixture.partialDataRecords();

      expect(
        () => records.removeLast(),
        throwsUnsupportedError,
      );
    });
  });

  group('AnalyticsIntegrationFixture — volume determinístico', () {
    test('gera a quantidade solicitada', () {
      final records =
          AnalyticsIntegrationFixture.largeDataset(count: 250);

      expect(records, hasLength(250));
    });

    test('zero gera lista vazia', () {
      final records =
          AnalyticsIntegrationFixture.largeDataset(count: 0);

      expect(records, isEmpty);
    });

    test('quantidade negativa é rejeitada', () {
      expect(
        () => AnalyticsIntegrationFixture.largeDataset(count: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a geração é determinística sem depender de operator ==', () {
      final first =
          AnalyticsIntegrationFixture.largeDataset(count: 100);
      final second =
          AnalyticsIntegrationFixture.largeDataset(count: 100);

      expect(
        first.map(_snapshot),
        orderedEquals(second.map(_snapshot)),
      );
    });

    test('gera identificadores únicos', () {
      final records =
          AnalyticsIntegrationFixture.largeDataset(count: 1000);
      final ids = records.map((record) => record.id).toSet();

      expect(ids, hasLength(1000));
    });

    test('a lista de volume é imutável', () {
      final records =
          AnalyticsIntegrationFixture.largeDataset(count: 10);

      expect(
        () => records.removeLast(),
        throwsUnsupportedError,
      );
    });

    test('mantém os campos estruturais obrigatórios no volume gerado', () {
      final records =
          AnalyticsIntegrationFixture.largeDataset(count: 500);

      expect(
        records.every(
          (record) =>
              record.id.isNotEmpty &&
              record.domain.isNotEmpty &&
              record.status.isNotEmpty &&
              record.dimension('regional') != null &&
              record.dimension('turno') != null &&
              record.dimension('projeto') != null &&
              record.dimension('tipo_acao') != null,
        ),
        isTrue,
      );
    });
  });
}


void _expectNonEmptyStringDimension(
  AnalyticsRecord record,
  String key,
) {
  final value = record.dimension(key);

  expect(
    value,
    isA<String>(),
    reason: 'A dimensão "$key" do registro ${record.id} deve ser String.',
  );

  expect(
    (value as String).trim(),
    isNotEmpty,
    reason: 'A dimensão "$key" do registro ${record.id} não pode ser vazia.',
  );
}

String _snapshot(AnalyticsRecord record) {
  final sortedDimensions = record.dimensions.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final dimensions = sortedDimensions
      .map((entry) => '${entry.key}=${entry.value}')
      .join('|');

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
    dimensions,
  ].join('::');
}
