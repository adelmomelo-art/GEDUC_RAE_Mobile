import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';

void main() {
  group('DashboardDefinition - requiresIndicator', () {
    test('retorna true para indicador obrigatório existente', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico', 'acoes'],
      );

      expect(definition.requiresIndicator('publico'), isTrue);
    });

    test('normaliza espaços externos na consulta', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      expect(definition.requiresIndicator('  publico  '), isTrue);
    });

    test('retorna false para indicador inexistente', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      expect(definition.requiresIndicator('veiculos'), isFalse);
    });

    test('retorna false para indicador vazio', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      expect(definition.requiresIndicator(''), isFalse);
    });

    test('retorna false para indicador somente com espaços', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      expect(definition.requiresIndicator('   '), isFalse);
    });

    test('comparação é sensível a maiúsculas e minúsculas', () {
      final definition = _createDefinition(
        requiredIndicators: const ['publico'],
      );

      expect(definition.requiresIndicator('Publico'), isFalse);
    });

    test('retorna false quando não existem indicadores', () {
      final definition = _createDefinition();

      expect(definition.requiresIndicator('publico'), isFalse);
    });
  });

  group('DashboardDefinition - allowsProfile', () {
    test('permite qualquer perfil quando a lista está vazia', () {
      final definition = _createDefinition();

      expect(definition.allowsProfile('administrador'), isTrue);
      expect(definition.allowsProfile('gestor'), isTrue);
      expect(definition.allowsProfile('agente'), isTrue);
    });

    test('permite perfil declarado', () {
      final definition = _createDefinition(
        allowedProfiles: const ['administrador', 'gestor'],
      );

      expect(definition.allowsProfile('gestor'), isTrue);
    });

    test('normaliza espaços externos do perfil consultado', () {
      final definition = _createDefinition(
        allowedProfiles: const ['gestor'],
      );

      expect(definition.allowsProfile('  gestor  '), isTrue);
    });

    test('comparação não diferencia maiúsculas e minúsculas', () {
      final definition = _createDefinition(
        allowedProfiles: const ['Gestor'],
      );

      expect(definition.allowsProfile('gestor'), isTrue);
      expect(definition.allowsProfile('GESTOR'), isTrue);
      expect(definition.allowsProfile('GeStOr'), isTrue);
    });

    test('retorna false para perfil não declarado', () {
      final definition = _createDefinition(
        allowedProfiles: const ['gestor'],
      );

      expect(definition.allowsProfile('agente'), isFalse);
    });

    test('retorna false para perfil vazio quando há restrições', () {
      final definition = _createDefinition(
        allowedProfiles: const ['gestor'],
      );

      expect(definition.allowsProfile(''), isFalse);
    });

    test('retorna false para espaços quando há restrições', () {
      final definition = _createDefinition(
        allowedProfiles: const ['gestor'],
      );

      expect(definition.allowsProfile('   '), isFalse);
    });

    test('perfil vazio é permitido quando não há restrições', () {
      final definition = _createDefinition();

      expect(definition.allowsProfile(''), isTrue);
    });

    test('espaços são permitidos quando não há restrições', () {
      final definition = _createDefinition();

      expect(definition.allowsProfile('   '), isTrue);
    });
  });

  group('DashboardDefinition - metadataValue', () {
    test('retorna metadado existente', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      expect(definition.metadataValue('owner'), 'AMC');
    });

    test('normaliza espaços externos da chave consultada', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      expect(definition.metadataValue('  owner  '), 'AMC');
    });

    test('retorna null para chave inexistente', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      expect(definition.metadataValue('priority'), isNull);
    });

    test('retorna null para chave vazia', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      expect(definition.metadataValue(''), isNull);
    });

    test('retorna null para chave somente com espaços', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      expect(definition.metadataValue('   '), isNull);
    });

    test('preserva valor null armazenado', () {
      final definition = _createDefinition(
        metadata: const {'nullable': null},
      );

      expect(definition.metadataValue('nullable'), isNull);
      expect(definition.containsMetadata('nullable'), isTrue);
    });

    test('consulta de chave é sensível a maiúsculas', () {
      final definition = _createDefinition(
        metadata: const {'owner': 'AMC'},
      );

      expect(definition.metadataValue('Owner'), isNull);
    });
  });

  group('DashboardDefinition - containsMetadata', () {
    test('retorna true para chave existente', () {
      final definition = _createDefinition(
        metadata: const {'source': 'atlas'},
      );

      expect(definition.containsMetadata('source'), isTrue);
    });

    test('normaliza espaços externos da chave', () {
      final definition = _createDefinition(
        metadata: const {'source': 'atlas'},
      );

      expect(definition.containsMetadata('  source  '), isTrue);
    });

    test('retorna false para chave inexistente', () {
      final definition = _createDefinition(
        metadata: const {'source': 'atlas'},
      );

      expect(definition.containsMetadata('owner'), isFalse);
    });

    test('retorna false para chave vazia', () {
      final definition = _createDefinition(
        metadata: const {'source': 'atlas'},
      );

      expect(definition.containsMetadata(''), isFalse);
    });

    test('retorna false para chave somente com espaços', () {
      final definition = _createDefinition(
        metadata: const {'source': 'atlas'},
      );

      expect(definition.containsMetadata('   '), isFalse);
    });

    test('reconhece chave associada a valor null', () {
      final definition = _createDefinition(
        metadata: const {'nullable': null},
      );

      expect(definition.containsMetadata('nullable'), isTrue);
    });
  });

  group('DashboardDefinition - enable', () {
    test('retorna a mesma instância quando já está habilitado', () {
      final definition = _createDefinition(enabled: true);

      final result = definition.enable();

      expect(result, same(definition));
      expect(result.enabled, isTrue);
    });

    test('retorna nova instância habilitada quando estava desabilitado', () {
      final definition = _createDefinition(enabled: false);

      final result = definition.enable();

      expect(result, isNot(same(definition)));
      expect(result.enabled, isTrue);
    });

    test('preserva todos os demais campos ao habilitar', () {
      final definition = _createDefinition(
        description: 'Descrição',
        version: '2.0.0',
        enabled: false,
        requiredIndicators: const ['publico'],
        allowedProfiles: const ['gestor'],
        metadata: const {'owner': 'AMC'},
      );

      final result = definition.enable();

      expect(result.id, definition.id);
      expect(result.title, definition.title);
      expect(result.description, definition.description);
      expect(result.domain, definition.domain);
      expect(result.audience, definition.audience);
      expect(result.category, definition.category);
      expect(result.version, definition.version);
      expect(result.requiredIndicators, definition.requiredIndicators);
      expect(result.allowedProfiles, definition.allowedProfiles);
      expect(result.metadata, definition.metadata);
    });
  });

  group('DashboardDefinition - disable', () {
    test('retorna a mesma instância quando já está desabilitado', () {
      final definition = _createDefinition(enabled: false);

      final result = definition.disable();

      expect(result, same(definition));
      expect(result.enabled, isFalse);
    });

    test('retorna nova instância desabilitada quando estava habilitado', () {
      final definition = _createDefinition(enabled: true);

      final result = definition.disable();

      expect(result, isNot(same(definition)));
      expect(result.enabled, isFalse);
    });

    test('preserva todos os demais campos ao desabilitar', () {
      final definition = _createDefinition(
        description: 'Descrição',
        version: '2.0.0',
        enabled: true,
        requiredIndicators: const ['publico'],
        allowedProfiles: const ['gestor'],
        metadata: const {'owner': 'AMC'},
      );

      final result = definition.disable();

      expect(result.id, definition.id);
      expect(result.title, definition.title);
      expect(result.description, definition.description);
      expect(result.domain, definition.domain);
      expect(result.audience, definition.audience);
      expect(result.category, definition.category);
      expect(result.version, definition.version);
      expect(result.requiredIndicators, definition.requiredIndicators);
      expect(result.allowedProfiles, definition.allowedProfiles);
      expect(result.metadata, definition.metadata);
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
