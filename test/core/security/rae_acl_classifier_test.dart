import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/rae_acl_classifier.dart';

void main() {
  group('RaeAclClassifier', () {
    test('classificação completa gera scopeKey canônica', () {
      final resultado = RaeAclClassifier.classify(
        responsavelUserId: 'usuario-1',
        coordenadorUserId: 'coordenador-1',
        regionalId: 'regional-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
      );

      expect(
        resultado.aclClassificacaoCompleta,
        isTrue,
      );

      expect(
        resultado.aclScopeKey,
        'r:regional-1|e:equipe-1|p:projeto-1',
      );

      expect(
        resultado.responsavelUserId,
        'usuario-1',
      );

      expect(
        resultado.coordenadorUserId,
        'coordenador-1',
      );

      expect(
        resultado.regionalId,
        'regional-1',
      );

      expect(
        resultado.equipeId,
        'equipe-1',
      );

      expect(
        resultado.projetoId,
        'projeto-1',
      );
    });

    test('normaliza espaços externos dos identificadores', () {
      final resultado = RaeAclClassifier.classify(
        responsavelUserId: '  usuario-1  ',
        coordenadorUserId: '  coordenador-1  ',
        regionalId: '  regional-1  ',
        equipeId: '  equipe-1  ',
        projetoId: '  projeto-1  ',
      );

      expect(
        resultado.aclClassificacaoCompleta,
        isTrue,
      );

      expect(
        resultado.responsavelUserId,
        'usuario-1',
      );

      expect(
        resultado.coordenadorUserId,
        'coordenador-1',
      );

      expect(
        resultado.regionalId,
        'regional-1',
      );

      expect(
        resultado.equipeId,
        'equipe-1',
      );

      expect(
        resultado.projetoId,
        'projeto-1',
      );

      expect(
        resultado.aclScopeKey,
        'r:regional-1|e:equipe-1|p:projeto-1',
      );
    });

    test('ausência de responsavelUserId torna classificação incompleta', () {
      final resultado = RaeAclClassifier.classify(
        responsavelUserId: '   ',
        coordenadorUserId: 'coordenador-1',
        regionalId: 'regional-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
      );

      expect(
        resultado.aclClassificacaoCompleta,
        isFalse,
      );

      expect(
        resultado.aclScopeKey,
        isEmpty,
      );
    });

    test('ausência de coordenadorUserId torna classificação incompleta', () {
      final resultado = RaeAclClassifier.classify(
        responsavelUserId: 'usuario-1',
        coordenadorUserId: '',
        regionalId: 'regional-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
      );

      expect(
        resultado.aclClassificacaoCompleta,
        isFalse,
      );

      expect(
        resultado.aclScopeKey,
        isEmpty,
      );
    });

    test('ausência de regionalId torna classificação incompleta', () {
      final resultado = RaeAclClassifier.classify(
        responsavelUserId: 'usuario-1',
        coordenadorUserId: 'coordenador-1',
        regionalId: '',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
      );

      expect(
        resultado.aclClassificacaoCompleta,
        isFalse,
      );

      expect(
        resultado.aclScopeKey,
        isEmpty,
      );
    });

    test('ausência de equipeId torna classificação incompleta', () {
      final resultado = RaeAclClassifier.classify(
        responsavelUserId: 'usuario-1',
        coordenadorUserId: 'coordenador-1',
        regionalId: 'regional-1',
        equipeId: '   ',
        projetoId: 'projeto-1',
      );

      expect(
        resultado.aclClassificacaoCompleta,
        isFalse,
      );

      expect(
        resultado.aclScopeKey,
        isEmpty,
      );
    });

    test('ausência de projetoId torna classificação incompleta', () {
      final resultado = RaeAclClassifier.classify(
        responsavelUserId: 'usuario-1',
        coordenadorUserId: 'coordenador-1',
        regionalId: 'regional-1',
        equipeId: 'equipe-1',
        projetoId: '',
      );

      expect(
        resultado.aclClassificacaoCompleta,
        isFalse,
      );

      expect(
        resultado.aclScopeKey,
        isEmpty,
      );
    });

    test('classificação incompleta nunca produz scopeKey parcial', () {
      final resultado = RaeAclClassifier.classify(
        responsavelUserId: 'usuario-1',
        coordenadorUserId: '',
        regionalId: 'regional-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
      );

      expect(
        resultado.aclClassificacaoCompleta,
        isFalse,
      );

      expect(
        resultado.aclScopeKey,
        isEmpty,
      );

      expect(
        resultado.aclScopeKey,
        isNot(
          contains('regional-1'),
        ),
      );

      expect(
        resultado.aclScopeKey,
        isNot(
          contains('equipe-1'),
        ),
      );

      expect(
        resultado.aclScopeKey,
        isNot(
          contains('projeto-1'),
        ),
      );
    });
  });
}
