import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geduc_rae_mobile/modules/agenda/pages/agenda_page.dart';
import 'package:geduc_rae_mobile/modules/agenda/models/agenda_compromisso.dart';
import 'agenda_controller_test.dart' show AgendaFake;

class _AgendaComFalha extends AgendaFake {
  @override
  Future<void> cancelar(AgendaCompromisso item,
      {required String motivo, required String usuarioId}) async {
    throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Conteúdo privado que não deve aparecer');
  }
}

void main() {
  setUpAll(() async => initializeDateFormatting('pt_BR'));
  testWidgets('falha do Firestore mostra código sem expor conteúdo privado',
      (tester) async {
    final repo = _AgendaComFalha();
    await tester.pumpWidget(MaterialApp(
        home: AgendaPage(
            usuarioId: 'responsavel',
            perfilAcesso: 'agente',
            repository: repo,
            dataInicial: repo.data)));
    await tester.pumpAndSettle();
    final cancelar = find.text('Cancelar ação').first;
    await tester.ensureVisible(cancelar);
    await tester.pumpAndSettle();
    await tester.tap(cancelar);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('agenda-motivo-cancelamento')), 'Chuva');
    await tester.tap(find.text('Confirmar cancelamento'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Não foi possível concluir (permission-denied). Atualize a agenda e tente novamente.'),
        findsOneWidget);
    expect(find.textContaining('Conteúdo privado'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('calendário e cadastro funcionam em largura de celular',
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
            dataInicial: repo.data)));
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
  testWidgets('usuário não designado não recebe calendário nem cadastro',
      (tester) async {
    final repo = AgendaFake();
    await tester.pumpWidget(MaterialApp(
        home: AgendaPage(
            usuarioId: 'outro', perfilAcesso: 'gerente', repository: repo)));
    await tester.pumpAndSettle();
    expect(repo.leituras, 0);
    expect(find.byKey(const ValueKey('agenda-nova')), findsNothing);
    expect(find.text('Agenda restrita ao responsável ativo pela escala.'),
        findsOneWidget);
  });
  testWidgets('cancelamento exige motivo e desmonta o formulário sem erro',
      (tester) async {
    final repo = AgendaFake();
    await tester.pumpWidget(MaterialApp(
        home: AgendaPage(
            usuarioId: 'responsavel',
            perfilAcesso: 'agente',
            repository: repo,
            dataInicial: repo.data)));
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
        find.byKey(const ValueKey('agenda-motivo-cancelamento')), 'Chuva');
    await tester.tap(find.text('Confirmar cancelamento'));
    await tester.pumpAndSettle();
    expect(repo.cancelamentos, 1);
    expect(repo.ultimoMotivo, 'Chuva');
    expect(find.text('Cancelar compromisso'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
