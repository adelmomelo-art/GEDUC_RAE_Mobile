import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  final agora = DateTime.utc(2026, 9, 17, 12);

  group('ESC-001C models', () {
    test('EscalaConfiguracaoModel round-trip', () {
      final original = EscalaConfiguracaoModel(
        id: 'principal',
        responsavelEscalaUsuarioId: 'agente-responsavel',
        responsavelEscalaMembroEquipeId: 'membro-responsavel',
        ativo: true,
        designadoPor: 'gerente',
        designadoEm: agora,
      );

      final reidratado = EscalaConfiguracaoModel.fromMap(
        original.toMap(),
        documentId: 'principal',
      );

      expect(reidratado.responsavelEscalaUsuarioId, 'agente-responsavel');
      expect(reidratado.responsavelEscalaMembroEquipeId, 'membro-responsavel');
      expect(reidratado.ativo, isTrue);
      expect(reidratado.designadoPor, 'gerente');
    });

    test('perfil operacional preserva GEDUC e carga horária', () {
      final original = EscalaPerfilOperacionalModel(
        id: 'membro-1',
        membroEquipeId: 'membro-1',
        usuarioId: 'agente-1',
        setorCodigo: 'GEDUC',
        cargaHorariaCodigo: '180H',
        ativo: true,
        criadoPor: 'gerente',
        criadoEm: agora,
        atualizadoPor: 'gerente',
        atualizadoEm: agora,
      );

      final map = original.toMap();
      expect(map['setorCodigo'], 'GEDUC');
      expect(map['cargaHorariaCodigo'], '180H');
      expect(map['criadoEm'], isA<Timestamp>());
    });

    test('escala publicada aceita metadados de publicação', () {
      final model = EscalaModel(
        id: '2026-09-17',
        data: DateTime.utc(2026, 9, 17),
        status: EscalaCodigos.statusPublicada,
        versao: 2,
        observacaoGeral: 'Escala revisada',
        motivoRevisao: 'Ajuste operacional',
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'gerente',
        atualizadoEm: agora,
        publicadoPor: 'gerente',
        publicadoEm: agora,
      );

      final reidratado = EscalaModel.fromMap(
        model.toMap(),
        documentId: model.id,
      );

      expect(reidratado.status, EscalaCodigos.statusPublicada);
      expect(reidratado.versao, 2);
      expect(reidratado.publicadoEm, isNotNull);
    });

    test('atividade educativa mantém QTR horário e QTH local separados', () {
      final atividade = EscalaAtividadeModel(
        id: 'atividade-1',
        escalaId: '2026-09-17',
        data: DateTime.utc(2026, 9, 17),
        secaoId: 'comandos',
        tipoAtividadeId: 'comando_educativo',
        naturezaAtividade: EscalaCodigos.naturezaEducativa,
        titulo: 'Motociclista Seguro',
        descricao: '',
        turnoId: 'manha',
        qtrHorario: '06:00',
        horaInicio: '07:00',
        horaFim: '11:00',
        qthLocal: 'Av. Tenente Benévolo x Rua Gonçalves Ledo',
        qthEndereco: '',
        qthRegionalId: 'regional-12',
        qthPontoReferencia: '',
        orientacaoOperacional: 'Abordagem educativa',
        coordenadorMembroEquipeId: 'coord-1',
        coordenadorUsuarioId: 'coord-user',
        coordenadorNomeSnapshot: 'Coordenador',
        participanteUsuarioIds: const ['agente-1', 'agente-2'],
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

      final map = atividade.toMap();
      expect(map['qtrHorario'], '06:00');
      expect(map['qthLocal'], contains('Tenente'));
      expect(map['horaInicio'], '07:00');
      expect(atividade.educativa, isTrue);
      expect(atividade.geraRae, isTrue);
    });

    test('alocação aceita membro sem usuarioId', () {
      final alocacao = EscalaAlocacaoModel(
        id: 'a-1',
        escalaId: '2026-09-17',
        atividadeId: 'atividade-1',
        data: DateTime.utc(2026, 9, 17),
        membroEquipeId: 'legado-1',
        usuarioId: '',
        nomeSnapshot: 'Membro legado',
        vinculoSnapshot: 'agente',
        setorSnapshot: 'GEDUC',
        cargaHorariaSnapshot: '240H',
        funcaoNaAtividade: 'apoio',
        turnoId: 'tarde',
        horaInicio: '13:00',
        horaFim: '16:00',
        observacao: '',
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
      );

      expect(alocacao.toMap()['usuarioId'], '');
      expect(alocacao.toMap()['cargaHorariaSnapshot'], '240H');
    });

    test('indisponibilidade é informativa e serializável', () {
      final item = EscalaIndisponibilidadeModel(
        id: 'i-1',
        dataInicio: DateTime.utc(2026, 9, 17),
        dataFim: DateTime.utc(2026, 9, 18),
        membroEquipeId: 'membro-1',
        usuarioId: 'agente-1',
        nomeSnapshot: 'Agente 1',
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

      expect(item.toMap()['tipoId'], 'ferias');
    });

    test('execução administrativa preserva evidência sem horas reais', () {
      final evidencia = MissaoEvidenciaModel(
        id: 'ev-1',
        tipo: 'documento',
        descricao: 'Planilha consolidada',
        referencia: 'referencia-futura',
        criadoPor: 'agente-1',
        criadoEm: agora,
      );

      final execucao = ExecucaoMissaoModel(
        id: 'exec-1',
        escalaAtividadeId: 'atividade-admin',
        escalaId: '2026-09-17',
        data: DateTime.utc(2026, 9, 17),
        status: EscalaCodigos.execucaoConcluida,
        resultadoResumo: 'Dados consolidados',
        observacao: '',
        evidencias: [evidencia],
        executadoPorUsuarioId: 'agente-1',
        executadoPorMembroEquipeId: 'membro-1',
        executadoPorNomeSnapshot: 'Agente 1',
        concluidoEm: agora,
        criadoEm: agora,
        atualizadoEm: agora,
      );

      final map = execucao.toMap();
      expect(map.containsKey('horaInicioReal'), isFalse);
      expect(map.containsKey('horaFimReal'), isFalse);
      expect((map['evidencias'] as List).length, 1);
    });
  });
}
