import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cio_dashboard_filters.dart';
import 'package:geduc_rae_mobile/modules/dashboard/widgets/executive/executive_filters.dart';
import 'package:geduc_rae_mobile/modules/dashboard/widgets/executive/executive_kpi_grid.dart';

void main() {
  for (final largura in [320.0, 360.0, 412.0, 800.0]) {
    testWidgets('filtros CIO sem overflow em ${largura.toInt()} px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(largura, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(
        SingleChildScrollView(
          child: ExecutiveFilters(
            filtros: const CioDashboardFilters(),
            regionais: const ['Regional 1', 'Regional 2'],
            tiposAcao: const ['Oficina', 'Palestra'],
            statusDisponiveis: const ['concluido', 'rascunho'],
            coordenadores: const ['Maria da Silva', 'Carlos Lima'],
            onAplicar: (_) {},
          ),
        ),
      ));
      await tester.tap(find.text('Filtros avançados'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('APLICAR FILTROS'), findsOneWidget);
    });
  }

  testWidgets('escala ampliada mantém filtros utilizáveis', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
      child: _app(
        SingleChildScrollView(
          child: ExecutiveFilters(
            filtros: const CioDashboardFilters(),
            regionais: const ['Regional Administrativa 1'],
            tiposAcao: const ['Oficina educativa de mobilidade segura'],
            statusDisponiveis: const ['concluido'],
            coordenadores: const ['Maria da Silva'],
            onAplicar: (_) {},
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('quatro indicadores respondem em celular e tablet',
      (tester) async {
    for (final largura in [320.0, 800.0]) {
      await tester.binding.setSurfaceSize(Size(largura, 1200));
      await tester.pumpWidget(_app(ExecutiveKpiGrid(
        larguraDisponivel: largura,
        totalAcoes: 20,
        totalPessoas: 1800,
        metasAtingidas: 16,
        profissionaisMobilizados: 45,
        comparacaoAcoes: 10,
        comparacaoPessoas: 900,
        comparacaoMetas: 8,
        comparacaoProfissionais: 40,
      )));
      expect(tester.takeException(), isNull);
      expect(find.text('Ações registradas'), findsOneWidget);
      expect(find.text('Profissionais mobilizados'), findsOneWidget);
    }
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}

Widget _app(Widget child) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: child),
    );
