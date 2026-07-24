import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_dashboard_model.dart';
import 'package:geduc_rae_mobile/core/analytics/analytics_result.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_builder.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_factory.dart';
import 'package:geduc_rae_mobile/core/analytics/dashboard_registry.dart';

import '../../fixtures/analytics_result_fixture.dart';

void main() {
  group('DashboardFactory', () {
    late DashboardRegistry registry;
    late RecordingDashboardBuilder builder;
    late DashboardFactory factory;

    setUp(() {
      registry = DashboardRegistry();
      builder = RecordingDashboardBuilder();

      factory = DashboardFactory(
        registry: registry,
        builder: builder,
      );
    });

    group('canCreate()', () {
      test(
        'retorna false quando o dashboard não está registrado',
        () {
          final result = factory.canCreate(
            'dashboard-inexistente',
          );

          expect(result, isFalse);
        },
      );

      test(
        'retorna true quando o dashboard está registrado e habilitado',
        () {
          registry.register(
            _createDefinition(),
          );

          final result = factory.canCreate(
            'executive',
          );

          expect(result, isTrue);
        },
      );

      test(
        'retorna false quando o dashboard está desabilitado',
        () {
          registry.register(
            _createDefinition(
              enabled: false,
            ),
          );

          final result = factory.canCreate(
            'executive',
          );

          expect(result, isFalse);
        },
      );

      test(
        'normaliza espaços do identificador por meio do registry',
        () {
          registry.register(
            _createDefinition(),
          );

          final result = factory.canCreate(
            '  executive  ',
          );

          expect(result, isTrue);
        },
      );
    });

    group('definition()', () {
      test(
        'retorna null quando a definição não existe',
        () {
          final result = factory.definition(
            'dashboard-inexistente',
          );

          expect(result, isNull);
        },
      );

      test(
        'retorna a definição registrada',
        () {
          final definition = _createDefinition();

          registry.register(definition);

          final result = factory.definition(
            definition.id,
          );

          expect(result, same(definition));
        },
      );

      test(
        'retorna definição desabilitada quando ela está registrada',
        () {
          final definition = _createDefinition(
            enabled: false,
          );

          registry.register(definition);

          final result = factory.definition(
            definition.id,
          );

          expect(result, same(definition));
          expect(result?.enabled, isFalse);
        },
      );

      test(
        'normaliza espaços do identificador por meio do registry',
        () {
          final definition = _createDefinition();

          registry.register(definition);

          final result = factory.definition(
            '  ${definition.id}  ',
          );

          expect(result, same(definition));
        },
      );
    });

    group('availableDashboards()', () {
      test(
        'retorna lista vazia quando não existem dashboards',
        () {
          final result = factory.availableDashboards();

          expect(result, isEmpty);
        },
      );

      test(
        'retorna somente dashboards habilitados',
        () {
          final enabledDefinition = _createDefinition(
            id: 'executive',
            enabled: true,
          );

          final disabledDefinition = _createDefinition(
            id: 'operational',
            enabled: false,
          );

          registry.registerAll([
            enabledDefinition,
            disabledDefinition,
          ]);

          final result = factory.availableDashboards();

          expect(result, hasLength(1));
          expect(result.single, same(enabledDefinition));
          expect(
            result,
            isNot(contains(disabledDefinition)),
          );
        },
      );

      test(
        'preserva a ordem de registro dos dashboards habilitados',
        () {
          final first = _createDefinition(
            id: 'executive',
            title: 'Executivo',
          );

          final second = _createDefinition(
            id: 'management',
            title: 'Gerencial',
          );

          final third = _createDefinition(
            id: 'operational',
            title: 'Operacional',
          );

          registry.registerAll([
            first,
            second,
            third,
          ]);

          final result = factory.availableDashboards();

          expect(
            result,
            orderedEquals([
              first,
              second,
              third,
            ]),
          );
        },
      );

      test(
        'retorna uma lista não modificável',
        () {
          registry.register(
            _createDefinition(),
          );

          final result = factory.availableDashboards();

          expect(
            () => result.add(
              _createDefinition(
                id: 'new-dashboard',
              ),
            ),
            throwsUnsupportedError,
          );
        },
      );
    });

    group('create()', () {
      test(
        'lança StateError quando o dashboard não está registrado',
        () {
          final analyticsResult =
              AnalyticsResultFixture.sample();

          expect(
            () => factory.create(
              dashboardId: 'dashboard-inexistente',
              result: analyticsResult,
            ),
            throwsA(
              isA<StateError>().having(
                (error) => error.message,
                'message',
                'Dashboard "dashboard-inexistente" '
                    'não está registrado.',
              ),
            ),
          );

          expect(builder.buildCallCount, 0);
        },
      );

      test(
        'lança StateError quando o dashboard está desabilitado',
        () {
          final definition = _createDefinition(
            enabled: false,
          );

          registry.register(definition);

          final analyticsResult =
              AnalyticsResultFixture.sample();

          expect(
            () => factory.create(
              dashboardId: definition.id,
              result: analyticsResult,
            ),
            throwsA(
              isA<StateError>().having(
                (error) => error.message,
                'message',
                'Dashboard "${definition.id}" '
                    'está desabilitado.',
              ),
            ),
          );

          expect(builder.buildCallCount, 0);
        },
      );

      test(
        'aciona o builder exatamente uma vez',
        () {
          final definition = _createDefinition();

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
          );

          expect(builder.buildCallCount, 1);
        },
      );

      test(
        'retorna exatamente o dashboard produzido pelo builder',
        () {
          final definition = _createDefinition();

          registry.register(definition);

          final result = factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
          );

          expect(
            result,
            same(builder.lastBuiltDashboard),
          );
        },
      );

      test(
        'encaminha o identificador da definição ao builder',
        () {
          final definition = _createDefinition(
            id: 'operational',
          );

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
          );

          expect(
            builder.lastId,
            definition.id,
          );
        },
      );

      test(
        'encaminha o título da definição ao builder',
        () {
          final definition = _createDefinition(
            title: 'Dashboard Estratégico',
          );

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
          );

          expect(
            builder.lastTitle,
            definition.title,
          );
        },
      );

      test(
        'encaminha a descrição da definição ao builder',
        () {
          final definition = _createDefinition(
            description:
                'Indicadores estratégicos institucionais.',
          );

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
          );

          expect(
            builder.lastDescription,
            definition.description,
          );
        },
      );

      test(
        'encaminha descrição nula ao builder',
        () {
          final definition = _createDefinition(
            description: null,
          );

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
          );

          expect(
            builder.lastDescription,
            isNull,
          );
        },
      );

      test(
        'encaminha o domínio da definição ao builder',
        () {
          final definition = _createDefinition(
            domain: 'educacao',
          );

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
          );

          expect(
            builder.lastDomain,
            definition.domain,
          );
        },
      );

      test(
        'encaminha a mesma instância de AnalyticsResult ao builder',
        () {
          final definition = _createDefinition();
          final analyticsResult =
              AnalyticsResultFixture.sample();

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: analyticsResult,
          );

          expect(
            builder.lastResult,
            same(analyticsResult),
          );
        },
      );

      test(
        'encaminha a data inicial de referência ao builder',
        () {
          final definition = _createDefinition();
          final referenceStartDate = DateTime(
            2026,
            1,
            1,
          );

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
            referenceStartDate: referenceStartDate,
          );

          expect(
            builder.lastReferenceStartDate,
            referenceStartDate,
          );
        },
      );

      test(
        'encaminha a data final de referência ao builder',
        () {
          final definition = _createDefinition();
          final referenceEndDate = DateTime(
            2026,
            12,
            31,
          );

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
            referenceEndDate: referenceEndDate,
          );

          expect(
            builder.lastReferenceEndDate,
            referenceEndDate,
          );
        },
      );

      test(
        'encaminha ambas as datas de referência ao builder',
        () {
          final definition = _createDefinition();

          final referenceStartDate = DateTime(
            2026,
            1,
            1,
          );

          final referenceEndDate = DateTime(
            2026,
            6,
            30,
          );

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
            referenceStartDate: referenceStartDate,
            referenceEndDate: referenceEndDate,
          );

          expect(
            builder.lastReferenceStartDate,
            referenceStartDate,
          );

          expect(
            builder.lastReferenceEndDate,
            referenceEndDate,
          );
        },
      );

      test(
        'encaminha datas de referência nulas quando não informadas',
        () {
          final definition = _createDefinition();

          registry.register(definition);

          factory.create(
            dashboardId: definition.id,
            result: AnalyticsResultFixture.sample(),
          );

          expect(
            builder.lastReferenceStartDate,
            isNull,
          );

          expect(
            builder.lastReferenceEndDate,
            isNull,
          );
        },
      );

      test(
        'aceita identificador com espaços externos',
        () {
          final definition = _createDefinition();

          registry.register(definition);

          factory.create(
            dashboardId: '  ${definition.id}  ',
            result: AnalyticsResultFixture.sample(),
          );

          expect(builder.buildCallCount, 1);
          expect(builder.lastId, definition.id);
        },
      );
    });

    group('toString()', () {
      test(
        'informa zero registros quando o registry está vazio',
        () {
          expect(
            factory.toString(),
            'DashboardFactory(registered: 0)',
          );
        },
      );

      test(
        'informa a quantidade de dashboards registrados',
        () {
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

          expect(
            factory.toString(),
            'DashboardFactory(registered: 3)',
          );
        },
      );

      test(
        'contabiliza também dashboards desabilitados',
        () {
          registry.registerAll([
            _createDefinition(
              id: 'enabled-dashboard',
              enabled: true,
            ),
            _createDefinition(
              id: 'disabled-dashboard',
              enabled: false,
            ),
          ]);

          expect(
            factory.toString(),
            'DashboardFactory(registered: 2)',
          );
        },
      );
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
  bool enabled = true,
}) {
  return DashboardDefinition(
    id: id,
    title: title,
    description: description,
    domain: domain,
    audience: audience,
    category: category,
    enabled: enabled,
  );
}

/// Builder controlado utilizado exclusivamente pelos testes.
///
/// Registra todos os argumentos recebidos e delega a construção
/// final ao [DashboardBuilder] real. Dessa forma, o teste consegue
/// validar a orquestração do [DashboardFactory] sem precisar recriar
/// manualmente um [AnalyticsDashboardModel].
final class RecordingDashboardBuilder
    implements DashboardBuilderBase {
  final DashboardBuilder _delegate =
      const DashboardBuilder();

  int buildCallCount = 0;

  String? lastId;
  String? lastTitle;
  String? lastDescription;
  String? lastDomain;

  AnalyticsResult? lastResult;

  DateTime? lastReferenceStartDate;
  DateTime? lastReferenceEndDate;

  AnalyticsDashboardModel? lastBuiltDashboard;

  @override
  AnalyticsDashboardModel build({
    required String id,
    required String title,
    required String domain,
    required AnalyticsResult result,
    String? description,
    DateTime? referenceStartDate,
    DateTime? referenceEndDate,
  }) {
    buildCallCount++;

    lastId = id;
    lastTitle = title;
    lastDescription = description;
    lastDomain = domain;
    lastResult = result;
    lastReferenceStartDate = referenceStartDate;
    lastReferenceEndDate = referenceEndDate;

    final dashboard = _delegate.build(
      id: id,
      title: title,
      domain: domain,
      result: result,
      description: description,
      referenceStartDate: referenceStartDate,
      referenceEndDate: referenceEndDate,
    );

    lastBuiltDashboard = dashboard;

    return dashboard;
  }
}