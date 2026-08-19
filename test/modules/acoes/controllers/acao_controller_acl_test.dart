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
  group('AcaoController - ACL identity binding', () {
    test('grava responsavelUserId e coordenadorUserId no RAE', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste();

      controller.vincularIdentidadeAcl(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        controller.acaoAtual!.responsavelUserId,
        'usuario-responsavel-1',
      );

      expect(
        controller.acaoAtual!.coordenadorUserId,
        'usuario-coordenador-1',
      );

      expect(
        repository.rascunhosSalvos,
        greaterThanOrEqualTo(1),
      );
    });

    test('normaliza espaços externos das identidades ACL', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste();

      controller.vincularIdentidadeAcl(
        responsavelUserId: '  usuario-responsavel-1  ',
        coordenadorUserId: '  usuario-coordenador-1  ',
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        controller.acaoAtual!.responsavelUserId,
        'usuario-responsavel-1',
      );

      expect(
        controller.acaoAtual!.coordenadorUserId,
        'usuario-coordenador-1',
      );
    });

    test('preserva regionalId existente durante binding de identidade',
        () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
      );

      controller.vincularIdentidadeAcl(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        controller.acaoAtual!.regionalId,
        'regional-1',
      );
    });

    test('binding de identidade não marca ACL como completa prematuramente',
        () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
      );

      controller.vincularIdentidadeAcl(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        controller.acaoAtual!.aclClassificacaoCompleta,
        isFalse,
      );
    });

    test('binding de identidade não cria aclScopeKey prematuramente', () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-1',
      );

      controller.vincularIdentidadeAcl(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorUserId: 'usuario-coordenador-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        controller.acaoAtual!.aclScopeKey,
        isEmpty,
      );
    });

    test('binding preserva simultaneamente regional e estado ACL incompleto',
        () async {
      final repository = _FakeAcaoRepository();
      final controller = AcaoController(
        acaoRepository: repository,
      );

      controller.acaoAtual = criarAcaoTeste().copyWith(
        regionalId: 'regional-fortaleza-1',
      );

      controller.vincularIdentidadeAcl(
        responsavelUserId: 'responsavel-1',
        coordenadorUserId: 'coordenador-1',
      );

      await Future<void>.delayed(Duration.zero);

      final acao = controller.acaoAtual!;

      expect(
        acao.responsavelUserId,
        'responsavel-1',
      );

      expect(
        acao.coordenadorUserId,
        'coordenador-1',
      );

      expect(
        acao.regionalId,
        'regional-fortaleza-1',
      );

      expect(
        acao.aclClassificacaoCompleta,
        isFalse,
      );

      expect(
        acao.aclScopeKey,
        isEmpty,
      );
    });
  });
  test('grava equipeId e projetoId resolvidos no RAE', () async {
    final repository = _FakeAcaoRepository();
    final controller = AcaoController(
      acaoRepository: repository,
    );

    controller.acaoAtual = criarAcaoTeste();

    controller.vincularEscopoAcl(
      equipeId: 'equipe-1',
      projetoId: 'projeto-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(
      controller.acaoAtual!.equipeId,
      'equipe-1',
    );

    expect(
      controller.acaoAtual!.projetoId,
      'projeto-1',
    );

    expect(
      repository.rascunhosSalvos,
      greaterThanOrEqualTo(1),
    );
  });

  test('normaliza espaços externos do escopo ACL', () async {
    final repository = _FakeAcaoRepository();
    final controller = AcaoController(
      acaoRepository: repository,
    );

    controller.acaoAtual = criarAcaoTeste();

    controller.vincularEscopoAcl(
      equipeId: '  equipe-1  ',
      projetoId: '  projeto-1  ',
    );

    await Future<void>.delayed(Duration.zero);

    expect(
      controller.acaoAtual!.equipeId,
      'equipe-1',
    );

    expect(
      controller.acaoAtual!.projetoId,
      'projeto-1',
    );
  });

  test('binding de escopo não completa ACL nem cria scopeKey', () async {
    final repository = _FakeAcaoRepository();
    final controller = AcaoController(
      acaoRepository: repository,
    );

    controller.acaoAtual = criarAcaoTeste().copyWith(
      regionalId: 'regional-1',
      responsavelUserId: 'responsavel-1',
      coordenadorUserId: 'coordenador-1',
    );

    controller.vincularEscopoAcl(
      equipeId: 'equipe-1',
      projetoId: 'projeto-1',
    );

    await Future<void>.delayed(Duration.zero);

    final acao = controller.acaoAtual!;

    expect(acao.regionalId, 'regional-1');
    expect(acao.responsavelUserId, 'responsavel-1');
    expect(acao.coordenadorUserId, 'coordenador-1');

    expect(acao.equipeId, 'equipe-1');
    expect(acao.projetoId, 'projeto-1');

    expect(
      acao.aclClassificacaoCompleta,
      isFalse,
    );

    expect(
      acao.aclScopeKey,
      isEmpty,
    );
  });
}
