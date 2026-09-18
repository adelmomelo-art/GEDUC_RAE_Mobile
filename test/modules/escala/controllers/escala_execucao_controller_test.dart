import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/modules/escala/controllers/escala_execucao_controller.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_execucao_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  final dia = DateTime.utc(2026, 9, 18);
  final instanteInicial = DateTime.utc(2026, 9, 18, 12);

  EscalaModel escala({String status = EscalaCodigos.statusPublicada}) {
    return EscalaModel(
      id: 'escala-publicada',
      data: dia,
      status: status,
      versao: 1,
      observacaoGeral: '',
      motivoRevisao: '',
      criadoPor: 'responsavel',
      criadoEm: instanteInicial,
      atualizadoPor: 'responsavel',
      atualizadoEm: instanteInicial,
      publicadoPor: 'responsavel',
      publicadoEm: instanteInicial,
    );
  }

  EscalaAtividadeModel atividade({
    String natureza = EscalaCodigos.naturezaAdministrativa,
    bool geraRae = false,
    List<String> participantes = const ['agente'],
    String coordenadorUid = 'coordenador',
  }) {
    return EscalaAtividadeModel(
      id: 'atividade-admin',
      escalaId: 'escala-publicada',
      data: dia,
      secaoId: 'apoio',
      tipoAtividadeId: 'missao',
      naturezaAtividade: natureza,
      titulo: 'Apoio GEDUC',
      descricao: 'Missão administrativa',
      turnoId: 'tarde',
      qtrHorario: '12:00',
      horaInicio: '12:00',
      horaFim: '18:00',
      qthLocal: 'GEDUC',
      qthEndereco: '',
      qthRegionalId: '',
      qthPontoReferencia: '',
      orientacaoOperacional: '',
      coordenadorMembroEquipeId: 'membro-coordenador',
      coordenadorUsuarioId: coordenadorUid,
      coordenadorNomeSnapshot: 'Coordenador',
      participanteUsuarioIds: participantes,
      geraRae: geraRae,
      contabilizaProdutividade: true,
      raeId: '',
      execucaoMissaoId: '',
      status: EscalaCodigos.atividadePublicada,
      criadoPor: 'responsavel',
      criadoEm: instanteInicial,
      atualizadoPor: 'responsavel',
      atualizadoEm: instanteInicial,
    );
  }

  MembroEquipeModel membro(String uid) {
    return MembroEquipeModel(
      id: 'membro-$uid',
      usuarioId: uid,
      nome: uid == 'agente' ? 'Agente A' : 'Coordenador A',
      vinculo: VinculoOperacional.agente,
      podeCoordenar: uid == 'coordenador',
      ativo: true,
      origem: 'usuario',
      createdAt: instanteInicial,
      updatedAt: instanteInicial,
    );
  }

  EscalaAlocacaoModel alocacao(String uid) {
    return EscalaAlocacaoModel(
      id: 'alocacao-$uid',
      escalaId: 'escala-publicada',
      atividadeId: 'atividade-admin',
      data: dia,
      membroEquipeId: 'membro-$uid',
      usuarioId: uid,
      nomeSnapshot: uid,
      vinculoSnapshot: 'agente',
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: '180H',
      funcaoNaAtividade: 'execucao',
      turnoId: 'tarde',
      horaInicio: '12:00',
      horaFim: '18:00',
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
      criadoEm: instanteInicial,
      atualizadoPor: 'responsavel',
      atualizadoEm: instanteInicial,
    );
  }

  EscalaExecucaoContexto contexto({
    String uid = 'agente',
    EscalaModel? escalaValor,
    EscalaAtividadeModel? atividadeValor,
    ExecucaoMissaoModel? execucao,
  }) {
    return EscalaExecucaoContexto(
      atividade: atividadeValor ?? atividade(),
      escala: escalaValor ?? escala(),
      equipe: [alocacao('agente')],
      executor: membro(uid),
      execucao: execucao,
    );
  }

  EscalaExecucaoController controller(
    _FakeExecucaoRepository repo, {
    String uid = 'agente',
    String perfil = 'agente',
  }) {
    var tick = 0;
    return EscalaExecucaoController(
      repository: repo,
      atividadeId: 'atividade-admin',
      usuarioId: uid,
      perfilAcesso: perfil,
      agora: () => instanteInicial.add(Duration(minutes: tick++)),
      novoIdEvidencia: (_, sequencia) => 'ev-$sequencia',
    );
  }

  group('EscalaExecucaoController ESC-001E.2', () {
    test('carrega participante elegível e equipe', () async {
      final repo = _FakeExecucaoRepository(contexto());
      final ctrl = controller(repo);

      await ctrl.carregar();

      expect(ctrl.erro, isNull);
      expect(ctrl.podeExecutar, isTrue);
      expect(ctrl.ehParticipante, isTrue);
      expect(ctrl.ehCoordenador, isFalse);
      expect(ctrl.equipe, hasLength(1));
    });

    test('inicia execução uma única vez com identidade canônica', () async {
      final repo = _FakeExecucaoRepository(contexto());
      final ctrl = controller(repo);

      await ctrl.carregar();
      await ctrl.iniciar();
      await ctrl.iniciar();

      expect(repo.inicios, 1);
      expect(ctrl.execucao!.id, 'exec-atividade-admin-agente');
      expect(ctrl.execucao!.status, EscalaCodigos.execucaoEmExecucao);
      expect(ctrl.execucao!.executadoPorUsuarioId, 'agente');
      expect(ctrl.execucao!.executadoPorMembroEquipeId, 'membro-agente');
      expect(ctrl.execucao!.executadoPorNomeSnapshot, 'Agente A');
    });

    test('salva resultado e observação enquanto em execução', () async {
      final repo = _FakeExecucaoRepository(contexto());
      final ctrl = controller(repo);

      await ctrl.carregar();
      await ctrl.iniciar();
      await ctrl.salvarResultadoObservacao(
        resultadoResumo: 'Parcial',
        observacao: 'Em andamento',
      );

      expect(repo.atualizacoes, 1);
      expect(ctrl.execucao!.resultadoResumo, 'Parcial');
      expect(ctrl.execucao!.observacao, 'Em andamento');
      expect(ctrl.execucao!.status, EscalaCodigos.execucaoEmExecucao);
    });

    test('adiciona e remove metadado de evidência', () async {
      final repo = _FakeExecucaoRepository(contexto());
      final ctrl = controller(repo);

      await ctrl.carregar();
      await ctrl.iniciar();

      await ctrl.adicionarEvidencia(
        tipo: EscalaCodigos.evidenciaDocumento,
        descricao: 'Relatório',
        referencia: 'ref-1',
      );

      expect(ctrl.execucao!.evidencias, hasLength(1));
      expect(ctrl.execucao!.evidencias.single.id, 'ev-1');
      expect(ctrl.execucao!.evidencias.single.criadoPor, 'agente');

      await ctrl.removerEvidencia('ev-1');
      expect(ctrl.execucao!.evidencias, isEmpty);
    });

    test('conclui com resultado e bloqueia alteração terminal', () async {
      final repo = _FakeExecucaoRepository(contexto());
      final ctrl = controller(repo);

      await ctrl.carregar();
      await ctrl.iniciar();
      await ctrl.concluir(
        resultadoResumo: 'Entrega finalizada',
        observacao: 'Sem intercorrências',
      );

      expect(ctrl.execucao!.status, EscalaCodigos.execucaoConcluida);
      expect(ctrl.execucao!.concluidoEm, isNotNull);
      expect(ctrl.terminal, isTrue);

      await expectLater(
        ctrl.salvarResultadoObservacao(
          resultadoResumo: 'Tentativa',
          observacao: '',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('cancelamento é terminal', () async {
      final repo = _FakeExecucaoRepository(contexto());
      final ctrl = controller(repo);

      await ctrl.carregar();
      await ctrl.iniciar();
      await ctrl.cancelar(observacao: 'Operação suspensa');

      expect(ctrl.execucao!.status, EscalaCodigos.execucaoCancelada);
      expect(ctrl.terminal, isTrue);
      expect(ctrl.execucao!.concluidoEm, isNull);
    });

    test('coordenador autorizado executa mesmo sem ser participante', () async {
      final repo = _FakeExecucaoRepository(
        contexto(
          uid: 'coordenador',
          atividadeValor: atividade(participantes: const ['agente']),
        ),
      );
      final ctrl = controller(
        repo,
        uid: 'coordenador',
        perfil: 'coordenador',
      );

      await ctrl.carregar();

      expect(ctrl.ehParticipante, isFalse);
      expect(ctrl.ehCoordenador, isTrue);
      expect(ctrl.podeExecutar, isTrue);

      await ctrl.iniciar();
      expect(repo.inicios, 1);
    });

    test('não participante não inicia missão', () async {
      final repo = _FakeExecucaoRepository(
        contexto(
          uid: 'outro',
          atividadeValor: atividade(
            participantes: const ['agente'],
            coordenadorUid: 'coordenador',
          ),
        ),
      );
      final ctrl = controller(repo, uid: 'outro');

      await ctrl.carregar();

      expect(ctrl.podeExecutar, isFalse);
      await expectLater(ctrl.iniciar(), throwsA(isA<StateError>()));
      expect(repo.inicios, 0);
    });

    test('atividade educativa não entra no fluxo administrativo', () async {
      final repo = _FakeExecucaoRepository(
        contexto(
          atividadeValor: atividade(
            natureza: EscalaCodigos.naturezaEducativa,
            geraRae: true,
          ),
        ),
      );
      final ctrl = controller(repo);

      await ctrl.carregar();

      expect(ctrl.podeExecutar, isFalse);
      await expectLater(ctrl.iniciar(), throwsA(isA<StateError>()));
    });
  });
}

class _FakeExecucaoRepository implements EscalaExecucaoRepository {
  _FakeExecucaoRepository(this.estado);

  EscalaExecucaoContexto estado;
  int inicios = 0;
  int atualizacoes = 0;

  @override
  String idExecucao({
    required String atividadeId,
    required String usuarioId,
  }) =>
      'exec-$atividadeId-$usuarioId';

  @override
  Future<EscalaExecucaoContexto> carregarContexto({
    required String atividadeId,
    required String usuarioId,
  }) async =>
      estado;

  @override
  Future<ExecucaoMissaoModel> iniciarExecucao(
    ExecucaoMissaoModel execucao,
  ) async {
    inicios++;
    final existente = estado.execucao;
    if (existente != null) return existente;
    estado = estado.comExecucao(execucao);
    return execucao;
  }

  @override
  Future<void> atualizarExecucao(
    ExecucaoMissaoModel execucao,
  ) async {
    atualizacoes++;
    estado = estado.comExecucao(execucao);
  }
}
