import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/pages/escala_historico_page.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    required String perfil,
    _FakeRepository? repository,
    String membroEquipeId = '',
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: EscalaHistoricoPage(
          usuarioId: 'uid-agente',
          perfilAcesso: perfil,
          membroEquipeId: membroEquipeId,
          repository: repository ?? _FakeRepository(_periodo()),
          inicioInicial: DateTime(2026, 9, 1),
          fimInicial: DateTime(2026, 9, 30),
          agora: () => DateTime(2026, 9, 15),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'gestor consulta indicadores gerais e alterna para próprias horas',
    (tester) async {
      final repository = _FakeRepository(_periodo());
      await pumpPage(
        tester,
        perfil: 'gestor',
        repository: repository,
        membroEquipeId: 'membro-agente',
      );

      expect(find.text('Histórico de horas'), findsOneWidget);
      expect(find.byKey(const ValueKey('historico-escopo')), findsOneWidget);
      expect(find.text('Dias publicados'), findsOneWidget);
      expect(find.text('Horas realizadas'), findsOneWidget);
      expect(find.text('Hora extra'), findsOneWidget);
      expect(find.text('Crédito no banco'), findsOneWidget);
      expect(find.text('Compensado'), findsOneWidget);
      expect(find.text('Saldo do banco'), findsOneWidget);
      expect(find.text('Banco por pessoa'), findsOneWidget);
      expect(find.text('Agente Atual'), findsOneWidget);
      expect(find.text('Agente Outro'), findsOneWidget);
      expect(find.text('+1h30'), findsOneWidget);
      expect(repository.chamadas, 1);

      await tester.tap(find.text('Minhas horas'));
      await tester.pumpAndSettle();

      expect(find.text('Meu banco de horas'), findsOneWidget);
      expect(find.text('Agente Atual'), findsOneWidget);
      expect(find.text('Agente Outro'), findsNothing);
      expect(find.text('+1h'), findsWidgets);
      expect(repository.chamadas, 2);
    },
  );

  testWidgets('agente permanece restrito às próprias horas', (tester) async {
    await pumpPage(tester, perfil: 'agente', membroEquipeId: 'membro-agente');

    expect(find.byKey(const ValueKey('historico-escopo')), findsNothing);
    expect(find.text('Minhas horas'), findsOneWidget);
    expect(find.text('Meu banco de horas'), findsOneWidget);
    expect(find.text('Agente Atual'), findsOneWidget);
    expect(find.text('Agente Outro'), findsNothing);
    // Planejado e realizado totalizam 2h30 neste cenario.
    expect(find.text('2h30'), findsNWidgets(2));
  });

  testWidgets('período sem publicação apresenta estado vazio', (tester) async {
    await pumpPage(
      tester,
      perfil: 'gestor',
      repository: _FakeRepository(
        EscalaPeriodoConsulta(
          inicio: DateTime(2026, 9, 1),
          fim: DateTime(2026, 9, 30),
          dias: const [],
        ),
      ),
    );

    expect(find.byKey(const ValueKey('historico-vazio')), findsOneWidget);
    expect(find.text('Nenhuma escala publicada no período'), findsOneWidget);
  });

  testWidgets('falha de consulta oferece nova tentativa sem expor dados', (
    tester,
  ) async {
    final repository = _FakeRepository(_periodo(), falhar: true);
    await pumpPage(tester, perfil: 'gestor', repository: repository);

    expect(find.byKey(const ValueKey('historico-erro')), findsOneWidget);
    expect(find.text('Não foi possível carregar o histórico'), findsOneWidget);
    expect(find.text('Banco por pessoa'), findsNothing);

    repository.falhar = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('historico-erro')), findsNothing);
    expect(find.text('Banco por pessoa'), findsOneWidget);
  });
}

class _FakeRepository implements EscalaRepository {
  _FakeRepository(this.resultado, {this.falhar = false});

  final EscalaPeriodoConsulta resultado;
  bool falhar;
  int chamadas = 0;

  @override
  Future<EscalaPeriodoConsulta> carregarPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    chamadas++;
    if (falhar) throw StateError('falha controlada');
    return resultado;
  }

  @override
  Future<EscalaDiaConsulta> carregarDia(DateTime data) {
    throw UnsupportedError('Consulta diária não usada neste teste.');
  }

  @override
  Future<void> salvarHorasRealizadas({
    required String alocacaoId,
    required String usuarioId,
    required String horaInicioReal,
    required String horaFimReal,
    required int minutosRealizados,
    required String observacao,
    required DateTime atualizadoEm,
  }) {
    throw UnsupportedError('Gravação não usada neste teste.');
  }
}

EscalaPeriodoConsulta _periodo() {
  final data = DateTime(2026, 9, 10);
  return EscalaPeriodoConsulta(
    inicio: DateTime(2026, 9, 1),
    fim: DateTime(2026, 9, 30),
    dias: [
      EscalaDiaConsulta(
        data: data,
        escala: _escala(data),
        atividades: const [],
        alocacoes: [
          _alocacao(
            id: 'normal-agente',
            data: data,
            usuarioId: 'uid-agente',
            membroEquipeId: 'membro-agente',
            nome: 'Agente Atual',
            tipoJornada: EscalaCodigos.jornadaNormal,
            minutos: 60,
          ),
          _alocacao(
            id: 'banco-agente',
            data: data,
            usuarioId: 'uid-agente',
            membroEquipeId: 'membro-agente',
            nome: 'Agente Atual',
            tipoJornada: EscalaCodigos.jornadaBancoHoras,
            minutos: 90,
          ),
          _alocacao(
            id: 'extra-outro',
            data: data,
            usuarioId: 'uid-outro',
            membroEquipeId: 'membro-outro',
            nome: 'Agente Outro',
            tipoJornada: EscalaCodigos.jornadaHoraExtra,
            minutos: 120,
          ),
          _alocacao(
            id: 'banco-outro',
            data: data,
            usuarioId: 'uid-outro',
            membroEquipeId: 'membro-outro',
            nome: 'Agente Outro',
            tipoJornada: EscalaCodigos.jornadaBancoHoras,
            minutos: 30,
          ),
        ],
        indisponibilidades: [_compensacao(data)],
      ),
    ],
  );
}

EscalaModel _escala(DateTime data) {
  return EscalaModel(
    id: 'escala-publicada',
    data: data,
    status: EscalaCodigos.statusPublicada,
    versao: 2,
    observacaoGeral: '',
    motivoRevisao: '',
    criadoPor: 'responsavel',
    criadoEm: data,
    atualizadoPor: 'responsavel',
    atualizadoEm: data,
    publicadoPor: 'responsavel',
    publicadoEm: data,
  );
}

EscalaAlocacaoModel _alocacao({
  required String id,
  required DateTime data,
  required String usuarioId,
  required String membroEquipeId,
  required String nome,
  required String tipoJornada,
  required int minutos,
}) {
  final fim = switch (minutos) {
    30 => '08:30',
    60 => '09:00',
    90 => '09:30',
    _ => '10:00',
  };
  return EscalaAlocacaoModel(
    id: id,
    escalaId: 'escala-publicada',
    atividadeId: 'atividade-$id',
    data: data,
    membroEquipeId: membroEquipeId,
    usuarioId: usuarioId,
    nomeSnapshot: nome,
    vinculoSnapshot: 'agente',
    setorSnapshot: 'GEDUC',
    cargaHorariaSnapshot: '180H',
    funcaoNaAtividade: 'participante',
    turnoId: 'manha',
    horaInicio: '08:00',
    horaFim: fim,
    tipoJornada: tipoJornada,
    horaInicioReal: '08:00',
    horaFimReal: fim,
    minutosPrevistos: minutos,
    minutosRealizados: minutos,
    motivoJornadaComplementar: '',
    classificadoPor: '',
    classificadoEm: null,
    observacao: '',
    criadoPor: 'responsavel',
    criadoEm: data,
    atualizadoPor: 'responsavel',
    atualizadoEm: data,
  );
}

EscalaIndisponibilidadeModel _compensacao(DateTime data) {
  return EscalaIndisponibilidadeModel(
    id: 'compensacao-agente',
    dataInicio: data,
    dataFim: data,
    membroEquipeId: 'membro-agente',
    usuarioId: 'uid-agente',
    nomeSnapshot: 'Agente Atual',
    tipoId: 'compensacao',
    turnoId: 'manha',
    horaInicio: '10:00',
    horaFim: '10:30',
    observacao: '',
    criadoPor: 'responsavel',
    criadoEm: data,
    atualizadoPor: 'responsavel',
    atualizadoEm: data,
  );
}
