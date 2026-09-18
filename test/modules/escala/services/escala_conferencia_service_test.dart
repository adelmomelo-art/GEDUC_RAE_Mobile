import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_conferencia_service.dart';

void main() {
  final dia = DateTime.utc(2026, 9, 17);
  final agora = DateTime.utc(2026, 9, 17, 12);

  MembroEquipeModel membro(int numero, {bool ativo = true, String? usuarioId}) {
    final id = 'membro-$numero';
    return MembroEquipeModel(
      id: id,
      usuarioId: usuarioId ?? 'uid-$numero',
      nome: 'Agente ${numero.toString().padLeft(2, '0')}',
      vinculo: VinculoOperacional.agente,
      podeCoordenar: numero % 5 == 0,
      ativo: ativo,
      origem: 'usuario',
      createdAt: agora,
      updatedAt: agora,
    );
  }

  EscalaPerfilOperacionalModel perfil(
    int numero, {
    bool ativo = true,
    String setor = 'GEDUC',
    String? usuarioId,
  }) {
    return EscalaPerfilOperacionalModel(
      id: 'perfil-$numero',
      membroEquipeId: 'membro-$numero',
      usuarioId: usuarioId ?? 'uid-$numero',
      setorCodigo: setor,
      cargaHorariaCodigo: numero.isEven ? '240H' : '180H',
      ativo: ativo,
      criadoPor: 'gerente',
      criadoEm: agora,
      atualizadoPor: 'gerente',
      atualizadoEm: agora,
    );
  }

  EscalaAlocacaoModel alocacao(
    int numero, {
    String? id,
    String? usuarioId,
    String? membroEquipeId,
    String tipoJornada = EscalaCodigos.jornadaNormal,
    String atividadeId = 'atividade-educativa',
  }) {
    return EscalaAlocacaoModel(
      id: id ?? 'alocacao-$numero',
      escalaId: '2026-09-17',
      atividadeId: atividadeId,
      data: dia,
      membroEquipeId: membroEquipeId ?? 'membro-$numero',
      usuarioId: usuarioId ?? 'uid-$numero',
      nomeSnapshot: 'Agente $numero',
      vinculoSnapshot: 'agente',
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: numero.isEven ? '240H' : '180H',
      funcaoNaAtividade: 'equipe',
      turnoId: 'manha',
      horaInicio: '06:00',
      horaFim: '12:00',
      tipoJornada: tipoJornada,
      horaInicioReal: '',
      horaFimReal: '',
      minutosPrevistos: 360,
      minutosRealizados: null,
      motivoJornadaComplementar:
          tipoJornada == EscalaCodigos.jornadaNormal ? '' : 'Reforco',
      classificadoPor:
          tipoJornada == EscalaCodigos.jornadaNormal ? '' : 'responsavel',
      classificadoEm: tipoJornada == EscalaCodigos.jornadaNormal ? null : agora,
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  EscalaIndisponibilidadeModel indisponibilidade(
    int numero,
    String tipo, {
    String? usuarioId,
    String? membroEquipeId,
  }) {
    return EscalaIndisponibilidadeModel(
      id: 'ind-$numero-$tipo',
      dataInicio: dia,
      dataFim: dia,
      membroEquipeId: membroEquipeId ?? 'membro-$numero',
      usuarioId: usuarioId ?? 'uid-$numero',
      nomeSnapshot: 'Agente $numero',
      tipoId: tipo,
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

  EscalaAtividadeModel atividade(String id, String natureza) {
    return EscalaAtividadeModel(
      id: id,
      escalaId: '2026-09-17',
      data: dia,
      secaoId: natureza,
      tipoAtividadeId: 'tipo',
      naturezaAtividade: natureza,
      titulo: id,
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
      coordenadorUsuarioId: '',
      coordenadorNomeSnapshot: '',
      participanteUsuarioIds: const [],
      geraRae: natureza == EscalaCodigos.naturezaEducativa,
      contabilizaProdutividade: true,
      raeId: '',
      execucaoMissaoId: '',
      status: EscalaCodigos.atividadePlanejada,
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  List<MembroEquipeModel> membros35() =>
      List<MembroEquipeModel>.generate(35, (index) => membro(index + 1));

  List<EscalaPerfilOperacionalModel> perfis35() =>
      List<EscalaPerfilOperacionalModel>.generate(
        35,
        (index) => perfil(index + 1),
      );

  group('EscalaConferenciaService', () {
    test('35/35: 30 em atividade, 3 ferias e 2 compensacao', () {
      final resultado = EscalaConferenciaService.conferir(
        data: dia,
        membrosEquipe: membros35(),
        perfisOperacionais: perfis35(),
        alocacoes: [for (var i = 1; i <= 30; i++) alocacao(i)],
        indisponibilidades: [
          for (var i = 31; i <= 33; i++) indisponibilidade(i, 'ferias'),
          for (var i = 34; i <= 35; i++) indisponibilidade(i, 'compensacao'),
        ],
        atividades: [
          atividade('atividade-educativa', EscalaCodigos.naturezaEducativa),
        ],
      );

      expect(resultado.totalEfetivo, 35);
      expect(resultado.totalEmAtividade, 30);
      expect(resultado.totalExplicados, 35);
      expect(resultado.totalSemSituacao, 0);
      expect(resultado.coberturaCompleta, isTrue);
      expect(resultado.indisponiveisPorTipo['ferias'], 3);
      expect(resultado.indisponiveisPorTipo['compensacao'], 2);
      expect(resultado.totalAtividadeEducativa, 30);
    });

    test('34/35: alocacao duplicada nao infla cobertura', () {
      final alocacoes = <EscalaAlocacaoModel>[
        for (var i = 1; i <= 29; i++) alocacao(i),
        alocacao(
          1,
          id: 'alocacao-1-extra',
          tipoJornada: EscalaCodigos.jornadaHoraExtra,
        ),
      ];

      final resultado = EscalaConferenciaService.conferir(
        data: dia,
        membrosEquipe: membros35(),
        perfisOperacionais: perfis35(),
        alocacoes: alocacoes,
        indisponibilidades: [
          for (var i = 31; i <= 33; i++) indisponibilidade(i, 'ferias'),
          for (var i = 34; i <= 35; i++) indisponibilidade(i, 'compensacao'),
        ],
      );

      expect(resultado.totalEfetivo, 35);
      expect(resultado.totalEmAtividade, 29);
      expect(resultado.totalAlocacoesMapeadas, 30);
      expect(resultado.totalMultiplasAlocacoes, 1);
      expect(resultado.totalJornadasComplementares, 1);
      expect(resultado.totalExplicados, 34);
      expect(resultado.totalSemSituacao, 1);
      expect(resultado.agentesSemSituacao.single.membroEquipeId, 'membro-30');
      expect(resultado.coberturaCompleta, isFalse);
    });

    test('situacao dupla explica agente e gera sinalizacao separada', () {
      final resultado = EscalaConferenciaService.conferir(
        data: dia,
        membrosEquipe: [membro(1)],
        perfisOperacionais: [perfil(1)],
        alocacoes: [alocacao(1)],
        indisponibilidades: [indisponibilidade(1, 'ferias')],
      );

      expect(resultado.totalExplicados, 1);
      expect(resultado.totalSituacaoDupla, 1);
      expect(
        resultado.agentesComSituacaoDupla.single.membroEquipeId,
        'membro-1',
      );
    });

    test('inativo e perfil fora da GEDUC nao entram no denominador', () {
      final resultado = EscalaConferenciaService.conferir(
        data: dia,
        membrosEquipe: [membro(1), membro(2, ativo: false), membro(3)],
        perfisOperacionais: [
          perfil(1),
          perfil(2),
          perfil(3, setor: 'OUTRO'),
        ],
        alocacoes: const [],
        indisponibilidades: const [],
      );

      expect(resultado.totalEfetivo, 1);
      expect(resultado.agentes.single.membroEquipeId, 'membro-1');
    });

    test(
      'mesmo UID em dois membros conta uma pessoa e sinaliza duplicidade',
      () {
        final resultado = EscalaConferenciaService.conferir(
          data: dia,
          membrosEquipe: [
            membro(1, usuarioId: 'uid-unico'),
            membro(2, usuarioId: 'uid-unico'),
          ],
          perfisOperacionais: [
            perfil(1, usuarioId: 'uid-unico'),
            perfil(2, usuarioId: 'uid-unico'),
          ],
          alocacoes: const [],
          indisponibilidades: const [],
        );

        expect(resultado.totalEfetivo, 1);
        expect(resultado.identidadesCanonicasDuplicadas, ['uid-unico']);
      },
    );

    test('membro legado sem UID usa fallback explicito e e sinalizado', () {
      final resultado = EscalaConferenciaService.conferir(
        data: dia,
        membrosEquipe: [membro(1, usuarioId: '')],
        perfisOperacionais: [perfil(1, usuarioId: '')],
        alocacoes: [alocacao(1, usuarioId: '', membroEquipeId: 'membro-1')],
        indisponibilidades: const [],
      );

      expect(resultado.totalEfetivo, 1);
      expect(resultado.totalEmAtividade, 1);
      expect(resultado.totalIdentidadeNaoCanonica, 1);
      expect(
        resultado.agentesSemIdentidadeCanonica.single.chavePessoa,
        'membro:membro-1',
      );
    });

    test(
      'atividade administrativa e educativa ficam separadas da cobertura',
      () {
        final resultado = EscalaConferenciaService.conferir(
          data: dia,
          membrosEquipe: [membro(1), membro(2)],
          perfisOperacionais: [perfil(1), perfil(2)],
          alocacoes: [
            alocacao(1, atividadeId: 'educativa'),
            alocacao(2, atividadeId: 'administrativa'),
          ],
          indisponibilidades: const [],
          atividades: [
            atividade('educativa', EscalaCodigos.naturezaEducativa),
            atividade('administrativa', EscalaCodigos.naturezaAdministrativa),
          ],
        );

        expect(resultado.totalEmAtividade, 2);
        expect(resultado.totalAtividadeEducativa, 1);
        expect(resultado.totalAdministrativoApoio, 1);
        expect(resultado.coberturaCompleta, isTrue);
      },
    );

    test('alocacao fora do efetivo e apresentada como nao mapeada', () {
      final resultado = EscalaConferenciaService.conferir(
        data: dia,
        membrosEquipe: [membro(1)],
        perfisOperacionais: [perfil(1)],
        alocacoes: [
          alocacao(99, usuarioId: 'uid-99', membroEquipeId: 'membro-99'),
        ],
        indisponibilidades: const [],
      );

      expect(resultado.totalEfetivo, 1);
      expect(resultado.totalAlocacoesMapeadas, 0);
      expect(resultado.alocacoesNaoMapeadas, ['alocacao-99']);
      expect(resultado.totalSemSituacao, 1);
    });
  });
}
