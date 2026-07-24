import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';

void main() {
  group('DashboardDefinition - copyWith', () {
    test('sem argumentos cria definição equivalente', () {
      final definition = _createDefinition(
        description: 'Descrição',
        requiredIndicators: const ['publico'],
        allowedProfiles: const ['gestor'],
        metadata: const {'owner': 'AMC'},
      );

      final copy = definition.copyWith();

      expect(copy, equals(definition));
      expect(copy, isNot(same(definition)));
      expect(copy.title, definition.title);
      expect(copy.description, definition.description);
      expect(copy.domain, definition.domain);
      expect(copy.audience, definition.audience);
      expect(copy.category, definition.category);
      expect(copy.enabled, definition.enabled);
      expect(copy.requiredIndicators, definition.requiredIndicators);
      expect(copy.allowedProfiles, definition.allowedProfiles);
      expect(copy.metadata, definition.metadata);
    });

    test('altera id', () {
      final result = _createDefinition().copyWith(id: 'operational');

      expect(result.id, 'operational');
    });

    test('altera título', () {
      final result = _createDefinition().copyWith(
        title: 'Dashboard Operacional',
      );

      expect(result.title, 'Dashboard Operacional');
    });

    test('altera descrição', () {
      final result = _createDefinition().copyWith(
        description: 'Nova descrição',
      );

      expect(result.description, 'Nova descrição');
    });

    test('não permite limpar descrição com null', () {
      final definition = _createDefinition(
        description: 'Descrição original',
      );

      final result = definition.copyWith(description: null);

      expect(result.description, 'Descrição original');
    });

    test('altera domínio', () {
      final result = _createDefinition().copyWith(
        domain: 'educacao',
      );

      expect(result.domain, 'educacao');
    });

    test('altera público', () {
      final result = _createDefinition().copyWith(
        audience: DashboardAudience.operational,
      );

      expect(result.audience, DashboardAudience.operational);
    });

    test('altera categoria', () {
      final result = _createDefinition().copyWith(
        category: DashboardCategory.productivity,
      );

      expect(result.category, DashboardCategory.productivity);
    });

    test('altera versão', () {
      final result = _createDefinition().copyWith(
        version: '2.0.0',
      );

      expect(result.version, '2.0.0');
    });

    test('altera enabled', () {
      final result = _createDefinition().copyWith(enabled: false);

      expect(result.enabled, isFalse);
    });

    test('substitui indicadores obrigatórios', () {
      final result = _createDefinition(
        requiredIndicators: const ['publico'],
      ).copyWith(
        requiredIndicators: const ['acoes', 'veiculos'],
      );

      expect(result.requiredIndicators, ['acoes', 'veiculos']);
    });

    test('substitui perfis autorizados', () {
      final result = _createDefinition(
        allowedProfiles: const ['gestor'],
      ).copyWith(
        allowedProfiles: const ['agente', 'coordenador'],
      );

      expect(result.allowedProfiles, ['agente', 'coordenador']);
    });

    test('substitui metadados', () {
      final result = _createDefinition(
        metadata: const {'owner': 'AMC'},
      ).copyWith(
        metadata: const {'source': 'Atlas'},
      );

      expect(result.metadata, {'source': 'Atlas'});
    });

    test('aplica normalização aos novos indicadores', () {
      final result = _createDefinition().copyWith(
        requiredIndicators: const [
          '  publico  ',
          '',
          'publico',
          'acoes',
        ],
      );

      expect(result.requiredIndicators, ['publico', 'acoes']);
    });

    test('valida campos alterados', () {
      expect(
        () => _createDefinition().copyWith(version: 'invalida'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DashboardDefinition - withMetadata', () {
    test('adiciona novo metadado', () {
      final definition = _createDefinition();

      final result = definition.withMetadata('owner', 'AMC');

      expect(result.metadata, {'owner': 'AMC'});
      expect(definition.metadata, isEmpty);
    });

    test('substitui metadado existente', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      final result = definition.withMetadata('owner', 'GEDUC');

      expect(result.metadata['owner'], 'GEDUC');
      expect(definition.metadata['owner'], 'AMC');
    });

    test('normaliza espaços externos da chave', () {
      final result = _createDefinition().withMetadata(
        '  owner  ',
        'AMC',
      );

      expect(result.containsMetadata('owner'), isTrue);
      expect(result.metadata['owner'], 'AMC');
    });

    test('aceita valor null', () {
      final result = _createDefinition().withMetadata(
        'nullable',
        null,
      );

      expect(result.containsMetadata('nullable'), isTrue);
      expect(result.metadataValue('nullable'), isNull);
    });

    test('preserva metadados existentes', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      final result = definition.withMetadata('source', 'Atlas');

      expect(
        result.metadata,
        {'owner': 'AMC', 'source': 'Atlas'},
      );
    });

    test('rejeita chave vazia', () {
      expect(
        () => _createDefinition().withMetadata('', 'valor'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'key',
          ),
        ),
      );
    });

    test('rejeita chave somente com espaços', () {
      expect(
        () => _createDefinition().withMetadata('   ', 'valor'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DashboardDefinition - withoutMetadata', () {
    test('remove metadado existente', () {
      final definition = _createDefinition(
        metadata: const {
          'owner': 'AMC',
          'source': 'Atlas',
        },
      );

      final result = definition.withoutMetadata('owner');

      expect(result.metadata, {'source': 'Atlas'});
      expect(definition.metadata.length, 2);
    });

    test('normaliza espaços externos da chave', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      final result = definition.withoutMetadata('  owner  ');

      expect(result.metadata, isEmpty);
    });

    test('retorna a mesma instância para chave inexistente', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      final result = definition.withoutMetadata('source');

      expect(result, same(definition));
    });

    test('retorna a mesma instância para chave vazia', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      final result = definition.withoutMetadata('');

      expect(result, same(definition));
    });

    test('retorna a mesma instância para chave somente com espaços', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      final result = definition.withoutMetadata('   ');

      expect(result, same(definition));
    });
  });

  group('DashboardDefinition - withRequiredIndicator', () {
    test('adiciona indicador ao final', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      final result = definition.withRequiredIndicator('acoes');

      expect(result.requiredIndicators, ['publico', 'acoes']);
      expect(definition.requiredIndicators, ['publico']);
    });

    test('normaliza espaços externos', () {
      final result = _createDefinition().withRequiredIndicator(
        '  publico  ',
      );

      expect(result.requiredIndicators, ['publico']);
    });

    test('retorna a mesma instância quando indicador já existe', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      final result = definition.withRequiredIndicator('publico');

      expect(result, same(definition));
    });

    test('duplicidade é sensível a maiúsculas', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      final result = definition.withRequiredIndicator('Publico');

      expect(result.requiredIndicators, ['publico', 'Publico']);
    });

    test('rejeita indicador vazio', () {
      expect(
        () => _createDefinition().withRequiredIndicator(''),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'indicatorId',
          ),
        ),
      );
    });

    test('rejeita indicador somente com espaços', () {
      expect(
        () => _createDefinition().withRequiredIndicator('   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DashboardDefinition - withoutRequiredIndicator', () {
    test('remove indicador existente', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico', 'acoes'],
      );

      final result = definition.withoutRequiredIndicator('publico');

      expect(result.requiredIndicators, ['acoes']);
      expect(definition.requiredIndicators, ['publico', 'acoes']);
    });

    test('normaliza espaços externos', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      final result = definition.withoutRequiredIndicator(
        '  publico  ',
      );

      expect(result.requiredIndicators, isEmpty);
    });

    test('retorna a mesma instância para indicador inexistente', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      final result = definition.withoutRequiredIndicator('acoes');

      expect(result, same(definition));
    });

    test('retorna a mesma instância para indicador vazio', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      final result = definition.withoutRequiredIndicator('');

      expect(result, same(definition));
    });

    test('retorna a mesma instância para espaços', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      final result = definition.withoutRequiredIndicator('   ');

      expect(result, same(definition));
    });

    test('remoção é sensível a maiúsculas', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      final result = definition.withoutRequiredIndicator('Publico');

      expect(result, same(definition));
      expect(result.requiredIndicators, ['publico']);
    });
  });

  group('DashboardDefinition - igualdade e hashCode', () {
    test('é igual à mesma instância', () {
      final definition = _createDefinition();

      expect(definition, equals(definition));
    });

    test('é igual quando id e versão são iguais', () {
      final first = _createDefinition(
        id: 'executive',
        version: '1.0.0',
        title: 'Primeiro',
      );
      final second = _createDefinition(
        id: 'executive',
        version: '1.0.0',
        title: 'Segundo',
        domain: 'outro',
        enabled: false,
      );

      expect(first, equals(second));
    });

    test('não é igual quando o id é diferente', () {
      final first = _createDefinition(id: 'executive');
      final second = _createDefinition(id: 'operational');

      expect(first, isNot(equals(second)));
    });

    test('não é igual quando a versão é diferente', () {
      final first = _createDefinition(version: '1.0.0');
      final second = _createDefinition(version: '2.0.0');

      expect(first, isNot(equals(second)));
    });

    test('não é igual a objeto de outro tipo', () {
      final definition = _createDefinition();

      expect(definition, isNot(equals('executive')));
    });

    test('objetos iguais possuem o mesmo hashCode', () {
      final first = _createDefinition(
        id: 'executive',
        version: '1.0.0',
      );
      final second = _createDefinition(
        id: 'executive',
        version: '1.0.0',
        title: 'Outro título',
      );

      expect(first.hashCode, second.hashCode);
    });

    test('funciona corretamente em Set', () {
      final definitions = <DashboardDefinition>{
        _createDefinition(id: 'executive', version: '1.0.0'),
        _createDefinition(
          id: 'executive',
          version: '1.0.0',
          title: 'Duplicado lógico',
        ),
        _createDefinition(id: 'executive', version: '2.0.0'),
      };

      expect(definitions.length, 2);
    });
  });

  group('DashboardDefinition - toString', () {
    test('retorna representação institucional completa', () {
      final definition = _createDefinition(
        id: 'operational',
        title: 'Dashboard Operacional',
        domain: 'fiscalizacao',
        audience: DashboardAudience.operational,
        category: DashboardCategory.productivity,
        version: '2.1.0',
        enabled: false,
      );

      expect(
        definition.toString(),
        'DashboardDefinition('
        'id: operational, '
        'title: Dashboard Operacional, '
        'domain: fiscalizacao, '
        'audience: operational, '
        'category: productivity, '
        'version: 2.1.0, '
        'enabled: false'
        ')',
      );
    });

    test('inclui o nome do público', () {
      final text = _createDefinition(
        audience: DashboardAudience.technical,
      ).toString();

      expect(text, contains('audience: technical'));
    });

    test('inclui o nome da categoria', () {
      final text = _createDefinition(
        category: DashboardCategory.analytical,
      ).toString();

      expect(text, contains('category: analytical'));
    });

    test('não inclui descrição, indicadores, perfis ou metadados', () {
      final text = _createDefinition(
        description: 'Descrição sigilosa',
        requiredIndicators: const ['publico'],
        allowedProfiles: const ['gestor'],
        metadata: const {'owner': 'AMC'},
      ).toString();

      expect(text, isNot(contains('Descrição sigilosa')));
      expect(text, isNot(contains('publico')));
      expect(text, isNot(contains('gestor')));
      expect(text, isNot(contains('owner')));
    });
  });
}

DashboardDefinition _createDefinition({
  String id = 'executive',
  String title = 'Dashboard Executivo',
  String? description,
  String domain = 'institucional',
  DashboardAudience audience = DashboardAudience.executive,
  DashboardCategory category = DashboardCategory.strategic,
  String version = '1.0.0',
  bool enabled = true,
  Iterable<String> requiredIndicators = const [],
  Iterable<String> allowedProfiles = const [],
  Map<String, Object?> metadata = const {},
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
    requiredIndicators: requiredIndicators,
    allowedProfiles: allowedProfiles,
    metadata: metadata,
  );
}
