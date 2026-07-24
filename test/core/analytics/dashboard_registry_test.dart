import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_registry.dart';

void main() {
  group('DashboardRegistry', () {
    late DashboardRegistry registry;

    setUp(() {
      registry = DashboardRegistry();
    });

    group('estado inicial', () {
      test('inicia vazio', () {
        expect(registry.isEmpty, isTrue);
        expect(registry.isNotEmpty, isFalse);
        expect(registry.count, 0);
      });

      test('retorna lista vazia em all()', () {
        expect(registry.all(), isEmpty);
      });

      test('retorna lista vazia em enabled()', () {
        expect(registry.enabled(), isEmpty);
      });

      test('representa estado vazio em toString()', () {
        expect(
          registry.toString(),
          'DashboardRegistry(count: 0)',
        );
      });
    });

    group('register()', () {
      test('registra uma definição', () {
        final definition = _createDefinition();

        registry.register(definition);

        expect(registry.count, 1);
        expect(registry.contains(definition.id), isTrue);
        expect(registry.find(definition.id), same(definition));
      });

      test('altera o estado para não vazio', () {
        registry.register(_createDefinition());

        expect(registry.isEmpty, isFalse);
        expect(registry.isNotEmpty, isTrue);
      });

      test('preserva a instância registrada', () {
        final definition = _createDefinition();

        registry.register(definition);

        expect(
          registry.all().single,
          same(definition),
        );
      });

      test('aceita definições com ids diferentes', () {
        registry.register(
          _createDefinition(
            id: 'executive',
          ),
        );

        registry.register(
          _createDefinition(
            id: 'operational',
          ),
        );

        expect(registry.count, 2);
      });

      test('lança StateError ao registrar id duplicado', () {
        final first = _createDefinition(
          id: 'executive',
        );

        final duplicate = _createDefinition(
          id: 'executive',
          title: 'Outro dashboard',
        );

        registry.register(first);

        expect(
          () => registry.register(duplicate),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              'Já existe um dashboard registrado '
                  'com id "executive".',
            ),
          ),
        );
      });

      test('mantém a definição original após duplicidade', () {
        final original = _createDefinition(
          id: 'executive',
        );

        final duplicate = _createDefinition(
          id: 'executive',
          title: 'Duplicado',
        );

        registry.register(original);

        expect(
          () => registry.register(duplicate),
          throwsStateError,
        );

        expect(registry.count, 1);
        expect(
          registry.find('executive'),
          same(original),
        );
      });

      test('diferencia ids por letras maiúsculas e minúsculas', () {
        registry.register(
          _createDefinition(
            id: 'executive',
          ),
        );

        registry.register(
          _createDefinition(
            id: 'EXECUTIVE',
          ),
        );

        expect(registry.count, 2);
        expect(registry.contains('executive'), isTrue);
        expect(registry.contains('EXECUTIVE'), isTrue);
      });

      test('preserva a ordem de registro', () {
        final first = _createDefinition(
          id: 'first',
        );

        final second = _createDefinition(
          id: 'second',
        );

        final third = _createDefinition(
          id: 'third',
        );

        registry.register(first);
        registry.register(second);
        registry.register(third);

        expect(
          registry.all(),
          orderedEquals([
            first,
            second,
            third,
          ]),
        );
      });
    });

    group('registerAll()', () {
      test('registra múltiplas definições', () {
        final definitions = [
          _createDefinition(
            id: 'executive',
          ),
          _createDefinition(
            id: 'management',
          ),
          _createDefinition(
            id: 'operational',
          ),
        ];

        registry.registerAll(definitions);

        expect(registry.count, 3);
        expect(
          registry.all(),
          orderedEquals(definitions),
        );
      });

      test('aceita uma coleção vazia', () {
        registry.registerAll(const []);

        expect(registry.isEmpty, isTrue);
        expect(registry.count, 0);
      });

      test('lança StateError quando existe duplicidade no lote', () {
        final definitions = [
          _createDefinition(
            id: 'executive',
          ),
          _createDefinition(
            id: 'executive',
            title: 'Duplicado',
          ),
        ];

        expect(
          () => registry.registerAll(definitions),
          throwsStateError,
        );
      });

      test(
        'mantém registros anteriores ao item duplicado do lote',
        () {
          final first = _createDefinition(
            id: 'first',
          );

          final second = _createDefinition(
            id: 'second',
          );

          final duplicate = _createDefinition(
            id: 'first',
          );

          expect(
            () => registry.registerAll([
              first,
              second,
              duplicate,
            ]),
            throwsStateError,
          );

          expect(registry.count, 2);
          expect(registry.find('first'), same(first));
          expect(registry.find('second'), same(second));
        },
      );

      test(
        'interrompe o registro após encontrar duplicidade',
        () {
          final first = _createDefinition(
            id: 'first',
          );

          final duplicate = _createDefinition(
            id: 'first',
          );

          final notRegistered = _createDefinition(
            id: 'third',
          );

          expect(
            () => registry.registerAll([
              first,
              duplicate,
              notRegistered,
            ]),
            throwsStateError,
          );

          expect(registry.contains('first'), isTrue);
          expect(registry.contains('third'), isFalse);
        },
      );
    });

    group('contains()', () {
      test('retorna false quando o id não existe', () {
        expect(
          registry.contains('inexistente'),
          isFalse,
        );
      });

      test('retorna true quando o id existe', () {
        registry.register(
          _createDefinition(
            id: 'executive',
          ),
        );

        expect(
          registry.contains('executive'),
          isTrue,
        );
      });

      test('remove espaços externos do id consultado', () {
        registry.register(
          _createDefinition(
            id: 'executive',
          ),
        );

        expect(
          registry.contains('  executive  '),
          isTrue,
        );
      });

      test('retorna false para id vazio', () {
        expect(registry.contains(''), isFalse);
      });

      test('retorna false para id contendo apenas espaços', () {
        expect(registry.contains('   '), isFalse);
      });

      test('mantém comparação sensível a maiúsculas', () {
        registry.register(
          _createDefinition(
            id: 'executive',
          ),
        );

        expect(
          registry.contains('EXECUTIVE'),
          isFalse,
        );
      });
    });

    group('find()', () {
      test('retorna null quando o id não existe', () {
        expect(
          registry.find('inexistente'),
          isNull,
        );
      });

      test('retorna a definição registrada', () {
        final definition = _createDefinition(
          id: 'executive',
        );

        registry.register(definition);

        expect(
          registry.find('executive'),
          same(definition),
        );
      });

      test('remove espaços externos do id consultado', () {
        final definition = _createDefinition(
          id: 'executive',
        );

        registry.register(definition);

        expect(
          registry.find('  executive  '),
          same(definition),
        );
      });

      test('retorna null para id vazio', () {
        expect(registry.find(''), isNull);
      });

      test('retorna também definição desabilitada', () {
        final definition = _createDefinition(
          enabled: false,
        );

        registry.register(definition);

        expect(
          registry.find(definition.id),
          same(definition),
        );
      });
    });

    group('remove()', () {
      test('remove uma definição existente', () {
        final definition = _createDefinition();

        registry.register(definition);

        final result = registry.remove(
          definition.id,
        );

        expect(result, isTrue);
        expect(registry.contains(definition.id), isFalse);
        expect(registry.count, 0);
      });

      test('retorna false quando o id não existe', () {
        expect(
          registry.remove('inexistente'),
          isFalse,
        );
      });

      test('remove espaços externos do id informado', () {
        registry.register(
          _createDefinition(
            id: 'executive',
          ),
        );

        final result = registry.remove(
          '  executive  ',
        );

        expect(result, isTrue);
        expect(registry.isEmpty, isTrue);
      });

      test('remove apenas a definição solicitada', () {
        final first = _createDefinition(
          id: 'first',
        );

        final second = _createDefinition(
          id: 'second',
        );

        registry.registerAll([
          first,
          second,
        ]);

        registry.remove(first.id);

        expect(registry.count, 1);
        expect(registry.find(first.id), isNull);
        expect(registry.find(second.id), same(second));
      });

      test('retorna false ao remover novamente o mesmo id', () {
        registry.register(
          _createDefinition(
            id: 'executive',
          ),
        );

        expect(
          registry.remove('executive'),
          isTrue,
        );

        expect(
          registry.remove('executive'),
          isFalse,
        );
      });
    });

    group('clear()', () {
      test('remove todas as definições', () {
        registry.registerAll([
          _createDefinition(
            id: 'executive',
          ),
          _createDefinition(
            id: 'management',
          ),
          _createDefinition(
            id: 'operational',
          ),
        ]);

        registry.clear();

        expect(registry.count, 0);
        expect(registry.isEmpty, isTrue);
        expect(registry.all(), isEmpty);
      });

      test('pode ser chamado quando o registro já está vazio', () {
        registry.clear();

        expect(registry.isEmpty, isTrue);
        expect(registry.count, 0);
      });

      test('permite novos registros após a limpeza', () {
        registry.register(
          _createDefinition(
            id: 'first',
          ),
        );

        registry.clear();

        final second = _createDefinition(
          id: 'second',
        );

        registry.register(second);

        expect(registry.count, 1);
        expect(registry.find('second'), same(second));
      });
    });

    group('all()', () {
      test('retorna todas as definições registradas', () {
        final enabled = _createDefinition(
          id: 'enabled',
          enabled: true,
        );

        final disabled = _createDefinition(
          id: 'disabled',
          enabled: false,
        );

        registry.registerAll([
          enabled,
          disabled,
        ]);

        expect(
          registry.all(),
          orderedEquals([
            enabled,
            disabled,
          ]),
        );
      });

      test('retorna lista não modificável', () {
        registry.register(
          _createDefinition(),
        );

        final result = registry.all();

        expect(
          () => result.add(
            _createDefinition(
              id: 'new-dashboard',
            ),
          ),
          throwsUnsupportedError,
        );
      });

      test('retorna uma nova lista a cada chamada', () {
        registry.register(
          _createDefinition(),
        );

        final first = registry.all();
        final second = registry.all();

        expect(first, isNot(same(second)));
        expect(first, orderedEquals(second));
      });
    });

    group('enabled()', () {
      test('retorna somente dashboards habilitados', () {
        final enabled = _createDefinition(
          id: 'enabled',
          enabled: true,
        );

        final disabled = _createDefinition(
          id: 'disabled',
          enabled: false,
        );

        registry.registerAll([
          enabled,
          disabled,
        ]);

        final result = registry.enabled();

        expect(result, hasLength(1));
        expect(result.single, same(enabled));
      });

      test('retorna lista vazia quando todos estão desabilitados', () {
        registry.registerAll([
          _createDefinition(
            id: 'first',
            enabled: false,
          ),
          _createDefinition(
            id: 'second',
            enabled: false,
          ),
        ]);

        expect(registry.enabled(), isEmpty);
      });

      test('preserva a ordem dos dashboards habilitados', () {
        final first = _createDefinition(
          id: 'first',
          enabled: true,
        );

        final disabled = _createDefinition(
          id: 'disabled',
          enabled: false,
        );

        final second = _createDefinition(
          id: 'second',
          enabled: true,
        );

        registry.registerAll([
          first,
          disabled,
          second,
        ]);

        expect(
          registry.enabled(),
          orderedEquals([
            first,
            second,
          ]),
        );
      });

      test('retorna lista não modificável', () {
        registry.register(
          _createDefinition(),
        );

        final result = registry.enabled();

        expect(
          () => result.clear(),
          throwsUnsupportedError,
        );
      });
    });

    group('byDomain()', () {
      test('retorna dashboards do domínio informado', () {
        final institutional = _createDefinition(
          id: 'institutional',
          domain: 'institucional',
        );

        final education = _createDefinition(
          id: 'education',
          domain: 'educacao',
        );

        registry.registerAll([
          institutional,
          education,
        ]);

        expect(
          registry.byDomain('educacao'),
          orderedEquals([
            education,
          ]),
        );
      });

      test('realiza comparação sem diferenciar maiúsculas', () {
        final definition = _createDefinition(
          domain: 'Educacao',
        );

        registry.register(definition);

        expect(
          registry.byDomain('EDUCACAO'),
          orderedEquals([
            definition,
          ]),
        );
      });

      test('remove espaços externos do domínio consultado', () {
        final definition = _createDefinition(
          domain: 'educacao',
        );

        registry.register(definition);

        expect(
          registry.byDomain('  educacao  '),
          orderedEquals([
            definition,
          ]),
        );
      });

      test('retorna lista vazia para domínio inexistente', () {
        registry.register(
          _createDefinition(
            domain: 'institucional',
          ),
        );

        expect(
          registry.byDomain('inexistente'),
          isEmpty,
        );
      });

      test('retorna também dashboards desabilitados', () {
        final definition = _createDefinition(
          domain: 'educacao',
          enabled: false,
        );

        registry.register(definition);

        expect(
          registry.byDomain('educacao'),
          orderedEquals([
            definition,
          ]),
        );
      });

      test('preserva a ordem de registro', () {
        final first = _createDefinition(
          id: 'first',
          domain: 'educacao',
        );

        final second = _createDefinition(
          id: 'second',
          domain: 'institucional',
        );

        final third = _createDefinition(
          id: 'third',
          domain: 'educacao',
        );

        registry.registerAll([
          first,
          second,
          third,
        ]);

        expect(
          registry.byDomain('educacao'),
          orderedEquals([
            first,
            third,
          ]),
        );
      });

      test('retorna lista não modificável', () {
        registry.register(
          _createDefinition(
            domain: 'educacao',
          ),
        );

        final result = registry.byDomain(
          'educacao',
        );

        expect(
          () => result.clear(),
          throwsUnsupportedError,
        );
      });
    });

    group('byAudience()', () {
      test('retorna dashboards do público informado', () {
        final executive = _createDefinition(
          id: 'executive',
          audience: DashboardAudience.executive,
        );

        final operational = _createDefinition(
          id: 'operational',
          audience: DashboardAudience.operational,
        );

        registry.registerAll([
          executive,
          operational,
        ]);

        expect(
          registry.byAudience(
            DashboardAudience.executive,
          ),
          orderedEquals([
            executive,
          ]),
        );
      });

      test('retorna lista vazia quando não há correspondência', () {
        registry.register(
          _createDefinition(
            audience: DashboardAudience.executive,
          ),
        );

        expect(
          registry.byAudience(
            DashboardAudience.technical,
          ),
          isEmpty,
        );
      });

      test('retorna também dashboards desabilitados', () {
        final definition = _createDefinition(
          audience: DashboardAudience.management,
          enabled: false,
        );

        registry.register(definition);

        expect(
          registry.byAudience(
            DashboardAudience.management,
          ),
          orderedEquals([
            definition,
          ]),
        );
      });

      test('preserva a ordem de registro', () {
        final first = _createDefinition(
          id: 'first',
          audience: DashboardAudience.operational,
        );

        final second = _createDefinition(
          id: 'second',
          audience: DashboardAudience.executive,
        );

        final third = _createDefinition(
          id: 'third',
          audience: DashboardAudience.operational,
        );

        registry.registerAll([
          first,
          second,
          third,
        ]);

        expect(
          registry.byAudience(
            DashboardAudience.operational,
          ),
          orderedEquals([
            first,
            third,
          ]),
        );
      });

      test('retorna lista não modificável', () {
        registry.register(
          _createDefinition(
            audience: DashboardAudience.executive,
          ),
        );

        final result = registry.byAudience(
          DashboardAudience.executive,
        );

        expect(
          () => result.clear(),
          throwsUnsupportedError,
        );
      });
    });

    group('byCategory()', () {
      test('retorna dashboards da categoria informada', () {
        final strategic = _createDefinition(
          id: 'strategic',
          category: DashboardCategory.strategic,
        );

        final operational = _createDefinition(
          id: 'operational',
          category: DashboardCategory.operational,
        );

        registry.registerAll([
          strategic,
          operational,
        ]);

        expect(
          registry.byCategory(
            DashboardCategory.strategic,
          ),
          orderedEquals([
            strategic,
          ]),
        );
      });

      test('retorna lista vazia quando não há correspondência', () {
        registry.register(
          _createDefinition(
            category: DashboardCategory.strategic,
          ),
        );

        expect(
          registry.byCategory(
            DashboardCategory.quality,
          ),
          isEmpty,
        );
      });

      test('retorna também dashboards desabilitados', () {
        final definition = _createDefinition(
          category: DashboardCategory.analytical,
          enabled: false,
        );

        registry.register(definition);

        expect(
          registry.byCategory(
            DashboardCategory.analytical,
          ),
          orderedEquals([
            definition,
          ]),
        );
      });

      test('preserva a ordem de registro', () {
        final first = _createDefinition(
          id: 'first',
          category: DashboardCategory.operational,
        );

        final second = _createDefinition(
          id: 'second',
          category: DashboardCategory.strategic,
        );

        final third = _createDefinition(
          id: 'third',
          category: DashboardCategory.operational,
        );

        registry.registerAll([
          first,
          second,
          third,
        ]);

        expect(
          registry.byCategory(
            DashboardCategory.operational,
          ),
          orderedEquals([
            first,
            third,
          ]),
        );
      });

      test('retorna lista não modificável', () {
        registry.register(
          _createDefinition(
            category: DashboardCategory.strategic,
          ),
        );

        final result = registry.byCategory(
          DashboardCategory.strategic,
        );

        expect(
          () => result.clear(),
          throwsUnsupportedError,
        );
      });
    });

    group('propriedades de estado', () {
      test('count acompanha registros e remoções', () {
        registry.registerAll([
          _createDefinition(
            id: 'first',
          ),
          _createDefinition(
            id: 'second',
          ),
        ]);

        expect(registry.count, 2);

        registry.remove('first');

        expect(registry.count, 1);

        registry.clear();

        expect(registry.count, 0);
      });

      test('isEmpty acompanha as alterações do registro', () {
        expect(registry.isEmpty, isTrue);

        registry.register(
          _createDefinition(),
        );

        expect(registry.isEmpty, isFalse);

        registry.clear();

        expect(registry.isEmpty, isTrue);
      });

      test('isNotEmpty acompanha as alterações do registro', () {
        expect(registry.isNotEmpty, isFalse);

        registry.register(
          _createDefinition(),
        );

        expect(registry.isNotEmpty, isTrue);

        registry.remove('executive');

        expect(registry.isNotEmpty, isFalse);
      });
    });

    group('toString()', () {
      test('informa a quantidade de dashboards registrados', () {
        registry.registerAll([
          _createDefinition(
            id: 'executive',
          ),
          _createDefinition(
            id: 'operational',
          ),
        ]);

        expect(
          registry.toString(),
          'DashboardRegistry(count: 2)',
        );
      });

      test('contabiliza dashboards desabilitados', () {
        registry.registerAll([
          _createDefinition(
            id: 'enabled',
            enabled: true,
          ),
          _createDefinition(
            id: 'disabled',
            enabled: false,
          ),
        ]);

        expect(
          registry.toString(),
          'DashboardRegistry(count: 2)',
        );
      });

      test('atualiza a representação após remoção', () {
        registry.registerAll([
          _createDefinition(
            id: 'first',
          ),
          _createDefinition(
            id: 'second',
          ),
        ]);

        registry.remove('first');

        expect(
          registry.toString(),
          'DashboardRegistry(count: 1)',
        );
      });
    });
  });
}

DashboardDefinition _createDefinition({
  String id = 'executive',
  String title = 'Dashboard Executivo',
  String? description = 'Visão estratégica institucional.',
  String domain = 'institucional',
  DashboardAudience audience =
      DashboardAudience.executive,
  DashboardCategory category =
      DashboardCategory.strategic,
  String version = '1.0.0',
  bool enabled = true,
}) {
  return DashboardDefinition(
    id: id,
    title: title,
    description: description,
    domain: domain,
    audience: audience,
    category: category,
    version: version,
    enabled: enabled,
  );
}