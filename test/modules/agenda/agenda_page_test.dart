import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geduc_rae_mobile/modules/agenda/pages/agenda_page.dart';
import 'package:geduc_rae_mobile/modules/agenda/models/agenda_compromisso.dart';
import 'agenda_controller_test.dart' show AgendaFake;
import 'package:geduc_rae_mobile/modules/agenda/data/agenda_repository.dart';

class _AgendaComFalha extends AgendaFake {
  @override
  Future<void> cancelar(
    AgendaCompromisso item, {
    required String motivo,
    required String usuarioId,
  }) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'Conteúdo privado que não deve aparecer',
    );
  }
}

class _AgendaCalendarioFake extends AgendaFake {
  @override
  Future<AgendaMes> carregarMes(DateTime mes) async => AgendaMes(
        compromissos: [
          AgendaCompromisso(
            id: 'verde',
            data: DateTime(2026, 10, 12),
            titulo: 'Visita escolar',
            turno: 'manha',
          ),
          AgendaCompromisso(
            id: 'amarelo',
            data: DateTime(2026, 10, 6),
            titulo: 'Palestra',
            turno: 'manha',
          ),
          AgendaCompromisso(
            id: 'vermelho',
            data: DateTime(2026, 10, 6),
            titulo: 'Palestra',
            turno: 'tarde',
            situacao: 'cancelada',
            motivo: 'Chuva',
          ),
          AgendaCompromisso(
            id: 'extra',
            data: DateTime(2026, 10, 6),
            titulo: 'Terceira ação',
            turno: 'noite',
          ),
        ],
        escalas: {},
        atividades: {},
      );
}

void main() {
  setUpAll(() async => initializeDateFormatting('pt_BR'));
  testWidgets('nomes com cores próprias abrem o cartão correto em outro dia', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: AgendaPage(
          usuarioId: 'responsavel',
          perfilAcesso: 'agente',
          repository: _AgendaCalendarioFake(),
          dataInicial: DateTime(2026, 10, 5),
          agora: () => DateTime(2026, 10, 6, 23, 59),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Color? fundo(String id) => tester
        .widget<TextButton>(find.byKey(ValueKey('agenda-link-$id')))
        .style!
        .backgroundColor!
        .resolve({});
    expect(fundo('verde'), const Color(0xFFE8F5E9));
    expect(fundo('amarelo'), const Color(0xFFFFF8E1));
    expect(fundo('vermelho'), const Color(0xFFFFEBEE));
    expect(find.byKey(const ValueKey('agenda-item-vermelho')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('agenda-link-vermelho')));
    await tester.pumpAndSettle();
    final card = tester.widget<Card>(
      find.byKey(const ValueKey('agenda-item-vermelho')),
    );
    expect((card.shape! as RoundedRectangleBorder).side.width, 2);
    final outro = tester.widget<Card>(
      find.byKey(const ValueKey('agenda-item-amarelo')),
    );
    expect(outro.shape, isNull);
    expect(find.text('Motivo: Chuva'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'mais ações alcança cartão adicional no celular com fonte ampliada',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: AgendaPage(
            usuarioId: 'responsavel',
            perfilAcesso: 'agente',
            repository: _AgendaCalendarioFake(),
            dataInicial: DateTime(2026, 10, 5),
            agora: () => DateTime(2026, 10, 6),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final mais = find.byKey(const ValueKey('agenda-mais-6'));
      await tester.ensureVisible(mais);
      await tester.pumpAndSettle();
      await tester.tap(mais);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('agenda-item-extra')), findsOneWidget);
      final card = tester.widget<Card>(
        find.byKey(const ValueKey('agenda-item-extra')),
      );
      expect((card.shape! as RoundedRectangleBorder).side.width, 2);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
      'celular mostra todas as colunas e domingo sem rolagem horizontal',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = AgendaFake();
    await tester.pumpWidget(MaterialApp(
        home: AgendaPage(
      usuarioId: 'responsavel',
      perfilAcesso: 'agente',
      repository: repo,
      dataInicial: DateTime(2026, 11, 1),
      agora: () => DateTime(2026, 11, 1),
    )));
    await tester.pumpAndSettle();
    final calendario = find.byKey(const ValueKey('agenda-calendario-mes'));
    for (final dia in ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']) {
      final cabecalho =
          find.descendant(of: calendario, matching: find.text(dia));
      final retangulo = tester.getRect(cabecalho);
      expect(retangulo.left, greaterThanOrEqualTo(0));
      expect(retangulo.right, lessThanOrEqualTo(390));
    }
    final domingo = find.byKey(const ValueKey('agenda-dia-1'));
    final retangulo = tester.getRect(domingo);
    expect(retangulo.right, lessThanOrEqualTo(390));
    expect(retangulo.left, greaterThan(300));
    expect(
        find.descendant(
            of: calendario, matching: find.byType(SingleChildScrollView)),
        findsNothing);
    await tester.tap(domingo);
    await tester.pumpAndSettle();
    expect(find.text('01/11/2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('falha do Firestore mostra código sem expor conteúdo privado', (
    tester,
  ) async {
    final repo = _AgendaComFalha();
    await tester.pumpWidget(
      MaterialApp(
        home: AgendaPage(
          usuarioId: 'responsavel',
          perfilAcesso: 'agente',
          repository: repo,
          dataInicial: repo.data,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final cancelar = find.text('Cancelar ação').first;
    await tester.ensureVisible(cancelar);
    await tester.pumpAndSettle();
    await tester.tap(cancelar);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('agenda-motivo-cancelamento')),
      'Chuva',
    );
    await tester.tap(find.text('Confirmar cancelamento'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Não foi possível concluir (permission-denied). Atualize a agenda e tente novamente.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Conteúdo privado'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('calendário e cadastro funcionam em largura de celular', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = AgendaFake();
    await tester.pumpWidget(
      MaterialApp(
        home: AgendaPage(
          usuarioId: 'responsavel',
          perfilAcesso: 'agente',
          repository: repo,
          dataInicial: repo.data,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('outubro 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('agenda-nova')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('agenda-nova')));
    await tester.pumpAndSettle();
    expect(find.text('Agendar ação'), findsWidgets);
    final titulo = find.byKey(const ValueKey('agenda-titulo'));
    await tester.ensureVisible(titulo);
    await tester.pumpAndSettle();
    await tester.enterText(titulo, 'Nova palestra');
    await tester.tap(find.byKey(const ValueKey('agenda-salvar')));
    await tester.pumpAndSettle();
    expect(repo.escritas, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('usuário não designado não recebe calendário nem cadastro', (
    tester,
  ) async {
    final repo = AgendaFake();
    await tester.pumpWidget(
      MaterialApp(
        home: AgendaPage(
          usuarioId: 'outro',
          perfilAcesso: 'gerente',
          repository: repo,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.leituras, 0);
    expect(find.byKey(const ValueKey('agenda-nova')), findsNothing);
    expect(
      find.text('Agenda restrita ao responsável ativo pela escala.'),
      findsOneWidget,
    );
  });
  testWidgets('cancelamento exige motivo e desmonta o formulário sem erro', (
    tester,
  ) async {
    final repo = AgendaFake();
    await tester.pumpWidget(
      MaterialApp(
        home: AgendaPage(
          usuarioId: 'responsavel',
          perfilAcesso: 'agente',
          repository: repo,
          dataInicial: repo.data,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final cancelar = find.text('Cancelar ação').first;
    await tester.ensureVisible(cancelar);
    await tester.pumpAndSettle();
    await tester.tap(cancelar);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar cancelamento'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o motivo'), findsOneWidget);
    expect(repo.cancelamentos, 0);
    await tester.enterText(
      find.byKey(const ValueKey('agenda-motivo-cancelamento')),
      'Chuva',
    );
    await tester.tap(find.text('Confirmar cancelamento'));
    await tester.pumpAndSettle();
    expect(repo.cancelamentos, 1);
    expect(repo.ultimoMotivo, 'Chuva');
    expect(find.text('Cancelar compromisso'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
