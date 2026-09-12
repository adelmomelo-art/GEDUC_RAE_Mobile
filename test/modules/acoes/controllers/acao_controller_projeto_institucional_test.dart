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
  group('Projeto institucional do RAE', () {
    test(
      'trocar projeto invalida ACL e preserva equipe dinamica',
      () async {
        final repository = _FakeAcaoRepository();

        final controller = AcaoController(
          acaoRepository: repository,
        )..acaoAtual = criarAcaoTeste().copyWith(
            projetoId: 'projeto-antigo',
            equipeId: 'rae_team_1234567890abcdef12345678',
            aclClassificacaoCompleta: true,
            aclScopeKey: 'scope-antigo',
          );

        controller.selecionarProjetoInstitucional(
          ' projeto-novo ',
        );

        await Future<void>.delayed(
          Duration.zero,
        );

        expect(
          controller.acaoAtual!.projetoId,
          'projeto-novo',
        );

        expect(
          controller.acaoAtual!.equipeId,
          'rae_team_1234567890abcdef12345678',
        );

        expect(
          controller.acaoAtual!.aclClassificacaoCompleta,
          isFalse,
        );

        expect(
          controller.acaoAtual!.aclScopeKey,
          isEmpty,
        );

        expect(
          repository.rascunhosSalvos,
          greaterThanOrEqualTo(1),
        );
      },
    );

    test(
      'selecionar mesmo projeto preserva ACL existente',
      () async {
        final repository = _FakeAcaoRepository();

        final controller = AcaoController(
          acaoRepository: repository,
        )..acaoAtual = criarAcaoTeste().copyWith(
            projetoId: 'projeto-1',
            equipeId: 'rae_team_1234567890abcdef12345678',
            aclClassificacaoCompleta: true,
            aclScopeKey: 'scope-valido',
          );

        controller.selecionarProjetoInstitucional(
          ' projeto-1 ',
        );

        await Future<void>.delayed(
          Duration.zero,
        );

        expect(
          controller.acaoAtual!.projetoId,
          'projeto-1',
        );

        expect(
          controller.acaoAtual!.equipeId,
          'rae_team_1234567890abcdef12345678',
        );

        expect(
          controller.acaoAtual!.aclClassificacaoCompleta,
          isTrue,
        );

        expect(
          controller.acaoAtual!.aclScopeKey,
          'scope-valido',
        );

        expect(
          repository.rascunhosSalvos,
          0,
        );
      },
    );

    test(
      'limpar projeto invalida ACL mas preserva equipe',
      () async {
        final repository = _FakeAcaoRepository();

        final controller = AcaoController(
          acaoRepository: repository,
        )..acaoAtual = criarAcaoTeste().copyWith(
            projetoId: 'projeto-1',
            equipeId: 'rae_team_1234567890abcdef12345678',
            aclClassificacaoCompleta: true,
            aclScopeKey: 'scope-valido',
          );

        controller.selecionarProjetoInstitucional(
          '   ',
        );

        await Future<void>.delayed(
          Duration.zero,
        );

        expect(
          controller.acaoAtual!.projetoId,
          isEmpty,
        );

        expect(
          controller.acaoAtual!.equipeId,
          'rae_team_1234567890abcdef12345678',
        );

        expect(
          controller.acaoAtual!.aclClassificacaoCompleta,
          isFalse,
        );

        expect(
          controller.acaoAtual!.aclScopeKey,
          isEmpty,
        );
      },
    );

    test(
      'cria rascunho quando necessario e vincula projeto',
      () async {
        final repository = _FakeAcaoRepository();

        final controller = AcaoController(
          acaoRepository: repository,
        );

        expect(
          controller.acaoAtual,
          isNull,
        );

        controller.selecionarProjetoInstitucional(
          'projeto-inicial',
        );

        await Future<void>.delayed(
          Duration.zero,
        );

        expect(
          controller.acaoAtual,
          isNotNull,
        );

        expect(
          controller.acaoAtual!.projetoId,
          'projeto-inicial',
        );

        expect(
          controller.acaoAtual!.aclClassificacaoCompleta,
          isFalse,
        );

        expect(
          controller.acaoAtual!.aclScopeKey,
          isEmpty,
        );
      },
    );
  });
}
