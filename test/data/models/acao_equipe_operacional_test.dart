import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';

import '../../support/acao_fixture.dart';

void main() {
  test('preserva classificação ACL canônica quando presente', () {
    final acao = AcaoModel.fromMap({
      'responsavelUserId': 'agente-1',
      'coordenadorUserId': 'coordenador-1',
      'regionalId': 'regional-1',
      'equipeId': 'equipe-1',
      'projetoId': 'projeto-1',
      'aclClassificacaoCompleta': true,
      'aclScopeKey': 'r:regional-1|e:equipe-1|p:projeto-1',
    });

    expect(acao.responsavelUserId, 'agente-1');
    expect(acao.coordenadorUserId, 'coordenador-1');
    expect(acao.equipeId, 'equipe-1');
    expect(acao.projetoId, 'projeto-1');
    expect(acao.aclClassificacaoCompleta, isTrue);
    expect(acao.toMap()['aclScopeKey'], 'r:regional-1|e:equipe-1|p:projeto-1');
  });

  test('preserva participantes nominais no mapa do RAE', () {
    final acao = AcaoModel.fromMap({
      'id': 'rae-1',
      'agentesTransito': 2,
      'equipeTerceirizada': 1,
      'agenteEquipeIds': ['a1', 'a2'],
      'agenteEquipeNomes': ['Ana', 'Bruno'],
      'terceirizadoEquipeIds': ['t1'],
      'terceirizadoEquipeNomes': ['Carlos'],
    });

    final mapa = acao.toMap();
    expect(mapa['agenteEquipeIds'], ['a1', 'a2']);
    expect(mapa['agenteEquipeNomes'], ['Ana', 'Bruno']);
    expect(mapa['terceirizadoEquipeIds'], ['t1']);
    expect(mapa['terceirizadoEquipeNomes'], ['Carlos']);
  });

  test('round-trip preserva equipe nominal, órgãos e ano do RAE', () {
    final original = criarAcaoTeste(
      agenteEquipeIds: const ['a1', 'a2'],
      agenteEquipeNomes: const ['Ana', 'Bruno'],
      terceirizadoEquipeIds: const ['t1'],
      terceirizadoEquipeNomes: const ['Carlos'],
      agentesTransito: 2,
      equipeTerceirizada: 1,
      orgaoParticipanteId: 'orgao_gmf',
      orgaoParticipanteIds: const ['orgao_gmf', 'orgao_detran'],
      anoRAE: 2025,
    );

    final restaurada = AcaoModel.fromMap(original.toMap());

    expect(restaurada.agenteEquipeIds, original.agenteEquipeIds);
    expect(restaurada.agenteEquipeNomes, original.agenteEquipeNomes);
    expect(restaurada.terceirizadoEquipeIds, original.terceirizadoEquipeIds);
    expect(
      restaurada.terceirizadoEquipeNomes,
      original.terceirizadoEquipeNomes,
    );
    expect(restaurada.orgaoParticipanteId, 'orgao_gmf');
    expect(restaurada.orgaoParticipanteIds, ['orgao_gmf', 'orgao_detran']);
    expect(restaurada.anoRAE, 2025);
  });

  test('RAE anterior conserva quantidades mesmo sem nomes', () {
    final acao = AcaoModel.fromMap({
      'id': 'rae-legado',
      'agentesTransito': 3,
      'equipeTerceirizada': 2,
    });

    expect(acao.agentesTransito, 3);
    expect(acao.equipeTerceirizada, 2);
    expect(acao.agenteEquipeIds, isEmpty);
    expect(acao.terceirizadoEquipeIds, isEmpty);
    final restaurada = AcaoModel.fromMap(acao.toMap());
    expect(restaurada.agentesTransito, 3);
    expect(restaurada.equipeTerceirizada, 2);
  });

  test('migra órgão participante antigo para seleção múltipla', () {
    final acao = AcaoModel.fromMap({
      'id': 'rae-orgao-legado',
      'houveParticipacaoOutroOrgao': true,
      'orgaoParticipanteId': 'orgao_gmf',
    });

    expect(acao.orgaoParticipanteIds, ['orgao_gmf']);
    expect(acao.orgaoParticipanteId, 'orgao_gmf');
  });

  test('preserva múltiplos órgãos participantes', () {
    final acao = AcaoModel.fromMap({
      'id': 'rae-multiplos-orgaos',
      'houveParticipacaoOutroOrgao': true,
      'orgaoParticipanteId': 'orgao_gmf',
      'orgaoParticipanteIds': ['orgao_gmf', 'orgao_detran'],
    });

    expect(acao.orgaoParticipanteIds, ['orgao_gmf', 'orgao_detran']);
    expect(acao.toMap()['orgaoParticipanteIds'], hasLength(2));
  });

  test('snapshot histórico nominal permanece intacto no round-trip', () {
    final mapaHistorico = criarAcaoTeste(
      agenteEquipeIds: const ['uid-antigo'],
      agenteEquipeNomes: const ['Nome preservado à época'],
      terceirizadoEquipeIds: const ['terceiro-antigo'],
      terceirizadoEquipeNomes: const ['Terceirizado histórico'],
    ).toMap();

    final snapshot = AcaoModel.fromMap(mapaHistorico);

    expect(snapshot.agenteEquipeIds, ['uid-antigo']);
    expect(snapshot.agenteEquipeNomes, ['Nome preservado à época']);
    expect(snapshot.terceirizadoEquipeIds, ['terceiro-antigo']);
    expect(snapshot.terceirizadoEquipeNomes, ['Terceirizado histórico']);
  });

  test('baseline aceita listas de IDs e nomes sem paridade', () {
    final acao = AcaoModel.fromMap({
      'agenteEquipeIds': ['a1', 'a2'],
      'agenteEquipeNomes': ['Ana'],
      'terceirizadoEquipeIds': ['t1'],
      'terceirizadoEquipeNomes': <String>[],
    });

    expect(acao.agenteEquipeIds, hasLength(2));
    expect(acao.agenteEquipeNomes, hasLength(1));
    expect(acao.terceirizadoEquipeIds, hasLength(1));
    expect(acao.terceirizadoEquipeNomes, isEmpty);
  });
}
