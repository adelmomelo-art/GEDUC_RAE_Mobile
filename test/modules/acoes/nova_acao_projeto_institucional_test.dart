import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/projeto_model.dart';
import 'package:geduc_rae_mobile/modules/acoes/controllers/acao_controller.dart';
import 'package:geduc_rae_mobile/modules/acoes/nova_acao_page.dart';
import 'package:geduc_rae_mobile/repositories/acao_repository.dart';
import 'package:provider/provider.dart';

import '../../support/acao_fixture.dart';

class _FakeAcaoRepository extends Fake implements AcaoRepository {
  int rascunhosSalvos = 0;

  @override
  Future<void> salvarRascunho(acao) async {
    rascunhosSalvos++;
  }
}

const _projeto = ProjetoModel(
  id: 'amc-kids',
  nome: 'AMC Kids',
  codigo: 'AE-AMC-KIDS',
  categoria: 'Ação Educativa',
  descricao: 'Atividade educativa lúdica.',
  objetivo: 'Promover educação para o trânsito.',
  publicoAlvo: 'Crianças',
  aliases: <String>[
    'Minicircuito',
    'Tabuleiro',
  ],
  palavrasChave: <String>[
    'educação',
    'crianças',
  ],
);

Widget _app({
  required AcaoController controller,
}) {
  return ChangeNotifierProvider<AcaoController>.value(
    value: controller,
    child: MaterialApp(
      home: NovaAcaoPage(
        listarTiposAcoes: () async => const [],
        listarMembros: () async => const [],
        listarProjetos: () async => const [
          _projeto,
        ],
      ),
    ),
  );
}

void main() {
  testWidgets(
    'seleciona projeto institucional e persiste projetoId',
    (tester) async {
      final repository = _FakeAcaoRepository();

      final controller = AcaoController(
        acaoRepository: repository,
      );

      await tester.pumpWidget(
        _app(controller: controller),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key('projeto-institucional-field'),
        ),
        findsOneWidget,
      );

      final projetoField = find.byKey(
        const Key('projeto-institucional-field'),
      );

      await tester.ensureVisible(
        projetoField,
      );

      await tester.pumpAndSettle();

      await tester.tap(
        projetoField,
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
          'Selecionar projeto ou ação institucional',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.text('AMC Kids').last,
      );

      await tester.pumpAndSettle();

      expect(
        controller.acaoAtual!.projetoId,
        'amc-kids',
      );

      final campoProjeto = find.byKey(const Key('projeto-institucional-field'));

      expect(
        find.descendant(
          of: campoProjeto,
          matching: find.text('AMC Kids'),
        ),
        findsOneWidget,
      );

      expect(
        repository.rascunhosSalvos,
        greaterThanOrEqualTo(1),
      );
    },
  );

  testWidgets(
    'restaura projetoId existente do rascunho',
    (tester) async {
      final repository = _FakeAcaoRepository();

      final controller = AcaoController(
        acaoRepository: repository,
      )..acaoAtual = criarAcaoTeste().copyWith(
          projetoId: 'amc-kids',
        );

      await tester.pumpWidget(
        _app(controller: controller),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('AMC Kids'),
        findsOneWidget,
      );

      expect(
        controller.acaoAtual!.projetoId,
        'amc-kids',
      );
    },
  );

  testWidgets(
    'pesquisa projeto por alias institucional',
    (tester) async {
      final repository = _FakeAcaoRepository();

      final controller = AcaoController(
        acaoRepository: repository,
      );

      await tester.pumpWidget(
        _app(controller: controller),
      );

      await tester.pumpAndSettle();

      final projetoField = find.byKey(
        const Key('projeto-institucional-field'),
      );

      await tester.ensureVisible(
        projetoField,
      );

      await tester.pumpAndSettle();

      await tester.tap(
        projetoField,
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(
          const Key(
            'pesquisa-projeto-institucional',
          ),
        ),
        'Minicircuito',
      );

      await tester.pump();

      expect(
        find.text('AMC Kids'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Faixita usa somente contexto institucional cadastrado',
    (tester) async {
      final repository = _FakeAcaoRepository();

      final controller = AcaoController(
        acaoRepository: repository,
      )..acaoAtual = criarAcaoTeste().copyWith(
          turno: 'Manhã',
          nomeAcao: '',
          projetoId: 'amc-kids',
        );

      await tester.pumpWidget(
        _app(controller: controller),
      );

      await tester.pumpAndSettle();

      // Com o projeto institucional restaurado, a Faixita nao solicita
      // mais o campo legado de nome da acao educativa.
      expect(
        controller.acaoAtual!.projetoId,
        'amc-kids',
      );
      expect(
        find.textContaining('nome da ação educativa'),
        findsNothing,
      );
    },
  );
}
