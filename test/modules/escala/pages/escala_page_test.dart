import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/pages/escala_page.dart';

void main() {
  final data = DateTime(2026, 9, 17);
  final agora = DateTime(2026, 9, 17, 12);

  EscalaModel escala({String status = EscalaCodigos.statusPublicada}) {
    return EscalaModel(
      id: '2026-09-17',
      data: data,
      status: status,
      versao: 3,
      observacaoGeral: '',
      motivoRevisao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'gerente',
      atualizadoEm: agora,
      publicadoPor: status == EscalaCodigos.statusPublicada ? 'gerente' : '',
      publicadoEm: status == EscalaCodigos.statusPublicada ? agora : null,
    );
  }

  EscalaAtividadeModel atividade(
    String id,
    String titulo,
    String secao, {
    bool administrativa = false,
    bool participante = false,
    String raeId = '',
  }) {
    return EscalaAtividadeModel(
      id: id,
      escalaId: '2026-09-17',
      data: data,
      secaoId: secao,
      tipoAtividadeId: 'comando_educativo',
      naturezaAtividade: administrativa
          ? EscalaCodigos.naturezaAdministrativa
          : EscalaCodigos.naturezaEducativa,
      titulo: titulo,
      descricao: '',
      turnoId: 'manha',
      qtrHorario: '06:00',
      horaInicio: '06:00',
      horaFim: '12:00',
      qthLocal: 'Praça Central',
      qthEndereco: '',
      qthRegionalId: '',
      qthPontoReferencia: '',
      orientacaoOperacional: 'Orientação operacional',
      coordenadorMembroEquipeId: 'coord',
      coordenadorUsuarioId: 'uid-coord',
      coordenadorNomeSnapshot: 'Coordenação',
      participanteUsuarioIds:
          administrativa || participante ? const ['uid-atual'] : const [],
      geraRae: !administrativa,
      contabilizaProdutividade: true,
      raeId: raeId,
      execucaoMissaoId: '',
      status: EscalaCodigos.atividadePublicada,
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  EscalaAlocacaoModel alocacao(
    String id,
    String atividadeId,
    String usuarioId,
  ) {
    return EscalaAlocacaoModel(
      id: id,
      escalaId: '2026-09-17',
      atividadeId: atividadeId,
      data: data,
      membroEquipeId: 'membro-$usuarioId',
      usuarioId: usuarioId,
      nomeSnapshot: usuarioId == 'uid-atual' ? 'Agente Atual' : 'Agente Outro',
      vinculoSnapshot: 'agente',
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: '180H',
      funcaoNaAtividade: 'equipe',
      turnoId: 'manha',
      horaInicio: '06:00',
      horaFim: '12:00',
      tipoJornada: EscalaCodigos.jornadaNormal,
      horaInicioReal: '',
      horaFimReal: '',
      minutosPrevistos: 360,
      minutosRealizados: null,
      motivoJornadaComplementar: '',
      classificadoPor: '',
      classificadoEm: null,
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  EscalaIndisponibilidadeModel indisponibilidade() {
    return EscalaIndisponibilidadeModel(
      id: 'ferias',
      dataInicio: data,
      dataFim: data,
      membroEquipeId: 'membro-uid-outro',
      usuarioId: 'uid-outro',
      nomeSnapshot: 'Agente de Férias',
      tipoId: 'ferias',
      turnoId: '',
      horaInicio: '',
      horaFim: '',
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  EscalaDiaConsulta publicado() {
    return EscalaDiaConsulta(
      data: data,
      escala: escala(),
      atividades: [
        atividade('a1', 'Motociclista Seguro', 'comandos'),
        atividade('a2', 'Apoio GEDUC', 'apoio'),
      ],
      alocacoes: [
        alocacao('al1', 'a1', 'uid-atual'),
        alocacao('al2', 'a2', 'uid-outro'),
      ],
      indisponibilidades: [indisponibilidade()],
    );
  }

  Future<void> pumpPage(
    WidgetTester tester,
    EscalaDiaConsulta resultado, {
    bool minha = false,
    String perfilAcesso = '',
    _FakeRepository? repository,
    Future<void> Function(EscalaDiaConsulta dia)? onGerarPdf,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: EscalaPage(
          usuarioId: 'uid-atual',
          perfilAcesso: perfilAcesso,
          repository: repository ?? _FakeRepository(resultado),
          dataInicial: data,
          iniciarMinhaEscala: minha,
          onGerarPdf: onGerarPdf,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('consulta publicada exibe seções, QTR e QTH', (tester) async {
    await pumpPage(tester, publicado());

    expect(find.text('Escala GEDUC'), findsOneWidget);
    expect(find.text('COMANDOS E AÇÕES TEMÁTICAS'), findsOneWidget);
    expect(find.text('Motociclista Seguro'), findsOneWidget);
    expect(find.text('QTR: '), findsNothing);
    expect(find.textContaining('06:00–12:00'), findsWidgets);
    expect(find.textContaining('Praça Central'), findsWidgets);
    expect(find.text('COMPENSAÇÕES, FÉRIAS E FOLGAS'), findsOneWidget);
    expect(find.textContaining('Agente de Férias'), findsOneWidget);
  });

  testWidgets('Minha Escala reduz atividades para identidade atual', (
    tester,
  ) async {
    await pumpPage(tester, publicado());

    await tester.tap(find.text('Minha Escala'));
    await tester.pumpAndSettle();

    expect(find.text('Motociclista Seguro'), findsOneWidget);
    expect(find.text('Apoio GEDUC'), findsNothing);
    expect(find.textContaining('Agente de Férias'), findsNothing);
    expect(find.textContaining('Agente Atual'), findsOneWidget);
  });

  testWidgets('rascunho não expõe conteúdo operacional', (tester) async {
    await pumpPage(
      tester,
      EscalaDiaConsulta(
        data: data,
        escala: escala(status: EscalaCodigos.statusRascunho),
        atividades: [atividade('rascunho', 'Conteúdo privado', 'comandos')],
        alocacoes: const [],
        indisponibilidades: const [],
      ),
    );

    expect(find.byKey(const ValueKey('escala-nao-publicada')), findsOneWidget);
    expect(find.text('Conteúdo privado'), findsNothing);
  });

  testWidgets('dia sem escala apresenta estado vazio', (tester) async {
    await pumpPage(tester, EscalaDiaConsulta.vazia(data));

    expect(find.byKey(const ValueKey('escala-vazia')), findsOneWidget);
    expect(find.text('Nenhuma escala encontrada'), findsOneWidget);
  });

  testWidgets('missão publicada oferece entrada só ao executor elegível', (
    tester,
  ) async {
    final missao = atividade(
      'm1',
      'Apoio interno',
      'administrativo',
      administrativa: true,
    );
    final dia = EscalaDiaConsulta(
      data: data,
      escala: escala(),
      atividades: [missao],
      alocacoes: [alocacao('al1', 'm1', 'uid-atual')],
      indisponibilidades: const [],
    );

    await pumpPage(tester, dia, perfilAcesso: 'agente');
    expect(
      find.byKey(const ValueKey('abrir-missao-m1'), skipOffstage: false),
      findsOneWidget,
    );

    await pumpPage(tester, dia, perfilAcesso: 'administrador');
    expect(
      find.byKey(const ValueKey('abrir-missao-m1'), skipOffstage: false),
      findsNothing,
    );
  });

  testWidgets('atividade educativa oferece criar ou abrir RAE sem duplicar', (
    tester,
  ) async {
    final semVinculo = atividade(
      'e1',
      'Educação no Trânsito',
      'comandos',
      participante: true,
    );
    final comVinculo = atividade(
      'e2',
      'Escola Segura',
      'programas',
      participante: true,
      raeId: 'rae-existente',
    );
    final dia = EscalaDiaConsulta(
      data: data,
      escala: escala(),
      atividades: [semVinculo, comVinculo],
      alocacoes: [
        alocacao('al-e1', 'e1', 'uid-atual'),
        alocacao('al-e2', 'e2', 'uid-atual'),
      ],
      indisponibilidades: const [],
    );

    await pumpPage(tester, dia, perfilAcesso: 'agente');

    expect(
      find.byKey(const ValueKey('criar-rae-e1'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('abrir-rae-e2'), skipOffstage: false),
      findsOneWidget,
    );

    await pumpPage(tester, dia, perfilAcesso: 'administrador');
    expect(find.byKey(const ValueKey('criar-rae-e1')), findsNothing);
    expect(find.byKey(const ValueKey('abrir-rae-e2')), findsNothing);
  });

  testWidgets('jornadas de referência são explicitamente informativas', (
    tester,
  ) async {
    await pumpPage(tester, publicado());

    expect(find.text('Jornadas de referência'), findsOneWidget);
    expect(
      find.text(
        'Horários informativos. Não são usados como trava de validação.',
      ),
      findsOneWidget,
    );
    expect(find.text('180H • 06:00–11:52'), findsOneWidget);
    expect(find.text('240H • 18:00–23:58'), findsOneWidget);
  });

  testWidgets('PDF oficial usa a escala publicada completa', (tester) async {
    EscalaDiaConsulta? documentoRecebido;
    await pumpPage(
      tester,
      publicado(),
      minha: true,
      onGerarPdf: (dia) async => documentoRecebido = dia,
    );

    final botao = find.byKey(const ValueKey('escala-pdf-oficial'));
    expect(botao, findsOneWidget);
    await tester.tap(botao);
    await tester.pumpAndSettle();

    expect(documentoRecebido, isNotNull);
    expect(documentoRecebido!.publicada, isTrue);
    expect(documentoRecebido!.atividades, hasLength(2));
    expect(documentoRecebido!.alocacoes, hasLength(2));
  });

  testWidgets('PDF oficial não é exposto para rascunho', (tester) async {
    await pumpPage(
      tester,
      EscalaDiaConsulta(
        data: data,
        escala: escala(status: EscalaCodigos.statusRascunho),
        atividades: const [],
        alocacoes: const [],
        indisponibilidades: const [],
      ),
    );

    expect(find.byKey(const ValueKey('escala-pdf-oficial')), findsNothing);
  });

  testWidgets(
    'participante registra horas reais calculadas na própria alocação',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _FakeRepository(publicado());
      await pumpPage(
        tester,
        publicado(),
        perfilAcesso: 'agente',
        repository: repository,
      );

      final botao = find.byKey(const ValueKey('registrar-horas-al1'));
      expect(botao, findsOneWidget);
      await tester.ensureVisible(botao);
      await tester.pumpAndSettle();
      await tester.tap(botao);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('horas-inicio-real')),
        '06:15',
      );
      await tester.enterText(
        find.byKey(const ValueKey('horas-fim-real')),
        '10:45',
      );
      await tester.enterText(
        find.byKey(const ValueKey('horas-observacao')),
        'Execução confirmada.',
      );
      await tester.pump();
      expect(find.text('Duração calculada: 4h30'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('horas-confirmar')));
      await tester.pumpAndSettle();

      expect(repository.alocacaoSalva, 'al1');
      expect(repository.minutosSalvos, 270);
      expect(
        find.textContaining('06:15–10:45', findRichText: true),
        findsOneWidget,
      );
    },
  );
}

class _FakeRepository implements EscalaRepository {
  _FakeRepository(this.resultado);

  final EscalaDiaConsulta resultado;
  String? alocacaoSalva;
  int? minutosSalvos;

  @override
  Future<EscalaDiaConsulta> carregarDia(DateTime data) async => resultado;

  @override
  Future<EscalaPeriodoConsulta> carregarPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) {
    throw UnsupportedError('Consulta por período não usada neste teste.');
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
  }) async {
    alocacaoSalva = alocacaoId;
    minutosSalvos = minutosRealizados;
  }
}
