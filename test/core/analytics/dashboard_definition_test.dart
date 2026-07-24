import 'package:flutter_test/flutter_test.dart';

import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';

void main() {
  group('DashboardDefinition - construção', () {
    test('deve criar uma definição válida com os campos obrigatórios', () {
      final definition = DashboardDefinition(
        id: 'geduc',
        title: 'Dashboard GEDUC',
        domain: 'educacao',
        audience: DashboardAudience.management,
        category: DashboardCategory.operational,
      );

      expect(definition.id, 'geduc');
      expect(definition.title, 'Dashboard GEDUC');
      expect(definition.domain, 'educacao');
      expect(
        definition.audience,
        DashboardAudience.management,
      );
      expect(
        definition.category,
        DashboardCategory.operational,
      );
      expect(definition.version, '1.0.0');
      expect(definition.enabled, isTrue);
      expect(definition.description, isNull);
      expect(definition.requiredIndicators, isEmpty);
      expect(definition.allowedProfiles, isEmpty);
      expect(definition.metadata, isEmpty);
    });

    test('deve criar uma definição completa', () {
      final definition = DashboardDefinition(
        id: 'executive',
        title: 'Dashboard Executivo',
        description: 'Indicadores estratégicos institucionais.',
        domain: 'institucional',
        audience: DashboardAudience.executive,
        category: DashboardCategory.strategic,
        version: '2.1.0',
        enabled: false,
        requiredIndicators: const [
          'publico_alcancado',
          'meta_atingida',
        ],
        allowedProfiles: const [
          'administrador',
          'gestor',
        ],
        metadata: const {
          'owner': 'Plataforma Fênix',
          'priority': 1,
        },
      );

      expect(definition.description, isNotNull);
      expect(definition.version, '2.1.0');
      expect(definition.enabled, isFalse);
      expect(definition.requiredIndicatorsCount, 2);
      expect(definition.allowedProfilesCount, 2);
      expect(definition.metadata['priority'], 1);
    });

    test('deve rejeitar id vazio', () {
      expect(
        () => DashboardDefinition(
          id: '   ',
          title: 'Dashboard',
          domain: 'institucional',
          audience: DashboardAudience.general,
          category: DashboardCategory.custom,
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar título vazio', () {
      expect(
        () => DashboardDefinition(
          id: 'dashboard',
          title: '   ',
          domain: 'institucional',
          audience: DashboardAudience.general,
          category: DashboardCategory.custom,
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar domínio vazio', () {
      expect(
        () => DashboardDefinition(
          id: 'dashboard',
          title: 'Dashboard',
          domain: '   ',
          audience: DashboardAudience.general,
          category: DashboardCategory.custom,
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar versão vazia', () {
      expect(
        () => DashboardDefinition(
          id: 'dashboard',
          title: 'Dashboard',
          domain: 'institucional',
          audience: DashboardAudience.general,
          category: DashboardCategory.custom,
          version: '   ',
        ),
        throwsArgumentError,
      );
    });

    test('deve rejeitar versão semântica inválida', () {
      final invalidVersions = [
        '1',
        '1.0',
        'v1.0.0',
        '1.0.0-beta',
        '1.0.0.0',
        'um.dois.tres',
      ];

      for (final version in invalidVersions) {
        expect(
          () => DashboardDefinition(
            id: 'dashboard',
            title: 'Dashboard',
            domain: 'institucional',
            audience: DashboardAudience.general,
            category: DashboardCategory.custom,
            version: version,
          ),
          throwsArgumentError,
          reason: 'A versão "$version" deveria ser rejeitada.',
        );
      }
    });

    test('deve aceitar versões semânticas válidas', () {
      final validVersions = [
        '0.0.1',
        '1.0.0',
        '2.10.35',
        '100.200.300',
      ];

      for (final version in validVersions) {
        final definition = DashboardDefinition(
          id: 'dashboard_$version',
          title: 'Dashboard',
          domain: 'institucional',
          audience: DashboardAudience.general,
          category: DashboardCategory.custom,
          version: version,
        );

        expect(definition.version, version);
      }
    });
  });

  group('DashboardDefinition - normalização', () {
    test(
      'deve remover valores vazios e duplicados dos indicadores',
      () {
        final definition = DashboardDefinition(
          id: 'geduc',
          title: 'Dashboard GEDUC',
          domain: 'educacao',
          audience: DashboardAudience.management,
          category: DashboardCategory.operational,
          requiredIndicators: const [
            'publico',
            ' ',
            'publico',
            'veiculos',
            '',
          ],
        );

        expect(
          definition.requiredIndicators,
          ['publico', 'veiculos'],
        );
      },
    );

    test(
      'deve remover valores vazios e duplicados dos perfis',
      () {
        final definition = DashboardDefinition(
          id: 'geduc',
          title: 'Dashboard GEDUC',
          domain: 'educacao',
          audience: DashboardAudience.management,
          category: DashboardCategory.operational,
          allowedProfiles: const [
            'gestor',
            '',
            'gestor',
            'administrador',
            '   ',
          ],
        );

        expect(
          definition.allowedProfiles,
          ['gestor', 'administrador'],
        );
      },
    );

    test('deve proteger a lista de indicadores contra alteração', () {
      final source = <String>['publico'];

      final definition = DashboardDefinition(
        id: 'geduc',
        title: 'Dashboard GEDUC',
        domain: 'educacao',
        audience: DashboardAudience.management,
        category: DashboardCategory.operational,
        requiredIndicators: source,
      );

      source.add('veiculos');

      expect(definition.requiredIndicators, ['publico']);

      expect(
        () => definition.requiredIndicators.add('meta'),
        throwsUnsupportedError,
      );
    });

    test('deve proteger a lista de perfis contra alteração', () {
      final source = <String>['gestor'];

      final definition = DashboardDefinition(
        id: 'geduc',
        title: 'Dashboard GEDUC',
        domain: 'educacao',
        audience: DashboardAudience.management,
        category: DashboardCategory.operational,
        allowedProfiles: source,
      );

      source.add('administrador');

      expect(definition.allowedProfiles, ['gestor']);

      expect(
        () => definition.allowedProfiles.add('coordenador'),
        throwsUnsupportedError,
      );
    });

    test('deve proteger os metadados contra alteração', () {
      final source = <String, Object?>{
        'owner': 'GEDUC',
      };

      final definition = DashboardDefinition(
        id: 'geduc',
        title: 'Dashboard GEDUC',
        domain: 'educacao',
        audience: DashboardAudience.management,
        category: DashboardCategory.operational,
        metadata: source,
      );

      source['owner'] = 'Outro';

      expect(definition.metadata['owner'], 'GEDUC');

      expect(
        () => definition.metadata['new'] = true,
        throwsUnsupportedError,
      );
    });
  });

  group('DashboardDefinition - getters', () {
    test('deve informar corretamente a existência de descrição', () {
      final withoutDescription = DashboardDefinition(
        id: 'one',
        title: 'Dashboard',
        domain: 'institucional',
        audience: DashboardAudience.general,
        category: DashboardCategory.custom,
      );

      final withDescription = DashboardDefinition(
        id: 'two',
        title: 'Dashboard',
        description: 'Descrição válida',
        domain: 'institucional',
        audience: DashboardAudience.general,
        category: DashboardCategory.custom,
      );

      expect(withoutDescription.hasDescription, isFalse);
      expect(withDescription.hasDescription, isTrue);
    });

    test('deve informar corretamente os estados das coleções', () {
      final definition = DashboardDefinition(
        id: 'geduc',
        title: 'Dashboard GEDUC',
        domain: 'educacao',
        audience: DashboardAudience.management,
        category: DashboardCategory.operational,
        requiredIndicators: const ['publico'],
        allowedProfiles: const ['gestor'],
        metadata: const {'owner': 'GEDUC'},
      );

      expect(definition.hasRequiredIndicators, isTrue);
      expect(definition.hasAllowedProfiles, isTrue);
      expect(definition.hasMetadata, isTrue);
      expect(definition.requiredIndicatorsCount, 1);
      expect(definition.allowedProfilesCount, 1);
    });
  });

  group('DashboardDefinition - indicadores obrigatórios', () {
    test('deve identificar indicador obrigatório', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      expect(
        definition.requiresIndicator('publico'),
        isTrue,
      );

      expect(
        definition.requiresIndicator('veiculos'),
        isFalse,
      );

      expect(
        definition.requiresIndicator('   '),
        isFalse,
      );
    });

    test('deve adicionar indicador obrigatório', () {
      final original = _createDefinition();

      final updated = original.withRequiredIndicator(
        'publico',
      );

      expect(original.requiredIndicators, isEmpty);
      expect(updated.requiredIndicators, ['publico']);
      expect(updated.requiresIndicator('publico'), isTrue);
    });

    test(
      'não deve duplicar indicador obrigatório já existente',
      () {
        final original = _createDefinition(
          requiredIndicators: const ['publico'],
        );

        final updated = original.withRequiredIndicator(
          'publico',
        );

        expect(identical(updated, original), isTrue);
        expect(updated.requiredIndicators, ['publico']);
      },
    );

    test('deve rejeitar indicador obrigatório vazio', () {
      final definition = _createDefinition();

      expect(
        () => definition.withRequiredIndicator('   '),
        throwsArgumentError,
      );
    });

    test('deve remover indicador obrigatório', () {
      final original = _createDefinition(
        requiredIndicators: const [
          'publico',
          'veiculos',
        ],
      );

      final updated = original.withoutRequiredIndicator(
        'publico',
      );

      expect(
        original.requiredIndicators,
        ['publico', 'veiculos'],
      );

      expect(
        updated.requiredIndicators,
        ['veiculos'],
      );
    });

    test(
      'deve retornar a mesma instância ao remover indicador inexistente',
      () {
        final definition = _createDefinition(
          requiredIndicators: const ['publico'],
        );

        final updated = definition.withoutRequiredIndicator(
          'inexistente',
        );

        expect(identical(updated, definition), isTrue);
      },
    );
  });

  group('DashboardDefinition - perfis autorizados', () {
    test(
      'deve permitir qualquer perfil quando não houver restrições',
      () {
        final definition = _createDefinition();

        expect(
          definition.allowsProfile('agente'),
          isTrue,
        );

        expect(
          definition.allowsProfile('gestor'),
          isTrue,
        );
      },
    );

    test('deve permitir perfil autorizado ignorando maiúsculas', () {
      final definition = _createDefinition(
        allowedProfiles: const [
          'Administrador',
          'Gestor',
        ],
      );

      expect(
        definition.allowsProfile('administrador'),
        isTrue,
      );

      expect(
        definition.allowsProfile('GESTOR'),
        isTrue,
      );

      expect(
        definition.allowsProfile('agente'),
        isFalse,
      );
    });

    test(
      'deve rejeitar perfil vazio quando houver restrições',
      () {
        final definition = _createDefinition(
          allowedProfiles: const ['gestor'],
        );

        expect(
          definition.allowsProfile('   '),
          isFalse,
        );
      },
    );
  });

  group('DashboardDefinition - metadados', () {
    test('deve localizar e consultar metadados', () {
      final definition = _createDefinition(
        metadata: const {
          'owner': 'GEDUC',
          'priority': 1,
        },
      );

      expect(
        definition.containsMetadata('owner'),
        isTrue,
      );

      expect(
        definition.containsMetadata('missing'),
        isFalse,
      );

      expect(
        definition.metadataValue('owner'),
        'GEDUC',
      );

      expect(
        definition.metadataValue('missing'),
        isNull,
      );

      expect(
        definition.metadataValue('   '),
        isNull,
      );
    });

    test('deve adicionar um novo metadado', () {
      final original = _createDefinition();

      final updated = original.withMetadata(
        'owner',
        'GEDUC',
      );

      expect(original.metadata, isEmpty);
      expect(updated.metadata['owner'], 'GEDUC');
    });

    test('deve substituir metadado existente', () {
      final original = _createDefinition(
        metadata: const {
          'owner': 'Antigo',
        },
      );

      final updated = original.withMetadata(
        'owner',
        'GEDUC',
      );

      expect(original.metadata['owner'], 'Antigo');
      expect(updated.metadata['owner'], 'GEDUC');
    });

    test('deve aceitar valor nulo em metadado', () {
      final definition = _createDefinition().withMetadata(
        'optional',
        null,
      );

      expect(
        definition.containsMetadata('optional'),
        isTrue,
      );

      expect(
        definition.metadataValue('optional'),
        isNull,
      );
    });

    test('deve rejeitar chave de metadado vazia', () {
      final definition = _createDefinition();

      expect(
        () => definition.withMetadata('   ', true),
        throwsArgumentError,
      );
    });

    test('deve remover metadado existente', () {
      final original = _createDefinition(
        metadata: const {
          'owner': 'GEDUC',
          'priority': 1,
        },
      );

      final updated = original.withoutMetadata('owner');

      expect(
        updated.containsMetadata('owner'),
        isFalse,
      );

      expect(
        updated.metadata['priority'],
        1,
      );
    });

    test(
      'deve retornar a mesma instância ao remover metadado inexistente',
      () {
        final definition = _createDefinition();

        final updated = definition.withoutMetadata(
          'inexistente',
        );

        expect(identical(updated, definition), isTrue);
      },
    );
  });

  group('DashboardDefinition - estado e cópia', () {
    test('deve desabilitar uma definição habilitada', () {
      final original = _createDefinition();

      final disabled = original.disable();

      expect(original.enabled, isTrue);
      expect(disabled.enabled, isFalse);
    });

    test(
      'deve retornar a mesma instância ao desabilitar novamente',
      () {
        final definition = _createDefinition(
          enabled: false,
        );

        final result = definition.disable();

        expect(identical(result, definition), isTrue);
      },
    );

    test('deve habilitar uma definição desabilitada', () {
      final original = _createDefinition(
        enabled: false,
      );

      final enabled = original.enable();

      expect(original.enabled, isFalse);
      expect(enabled.enabled, isTrue);
    });

    test(
      'deve retornar a mesma instância ao habilitar novamente',
      () {
        final definition = _createDefinition();

        final result = definition.enable();

        expect(identical(result, definition), isTrue);
      },
    );

    test('copyWith deve alterar apenas os campos informados', () {
      final original = _createDefinition(
        description: 'Descrição original',
        metadata: const {
          'owner': 'GEDUC',
        },
      );

      final updated = original.copyWith(
        title: 'Novo título',
        version: '2.0.0',
        enabled: false,
      );

      expect(updated.id, original.id);
      expect(updated.title, 'Novo título');
      expect(updated.description, 'Descrição original');
      expect(updated.domain, original.domain);
      expect(updated.audience, original.audience);
      expect(updated.category, original.category);
      expect(updated.version, '2.0.0');
      expect(updated.enabled, isFalse);
      expect(updated.metadata['owner'], 'GEDUC');
    });
  });

  group('DashboardDefinition - igualdade', () {
    test(
      'duas definições com mesmo id e versão devem ser iguais',
      () {
        final first = _createDefinition(
          title: 'Título A',
          version: '1.0.0',
        );

        final second = _createDefinition(
          title: 'Título B',
          version: '1.0.0',
        );

        expect(first, equals(second));
        expect(first.hashCode, equals(second.hashCode));
      },
    );

    test(
      'definições com versões diferentes não devem ser iguais',
      () {
        final first = _createDefinition(
          version: '1.0.0',
        );

        final second = _createDefinition(
          version: '2.0.0',
        );

        expect(first, isNot(equals(second)));
      },
    );

    test(
      'definições com identificadores diferentes não devem ser iguais',
      () {
        final first = _createDefinition(
          id: 'geduc',
        );

        final second = _createDefinition(
          id: 'rpas',
        );

        expect(first, isNot(equals(second)));
      },
    );

    test('toString deve apresentar informações essenciais', () {
      final definition = _createDefinition();

      final result = definition.toString();

      expect(result, contains('DashboardDefinition'));
      expect(result, contains('id: geduc'));
      expect(result, contains('domain: educacao'));
      expect(result, contains('version: 1.0.0'));
      expect(result, contains('enabled: true'));
    });
  });
}

DashboardDefinition _createDefinition({
  String id = 'geduc',
  String title = 'Dashboard GEDUC',
  String? description,
  String domain = 'educacao',
  DashboardAudience audience = DashboardAudience.management,
  DashboardCategory category = DashboardCategory.operational,
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