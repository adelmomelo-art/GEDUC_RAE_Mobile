import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/equipe_model.dart';
import 'package:geduc_rae_mobile/data/models/projeto_model.dart';

void main() {
  test('EquipeModel preserva vínculos canônicos', () {
    final equipe = EquipeModel.fromMap('equipe-1', <String, dynamic>{
      'nome': 'Equipe Centro',
      'regionalIds': <String>['regional-1'],
      'membroIds': <String>['membro-1'],
      'coordenadorUserIds': <String>['usuario-1'],
    });

    expect(equipe.valido, isTrue);
    expect(equipe.toMap()['regionalIds'], <String>['regional-1']);
  });

  test('ProjetoModel preserva vínculos com Regionais e equipes', () {
    final projeto = ProjetoModel.fromMap('projeto-1', <String, dynamic>{
      'nome': 'Projeto Escola Segura',
      'regionalIds': <String>['regional-1'],
      'equipeIds': <String>['equipe-1'],
    });

    expect(projeto.valido, isTrue);
    expect(projeto.toMap()['equipeIds'], <String>['equipe-1']);
  });
}
