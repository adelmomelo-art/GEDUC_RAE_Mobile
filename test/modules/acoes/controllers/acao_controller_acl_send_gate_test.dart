import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/acoes/controllers/acao_controller.dart';
import 'package:geduc_rae_mobile/repositories/acao_repository.dart';

import '../../../support/acao_fixture.dart';

class _FakeAcaoRepository extends Fake implements AcaoRepository {
  int envios = 0;
  int rascunhosSalvos = 0;

  @override
  Future<void> salvarRascunho(acao) async {
    rascunhosSalvos++;
  }

  @override
  Future<String> enviarAcao(acao) async {
    envios++;
    return 'rae-teste';
  }
}

void main() {
  group('AUD-L2-R4.4-B — Send Gate ACL', () {
    test('rascunho com ACL incompleta é bloqueado antes das demais validações',
        () {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(acaoRepository: repository);

      controller.acaoAtual = criarAcaoTeste().copyWith(
        status: 'rascunho',
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: '',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
        aclClassificacaoCompleta: false,
        aclScopeKey: '',
      );

      final valido = controller.validarAntesDoEnvio();

      expect(valido, isFalse);
      expect(controller.erro, contains('ACL'));
    });

    test('rascunho com scope key persistida inconsistente é bloqueado', () {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(acaoRepository: repository);

      controller.acaoAtual = criarAcaoTeste().copyWith(
        status: 'rascunho',
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
        aclClassificacaoCompleta: true,
        aclScopeKey: 'r:regional-X|e:equipe-X|p:projeto-X',
      );

      final valido = controller.validarAntesDoEnvio();

      expect(valido, isFalse);
      expect(controller.erro, contains('ACL'));
    });

    test('ACL íntegra atravessa o gate ACL', () {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(acaoRepository: repository);

      controller.acaoAtual = criarAcaoTeste().copyWith(
        status: 'rascunho',
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
        aclClassificacaoCompleta: true,
        aclScopeKey: 'r:regional-1|e:equipe-1|p:projeto-1',
      );

      controller.validarAntesDoEnvio();

      expect(controller.erro, isNot(contains('ACL')));
    });

    test('registro legado fora de rascunho não recebe bloqueio ACL retroativo',
        () {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(acaoRepository: repository);

      controller.acaoAtual = criarAcaoTeste().copyWith(
        status: 'enviado',
        regionalId: '',
        responsavelUserId: '',
        coordenadorUserId: '',
        equipeId: '',
        projetoId: '',
        aclClassificacaoCompleta: false,
        aclScopeKey: '',
      );

      controller.validarAntesDoEnvio();

      expect(controller.erro, isNot(contains('ACL')));
    });

    test(
        'enviarRelatorio não corrige silenciosamente ACL persistida inconsistente',
        () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(acaoRepository: repository);

      controller.acaoAtual = criarAcaoTeste().copyWith(
        status: 'rascunho',
        regionalId: 'regional-1',
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
        aclClassificacaoCompleta: true,
        aclScopeKey: 'r:regional-X|e:equipe-X|p:projeto-X',
      );

      final enviado = await controller.enviarRelatorio();

      expect(enviado, isFalse);
      expect(controller.erro, contains('ACL'));
      expect(repository.envios, 0);
      expect(
        controller.acaoAtual!.aclScopeKey,
        'r:regional-X|e:equipe-X|p:projeto-X',
      );
    });
  });
}
