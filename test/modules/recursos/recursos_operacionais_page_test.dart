import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/modules/acoes/controllers/acao_controller.dart';
import 'package:geduc_rae_mobile/modules/recursos/recursos_operacionais_page.dart';
import 'package:geduc_rae_mobile/repositories/acao_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../support/acao_fixture.dart';

class _FakeAcaoRepository extends Fake implements AcaoRepository {
  int rascunhosSalvos = 0;

  @override
  Future<void> salvarRascunho(acao) async {
    rascunhosSalvos++;
  }
}

MembroEquipeModel _membro({
  required String id,
  required String nome,
  required VinculoOperacional vinculo,
  bool ativo = true,
  bool podeCoordenar = false,
}) {
  return MembroEquipeModel(
    id: id,
    usuarioId: id,
    nome: nome,
    vinculo: vinculo,
    podeCoordenar: podeCoordenar,
    ativo: ativo,
    origem: 'usuario',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Future<({AcaoController controller, _FakeAcaoRepository repository})>
    _pumpPagina(
  WidgetTester tester, {
  required Future<List<MembroEquipeModel>> Function() listarMembros,
  required acao,
}) async {
  final repository = _FakeAcaoRepository();
  final controller = AcaoController(acaoRepository: repository)
    ..acaoAtual = acao;
  final router = GoRouter(
    initialLocation: '/recursos-operacionais',
    routes: [
      GoRoute(
        path: '/recursos-operacionais',
        builder: (_, __) => RecursosOperacionaisPage(
          listarMembros: listarMembros,
        ),
      ),
      GoRoute(
        path: '/caracterizacao-acao',
        builder: (_, __) => const Scaffold(body: Text('CARACTERIZAÇÃO')),
      ),
      GoRoute(
        path: '/integracao-observacoes',
        builder: (_, __) => const Scaffold(body: Text('INTEGRAÇÃO')),
      ),
    ],
  );

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return (controller: controller, repository: repository);
}

void main() {
  final coordenadora = _membro(
    id: 'coord-1',
    nome: 'Coordenadora Ana',
    vinculo: VinculoOperacional.agente,
    podeCoordenar: true,
  );
  final agente = _membro(
    id: 'agente-1',
    nome: 'Agente Bruno',
    vinculo: VinculoOperacional.agente,
  );
  final terceirizado = _membro(
    id: 'terceiro-1',
    nome: 'Terceirizada Carla',
    vinculo: VinculoOperacional.terceirizado,
  );

  testWidgets('carrega equipe nominal e restaura materiais existentes',
      (tester) async {
    await _pumpPagina(
      tester,
      listarMembros: () async => [coordenadora, agente, terceirizado],
      acao: criarAcaoTeste(
        agenteEquipeIds: const ['agente-1'],
        agenteEquipeNomes: const ['Agente Bruno'],
        terceirizadoEquipeIds: const ['terceiro-1'],
        terceirizadoEquipeNomes: const ['Terceirizada Carla'],
        materialUtilizadoIds: const ['material_cone'],
      ),
    );

    expect(find.text('Coordenadora Ana'), findsWidgets);
    expect(find.text('Agente Bruno'), findsOneWidget);
    expect(find.text('Terceirizada Carla'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Cone'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    final cone = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Cone'),
    );
    expect(cone.selected, isTrue);
  });

  testWidgets('registro legado exibe quantidades sem nomes', (tester) async {
    await _pumpPagina(
      tester,
      listarMembros: () async => [coordenadora],
      acao: criarAcaoTeste(agentesTransito: 3, equipeTerceirizada: 2),
    );

    expect(
      find.text(
          '3 participante(s) sem identificação nominal (registro anterior).'),
      findsOneWidget,
    );
    expect(
      find.text(
          '2 participante(s) sem identificação nominal (registro anterior).'),
      findsOneWidget,
    );
  });

  testWidgets(
      'seletor separa vínculos, preserva inativo histórico e trava coordenador',
      (tester) async {
    final historico = _membro(
      id: 'historico',
      nome: 'Agente Histórico',
      vinculo: VinculoOperacional.agente,
      ativo: false,
    );
    final inativoNovo = _membro(
      id: 'inativo-novo',
      nome: 'Agente Inativo Novo',
      vinculo: VinculoOperacional.agente,
      ativo: false,
    );
    await _pumpPagina(
      tester,
      listarMembros: () async => [
        coordenadora,
        agente,
        terceirizado,
        historico,
        inativoNovo,
      ],
      acao: criarAcaoTeste(
        agenteEquipeIds: const ['historico'],
        agenteEquipeNomes: const ['Agente Histórico'],
      ),
    );

    await Scrollable.ensureVisible(
      tester.element(find.text('Selecionar').first),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selecionar').first);
    await tester.pumpAndSettle();

    expect(find.text('Coordenadora Ana'), findsWidgets);
    expect(find.text('Agente Bruno'), findsOneWidget);
    expect(find.text('Agente Histórico'), findsWidgets);
    expect(find.text('Agente Inativo Novo'), findsNothing);
    expect(find.text('Terceirizada Carla'), findsNothing);
    final coordenadorTile = tester.widget<CheckboxListTile>(
      find.ancestor(
        of: find.text('Coordenadora Ana'),
        matching: find.byType(CheckboxListTile),
      ),
    );
    expect(coordenadorTile.value, isTrue);
    expect(coordenadorTile.onChanged, isNull);
  });

  testWidgets('Voltar persiste recursos no controller', (tester) async {
    final resultado = await _pumpPagina(
      tester,
      listarMembros: () async => [coordenadora],
      acao: criarAcaoTeste(materialUtilizadoIds: const ['material_cone']),
    );

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('CARACTERIZAÇÃO'), findsOneWidget);
    expect(resultado.controller.acaoAtual!.agenteEquipeIds, ['coord-1']);
    expect(resultado.controller.acaoAtual!.agenteEquipeNomes,
        ['Coordenadora Ana']);
    expect(resultado.repository.rascunhosSalvos, greaterThanOrEqualTo(1));
  });

  testWidgets('confirmação exige material e avança após seleção',
      (tester) async {
    await _pumpPagina(
      tester,
      listarMembros: () async => [coordenadora],
      acao: criarAcaoTeste(),
    );

    await tester.tap(find.text('Confirmar e avançar'));
    await tester.pump();
    expect(
        find.text('Selecione ao menos um material utilizado.'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Cone'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    final cone = find.widgetWithText(FilterChip, 'Cone');
    await tester.tap(cone);
    await tester.pump();
    await tester.tap(find.text('Confirmar e avançar'));
    await tester.pumpAndSettle();

    expect(find.text('INTEGRAÇÃO'), findsOneWidget);
  });

  testWidgets('erro de carregamento oferece retry funcional', (tester) async {
    var tentativas = 0;
    await _pumpPagina(
      tester,
      listarMembros: () async {
        tentativas++;
        if (tentativas == 1) throw Exception('indisponível');
        return [coordenadora];
      },
      acao: criarAcaoTeste(),
    );

    expect(find.text('TENTAR NOVAMENTE'), findsOneWidget);
    await tester.tap(find.text('TENTAR NOVAMENTE'));
    await tester.pumpAndSettle();

    expect(tentativas, 2);
    expect(find.text('TENTAR NOVAMENTE'), findsNothing);
    expect(find.text('Coordenadora Ana'), findsWidgets);
  });

  testWidgets('baseline aceita coordenador inativo encontrado', (tester) async {
    final coordenadorInativo = _membro(
      id: 'coord-1',
      nome: 'Coordenadora Ana',
      vinculo: VinculoOperacional.agente,
      ativo: false,
      podeCoordenar: true,
    );
    await _pumpPagina(
      tester,
      listarMembros: () async => [coordenadorInativo],
      acao: criarAcaoTeste(materialUtilizadoIds: const ['material_cone']),
    );

    await tester.tap(find.text('Confirmar e avançar'));
    await tester.pumpAndSettle();
    expect(find.text('INTEGRAÇÃO'), findsOneWidget);
  });

  testWidgets('baseline aceita coordenador sem podeCoordenar', (tester) async {
    final coordenadorSemPermissao = _membro(
      id: 'coord-1',
      nome: 'Coordenadora Ana',
      vinculo: VinculoOperacional.agente,
      podeCoordenar: false,
    );
    await _pumpPagina(
      tester,
      listarMembros: () async => [coordenadorSemPermissao],
      acao: criarAcaoTeste(materialUtilizadoIds: const ['material_cone']),
    );

    await tester.tap(find.text('Confirmar e avançar'));
    await tester.pumpAndSettle();
    expect(find.text('INTEGRAÇÃO'), findsOneWidget);
  });
}
