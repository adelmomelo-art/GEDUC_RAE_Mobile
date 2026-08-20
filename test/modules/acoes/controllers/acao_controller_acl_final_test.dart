import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/acoes/controllers/acao_controller.dart';
import 'package:geduc_rae_mobile/repositories/acao_repository.dart';

import '../../../support/acao_fixture.dart';

class _FakeAcaoRepository extends Fake implements AcaoRepository {
  int rascunhosSalvos = 0;

  @override
  Future<void> salvarRascunho(acao) async {
    rascunhosSalvos++;
  }
}

void main() {
  group('AUD-L2-R4.4-A — Final Classification', () {
    test('classifica ACL completa e gera scope key canônica', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
      );

      final resultado = controller.classificarAclFinal();

      await Future<void>.delayed(Duration.zero);

      expect(resultado, isTrue);
      expect(controller.acaoAtual!.aclClassificacaoCompleta, isTrue);
      expect(
        controller.acaoAtual!.aclScopeKey,
        'r:regional-1|e:equipe-1|p:projeto-1',
      );
      expect(repository.rascunhosSalvos, greaterThanOrEqualTo(1));
    });

    test('normaliza os cinco identificadores antes de classificar', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: '  regional-1  ',
        responsavelUserId: '  usuario-responsavel-1  ',
        coordenadorUserId: '  usuario-coordenador-1  ',
        equipeId: '  equipe-1  ',
        projetoId: '  projeto-1  ',
      );

      final resultado = controller.classificarAclFinal();

      await Future<void>.delayed(Duration.zero);

      expect(resultado, isTrue);

      final acao = controller.acaoAtual!;
      expect(acao.regionalId, 'regional-1');
      expect(acao.responsavelUserId, 'usuario-responsavel-1');
      expect(acao.coordenadorUserId, 'usuario-coordenador-1');
      expect(acao.equipeId, 'equipe-1');
      expect(acao.projetoId, 'projeto-1');
    });

    test('identidade incompleta impede classificação final', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: '',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
        aclClassificacaoCompleta: true,
        aclScopeKey: 'r:antiga|e:antiga|p:antigo',
      );

      final resultado = controller.classificarAclFinal();

      await Future<void>.delayed(Duration.zero);

      expect(resultado, isFalse);
      expect(controller.acaoAtual!.aclClassificacaoCompleta, isFalse);
      expect(controller.acaoAtual!.aclScopeKey, isEmpty);
    });

    test('escopo incompleto impede classificação final', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
        equipeId: 'equipe-1',
        projetoId: '',
      );

      final resultado = controller.classificarAclFinal();

      await Future<void>.delayed(Duration.zero);

      expect(resultado, isFalse);
      expect(controller.acaoAtual!.aclClassificacaoCompleta, isFalse);
      expect(controller.acaoAtual!.aclScopeKey, isEmpty);
    });

    test('nova identidade invalida classificação ACL anterior', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
        aclClassificacaoCompleta: true,
        aclScopeKey: 'r:regional-1|e:equipe-1|p:projeto-1',
      );

      controller.vincularIdentidadeAcl(
        responsavelUserId: 'usuario-responsavel-2',
        coordenadorUserId: 'usuario-coordenador-2',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.acaoAtual!.aclClassificacaoCompleta, isFalse);
      expect(controller.acaoAtual!.aclScopeKey, isEmpty);
    });

    test('novo escopo invalida classificação ACL anterior', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
        aclClassificacaoCompleta: true,
        aclScopeKey: 'r:regional-1|e:equipe-1|p:projeto-1',
      );

      controller.vincularEscopoAcl(
        equipeId: 'equipe-2',
        projetoId: 'projeto-2',
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.acaoAtual!.aclClassificacaoCompleta, isFalse);
      expect(controller.acaoAtual!.aclScopeKey, isEmpty);
    });

    test('mudança de regional invalida classificação ACL anterior', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
        aclClassificacaoCompleta: true,
        aclScopeKey: 'r:regional-1|e:equipe-1|p:projeto-1',
      );

      controller.preencherLocalizacao(
        endereco: 'Rua Nova',
        bairro: 'Centro',
        regional: 'Regional 2',
        regionalId: 'regional-2',
        equipamentoReferencia: 'Praça',
        latitude: -3.7,
        longitude: -38.5,
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.acaoAtual!.regionalId, 'regional-2');
      expect(controller.acaoAtual!.aclClassificacaoCompleta, isFalse);
      expect(controller.acaoAtual!.aclScopeKey, isEmpty);
    });
  });
}
