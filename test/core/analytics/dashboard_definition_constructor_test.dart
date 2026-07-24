import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';

void main() {
  group('DashboardDefinition - construtor e valores padrão', () {
    test('cria definição com os campos obrigatórios', () {
      final definition = _createDefinition();

      expect(definition.id, 'executive');
      expect(definition.title, 'Dashboard Executivo');
      expect(definition.domain, 'institucional');
      expect(definition.audience, DashboardAudience.executive);
      expect(definition.category, DashboardCategory.strategic);
    });

    test('utiliza versão padrão 1.0.0', () {
      expect(_createDefinition().version, '1.0.0');
    });

    test('é habilitado por padrão', () {
      expect(_createDefinition().enabled, isTrue);
    });

    test('utiliza descrição nula por padrão', () {
      expect(_createDefinition().description, isNull);
    });

    test('utiliza coleções vazias por padrão', () {
      final definition = _createDefinition();

      expect(definition.requiredIndicators, isEmpty);
      expect(definition.allowedProfiles, isEmpty);
      expect(definition.metadata, isEmpty);
      expect(definition.hasRequiredIndicators, isFalse);
      expect(definition.hasAllowedProfiles, isFalse);
      expect(definition.hasMetadata, isFalse);
      expect(definition.requiredIndicatorsCount, 0);
      expect(definition.allowedProfilesCount, 0);
    });

    test('aceita todos os valores opcionais', () {
      final definition = DashboardDefinition(
        id: 'operational',
        title: 'Dashboard Operacional',
        description: 'Acompanhamento diário da operação.',
        domain: 'fiscalizacao',
        audience: DashboardAudience.operational,
        category: DashboardCategory.operational,
        version: '2.4.8',
        enabled: false,
        requiredIndicators: const ['abordagens', 'veiculos'],
        allowedProfiles: const ['gestor', 'coordenador'],
        metadata: const {
          'owner': 'AMC',
          'priority': 10,
          'public': false,
        },
      );

      expect(definition.id, 'operational');
      expect(definition.title, 'Dashboard Operacional');
      expect(definition.description, 'Acompanhamento diário da operação.');
      expect(definition.domain, 'fiscalizacao');
      expect(definition.audience, DashboardAudience.operational);
      expect(definition.category, DashboardCategory.operational);
      expect(definition.version, '2.4.8');
      expect(definition.enabled, isFalse);
      expect(definition.requiredIndicators, ['abordagens', 'veiculos']);
      expect(definition.allowedProfiles, ['gestor', 'coordenador']);
      expect(definition.metadata['owner'], 'AMC');
      expect(definition.metadata['priority'], 10);
      expect(definition.metadata['public'], isFalse);
    });

    test('hasDescription reconhece descrição preenchida', () {
      expect(
        _createDefinition(description: 'Descrição institucional')
            .hasDescription,
        isTrue,
      );
    });

    test('hasDescription é falso para descrição nula', () {
      expect(_createDefinition().hasDescription, isFalse);
    });

    test('hasDescription é falso para descrição vazia', () {
      expect(_createDefinition(description: '').hasDescription, isFalse);
    });

    test('hasDescription é falso para descrição somente com espaços', () {
      expect(_createDefinition(description: '   ').hasDescription, isFalse);
    });

    test('contabiliza indicadores obrigatórios', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico', 'acoes', 'veiculos'],
      );

      expect(definition.hasRequiredIndicators, isTrue);
      expect(definition.requiredIndicatorsCount, 3);
    });

    test('contabiliza perfis autorizados', () {
      final definition = _createDefinition(
        allowedProfiles: const ['administrador', 'gestor'],
      );

      expect(definition.hasAllowedProfiles, isTrue);
      expect(definition.allowedProfilesCount, 2);
    });

    test('hasMetadata é verdadeiro quando existem metadados', () {
      expect(
        _createDefinition(metadata: const {'source': 'atlas'}).hasMetadata,
        isTrue,
      );
    });
  });

  group('DashboardDefinition - normalização de indicadores', () {
    test('remove espaços externos', () {
      final definition = _createDefinition(
        requiredIndicators: const [
          '  publico_alcancado  ',
          'veiculos_abordados ',
        ],
      );

      expect(
        definition.requiredIndicators,
        ['publico_alcancado', 'veiculos_abordados'],
      );
    });

    test('remove valores vazios', () {
      final definition = _createDefinition(
        requiredIndicators: const ['', '   ', 'acoes_realizadas'],
      );

      expect(definition.requiredIndicators, ['acoes_realizadas']);
    });

    test('remove duplicados preservando a ordem', () {
      final definition = _createDefinition(
        requiredIndicators: const [
          'publico',
          'acoes',
          'publico',
          'veiculos',
          'acoes',
        ],
      );

      expect(definition.requiredIndicators, ['publico', 'acoes', 'veiculos']);
    });

    test('duplicidade é sensível a maiúsculas', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico', 'Publico', 'PUBLICO'],
      );

      expect(definition.requiredIndicators, ['publico', 'Publico', 'PUBLICO']);
    });

    test('aceita Iterable que não seja List', () {
      final definition = _createDefinition(
        requiredIndicators: {'publico', 'acoes'},
      );

      expect(definition.requiredIndicators, ['publico', 'acoes']);
    });
  });

  group('DashboardDefinition - normalização de perfis', () {
    test('remove espaços externos', () {
      final definition = _createDefinition(
        allowedProfiles: const ['  administrador  ', 'gestor '],
      );

      expect(definition.allowedProfiles, ['administrador', 'gestor']);
    });

    test('remove valores vazios', () {
      final definition = _createDefinition(
        allowedProfiles: const ['', '   ', 'coordenador'],
      );

      expect(definition.allowedProfiles, ['coordenador']);
    });

    test('remove duplicados preservando a ordem', () {
      final definition = _createDefinition(
        allowedProfiles: const [
          'gestor',
          'agente',
          'gestor',
          'coordenador',
          'agente',
        ],
      );

      expect(definition.allowedProfiles, ['gestor', 'agente', 'coordenador']);
    });

    test('duplicidade no construtor é sensível a maiúsculas', () {
      final definition = _createDefinition(
        allowedProfiles: const ['gestor', 'Gestor', 'GESTOR'],
      );

      expect(definition.allowedProfiles, ['gestor', 'Gestor', 'GESTOR']);
    });

    test('aceita Iterable que não seja List', () {
      final definition = _createDefinition(
        allowedProfiles: {'administrador', 'gestor'},
      );

      expect(definition.allowedProfiles, ['administrador', 'gestor']);
    });
  });

  group('DashboardDefinition - imutabilidade', () {
    test('requiredIndicators não permite inclusão', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      expect(
        () => definition.requiredIndicators.add('acoes'),
        throwsUnsupportedError,
      );
    });

    test('requiredIndicators não permite remoção', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      expect(
        () => definition.requiredIndicators.remove('publico'),
        throwsUnsupportedError,
      );
    });

    test('allowedProfiles não permite inclusão', () {
      final definition = _createDefinition(
        allowedProfiles: const ['gestor'],
      );

      expect(
        () => definition.allowedProfiles.add('agente'),
        throwsUnsupportedError,
      );
    });

    test('allowedProfiles não permite remoção', () {
      final definition = _createDefinition(
        allowedProfiles: const ['gestor'],
      );

      expect(
        () => definition.allowedProfiles.remove('gestor'),
        throwsUnsupportedError,
      );
    });

    test('metadata não permite inclusão', () {
      final definition = _createDefinition(
        metadata: const {'source': 'atlas'},
      );

      expect(
        () => definition.metadata['owner'] = 'AMC',
        throwsUnsupportedError,
      );
    });

    test('metadata não permite remoção', () {
      final definition = _createDefinition(
        metadata: const {'source': 'atlas'},
      );

      expect(
        () => definition.metadata.remove('source'),
        throwsUnsupportedError,
      );
    });

    test('copia os indicadores recebidos', () {
      final source = <String>['publico'];
      final definition = _createDefinition(requiredIndicators: source);

      source.add('acoes');

      expect(definition.requiredIndicators, ['publico']);
    });

    test('copia os perfis recebidos', () {
      final source = <String>['gestor'];
      final definition = _createDefinition(allowedProfiles: source);

      source.add('agente');

      expect(definition.allowedProfiles, ['gestor']);
    });

    test('copia o mapa de metadados recebido', () {
      final source = <String, Object?>{'source': 'atlas'};
      final definition = _createDefinition(metadata: source);

      source['source'] = 'externo';
      source['owner'] = 'AMC';

      expect(definition.metadata, {'source': 'atlas'});
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
