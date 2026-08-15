import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/access_scope.dart';
import 'package:geduc_rae_mobile/data/models/usuario_model.dart';

void main() {
  group('AccessScope do Gerente', () {
    test('permanece bloqueado quando qualquer dimensão está vazia', () {
      final escopo = AccessScope(
        regionalIds: const ['regional-1'],
        equipeIds: const ['equipe-1'],
      );

      expect(escopo.completoParaGerente, isFalse);
      expect(
        escopo.abrangeGerente(
          regionalId: 'regional-1',
          equipeId: 'equipe-1',
          projetoId: 'projeto-1',
        ),
        isFalse,
      );
    });

    test('exige interseção das três dimensões', () {
      final escopo = AccessScope(
        regionalIds: const ['regional-1'],
        equipeIds: const ['equipe-1'],
        projetoIds: const ['projeto-1'],
      );

      expect(escopo.completoParaGerente, isTrue);
      expect(
        escopo.abrangeGerente(
          regionalId: 'regional-1',
          equipeId: 'equipe-1',
          projetoId: 'projeto-1',
        ),
        isTrue,
      );
      expect(
        escopo.abrangeGerente(
          regionalId: 'regional-1',
          equipeId: 'equipe-2',
          projetoId: 'projeto-1',
        ),
        isFalse,
      );
    });

    test('normaliza, remove vazios e duplicidades', () {
      final escopo = AccessScope.fromMap(<String, dynamic>{
        'regionalIds': <Object?>[' regional-1 ', '', 'regional-1'],
        'equipeIds': <String>['equipe-1'],
        'projetoIds': <String>['projeto-1'],
        'scopeVersion': 2,
      });

      expect(escopo.regionalIds, <String>{'regional-1'});
      expect(escopo.version, 2);
      expect(escopo.toMap()['scopeVersion'], 2);
    });
  });

  test('UsuarioModel carrega escopo versionado da identidade', () {
    final usuario = UsuarioModel.fromMap(<String, dynamic>{
      'nome': 'Gerente Teste',
      'perfilAcesso': 'gerente',
      'ativo': true,
      'escopoAcesso': <String, dynamic>{
        'regionalIds': <String>['regional-1'],
        'equipeIds': <String>['equipe-1'],
        'projetoIds': <String>['projeto-1'],
        'scopeVersion': 3,
      },
    }, documentId: 'gerente-1');

    expect(usuario.escopoAcesso.completoParaGerente, isTrue);
    expect(usuario.escopoAcesso.version, 3);
    expect(usuario.toMap()['escopoAcesso'], isA<Map<String, dynamic>>());
  });
}
