import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/home/domain/alert_level.dart';
import 'package:geduc_rae_mobile/modules/home/domain/operational_alert.dart';
import 'package:geduc_rae_mobile/modules/home/models/home_operational_status.dart';
import 'package:geduc_rae_mobile/modules/home/models/home_state.dart';
import 'package:geduc_rae_mobile/modules/home/theme/home_visual_tokens.dart';
import 'package:geduc_rae_mobile/modules/home/widgets/centro_operacoes_header.dart';
import 'package:geduc_rae_mobile/modules/home/widgets/indicadores_widget.dart';
import 'package:geduc_rae_mobile/modules/home/widgets/status_widget.dart';
import 'package:geduc_rae_mobile/modules/home/widgets/ultimos_raes_widget.dart';

void main() {
  const headerTitle = 'Centro de Operações Educativas';
  const headerSubtitle = 'Plataforma Fênix • GEDUC';

  test('paleta cromática R3 corresponde ao layout aprovado', () {
    expect(HomeVisualTokens.headerOrangeStart, const Color(0xFFF24A0D));
    expect(HomeVisualTokens.headerOrangeEnd, const Color(0xFFE33F0D));
    expect(HomeVisualTokens.orange, const Color(0xFFC83A0F));
    expect(HomeVisualTokens.teal, const Color(0xFF007C72));
    expect(HomeVisualTokens.blue, const Color(0xFF0B88C9));
    expect(HomeVisualTokens.navy, const Color(0xFF153E5A));
    expect(HomeVisualTokens.faixitaSurface, const Color(0xFFFFEEDC));
  });

  for (final scenario in <({Size size, double textScale})>[
    (size: const Size(320, 800), textScale: 1),
    (size: const Size(360, 800), textScale: 1.3),
    (size: const Size(412, 915), textScale: 1.3),
    (size: const Size(800, 1280), textScale: 1.3),
  ]) {
    testWidgets(
      'cabeçalho preserva textos em ${scenario.size.width.toInt()} px '
      'com escala ${scenario.textScale}',
      (tester) async {
        await tester.pumpWidget(
          _testApp(
            size: scenario.size,
            textScale: scenario.textScale,
            child: CentroOperacoesHeader(
              usuario: null,
              onAtualizar: () {},
              onSair: () {},
            ),
          ),
        );

        expect(find.text(headerTitle), findsOneWidget);
        expect(find.text(headerSubtitle), findsOneWidget);
        expect(find.text('Bem-vindo, usuário.'), findsOneWidget);
        expect(_didExceedMaxLines(tester, headerTitle), isFalse);
        expect(_didExceedMaxLines(tester, headerSubtitle), isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('cabeçalho compacto mantém ações acessíveis e funcionais',
      (tester) async {
    var refreshCount = 0;
    var logoutCount = 0;

    await tester.pumpWidget(
      _testApp(
        size: const Size(320, 800),
        textScale: 1.3,
        child: CentroOperacoesHeader(
          usuario: null,
          onAtualizar: () => refreshCount++,
          onSair: () => logoutCount++,
        ),
      ),
    );

    final refresh = find.byTooltip('Atualizar informações');
    final logout = find.byTooltip('Sair da plataforma');
    expect(refresh, findsOneWidget);
    expect(logout, findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 48 && widget.height == 48,
      ),
      findsNWidgets(2),
    );

    await tester.tap(refresh);
    await tester.tap(logout);
    await tester.pump();

    expect(refreshCount, 1);
    expect(logoutCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cabeçalho alterna entre composição compacta e ampla',
      (tester) async {
    await tester.pumpWidget(
      _testApp(
        size: const Size(412, 915),
        child: CentroOperacoesHeader(
          usuario: null,
          onAtualizar: () {},
          onSair: () {},
        ),
      ),
    );

    final compactTitle = tester.getRect(find.text(headerTitle));
    final compactRefresh = tester.getRect(find.byIcon(Icons.refresh_rounded));
    expect(compactTitle.top, greaterThan(compactRefresh.bottom));

    await tester.pumpWidget(
      _testApp(
        size: const Size(800, 1280),
        child: CentroOperacoesHeader(
          usuario: null,
          onAtualizar: () {},
          onSair: () {},
        ),
      ),
    );

    final wideTitle = tester.getRect(find.text(headerTitle));
    final wideRefresh = tester.getRect(find.byIcon(Icons.refresh_rounded));
    expect(wideTitle.top, lessThan(wideRefresh.bottom));
    expect(wideTitle.left, lessThan(wideRefresh.left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('indicadores não apresentam overflow em 360 px', (tester) async {
    await tester.pumpWidget(
      _testApp(
        size: const Size(360, 800),
        child: const IndicadoresWidget(
          totalAcoes: 23,
          totalPessoas: 1747,
          totalVeiculos: 1265,
          totalCredenciais: 30,
        ),
      ),
    );

    expect(find.text('Ações'), findsOneWidget);
    expect(find.text('1.747'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet apresenta os quatro indicadores na mesma linha',
      (tester) async {
    await tester.pumpWidget(
      _testApp(
        size: const Size(800, 1280),
        child: const IndicadoresWidget(
          totalAcoes: 1,
          totalPessoas: 2,
          totalVeiculos: 3,
          totalCredenciais: 4,
        ),
      ),
    );

    final labels = ['Ações', 'Pessoas', 'Veículos', 'Credenciais'];
    final verticalPositions =
        labels.map((label) => tester.getTopLeft(find.text(label)).dy).toSet();
    expect(verticalPositions, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('lista compacta apresenta um, dois e três RAEs sem grade vazia',
      (tester) async {
    for (var count = 1; count <= 3; count++) {
      final actions = List.generate(count, _action);
      await tester.pumpWidget(
        _testApp(
          child: UltimosRaesWidget(
            acoes: actions,
            onAbrirRae: (_) {},
          ),
        ),
      );

      for (final action in actions) {
        expect(find.text('RAE ${action.numeroRAE}'), findsOneWidget);
      }

      final positions = actions
          .map(
            (action) => tester.getTopLeft(
              find.text('RAE ${action.numeroRAE}'),
            ),
          )
          .toList(growable: false);

      expect(
        positions.map((position) => position.dx).toSet(),
        hasLength(1),
        reason: 'Os RAEs devem permanecer alinhados em uma lista vertical.',
      );
      expect(
        positions.map((position) => position.dy).toSet(),
        hasLength(count),
        reason: 'Cada RAE deve ocupar sua própria linha compacta.',
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('toque em RAE devolve exatamente o objeto exibido',
      (tester) async {
    final action = _action(0);
    AcaoModel? opened;
    await tester.pumpWidget(
      _testApp(
        child: UltimosRaesWidget(
          acoes: [action],
          onAbrirRae: (value) => opened = value,
        ),
      ),
    );

    await tester.tap(find.text('RAE ${action.numeroRAE}'));
    await tester.pump();
    expect(identical(opened, action), isTrue);
  });

  testWidgets('estado sem RAE apresenta mensagem apropriada', (tester) async {
    await tester.pumpWidget(
      _testApp(
        child: UltimosRaesWidget(
          acoes: const [],
          onAbrirRae: (_) {},
        ),
      ),
    );

    expect(find.text('Nenhum RAE cadastrado.'), findsOneWidget);
  });

  testWidgets('monitoramento saudável apresenta resumo compacto',
      (tester) async {
    const state = HomeState(
      status: HomeStatus.online,
      monitoramentoOperacional: HomeOperationalStatus(
        conectado: true,
        monitoramentoAtivo: true,
      ),
    );
    await tester
        .pumpWidget(_testApp(child: const StatusWidget(homeState: state)));

    expect(find.text('Sistema operacional'), findsOneWidget);
    expect(find.text('Tudo funcionando normalmente.'), findsOneWidget);
    expect(find.text('Conectividade'), findsNothing);
  });

  testWidgets('alerta operacional permanece visível com detalhes recolhidos',
      (tester) async {
    final state = HomeState(
      status: HomeStatus.online,
      alertasOperacionais: [
        OperationalAlert(
          id: 'pending-sync',
          level: AlertLevel.warning,
          title: 'Envio pendente',
          message: 'Há um registro aguardando sincronização.',
          recommendation: 'Conecte o dispositivo e atualize a Home.',
          createdAt: DateTime(2026, 8, 3),
        ),
      ],
    );
    await tester.pumpWidget(_testApp(child: StatusWidget(homeState: state)));

    expect(find.text('Envio pendente'), findsOneWidget);
    expect(find.textContaining('Há um registro'), findsOneWidget);
    expect(find.text('Conectividade'), findsNothing);
  });

  testWidgets('escala de texto 1,3 não provoca erro de layout', (tester) async {
    await tester.pumpWidget(
      _testApp(
        size: const Size(360, 800),
        textScale: 1.3,
        child: UltimosRaesWidget(
          acoes: [_action(1), _action(2), _action(3)],
          onAbrirRae: (_) {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

bool _didExceedMaxLines(WidgetTester tester, String text) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
  return paragraph.didExceedMaxLines;
}

Widget _testApp({
  required Widget child,
  Size size = const Size(800, 1280),
  double textScale = 1,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: size.width, child: child),
        ),
      ),
    ),
  );
}

AcaoModel _action(int index) {
  final number = (index + 14).toString().padLeft(4, '0');
  return AcaoModel(
    id: 'action-$index',
    numeroRAE: '$number/2026',
    anoRAE: 2026,
    dataAcao: DateTime(2026, 8, 3),
    turno: 'Manhã',
    nomeAcao: 'Ação educativa ${index + 1}',
    tipoAcao: 'Abordagem',
    publicoEstimado: 50,
    publicoMinimo: 20,
    horaInicio: '08:00',
    pessoasAlcancadas: 42,
    veiculosAbordados: 18,
    credenciaisEmitidas: 2,
    metaAtingida: true,
    endereco: 'Avenida Central',
    bairro: 'Itaperi',
    regional: 'SER 09',
    latitude: -3.75,
    longitude: -38.52,
    coordenadorId: 'coordinator-1',
    coordenadorNome: 'Equipe GEDUC',
    status: 'Sincronizado',
    sincronizado: true,
  );
}
