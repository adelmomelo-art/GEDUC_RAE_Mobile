import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_record.dart';

import '../../../fixtures/analytics_integration_fixture.dart';

void main() {
  group('OE-003.7.2 — RT-001 Golden Dataset', () {
    test('mantém o snapshot canônico da massa operacional oficial', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      final snapshot = records
          .map(_canonicalRecord)
          .toList(growable: false);

      expect(snapshot, _expectedOperationalSnapshot);
    });

    test('mantém quantidade, domínios e status homologados', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(records, hasLength(24));

      expect(
        _countBy(records, (record) => record.domain),
        {
          AnalyticsIntegrationFixture.educationDomain: 18,
          AnalyticsIntegrationFixture.rpasDomain: 4,
          AnalyticsIntegrationFixture.inspectionDomain: 2,
        },
      );

      expect(
        _countBy(records, (record) => record.status),
        {
          AnalyticsIntegrationFixture.completedStatus: 18,
          AnalyticsIntegrationFixture.plannedStatus: 3,
          AnalyticsIntegrationFixture.cancelledStatus: 3,
        },
      );
    });

    test('mantém os totais operacionais homologados', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(
        records.fold<int>(
          0,
          (sum, record) => sum + record.peopleCount,
        ),
        2680,
      );

      expect(
        records.fold<int>(
          0,
          (sum, record) => sum + record.vehicleCount,
        ),
        1103,
      );

      expect(
        records.fold<int>(
          0,
          (sum, record) => sum + record.humanResourcesCount,
        ),
        112,
      );
    });

    test('mantém os contratos de campos opcionais', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();

      expect(
        records.where((record) => record.targetValue != null),
        hasLength(21),
      );

      expect(
        records.where((record) => record.achievedValue != null),
        hasLength(18),
      );

      expect(
        records.where((record) => record.rating != null),
        hasLength(17),
      );
    });

    test('mantém identificadores únicos e na ordem oficial', () {
      final records = AnalyticsIntegrationFixture.operationalRecords();
      final ids = records
          .map((record) => record.id)
          .toList(growable: false);

      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, _expectedOperationalIds);
    });

    test('cada chamada retorna uma nova lista com o mesmo conteúdo', () {
      final first = AnalyticsIntegrationFixture.operationalRecords();
      final second = AnalyticsIntegrationFixture.operationalRecords();

      expect(identical(first, second), isFalse);

      expect(
        first.map(_canonicalRecord).toList(growable: false),
        second.map(_canonicalRecord).toList(growable: false),
      );
    });
  });
}

Map<String, int> _countBy(
  Iterable<AnalyticsRecord> records,
  String Function(AnalyticsRecord record) selector,
) {
  final result = <String, int>{};

  for (final record in records) {
    final key = selector(record);
    result[key] = (result[key] ?? 0) + 1;
  }

  return result;
}

String _canonicalRecord(AnalyticsRecord record) {
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
    record.dimension('regional'),
    record.dimension('turno'),
    record.dimension('projeto'),
    record.dimension('tipo_acao'),
  ].join('|');
}

const List<String> _expectedOperationalIds = [
  'EDU-001',
  'EDU-002',
  'EDU-003',
  'EDU-004',
  'EDU-005',
  'EDU-006',
  'EDU-007',
  'EDU-008',
  'EDU-009',
  'EDU-010',
  'EDU-011',
  'EDU-012',
  'EDU-013',
  'EDU-014',
  'EDU-015',
  'EDU-016',
  'EDU-017',
  'EDU-018',
  'RPAS-001',
  'RPAS-002',
  'RPAS-003',
  'RPAS-004',
  'FIS-001',
  'FIS-002',
];

const List<String> _expectedOperationalSnapshot = [
  'EDU-001|educacao|2026-01-10T08:00:00.000|concluida|120|35|5|100.0|120.0|4.5|I|manha|AMC nas Escolas|palestra',
  'EDU-002|educacao|2026-01-20T14:00:00.000|concluida|80|20|4|100.0|80.0|4.0|II|tarde|Pit Stop da Educacao|comando educativo',
  'EDU-003|educacao|2026-02-05T09:00:00.000|concluida|210|55|7|200.0|210.0|5.0|VI|manha|Volta as Aulas|acao integrada',
  'EDU-004|educacao|2026-02-18T15:00:00.000|cancelada|0|0|0|null|null|null|III|tarde|Bike Cidade|comando educativo',
  'EDU-005|educacao|2026-03-03T08:30:00.000|concluida|160|40|6|150.0|160.0|4.2|VI|manha|Ciclista Seguro|comando educativo',
  'EDU-006|educacao|2026-03-22T19:00:00.000|concluida|95|60|5|100.0|95.0|3.8|IV|noite|AMC nos Bares|abordagem educativa',
  'EDU-007|educacao|2026-04-07T10:00:00.000|planejada|0|0|0|180.0|null|null|V|manha|AMC Kids|minicircuito',
  'EDU-008|educacao|2026-04-25T14:00:00.000|concluida|300|75|9|250.0|300.0|4.9|VI|tarde|AMC Itinerante|acao integrada',
  'EDU-009|educacao|2026-05-09T07:30:00.000|concluida|140|90|6|140.0|140.0|4.4|I|manha|Condutor Consciente|comando educativo',
  'EDU-010|educacao|2026-05-28T16:00:00.000|concluida|70|25|3|80.0|70.0|3.5|II|tarde|Crianca Segura|palestra',
  'EDU-011|educacao|2026-06-12T09:00:00.000|concluida|260|100|8|250.0|260.0|4.7|VI|manha|Motociclista Prudente|comando educativo',
  'EDU-012|educacao|2026-06-30T20:00:00.000|cancelada|0|0|0|120.0|null|null|XII|noite|Alegria com Responsabilidade|comando educativo',
  'EDU-013|educacao|2026-07-01T08:00:00.000|concluida|180|65|7|150.0|180.0|4.8|VI|manha|Volta as Aulas|acao integrada',
  'EDU-014|educacao|2026-07-11T08:30:00.000|concluida|240|85|8|200.0|240.0|4.6|VI|manha|Pit Stop da Educacao|comando educativo',
  'EDU-015|educacao|2026-07-15T14:00:00.000|concluida|110|45|5|120.0|110.0|4.1|II|tarde|Passeio Seguro|abordagem educativa',
  'EDU-016|educacao|2026-07-22T09:00:00.000|concluida|320|120|10|300.0|320.0|5.0|VI|manha|AMC nas Escolas|palestra',
  'EDU-017|educacao|2026-07-31T18:00:00.000|planejada|0|0|0|200.0|null|null|III|noite|Desacelere|comando educativo',
  'EDU-018|educacao|2026-08-08T10:00:00.000|concluida|150|40|6|null|150.0|null|V|manha|Transito e Meio Ambiente|palestra',
  'RPAS-001|rpas|2026-02-12T09:00:00.000|concluida|35|2|4|30.0|35.0|4.8|CENTRO|manha|Workshop RPAS|capacitacao',
  'RPAS-002|rpas|2026-04-15T15:00:00.000|planejada|0|0|0|20.0|null|null|VI|tarde|Mapeamento Aereo|missao',
  'RPAS-003|rpas|2026-06-21T07:00:00.000|concluida|20|1|3|20.0|20.0|4.5|V|manha|Inspecao Aerea|missao',
  'RPAS-004|rpas|2026-07-18T16:00:00.000|cancelada|0|0|0|null|null|null|II|tarde|Cobertura Institucional|missao',
  'FIS-001|fiscalizacao|2026-03-14T22:00:00.000|concluida|60|110|8|100.0|110.0|4.0|IV|noite|Operacao Integrada|fiscalizacao',
  'FIS-002|fiscalizacao|2026-07-25T21:00:00.000|concluida|130|135|8|120.0|135.0|4.3|VI|noite|Operacao Integrada|fiscalizacao',
];
