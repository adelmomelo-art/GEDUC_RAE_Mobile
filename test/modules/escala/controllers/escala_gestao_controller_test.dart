import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/modules/escala/controllers/escala_gestao_controller.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_gestao_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  final dia = DateTime(2026, 9, 17);
  final agora = DateTime(2026, 9, 17, 12);

  MembroEquipeModel membro(
    String id,
    String uid, {
    bool podeCoordenar = false,
  }) =>
      MembroEquipeModel(
        id: id,
        usuarioId: uid,
        nome: id,
        vinculo: VinculoOperacional.agente,
        podeCoordenar: podeCoordenar,
        ativo: true,
        origem: 'usuario',
        createdAt: agora,
        updatedAt: agora,
      );

  EscalaPerfilOperacionalModel perfil(String membroId, String uid) =>
      EscalaPerfilOperacionalModel(
        id: 'perfil-$membroId',
        membroEquipeId: membroId,
        usuarioId: uid,
        setorCodigo: 'GEDUC',
        cargaHorariaCodigo: '180H',
        ativo: true,
        criadoPor: 'gerente',
        criadoEm: agora,
        atualizadoPor: 'gerente',
        atualizadoEm: agora,
      );

  EscalaConfiguracaoModel configuracao() => EscalaConfiguracaoModel(
        id: 'principal',
        responsavelEscalaUsuarioId: 'responsavel',
        responsavelEscalaMembroEquipeId: 'membro-responsavel',
        ativo: true,
        designadoPor: 'gerente',
        designadoEm: agora,
      );

  EscalaModel rascunho() => EscalaModel(
        id: '2026-09-17',
        data: dia,
        status: EscalaCodigos.statusRascunho,
        versao: 1,
        observacaoGeral: '',
        motivoRevisao: '',
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
        publicadoPor: '',
        publicadoEm: null,
      );

  EscalaAtividadeModel atividade(String id) => EscalaAtividadeModel(
        id: id,
        escalaId: '2026-09-17',
        data: dia,
        secaoId: 'comandos_tematicos',
        tipoAtividadeId: 'comando',
        naturezaAtividade: EscalaCodigos.naturezaEducativa,
        titulo: 'Atividade $id',
        descricao: '',
        turnoId: 'manha',
        qtrHorario: '06:00',
        horaInicio: '06:00',
        horaFim: '12:00',
        qthLocal: 'Local',
        qthEndereco: '',
        qthRegionalId: '',
        qthPontoReferencia: '',
        orientacaoOperacional: '',
        coordenadorMembroEquipeId: '',
        coordenadorUsuarioId: '',
        coordenadorNomeSnapshot: '',
        participanteUsuarioIds: const [],
        geraRae: true,
        contabilizaProdutividade: true,
        raeId: '',
        execucaoMissaoId: '',
        status: EscalaCodigos.atividadePlanejada,
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
      );

  EscalaAlocacaoModel alocacao({
    required String id,
    required String atividadeId,
    required String membroId,
    required String uid,
    String tipo = EscalaCodigos.jornadaNormal,
    String motivo = '',
    String classificadoPor = '',
  }) =>
      EscalaAlocacaoModel(
        id: id,
        escalaId: '2026-09-17',
        atividadeId: atividadeId,
        data: dia,
        membroEquipeId: membroId,
        usuarioId: uid,
        nomeSnapshot: membroId,
        vinculoSnapshot: 'agente',
        setorSnapshot: 'GEDUC',
        cargaHorariaSnapshot: '180H',
        funcaoNaAtividade: 'equipe',
        turnoId: 'manha',
        horaInicio: '06:00',
        horaFim: '12:00',
        tipoJornada: tipo,
        horaInicioReal: '',
        horaFimReal: '',
        minutosPrevistos: 360,
        minutosRealizados: null,
        motivoJornadaComplementar: motivo,
        classificadoPor: classificadoPor,
        classificadoEm: classificadoPor.isEmpty ? null : agora,
        observacao: '',
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
      );

  EscalaGestaoDados dados({
    EscalaModel? escala,
    List<EscalaAtividadeModel> atividades = const [],
    List<EscalaAlocacaoModel> alocacoes = const [],
  }) =>
      EscalaGestaoDados(
        dia: EscalaDiaConsulta(
          data: dia,
          escala: escala,
          atividades: atividades,
          alocacoes: alocacoes,
          indisponibilidades: const [],
        ),
        configuracao: configuracao(),
        membrosEquipe: [
          membro('membro-responsavel', 'responsavel'),
          membro('membro-a', 'uid-a'),
          membro('membro-b', 'uid-b', podeCoordenar: true),
        ],
        perfisOperacionais: [
          perfil('membro-responsavel', 'responsavel'),
          perfil('membro-a', 'uid-a'),
          perfil('membro-b', 'uid-b'),
        ],
      );

  EscalaAtividadeEntrada entrada({
    String? atividadeId,
    List<EscalaEquipeSelecao> equipe = const [],
  }) =>
      EscalaAtividadeEntrada(
        atividadeId: atividadeId,
        naturezaAtividade: EscalaCodigos.naturezaEducativa,
        secaoId: 'comandos_tematicos',
        tipoAtividadeId: 'comando',
        titulo: 'Motociclista Seguro',
        descricao: '',
        turnoId: 'tarde',
        qtrHorario: '12:00',
        horaInicio: '12:00',
        horaFim: '18:00',
        qthLocal: 'Local',
        qthEndereco: '',
        qthRegionalId: '',
        qthPontoReferencia: '',
        orientacaoOperacional: '',
        coordenadorMembroEquipeId: '',
        equipe: equipe,
      );

  test('somente agente responsavel cria nova escala', () async {
    final repoResponsavel = _FakeGestaoRepository(dados());
    final responsavel = EscalaGestaoController(
      repository: repoResponsavel,
      usuarioId: 'responsavel',
      perfilAcesso: 'agente',
      dataInicial: dia,
      agora: () => agora,
    );
    await responsavel.carregar();
    expect(responsavel.podeCriarEscala, isTrue);
    await responsavel.criarRascunho();
    expect(repoResponsavel.rascunhosCriados, 1);

    final gerente = EscalaGestaoController(
      repository: _FakeGestaoRepository(dados()),
      usuarioId: 'gerente',
      perfilAcesso: 'gerente',
      dataInicial: dia,
      agora: () => agora,
    );
    await gerente.carregar();
    expect(gerente.podeCriarEscala, isFalse);
  });

  test(
    'gerente edita rascunho mas nao classifica nova segunda jornada',
    () async {
      final base = dados(
        escala: rascunho(),
        atividades: [atividade('a1')],
        alocacoes: [
          alocacao(
            id: 'al-a1',
            atividadeId: 'a1',
            membroId: 'membro-a',
            uid: 'uid-a',
          ),
        ],
      );
      final gerente = EscalaGestaoController(
        repository: _FakeGestaoRepository(base),
        usuarioId: 'gerente',
        perfilAcesso: 'gerente',
        dataInicial: dia,
        agora: () => agora,
      );
      await gerente.carregar();
      expect(gerente.podeEditarEscala, isTrue);
      expect(gerente.podeClassificarJornada, isFalse);

      final preparacao = gerente.prepararAtividade(
        entrada(
          equipe: const [
            EscalaEquipeSelecao(
              membroEquipeId: 'membro-a',
              tipoJornada: EscalaCodigos.jornadaHoraExtra,
              motivoJornadaComplementar: 'Reforco',
            ),
          ],
        ),
      );
      expect(preparacao.valida, isFalse);
      expect(
        preparacao.bloqueios.join(' '),
        contains('Somente o agente responsável'),
      );
    },
  );

  test('primeira alocacao sem escolha assume normal', () async {
    final repo = _FakeGestaoRepository(dados(escala: rascunho()));
    final controller = EscalaGestaoController(
      repository: repo,
      usuarioId: 'responsavel',
      perfilAcesso: 'agente',
      dataInicial: dia,
      agora: () => agora,
    );
    await controller.carregar();
    await controller.salvarAtividade(
      entrada(equipe: const [EscalaEquipeSelecao(membroEquipeId: 'membro-a')]),
    );
    final persistencia = repo.ultimaPersistencia!;
    expect(
      persistencia.alocacoes.single.tipoJornada,
      EscalaCodigos.jornadaNormal,
    );
    expect(persistencia.atividade.participanteUsuarioIds, ['uid-a']);
  });

  test('segunda alocacao exige classificacao explicita', () async {
    final base = dados(
      escala: rascunho(),
      atividades: [atividade('a1')],
      alocacoes: [
        alocacao(
          id: 'al-a1',
          atividadeId: 'a1',
          membroId: 'membro-a',
          uid: 'uid-a',
        ),
      ],
    );
    final controller = EscalaGestaoController(
      repository: _FakeGestaoRepository(base),
      usuarioId: 'responsavel',
      perfilAcesso: 'agente',
      dataInicial: dia,
      agora: () => agora,
    );
    await controller.carregar();
    final preparacao = controller.prepararAtividade(
      entrada(equipe: const [EscalaEquipeSelecao(membroEquipeId: 'membro-a')]),
    );
    expect(preparacao.valida, isFalse);
    expect(
      preparacao.bloqueios.join(' '),
      contains('Classifique a nova jornada'),
    );
  });

  test('responsavel classifica hora extra com autoria e motivo', () async {
    final base = dados(
      escala: rascunho(),
      atividades: [atividade('a1')],
      alocacoes: [
        alocacao(
          id: 'al-a1',
          atividadeId: 'a1',
          membroId: 'membro-a',
          uid: 'uid-a',
        ),
      ],
    );
    final repo = _FakeGestaoRepository(base);
    final controller = EscalaGestaoController(
      repository: repo,
      usuarioId: 'responsavel',
      perfilAcesso: 'agente',
      dataInicial: dia,
      agora: () => agora,
    );
    await controller.carregar();
    await controller.salvarAtividade(
      entrada(
        equipe: const [
          EscalaEquipeSelecao(
            membroEquipeId: 'membro-a',
            tipoJornada: EscalaCodigos.jornadaHoraExtra,
            motivoJornadaComplementar: 'Reforco noturno',
          ),
        ],
      ),
    );
    final item = repo.ultimaPersistencia!.alocacoes.single;
    expect(item.tipoJornada, EscalaCodigos.jornadaHoraExtra);
    expect(item.motivoJornadaComplementar, 'Reforco noturno');
    expect(item.classificadoPor, 'responsavel');
    expect(item.classificadoEm, agora);
  });

  test('remocao de integrante vira delete da alocacao do rascunho', () async {
    final base = dados(
      escala: rascunho(),
      atividades: [atividade('a1')],
      alocacoes: [
        alocacao(
          id: 'al-a',
          atividadeId: 'a1',
          membroId: 'membro-a',
          uid: 'uid-a',
        ),
        alocacao(
          id: 'al-b',
          atividadeId: 'a1',
          membroId: 'membro-b',
          uid: 'uid-b',
        ),
      ],
    );
    final repo = _FakeGestaoRepository(base);
    final controller = EscalaGestaoController(
      repository: repo,
      usuarioId: 'responsavel',
      perfilAcesso: 'agente',
      dataInicial: dia,
      agora: () => agora,
    );
    await controller.carregar();
    await controller.salvarAtividade(
      entrada(
        atividadeId: 'a1',
        equipe: const [
          EscalaEquipeSelecao(
            membroEquipeId: 'membro-a',
            tipoJornada: EscalaCodigos.jornadaNormal,
          ),
        ],
      ),
    );
    expect(repo.ultimaPersistencia!.removerAlocacaoIds, {'al-b'});
  });
}

class _FakeGestaoRepository implements EscalaGestaoRepository {
  _FakeGestaoRepository(this.estado);

  EscalaGestaoDados estado;
  int rascunhosCriados = 0;
  int _atividade = 0;
  int _alocacao = 0;
  EscalaAtividadePersistencia? ultimaPersistencia;

  @override
  Future<EscalaConfiguracaoModel?> carregarConfiguracao() async =>
      estado.configuracao;

  @override
  Future<EscalaGestaoDados> carregarGestao(DateTime data) async => estado;

  @override
  Future<void> criarRascunho(EscalaModel escala) async {
    rascunhosCriados++;
    estado = EscalaGestaoDados(
      dia: EscalaDiaConsulta(
        data: estado.dia.data,
        escala: escala,
        atividades: estado.dia.atividades,
        alocacoes: estado.dia.alocacoes,
        indisponibilidades: estado.dia.indisponibilidades,
      ),
      configuracao: estado.configuracao,
      membrosEquipe: estado.membrosEquipe,
      perfisOperacionais: estado.perfisOperacionais,
    );
  }

  @override
  String novoIdAtividade() => 'atividade-${++_atividade}';

  @override
  String novoIdAlocacao() => 'alocacao-${++_alocacao}';

  @override
  Future<void> salvarAtividadeComEquipe(
    EscalaAtividadePersistencia persistencia,
  ) async {
    ultimaPersistencia = persistencia;
    final atividades = [
      ...estado.dia.atividades.where(
        (item) => item.id != persistencia.atividade.id,
      ),
      persistencia.atividade,
    ];
    final removidos = persistencia.removerAlocacaoIds;
    final novosIds = persistencia.alocacoes.map((item) => item.id).toSet();
    final alocacoes = [
      ...estado.dia.alocacoes.where(
        (item) => !removidos.contains(item.id) && !novosIds.contains(item.id),
      ),
      ...persistencia.alocacoes,
    ];
    estado = EscalaGestaoDados(
      dia: EscalaDiaConsulta(
        data: estado.dia.data,
        escala: estado.dia.escala,
        atividades: atividades,
        alocacoes: alocacoes,
        indisponibilidades: estado.dia.indisponibilidades,
      ),
      configuracao: estado.configuracao,
      membrosEquipe: estado.membrosEquipe,
      perfisOperacionais: estado.perfisOperacionais,
    );
  }
}
