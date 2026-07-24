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
    Map<String, Object?> dimensions = const {},
  }) {
    return AnalyticsRecord(
      id: id,
      domain: domain,
      occurredAt: occurredAt,
      status: status,
      dimensions: dimensions,
    );
  }

  int processed(
    Iterable<AnalyticsRecord> records,
    AnalyticsFilters filters,
  ) {
    return engine.process(records: records, filters: filters).processedRecords;
  }

  group('AnalyticsEngine — filtro por domínio', () {
    test('mantém todos os registros quando domain é nulo', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), domain: 'educacao'),
        record(id: '2', occurredAt: DateTime(2026, 1, 2), domain: 'rpas'),
      ];
      expect(processed(records, AnalyticsFilters()), 2);
    });

    test('seleciona somente o domínio solicitado', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), domain: 'educacao'),
        record(id: '2', occurredAt: DateTime(2026, 1, 2), domain: 'rpas'),
      ];
      expect(processed(records, AnalyticsFilters(domain: 'educacao')), 1);
    });

    test('normaliza espaços e caixa do valor informado no filtro', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), domain: 'educacao'),
      ];
      expect(processed(records, AnalyticsFilters(domain: '  EDUCACAO  ')), 1);
    });

    test('normaliza espaços e caixa do domínio armazenado no registro', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), domain: '  EDUCACAO  '),
      ];
      expect(processed(records, AnalyticsFilters(domain: 'educacao')), 1);
    });

    test('ignora todos quando nenhum domínio corresponde', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), domain: 'engenharia'),
      ];
      expect(processed(records, AnalyticsFilters(domain: 'rpas')), 0);
    });
  });

  group('AnalyticsEngine — filtro por status', () {
    test('mantém todos os registros quando status é nulo', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), status: 'concluida'),
        record(id: '2', occurredAt: DateTime(2026, 1, 2), status: 'planejada'),
      ];
      expect(processed(records, AnalyticsFilters()), 2);
    });

    test('seleciona somente o status solicitado', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), status: 'concluida'),
        record(id: '2', occurredAt: DateTime(2026, 1, 2), status: 'planejada'),
      ];
      expect(processed(records, AnalyticsFilters(status: 'concluida')), 1);
    });

    test('normaliza espaços e caixa do status informado no filtro', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), status: 'concluida'),
      ];
      expect(processed(records, AnalyticsFilters(status: ' CONCLUIDA ')), 1);
    });

    test('normaliza espaços e caixa do status armazenado no registro', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1), status: ' CONCLUIDA '),
      ];
      expect(processed(records, AnalyticsFilters(status: 'concluida')), 1);
    });
  });

  group('AnalyticsEngine — período inclusivo', () {
    test('mantém todos os registros sem datas definidas', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 1)),
        record(id: '2', occurredAt: DateTime(2026, 12, 31)),
      ];
      expect(processed(records, AnalyticsFilters()), 2);
    });

    test('exclui registro anterior à data inicial', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 9, 23, 59)),
        record(id: '2', occurredAt: DateTime(2026, 1, 10)),
      ];
      expect(
        processed(records, AnalyticsFilters(startDate: DateTime(2026, 1, 10))),
        1,
      );
    });

    test('inclui registro exatamente na data inicial', () {
      final instant = DateTime(2026, 1, 10, 8, 30);
      expect(
        processed(
          [record(id: '1', occurredAt: instant)],
          AnalyticsFilters(startDate: instant),
        ),
        1,
      );
    });

    test('exclui registro posterior à data final', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 10)),
        record(id: '2', occurredAt: DateTime(2026, 1, 10, 0, 0, 1)),
      ];
      expect(
        processed(records, AnalyticsFilters(endDate: DateTime(2026, 1, 10))),
        1,
      );
    });

    test('inclui registro exatamente na data final', () {
      final instant = DateTime(2026, 1, 10, 18);
      expect(
        processed(
          [record(id: '1', occurredAt: instant)],
          AnalyticsFilters(endDate: instant),
        ),
        1,
      );
    });

    test('aplica simultaneamente início e fim', () {
      final records = [
        record(id: '1', occurredAt: DateTime(2026, 1, 9)),
        record(id: '2', occurredAt: DateTime(2026, 1, 10)),
        record(id: '3', occurredAt: DateTime(2026, 1, 15)),
        record(id: '4', occurredAt: DateTime(2026, 1, 16)),
      ];
      expect(
        processed(
          records,
          AnalyticsFilters(
            startDate: DateTime(2026, 1, 10),
            endDate: DateTime(2026, 1, 15),
          ),
        ),
        2,
      );
    });
  });

  group('AnalyticsEngine — dimensões String', () {
    test('compara String removendo espaços nas extremidades', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'regional': ' Regional 6 '},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'regional': 'Regional 6'}),
        ),
        1,
      );
    });

    test('comparação de String preserva diferença entre maiúsculas e minúsculas', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'turno': 'Manhã'},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'turno': 'manhã'}),
        ),
        0,
      );
    });

    test('normaliza a chave da dimensão', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {' Regional ': 'VI'},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {' REGIONAL ': 'VI'}),
        ),
        1,
      );
    });

    test('dimensão ausente não corresponde', () {
      final source = [record(id: '1', occurredAt: DateTime(2026, 1, 1))];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'regional': 'VI'}),
        ),
        0,
      );
    });

    test('dimensão nula não corresponde', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'regional': null},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'regional': 'VI'}),
        ),
        0,
      );
    });
  });

  group('AnalyticsEngine — dimensões booleanas', () {
    for (final value in const ['true', '1', 'sim', 'yes']) {
      test('bool true corresponde ao filtro "$value"', () {
        final source = [
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            dimensions: const {'planejada': true},
          ),
        ];
        expect(
          processed(
            source,
            AnalyticsFilters(dimensions: {'planejada': value}),
          ),
          1,
        );
      });
    }

    for (final value in const ['false', '0', 'não', 'nao', 'no']) {
      test('bool false corresponde ao filtro "$value"', () {
        final source = [
          record(
            id: '1',
            occurredAt: DateTime(2026, 1, 1),
            dimensions: const {'planejada': false},
          ),
        ];
        expect(
          processed(
            source,
            AnalyticsFilters(dimensions: {'planejada': value}),
          ),
          1,
        );
      });
    }

    test('representação booleana inválida não corresponde', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'planejada': true},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'planejada': 'talvez'}),
        ),
        0,
      );
    });
  });

  group('AnalyticsEngine — dimensões numéricas', () {
    test('int corresponde ao mesmo valor textual', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'ano': 2026},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'ano': '2026'}),
        ),
        1,
      );
    });

    test('int corresponde a representação decimal equivalente', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'meta': 10},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'meta': '10.0'}),
        ),
        1,
      );
    });

    test('double corresponde a valor com ponto decimal', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'indice': 4.5},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'indice': '4.5'}),
        ),
        1,
      );
    });

    test('double corresponde a valor com vírgula decimal', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'indice': 4.5},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'indice': '4,5'}),
        ),
        1,
      );
    });

    test('valor numérico diferente não corresponde', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'ano': 2026},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'ano': '2025'}),
        ),
        0,
      );
    });

    test('texto não numérico não corresponde a dimensão numérica', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'ano': 2026},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(
            dimensions: const {'ano': 'dois mil e vinte e seis'},
          ),
        ),
        0,
      );
    });
  });

  group('AnalyticsEngine — dimensões DateTime', () {
    test('DateTime corresponde à representação ISO-8601', () {
      final instant = DateTime.utc(2026, 7, 22, 13, 45);
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: {'data_referencia': instant},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(
            dimensions: {'data_referencia': instant.toIso8601String()},
          ),
        ),
        1,
      );
    });

    test('DateTime compara o mesmo instante com fusos equivalentes', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: {
            'data_referencia': DateTime.parse('2026-07-22T12:00:00Z'),
          },
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(
            dimensions: const {
              'data_referencia': '2026-07-22T09:00:00-03:00',
            },
          ),
        ),
        1,
      );
    });

    test('texto inválido não corresponde a DateTime', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: {'data_referencia': DateTime(2026, 7, 22)},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(
            dimensions: const {'data_referencia': 'data inválida'},
          ),
        ),
        0,
      );
    });
  });

  group('AnalyticsEngine — demais tipos de dimensão', () {
    test('utiliza toString para objeto não tratado especificamente', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'codigo': TestDimensionValue('ABC-123')},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'codigo': 'ABC-123'}),
        ),
        1,
      );
    });

    test('remove espaços do toString do objeto antes de comparar', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'codigo': TestDimensionValue('  ABC-123  ')},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(dimensions: const {'codigo': 'ABC-123'}),
        ),
        1,
      );
    });
  });

  group('AnalyticsEngine — composição de filtros', () {
    test('todas as dimensões devem corresponder simultaneamente', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 1, 1),
          dimensions: const {'regional': 'VI', 'turno': 'Manhã'},
        ),
        record(
          id: '2',
          occurredAt: DateTime(2026, 1, 2),
          dimensions: const {'regional': 'VI', 'turno': 'Tarde'},
        ),
      ];
      expect(
        processed(
          source,
          AnalyticsFilters(
            dimensions: const {'regional': 'VI', 'turno': 'Manhã'},
          ),
        ),
        1,
      );
    });

    test('domínio, status, período e dimensão são aplicados em conjunto', () {
      final source = [
        record(
          id: '1',
          occurredAt: DateTime(2026, 7, 10),
          domain: 'educacao',
          status: 'concluida',
          dimensions: const {'regional': 'VI'},
        ),
        record(
          id: '2',
          occurredAt: DateTime(2026, 7, 10),
          domain: 'educacao',
          status: 'planejada',
          dimensions: const {'regional': 'VI'},
        ),
        record(
          id: '3',
          occurredAt: DateTime(2026, 7, 10),
          domain: 'rpas',
          status: 'concluida',
          dimensions: const {'regional': 'VI'},
        ),
        record(
          id: '4',
          occurredAt: DateTime(2026, 8, 1),
          domain: 'educacao',
          status: 'concluida',
          dimensions: const {'regional': 'VI'},
        ),
        record(
          id: '5',
          occurredAt: DateTime(2026, 7, 10),
          domain: 'educacao',
          status: 'concluida',
          dimensions: const {'regional': 'V'},
        ),
      ];
      final result = engine.process(
        records: source,
        filters: AnalyticsFilters(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 31, 23, 59, 59),
          domain: 'educacao',
          status: 'concluida',
          dimensions: const {'regional': 'VI'},
        ),
      );
      expect(result.processedRecords, 1);
      expect(result.ignoredRecords, 4);
      expect(result.metrics.totalRecords, 1);
    });
  });
}

final class TestDimensionValue {
  const TestDimensionValue(this.value);

  final String value;

  @override
  String toString() => value;
}
