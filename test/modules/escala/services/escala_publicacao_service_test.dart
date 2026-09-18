import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_publicacao_service.dart';

void main() {
  final dia = DateTime(2026, 9, 17);
  final agora = DateTime(2026, 9, 17, 12);

  EscalaModel escala({
    int versao = 1,
    String motivo = '',
    String origem = '',
    bool preparada = true,
  }) =>
      EscalaModel(
        id: versao == 1 ? '2026-09-17' : '2026-09-17-v$versao',
        data: dia,
        status: EscalaCodigos.statusRascunho,
        versao: versao,
        observacaoGeral: '',
        motivoRevisao: motivo,
        revisaoDeEscalaId: origem,
        revisaoPreparada: preparada,
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
        publicadoPor: '',
        publicadoEm: null,
      );

  EscalaAtividadeModel atividade({
    String id = 'atividade-1',
    bool geraRae = true,
    String natureza = EscalaCodigos.naturezaEducativa,
  }) =>
      EscalaAtividadeModel(
        id: id,
        escalaId: '2026-09-17',
        data: dia,
        secaoId: 'comandos_tematicos',
        tipoAtividadeId: 'comando',
        naturezaAtividade: natureza,
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
        participanteUsuarioIds: const ['uid-a'],
        geraRae: geraRae,
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
    String tipo = EscalaCodigos.jornadaNormal,
    String motivo = '',
    String classificadoPor = '',
    DateTime? classificadoEm,
  }) =>
      EscalaAlocacaoModel(
        id: 'alocacao-1',
        escalaId: '2026-09-17',
        atividadeId: 'atividade-1',
        data: dia,
        membroEquipeId: 'membro-a',
        usuarioId: 'uid-a',
        nomeSnapshot: 'Agente A',
        vinculoSnapshot: 'agente',
        setorSnapshot: 'GEDUC',
        cargaHorariaSnapshot: '180H',
        funcaoNaAtividade: 'equipe',
        turnoId: 'manha',
        horaInicio: '07:00',
        horaFim: '11:00',
        tipoJornada: tipo,
        horaInicioReal: '',
        horaFimReal: '',
        minutosPrevistos: 240,
        minutosRealizados: null,
        motivoJornadaComplementar: motivo,
        classificadoPor: classificadoPor,
        classificadoEm: classificadoEm,
        observacao: '',
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
      );

  test(
    'alertas operacionais nao bloqueiam publicacao estruturalmente valida',
    () {
      final resultado = EscalaPublicacaoService.analisar(
        escala: escala(),
        atividades: [atividade()],
        alocacoes: [alocacao()],
        alertasOperacionais: const [
          '1 sobreposição de horário.',
          '1 agente em férias.',
        ],
      );

      expect(resultado.podePublicar, isTrue);
      expect(resultado.bloqueios, isEmpty);
      expect(resultado.alertas, hasLength(2));
      expect(resultado.totalAtividades, 1);
      expect(resultado.totalAgentes, 1);
      expect(resultado.totalEducativas, 1);
    },
  );

  test('atividade educativa com geraRae false bloqueia', () {
    final resultado = EscalaPublicacaoService.analisar(
      escala: escala(),
      atividades: [atividade(geraRae: false)],
      alocacoes: const [],
    );

    expect(resultado.podePublicar, isFalse);
    expect(resultado.bloqueios.join(' '), contains('precisa gerar RAE'));
  });

  test('revisao exige origem motivo e preparacao concluida', () {
    final resultado = EscalaPublicacaoService.analisar(
      escala: escala(versao: 2, motivo: '', origem: '', preparada: false),
      atividades: const [],
      alocacoes: const [],
    );

    expect(resultado.podePublicar, isFalse);
    expect(
      resultado.bloqueios.join(' '),
      allOf(
        contains('motivo'),
        contains('versão publicada anterior'),
        contains('preparação'),
      ),
    );
  });

  test('jornada complementar incompleta bloqueia', () {
    final resultado = EscalaPublicacaoService.analisar(
      escala: escala(),
      atividades: [atividade()],
      alocacoes: [alocacao(tipo: EscalaCodigos.jornadaHoraExtra)],
    );

    expect(resultado.podePublicar, isFalse);
    expect(resultado.bloqueios.join(' '), contains('classificação completa'));
  });
}
