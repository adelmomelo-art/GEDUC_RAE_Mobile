import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_rae_service.dart';

void main() {
  final agora = DateTime(2026, 9, 23, 8);

  EscalaAtividadeModel atividade({String raeId = ''}) {
    return EscalaAtividadeModel(
      id: 'atividade-educativa-1',
      escalaId: '2026-09-23',
      data: DateTime(2026, 9, 23),
      secaoId: 'comandos',
      tipoAtividadeId: 'comando_educativo',
      naturezaAtividade: EscalaCodigos.naturezaEducativa,
      titulo: 'Motociclista Seguro',
      descricao: 'Abordagem educativa',
      turnoId: 'manha',
      qtrHorario: '08:00–10:00',
      horaInicio: '08:00',
      horaFim: '10:00',
      qthLocal: 'Praça Central',
      qthEndereco: 'Rua Central, 10',
      qthRegionalId: 'regional-1',
      qthPontoReferencia: 'Próximo ao terminal',
      orientacaoOperacional: '',
      coordenadorMembroEquipeId: 'membro-coord',
      coordenadorUsuarioId: 'uid-coord',
      coordenadorNomeSnapshot: 'Coordenação HML',
      participanteUsuarioIds: const ['uid-agente'],
      geraRae: true,
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

  EscalaAlocacaoModel alocacao({
    required String id,
    required String uid,
    String vinculo = 'agente',
  }) {
    return EscalaAlocacaoModel(
      id: id,
      escalaId: '2026-09-23',
      atividadeId: 'atividade-educativa-1',
      data: DateTime(2026, 9, 23),
      membroEquipeId: 'membro-$uid',
      usuarioId: uid,
      nomeSnapshot: 'Nome $uid',
      vinculoSnapshot: vinculo,
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: '180H',
      funcaoNaAtividade: 'equipe',
      turnoId: 'manha',
      horaInicio: '08:00',
      horaFim: '10:00',
      tipoJornada: EscalaCodigos.jornadaNormal,
      horaInicioReal: '',
      horaFimReal: '',
      minutosPrevistos: 120,
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

  test('ID do RAE é SHA256 determinístico por escala e atividade', () {
    final primeiro = EscalaRaeService.idDeterministico(
      escalaId: '2026-09-23',
      atividadeId: 'atividade-educativa-1',
    );
    final segundo = EscalaRaeService.idDeterministico(
      escalaId: '2026-09-23',
      atividadeId: 'atividade-educativa-1',
    );

    expect(primeiro, segundo);
    expect(primeiro, startsWith('rae-'));
    expect(primeiro.length, 68);
  });

  test(
    'participante e coordenador elegíveis criam; administrador não opera',
    () {
      final item = atividade();

      expect(
        EscalaRaeService.podeCriarRae(
          atividade: item,
          escalaPublicada: true,
          perfilAcesso: 'agente',
          usuarioId: 'uid-agente',
        ),
        isTrue,
      );
      expect(
        EscalaRaeService.podeCriarRae(
          atividade: item,
          escalaPublicada: true,
          perfilAcesso: 'coordenador',
          usuarioId: 'uid-coord',
        ),
        isTrue,
      );
      expect(
        EscalaRaeService.podeCriarRae(
          atividade: item,
          escalaPublicada: true,
          perfilAcesso: 'administrador',
          usuarioId: 'uid-agente',
        ),
        isFalse,
      );
    },
  );

  test('rascunho transporta origem e dados operacionais sem financeiro', () {
    final item = atividade();
    final rascunho = EscalaRaeService.criarRascunho(
      atividade: item,
      alocacoes: [
        alocacao(id: 'aloc-1', uid: 'uid-agente'),
        alocacao(id: 'aloc-2', uid: 'uid-terceiro', vinculo: 'terceirizado'),
      ],
      usuarioId: 'uid-agente',
    );

    expect(rascunho.escalaId, '2026-09-23');
    expect(rascunho.escalaAtividadeId, item.id);
    expect(rascunho.originadaDaEscala, isTrue);
    expect(rascunho.acaoPlanejada, isTrue);
    expect(rascunho.nomeAcao, 'Motociclista Seguro');
    expect(rascunho.horaInicio, '08:00');
    expect(rascunho.horaFinal, isNull);
    expect(rascunho.localizacaoValidada, isFalse);
    expect(rascunho.agentesTransito, 1);
    expect(rascunho.equipeTerceirizada, 1);
    expect(rascunho.responsavelUserId, 'uid-agente');
    expect(rascunho.aclClassificacaoCompleta, isFalse);
  });

  test('serialização preserva vínculo Escala → RAE', () {
    final rascunho = EscalaRaeService.criarRascunho(
      atividade: atividade(),
      alocacoes: [alocacao(id: 'aloc-1', uid: 'uid-agente')],
      usuarioId: 'uid-agente',
    );

    final restaurado = rascunho.toMap();
    expect(restaurado['escalaId'], '2026-09-23');
    expect(restaurado['escalaAtividadeId'], 'atividade-educativa-1');
  });
}
