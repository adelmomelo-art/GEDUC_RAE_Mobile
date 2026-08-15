import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';

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
}
