import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../data/models/acao_model.dart';
import '../models/escala_models.dart';

class EscalaRaeService {
  const EscalaRaeService._();

  static bool podeCriarRae({
    required EscalaAtividadeModel atividade,
    required bool escalaPublicada,
    required String perfilAcesso,
    required String usuarioId,
  }) {
    final uid = usuarioId.trim();
    final perfil = perfilAcesso.trim().toLowerCase();

    if (!escalaPublicada ||
        uid.isEmpty ||
        !atividade.educativa ||
        !atividade.geraRae) {
      return false;
    }

    final participante = atividade.participanteUsuarioIds.contains(uid);
    final coordenador = atividade.coordenadorUsuarioId.trim() == uid;

    return switch (perfil) {
      'agente' => participante,
      'coordenador' => participante || coordenador,
      _ => false,
    };
  }

  static String idDeterministico({
    required String escalaId,
    required String atividadeId,
  }) {
    final escala = escalaId.trim();
    final atividade = atividadeId.trim();
    if (escala.isEmpty || atividade.isEmpty) {
      throw ArgumentError(
        'Escala e atividade são obrigatórias para gerar o ID do RAE.',
      );
    }

    final digest = sha256.convert(utf8.encode('$escala|$atividade'));
    return 'rae-$digest';
  }

  static AcaoModel criarRascunho({
    required EscalaAtividadeModel atividade,
    required Iterable<EscalaAlocacaoModel> alocacoes,
    required String usuarioId,
  }) {
    final uid = usuarioId.trim();
    if (uid.isEmpty) {
      throw ArgumentError.value(usuarioId, 'usuarioId', 'Usuário obrigatório.');
    }
    if (!atividade.educativa || !atividade.geraRae) {
      throw StateError(
        'Somente atividade educativa marcada para RAE é aceita.',
      );
    }

    final equipe = alocacoes
        .where((item) => item.atividadeId.trim() == atividade.id.trim())
        .toList(growable: false);
    final agentes = equipe
        .where((item) => item.vinculoSnapshot.trim() != 'terceirizado')
        .toList(growable: false);
    final terceirizados = equipe
        .where((item) => item.vinculoSnapshot.trim() == 'terceirizado')
        .toList(growable: false);

    return AcaoModel(
      id: idDeterministico(
        escalaId: atividade.escalaId,
        atividadeId: atividade.id,
      ),
      dataAcao: atividade.data,
      turno: atividade.turnoId.trim(),
      nomeAcao: atividade.titulo.trim(),
      tipoAcao: atividade.tipoAtividadeId.trim(),
      publicoEstimado: 0,
      publicoMinimo: 0,
      acaoPlanejada: true,
      horaInicio: atividade.horaInicio.trim(),
      pessoasAlcancadas: 0,
      veiculosAbordados: 0,
      credenciaisEmitidas: 0,
      metaAtingida: false,
      endereco: atividade.qthEndereco.trim(),
      bairro: '',
      regional: '',
      regionalId: atividade.qthRegionalId.trim(),
      equipamentoReferencia: atividade.qthPontoReferencia.trim(),
      nomeLocal: atividade.qthLocal.trim(),
      pontoReferencia: atividade.qthPontoReferencia.trim(),
      latitude: 0,
      longitude: 0,
      localizacaoValidada: false,
      coordenadorId: atividade.coordenadorUsuarioId.trim(),
      coordenadorNome: atividade.coordenadorNomeSnapshot.trim(),
      agentesTransito: agentes.length,
      equipeTerceirizada: terceirizados.length,
      agenteEquipeIds: agentes
          .map((item) => item.membroEquipeId.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      agenteEquipeNomes: agentes
          .map((item) => item.nomeSnapshot.trim())
          .toList(growable: false),
      agenteEquipeUserIds: agentes
          .map((item) => item.usuarioId.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      terceirizadoEquipeIds: terceirizados
          .map((item) => item.membroEquipeId.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      terceirizadoEquipeNomes: terceirizados
          .map((item) => item.nomeSnapshot.trim())
          .toList(growable: false),
      terceirizadoEquipeUserIds: terceirizados
          .map((item) => item.usuarioId.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      status: 'rascunho',
      sincronizado: false,
      responsavelUserId: uid,
      coordenadorUserId: atividade.coordenadorUsuarioId.trim(),
      aclClassificacaoCompleta: false,
      escalaId: atividade.escalaId.trim(),
      escalaAtividadeId: atividade.id.trim(),
    );
  }
}
