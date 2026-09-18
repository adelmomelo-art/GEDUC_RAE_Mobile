import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/controllers/escala_gestao_controller.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_gestao_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  final dia = DateTime(2026, 9, 17);
  final agora = DateTime(2026, 9, 17, 12);

  EscalaConfiguracaoModel configuracao() => EscalaConfiguracaoModel(
        id: 'principal',
        responsavelEscalaUsuarioId: 'responsavel',
        responsavelEscalaMembroEquipeId: 'membro-responsavel',
        ativo: true,
        designadoPor: 'gerente',
        designadoEm: agora,
      );

  EscalaModel escala({
    required String status,
    int versao = 1,
    String motivo = '',
    String origem = '',
    bool preparada = true,
    String criadoPor = 'responsavel',
  }) =>
      EscalaModel(
        id: versao == 1 ? '2026-09-17' : '2026-09-17-v$versao',
        data: dia,
        status: status,
        versao: versao,
        observacaoGeral: '',
        motivoRevisao: motivo,
        revisaoDeEscalaId: origem,
        revisaoPreparada: preparada,
        criadoPor: criadoPor,
        criadoEm: agora,
        atualizadoPor: criadoPor,
        atualizadoEm: agora,
        publicadoPor: status == EscalaCodigos.statusPublicada ? criadoPor : '',
        publicadoEm: status == EscalaCodigos.statusPublicada ? agora : null,
      );

  EscalaAtividadeModel atividade(String escalaId) => EscalaAtividadeModel(
        id: 'atividade-1',
        escalaId: escalaId,
        data: dia,
        secaoId: 'comandos_tematicos',
        tipoAtividadeId: 'comando',
        naturezaAtividade: EscalaCodigos.naturezaEducativa,
        titulo: 'Motociclista Seguro',
        descricao: '',
        turnoId: 'manha',
        qtrHorario: '06:00',
        horaInicio: '07:00',
        horaFim: '11:00',
        qthLocal: 'Praça Central',
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

  EscalaGestaoDados dados(EscalaModel item) => EscalaGestaoDados(
        dia: EscalaDiaConsulta(
          data: dia,
          escala: item,
          atividades: [atividade(item.id)],
          alocacoes: const [],
          indisponibilidades: const [],
        ),
        configuracao: configuracao(),
        membrosEquipe: const [],
        perfisOperacionais: const [],
      );

  test('responsavel publica rascunho estruturalmente valido', () async {
    final repo = _FakeD5Repository(
      dados(escala(status: EscalaCodigos.statusRascunho)),
    );

    final controller = EscalaGestaoController(
      repository: repo,
      usuarioId: 'responsavel',
      perfilAcesso: 'agente',
      dataInicial: dia,
      agora: () => agora,
    );

    await controller.carregar();

    expect(controller.podePublicarEscala, isTrue);
    await controller.publicarEscala();
    expect(repo.publicacoes, 1);
  });

  test('gerente inicia revisao versionada com motivo', () async {
    final repo = _FakeD5Repository(
      dados(escala(status: EscalaCodigos.statusPublicada)),
    );

    final controller = EscalaGestaoController(
      repository: repo,
      usuarioId: 'gerente',
      perfilAcesso: 'gerente',
      dataInicial: dia,
      agora: () => agora,
    );

    await controller.carregar();

    expect(controller.podeRevisarEscala, isTrue);
    await controller.iniciarRevisao('Mudança operacional');
    expect(repo.revisoes, 1);
    expect(repo.ultimoMotivo, 'Mudança operacional');
  });

  test('revisao sem motivo e recusada', () async {
    final repo = _FakeD5Repository(
      dados(escala(status: EscalaCodigos.statusPublicada)),
    );

    final controller = EscalaGestaoController(
      repository: repo,
      usuarioId: 'responsavel',
      perfilAcesso: 'agente',
      dataInicial: dia,
      agora: () => agora,
    );

    await controller.carregar();

    await expectLater(
      controller.iniciarRevisao('   '),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'revisao incompleta bloqueia edicao e publicacao e pode retomar',
    () async {
      final repo = _FakeD5Repository(
        dados(
          escala(
            status: EscalaCodigos.statusRascunho,
            versao: 2,
            motivo: 'Mudança',
            origem: '2026-09-17',
            preparada: false,
            criadoPor: 'gerente',
          ),
        ),
      );

      final controller = EscalaGestaoController(
        repository: repo,
        usuarioId: 'gerente',
        perfilAcesso: 'gerente',
        dataInicial: dia,
        agora: () => agora,
      );

      await controller.carregar();

      expect(controller.revisaoPreparacaoPendente, isTrue);
      expect(controller.podeEditarEscala, isFalse);
      expect(controller.podePublicarEscala, isFalse);

      await controller.retomarRevisao();
      expect(repo.revisoes, 1);
    },
  );
}

class _FakeD5Repository implements EscalaGestaoRepository {
  _FakeD5Repository(this.estado);

  EscalaGestaoDados estado;
  int publicacoes = 0;
  int revisoes = 0;
  String ultimoMotivo = '';

  @override
  Future<EscalaConfiguracaoModel?> carregarConfiguracao() async =>
      estado.configuracao;

  @override
  Future<EscalaGestaoDados> carregarGestao(DateTime data) async => estado;

  @override
  Future<void> criarRascunho(EscalaModel escala) async {}

  @override
  Future<void> salvarAtividadeComEquipe(
    EscalaAtividadePersistencia persistencia,
  ) async {}

  @override
  Future<void> publicarEscala({
    required EscalaModel escalaAtual,
    required String usuarioId,
    required DateTime agora,
  }) async {
    publicacoes++;
  }

  @override
  Future<void> prepararRevisao({
    required EscalaModel escalaAtual,
    required String motivo,
    required String usuarioId,
    required DateTime agora,
  }) async {
    revisoes++;
    ultimoMotivo = motivo;
  }

  @override
  String novoIdAtividade() => 'atividade';

  @override
  String novoIdAlocacao() => 'alocacao';
}
