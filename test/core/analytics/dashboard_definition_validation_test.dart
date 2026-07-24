import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';

void main() {
  group('DashboardDefinition - validação de id', () {
    test('rejeita id vazio', () {
      expect(
        () => _createDefinition(id: ''),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'id')
              .having((error) => error.invalidValue, 'invalidValue', ''),
        ),
      );
    });

    test('rejeita id contendo apenas espaços', () {
      expect(
        () => _createDefinition(id: '   '),
        throwsA(
          isA<ArgumentError>().having((error) => error.name, 'name', 'id'),
        ),
      );
    });

    test('aceita id com conteúdo e espaços externos', () {
      final definition = _createDefinition(id: '  executive  ');

      expect(definition.id, '  executive  ');
    });

    test('aceita id com números, hífen e sublinhado', () {
      final definition = _createDefinition(
        id: 'dashboard_2026-executive',
      );

      expect(definition.id, 'dashboard_2026-executive');
    });
  });

  group('DashboardDefinition - validação de título', () {
    test('rejeita título vazio', () {
      expect(
        () => _createDefinition(title: ''),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'title')
              .having((error) => error.invalidValue, 'invalidValue', ''),
        ),
      );
    });

    test('rejeita título contendo apenas espaços', () {
      expect(
        () => _createDefinition(title: '   '),
        throwsA(
          isA<ArgumentError>().having((error) => error.name, 'name', 'title'),
        ),
      );
    });

    test('aceita título com conteúdo e espaços externos', () {
      final definition = _createDefinition(
        title: '  Dashboard Executivo  ',
      );

      expect(definition.title, '  Dashboard Executivo  ');
    });

    test('aceita título com caracteres acentuados', () {
      final definition = _createDefinition(
        title: 'Gestão, Educação e Fiscalização',
      );

      expect(definition.title, 'Gestão, Educação e Fiscalização');
    });
  });

  group('DashboardDefinition - validação de domínio', () {
    test('rejeita domínio vazio', () {
      expect(
        () => _createDefinition(domain: ''),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'domain')
              .having((error) => error.invalidValue, 'invalidValue', ''),
        ),
      );
    });

    test('rejeita domínio contendo apenas espaços', () {
      expect(
        () => _createDefinition(domain: '   '),
        throwsA(
          isA<ArgumentError>().having((error) => error.name, 'name', 'domain'),
        ),
      );
    });

    test('aceita domínio com conteúdo e espaços externos', () {
      final definition = _createDefinition(
        domain: '  institucional  ',
      );

      expect(definition.domain, '  institucional  ');
    });

    test('aceita domínio composto', () {
      final definition = _createDefinition(
        domain: 'educacao-seguranca_viaria',
      );

      expect(definition.domain, 'educacao-seguranca_viaria');
    });
  });

  group('DashboardDefinition - validação de versão', () {
    test('rejeita versão vazia', () {
      expect(
        () => _createDefinition(version: ''),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'version')
              .having((error) => error.invalidValue, 'invalidValue', ''),
        ),
      );
    });

    test('rejeita versão contendo apenas espaços', () {
      expect(
        () => _createDefinition(version: '   '),
        throwsA(
          isA<ArgumentError>().having((error) => error.name, 'name', 'version'),
        ),
      );
    });

    test('aceita versão semântica básica', () {
      expect(_createDefinition(version: '1.0.0').version, '1.0.0');
    });

    test('aceita versão semântica com números maiores', () {
      expect(_createDefinition(version: '125.48.900').version, '125.48.900');
    });

    test('aceita zeros à esquerda', () {
      expect(_createDefinition(version: '01.002.0003').version, '01.002.0003');
    });

    test('aceita versão com espaços externos', () {
      expect(_createDefinition(version: '  2.5.9  ').version, '  2.5.9  ');
    });

    test('rejeita versão com apenas major', () {
      expect(
        () => _createDefinition(version: '1'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com major e minor', () {
      expect(
        () => _createDefinition(version: '1.0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com quatro segmentos', () {
      expect(
        () => _createDefinition(version: '1.0.0.0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão iniciada por ponto', () {
      expect(
        () => _createDefinition(version: '.1.0.0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão terminada por ponto', () {
      expect(
        () => _createDefinition(version: '1.0.0.'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com segmento vazio', () {
      expect(
        () => _createDefinition(version: '1..0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com letras', () {
      expect(
        () => _createDefinition(version: 'v1.0.0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com sufixo prerelease', () {
      expect(
        () => _createDefinition(version: '1.0.0-beta'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com metadados de build', () {
      expect(
        () => _createDefinition(version: '1.0.0+10'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com números negativos', () {
      expect(
        () => _createDefinition(version: '-1.0.0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com espaços internos', () {
      expect(
        () => _createDefinition(version: '1. 0.0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejeita versão com vírgulas', () {
      expect(
        () => _createDefinition(version: '1,0,0'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('erro de versão inválida identifica o parâmetro version', () {
      expect(
        () => _createDefinition(version: 'versao-invalida'),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'version')
              .having(
                (error) => error.invalidValue,
                'invalidValue',
                'versao-invalida',
              ),
        ),
      );
    });
  });

  group('DashboardDefinition - preservação dos valores', () {
    test('não normaliza o id armazenado', () {
      expect(_createDefinition(id: '  executive  ').id, '  executive  ');
    });

    test('não normaliza o título armazenado', () {
      expect(
        _createDefinition(title: '  Dashboard Executivo  ').title,
        '  Dashboard Executivo  ',
      );
    });

    test('não normaliza o domínio armazenado', () {
      expect(
        _createDefinition(domain: '  institucional  ').domain,
        '  institucional  ',
      );
    });

    test('não normaliza a versão armazenada', () {
      expect(_createDefinition(version: '  1.2.3  ').version, '  1.2.3  ');
    });

    test('preserva o valor exato da descrição', () {
      expect(
        _createDefinition(
          description: '  Descrição institucional  ',
        ).description,
        '  Descrição institucional  ',
      );
    });

    test('preserva tipos diferentes nos metadados', () {
      final date = DateTime(2026, 7, 22);
      final definition = _createDefinition(
        metadata: {
          'text': 'Atlas',
          'number': 42,
          'decimal': 3.14,
          'boolean': true,
          'nullable': null,
          'date': date,
          'list': const ['a', 'b'],
        },
      );

      expect(definition.metadata['text'], 'Atlas');
      expect(definition.metadata['number'], 42);
      expect(definition.metadata['decimal'], 3.14);
      expect(definition.metadata['boolean'], isTrue);
      expect(definition.metadata['nullable'], isNull);
      expect(definition.metadata['date'], same(date));
      expect(definition.metadata['list'], ['a', 'b']);
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
