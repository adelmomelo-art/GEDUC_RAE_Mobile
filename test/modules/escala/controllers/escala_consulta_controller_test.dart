import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/controllers/escala_consulta_controller.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  final data = DateTime(2026, 9, 17);
  final agora = DateTime(2026, 9, 17, 12);

  EscalaModel escala({String status = EscalaCodigos.statusPublicada}) {
    return EscalaModel(
      id: '2026-09-17',
      data: data,
      status: status,
      versao: 2,
      observacaoGeral: '',
      motivoRevisao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
      publicadoPor: status == EscalaCodigos.statusPublicada ? 'gerente' : '',
      publicadoEm: status == EscalaCodigos.statusPublicada ? agora : null,
    );
  }

  EscalaAtividadeModel atividade({
    required String id,
    required String titulo,
    required String secao,
    String coordenadorUsuarioId = '',
    List<String> participantes = const [],
  }) {
    return EscalaAtividadeModel(
      id: id,
      escalaId: '2026-09-17',
      data: data,
      secaoId: secao,
      tipoAtividadeId: 'tipo',
      naturezaAtividade: EscalaCodigos.naturezaEducativa,
      titulo: titulo,
      descricao: '',
      turnoId: 'manha',
      qtrHorario: '06:00',
      horaInicio: '06:00',
      horaFim: '12:00',
      qthLocal: 'Fortaleza',
      qthEndereco: '',
      qthRegionalId: '',
      qthPontoReferencia: '',
      orientacaoOperacional: '',
      coordenadorMembroEquipeId: '',
      coordenadorUsuarioId: coordenadorUsuarioId,
      coordenadorNomeSnapshot: '',
      participanteUsuarioIds: participantes,
      geraRae: true,
      contabilizaProdutividade: true,
      raeId: '',
      execucaoMissaoId: '',
      status: EscalaCodigos.atividadePublicada,
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  EscalaAlocacaoModel alocacao({
    required String id,
    required String atividadeId,
    required String usuarioId,
    String tipoJornada = EscalaCodigos.jornadaNormal,
  }) {
    return EscalaAlocacaoModel(
      id: id,
      escalaId: '2026-09-17',
      atividadeId: atividadeId,
      data: data,
      membroEquipeId: 'membro-$usuarioId',
      usuarioId: usuarioId,
      nomeSnapshot: usuarioId,
      vinculoSnapshot: 'agente',
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: '180H',
      funcaoNaAtividade: 'equipe',
      turnoId: 'manha',
      horaInicio: '06:00',
      horaFim: '12:00',
      tipoJornada: tipoJornada,
      horaInicioReal: '',
      horaFimReal: '',
      minutosPrevistos: 360,
      minutosRealizados: null,
      motivoJornadaComplementar: tipoJornada == EscalaCodigos.jornadaNormal
          ? ''
          : 'Reforço',
      classificadoPor: tipoJornada == EscalaCodigos.jornadaNormal
          ? ''
          : 'responsavel',
      classificadoEm: tipoJornada == EscalaCodigos.jornadaNormal ? null : agora,
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  EscalaIndisponibilidadeModel indisponibilidade(String usuarioId) {
    return EscalaIndisponibilidadeModel(
      id: 'ind-$usuarioId',
      dataInicio: data,
      dataFim: data,
      membroEquipeId: 'membro-$usuarioId',
      usuarioId: usuarioId,
      nomeSnapshot: usuarioId,
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

  EscalaDiaConsulta diaPublicado() {
    return EscalaDiaConsulta(
      data: data,
      escala: escala(),
      atividades: [
        atividade(id: 'a1', titulo: 'Minha atividade', secao: 'comandos'),
        atividade(id: 'a2', titulo: 'Outra atividade', secao: 'apoio'),
      ],
      alocacoes: [
        alocacao(id: 'al1', atividadeId: 'a1', usuarioId: 'uid-atual'),
        alocacao(
          id: 'al2',
          atividadeId: 'a2',
          usuarioId: 'uid-outro',
          tipoJornada: EscalaCodigos.jornadaHoraExtra,
        ),
      ],
      indisponibilidades: [indisponibilidade('uid-outro')],
    );
  }

  group('EscalaConsultaController', () {
    test('carrega escala completa e resume horas', () async {
      final repository = _FakeEscalaRepository((_) async => diaPublicado());
      final controller = EscalaConsultaController(
        repository: repository,
        usuarioId: 'uid-atual',
        dataInicial: data,
      );

      await controller.carregar();

      expect(controller.erro, isNull);
      expect(controller.escalaPublicada, isTrue);
      expect(controller.atividadesVisiveis, hasLength(2));
      expect(controller.resumoHoras.totalAgentesUnicos, 2);
      expect(controller.resumoHoras.totalMinutosProgramados, 720);
      expect(controller.resumoHoras.minutosHoraExtra, 360);
    });

    test(
      'Minha Escala filtra atividade e horas pela identidade atual',
      () async {
        final repository = _FakeEscalaRepository((_) async => diaPublicado());
        final controller = EscalaConsultaController(
          repository: repository,
          usuarioId: 'uid-atual',
          dataInicial: data,
          iniciarMinhaEscala: true,
        );

        await controller.carregar();

        expect(controller.atividadesVisiveis, hasLength(1));
        expect(controller.atividadesVisiveis.single.id, 'a1');
        expect(controller.alocacoesDoModoAtual, hasLength(1));
        expect(controller.resumoHoras.totalMinutosProgramados, 360);
        expect(controller.indisponibilidadesVisiveis, isEmpty);
      },
    );

    test('coordenação também inclui atividade em Minha Escala', () async {
      final resultado = diaPublicado();
      final comCoordenacao = EscalaDiaConsulta(
        data: resultado.data,
        escala: resultado.escala,
        atividades: [
          ...resultado.atividades,
          atividade(
            id: 'a3',
            titulo: 'Coordenação',
            secao: 'programas',
            coordenadorUsuarioId: 'uid-atual',
          ),
        ],
        alocacoes: resultado.alocacoes,
        indisponibilidades: resultado.indisponibilidades,
      );

      final controller = EscalaConsultaController(
        repository: _FakeEscalaRepository((_) async => comCoordenacao),
        usuarioId: 'uid-atual',
        dataInicial: data,
        iniciarMinhaEscala: true,
      );

      await controller.carregar();

      expect(
        controller.atividadesVisiveis.map((item) => item.id),
        containsAll(['a1', 'a3']),
      );
    });

    test('rascunho não expõe atividades na consulta', () async {
      final controller = EscalaConsultaController(
        repository: _FakeEscalaRepository(
          (_) async => EscalaDiaConsulta(
            data: data,
            escala: escala(status: EscalaCodigos.statusRascunho),
            atividades: [
              atividade(id: 'privada', titulo: 'Rascunho', secao: 'comandos'),
            ],
            alocacoes: const [],
            indisponibilidades: const [],
          ),
        ),
        usuarioId: 'uid-atual',
        dataInicial: data,
      );

      await controller.carregar();

      expect(controller.escalaEncontrada, isTrue);
      expect(controller.escalaPublicada, isFalse);
      expect(controller.atividadesVisiveis, isEmpty);
    });

    test('navegação altera data e recarrega repositório', () async {
      final datas = <DateTime>[];
      final controller = EscalaConsultaController(
        repository: _FakeEscalaRepository((data) async {
          datas.add(data);
          return EscalaDiaConsulta.vazia(data);
        }),
        usuarioId: 'uid-atual',
        dataInicial: data,
      );

      await controller.carregar();
      await controller.proximoDia();

      expect(datas, hasLength(2));
      expect(controller.dataSelecionada, DateTime(2026, 9, 18));
    });

    test('erro do repositório fica disponível sem propagar', () async {
      final controller = EscalaConsultaController(
        repository: _FakeEscalaRepository(
          (_) async => throw StateError('offline'),
        ),
        usuarioId: 'uid-atual',
        dataInicial: data,
      );

      await controller.carregar();

      expect(controller.erro, isA<StateError>());
      expect(controller.carregando, isFalse);
      expect(controller.dia, isNull);
    });
  });
}

class _FakeEscalaRepository implements EscalaRepository {
  _FakeEscalaRepository(this.onCarregar);

  final Future<EscalaDiaConsulta> Function(DateTime data) onCarregar;

  @override
  Future<EscalaDiaConsulta> carregarDia(DateTime data) => onCarregar(data);
}
