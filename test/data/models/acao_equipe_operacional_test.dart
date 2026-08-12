import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';

void main() {
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
