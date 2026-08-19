import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/access_scope.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/data/models/equipe_model.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/data/models/projeto_model.dart';
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
  String? usuarioId,
  required String nome,
  required VinculoOperacional vinculo,
  bool ativo = true,
  bool podeCoordenar = false,
}) {
  return MembroEquipeModel(
    id: id,
    usuarioId: usuarioId ?? id,
    nome: nome,
    vinculo: vinculo,
    podeCoordenar: podeCoordenar,
    ativo: ativo,
    origem: 'usuario',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

EquipeModel _equipeAcl({
  required String id,
  required List<String> regionalIds,
  required List<String> coordenadorUserIds,
  bool ativo = true,
}) {
  return EquipeModel(
    id: id,
    nome: 'Equipe $id',
    regionalIds: regionalIds,
    coordenadorUserIds: coordenadorUserIds,
    ativo: ativo,
  );
}

ProjetoModel _projetoAcl({
  required String id,
  required List<String> regionalIds,
  required List<String> equipeIds,
  bool ativo = true,
}) {
  return ProjetoModel(
    id: id,
    nome: 'Projeto $id',
    regionalIds: regionalIds,
    equipeIds: equipeIds,
    ativo: ativo,
  );
}

Future<({AcaoController controller, _FakeAcaoRepository repository})>
    _pumpPagina(
  WidgetTester tester, {
  required Future<List<MembroEquipeModel>> Function() listarMembros,
  required AcaoModel acao,
  AccessScope? escopoAcesso,
  Future<List<EquipeModel>> Function()? listarEquipes,
  Future<List<ProjetoModel>> Function()? listarProjetos,
}) async {
  final repository = _FakeAcaoRepository();

  final controller = AcaoController(
    acaoRepository: repository,
  )..acaoAtual = acao;

  final router = GoRouter(
    initialLocation: '/recursos-operacionais',
    routes: [
      GoRoute(
        path: '/recursos-operacionais',
        builder: (_, __) => RecursosOperacionaisPage(
          listarMembros: listarMembros,
          responsavelUserId: 'usuario-responsavel-teste',
          escopoAcesso: escopoAcesso ?? AccessScope(),
          listarEquipes: listarEquipes ?? () async => const <EquipeModel>[],
          listarProjetos: listarProjetos ?? () async => const <ProjetoModel>[],
        ),
      ),
      GoRoute(
        path: '/caracterizacao-acao',
        builder: (_, __) => const Scaffold(
          body: Text('CARACTERIZAÇÃO'),
        ),
      ),
      GoRoute(
        path: '/integracao-observacoes',
        builder: (_, __) => const Scaffold(
          body: Text('INTEGRAÇÃO'),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );

  await tester.pumpAndSettle();

  return (
    controller: controller,
    repository: repository,
  );
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

  testWidgets(
    'carrega equipe nominal e restaura materiais existentes',
    (tester) async {
      await _pumpPagina(
        tester,
        listarMembros: () async => [
          coordenadora,
          agente,
          terceirizado,
        ],
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
    },
  );

  testWidgets(
    'registro legado exibe quantidades sem nomes',
    (tester) async {
      await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadora],
        acao: criarAcaoTeste(
          agentesTransito: 3,
          equipeTerceirizada: 2,
        ),
      );

      expect(
        find.text(
          '3 participante(s) sem identificação nominal (registro anterior).',
        ),
        findsOneWidget,
      );

      expect(
        find.text(
          '2 participante(s) sem identificação nominal (registro anterior).',
        ),
        findsOneWidget,
      );
    },
  );

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
    },
  );

  testWidgets(
    'Voltar persiste recursos no controller',
    (tester) async {
      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadora],
        acao: criarAcaoTeste(
          materialUtilizadoIds: const ['material_cone'],
        ),
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('CARACTERIZAÇÃO'), findsOneWidget);
      expect(
        resultado.controller.acaoAtual!.agenteEquipeIds,
        ['coord-1'],
      );
      expect(
        resultado.controller.acaoAtual!.agenteEquipeNomes,
        ['Coordenadora Ana'],
      );
      expect(
        resultado.repository.rascunhosSalvos,
        greaterThanOrEqualTo(1),
      );
    },
  );

  testWidgets(
    'confirmação exige material e avança após seleção',
    (tester) async {
      await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadora],
        acao: criarAcaoTeste(),
      );

      await tester.tap(find.text('Confirmar e avançar'));
      await tester.pump();

      expect(
        find.text('Selecione ao menos um material utilizado.'),
        findsOneWidget,
      );

      await tester.dragUntilVisible(
        find.text('Cone'),
        find.byType(ListView),
        const Offset(0, -300),
      );

      await tester.tap(
        find.widgetWithText(FilterChip, 'Cone'),
      );
      await tester.pump();

      await tester.tap(find.text('Confirmar e avançar'));
      await tester.pumpAndSettle();

      expect(find.text('INTEGRAÇÃO'), findsOneWidget);
    },
  );

  testWidgets(
    'erro de carregamento oferece retry funcional',
    (tester) async {
      var tentativas = 0;

      await _pumpPagina(
        tester,
        listarMembros: () async {
          tentativas++;

          if (tentativas == 1) {
            throw Exception('indisponível');
          }

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
    },
  );

  testWidgets(
    'bloqueia coordenador inativo encontrado',
    (tester) async {
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
        acao: criarAcaoTeste(
          materialUtilizadoIds: const ['material_cone'],
        ),
      );

      await tester.tap(find.text('Confirmar e avançar'));
      await tester.pump();

      expect(find.text('INTEGRAÇÃO'), findsNothing);
      expect(
        find.text(
          'Vincule o coordenador à Equipe Operacional antes de avançar.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'bloqueia coordenador sem habilitação para coordenar',
    (tester) async {
      final coordenadorSemPermissao = _membro(
        id: 'coord-1',
        nome: 'Coordenadora Ana',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: false,
      );

      await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadorSemPermissao],
        acao: criarAcaoTeste(
          materialUtilizadoIds: const ['material_cone'],
        ),
      );

      await tester.tap(find.text('Confirmar e avançar'));
      await tester.pump();

      expect(find.text('INTEGRAÇÃO'), findsNothing);
      expect(
        find.text(
          'Vincule o coordenador à Equipe Operacional antes de avançar.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'bloqueia coordenador resolvido apenas por fallback de nome',
    (tester) async {
      final coordenadorSomentePorNome = _membro(
        id: 'coord-catalogo',
        usuarioId: 'usuario-coord-fallback',
        nome: 'Coordenadora Ana',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: true,
      );

      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadorSomentePorNome],
        acao: criarAcaoTeste(
          coordenadorId: 'uid-diferente',
          coordenadorNome: 'Coordenadora Ana',
          materialUtilizadoIds: const ['material_cone'],
        ),
      );

      expect(
        find.textContaining('localizado apenas pelo nome'),
        findsWidgets,
      );

      await tester.tap(find.text('Confirmar e avançar'));
      await tester.pump();

      expect(find.text('INTEGRAÇÃO'), findsNothing);
      expect(
        find.text(
          'Vincule o coordenador à Equipe Operacional antes de avançar.',
        ),
        findsOneWidget,
      );

      expect(
        resultado.controller.acaoAtual!.coordenadorUserId,
        isEmpty,
      );
    },
  );

  testWidgets(
    'cancelar migração nominal preserva registro legado',
    (tester) async {
      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [
          coordenadora,
          agente,
        ],
        acao: criarAcaoTeste(
          agentesTransito: 3,
          equipeTerceirizada: 2,
          materialUtilizadoIds: const ['material_cone'],
        ),
      );

      await Scrollable.ensureVisible(
        tester.element(find.text('Selecionar').first),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selecionar').first);
      await tester.pumpAndSettle();

      expect(find.text('Agente Bruno'), findsOneWidget);

      final agenteTile = tester.widget<CheckboxListTile>(
        find.ancestor(
          of: find.text('Agente Bruno'),
          matching: find.byType(CheckboxListTile),
        ),
      );

      expect(agenteTile.value, isFalse);

      await tester.tap(
        find.ancestor(
          of: find.text('Agente Bruno'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('CONFIRMAR'));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar equipe histórica?'), findsOneWidget);
      expect(find.textContaining('3 agente(s)'), findsOneWidget);
      expect(find.textContaining('2 terceirizado(s)'), findsOneWidget);

      await tester.tap(find.text('CANCELAR'));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar equipe histórica?'), findsNothing);

      expect(
        find.text(
          '3 participante(s) sem identificação nominal (registro anterior).',
        ),
        findsOneWidget,
      );

      expect(
        find.text(
          '2 participante(s) sem identificação nominal (registro anterior).',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(resultado.controller.acaoAtual!.agentesTransito, 3);
      expect(resultado.controller.acaoAtual!.equipeTerceirizada, 2);
      expect(
        resultado.controller.acaoAtual!.agenteEquipeIds,
        isEmpty,
      );
      expect(
        resultado.controller.acaoAtual!.terceirizadoEquipeIds,
        isEmpty,
      );
    },
  );

  testWidgets(
    'confirmar migração converte registro legado para equipe nominal',
    (tester) async {
      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [
          coordenadora,
          agente,
        ],
        acao: criarAcaoTeste(
          agentesTransito: 3,
          equipeTerceirizada: 0,
          materialUtilizadoIds: const ['material_cone'],
        ),
      );

      await Scrollable.ensureVisible(
        tester.element(find.text('Selecionar').first),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selecionar').first);
      await tester.pumpAndSettle();

      await tester.tap(
        find.ancestor(
          of: find.text('Agente Bruno'),
          matching: find.byType(CheckboxListTile),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('CONFIRMAR'));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar equipe histórica?'), findsOneWidget);

      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar equipe histórica?'), findsNothing);

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(
        resultado.controller.acaoAtual!.agenteEquipeIds,
        containsAll([
          'coord-1',
          'agente-1',
        ]),
      );

      expect(
        resultado.controller.acaoAtual!.agenteEquipeNomes,
        containsAll([
          'Coordenadora Ana',
          'Agente Bruno',
        ]),
      );

      expect(resultado.controller.acaoAtual!.agentesTransito, 2);
    },
  );

  testWidgets(
    'persiste responsavelUserId no RAE',
    (tester) async {
      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadora],
        acao: criarAcaoTeste(
          materialUtilizadoIds: const ['material_cone'],
        ),
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(
        resultado.controller.acaoAtual!.responsavelUserId,
        'usuario-responsavel-teste',
      );
    },
  );

  testWidgets(
    'converte id operacional do coordenador para usuarioId canônico',
    (tester) async {
      final coordenadorComIdentidadeCanonica = _membro(
        id: 'coord-operacional-1',
        usuarioId: 'usuario-coordenador-99',
        nome: 'Coordenadora Canônica',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: true,
      );

      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [
          coordenadorComIdentidadeCanonica,
        ],
        acao: criarAcaoTeste(
          coordenadorId: 'coord-operacional-1',
          coordenadorNome: 'Coordenadora Canônica',
          materialUtilizadoIds: const ['material_cone'],
        ),
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(
        resultado.controller.acaoAtual!.coordenadorUserId,
        'usuario-coordenador-99',
      );

      expect(
        resultado.controller.acaoAtual!.coordenadorUserId,
        isNot('coord-operacional-1'),
      );

      expect(
        resultado.controller.acaoAtual!.responsavelUserId,
        'usuario-responsavel-teste',
      );
    },
  );

  testWidgets(
    'resolução ACL única grava equipeId e projetoId',
    (tester) async {
      final coordenadorCanonico = _membro(
        id: 'coord-operacional-1',
        usuarioId: 'usuario-coordenador-1',
        nome: 'Coordenadora Canônica',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: true,
      );

      final acao = criarAcaoTeste(
        coordenadorId: 'coord-operacional-1',
        coordenadorNome: 'Coordenadora Canônica',
        materialUtilizadoIds: const ['material_cone'],
      ).copyWith(
        regionalId: 'regional-1',
      );

      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadorCanonico],
        acao: acao,
        escopoAcesso: AccessScope(
          regionalIds: const ['regional-1'],
          equipeIds: const ['equipe-1'],
          projetoIds: const ['projeto-1'],
        ),
        listarEquipes: () async => [
          _equipeAcl(
            id: 'equipe-1',
            regionalIds: const ['regional-1'],
            coordenadorUserIds: const ['usuario-coordenador-1'],
          ),
        ],
        listarProjetos: () async => [
          _projetoAcl(
            id: 'projeto-1',
            regionalIds: const ['regional-1'],
            equipeIds: const ['equipe-1'],
          ),
        ],
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(resultado.controller.acaoAtual!.equipeId, 'equipe-1');
      expect(resultado.controller.acaoAtual!.projetoId, 'projeto-1');
      expect(
        resultado.controller.acaoAtual!.aclClassificacaoCompleta,
        isFalse,
      );
      expect(resultado.controller.acaoAtual!.aclScopeKey, isEmpty);
    },
  );

  testWidgets(
    'ambiguidade de equipe não grava classificação de escopo',
    (tester) async {
      final coordenadorCanonico = _membro(
        id: 'coord-operacional-1',
        usuarioId: 'usuario-coordenador-1',
        nome: 'Coordenadora Canônica',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: true,
      );

      final acao = criarAcaoTeste(
        coordenadorId: 'coord-operacional-1',
        coordenadorNome: 'Coordenadora Canônica',
        materialUtilizadoIds: const ['material_cone'],
      ).copyWith(
        regionalId: 'regional-1',
        equipeId: 'equipe-antiga',
        projetoId: 'projeto-antigo',
      );

      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadorCanonico],
        acao: acao,
        escopoAcesso: AccessScope(
          regionalIds: const ['regional-1'],
          equipeIds: const ['equipe-1', 'equipe-2'],
          projetoIds: const ['projeto-1'],
        ),
        listarEquipes: () async => [
          _equipeAcl(
            id: 'equipe-1',
            regionalIds: const ['regional-1'],
            coordenadorUserIds: const ['usuario-coordenador-1'],
          ),
          _equipeAcl(
            id: 'equipe-2',
            regionalIds: const ['regional-1'],
            coordenadorUserIds: const ['usuario-coordenador-1'],
          ),
        ],
        listarProjetos: () async => [
          _projetoAcl(
            id: 'projeto-1',
            regionalIds: const ['regional-1'],
            equipeIds: const ['equipe-1'],
          ),
        ],
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(resultado.controller.acaoAtual!.equipeId, isEmpty);
      expect(resultado.controller.acaoAtual!.projetoId, isEmpty);
    },
  );

  testWidgets(
    'escopo vazio não grava classificação de escopo',
    (tester) async {
      final coordenadorCanonico = _membro(
        id: 'coord-operacional-1',
        usuarioId: 'usuario-coordenador-1',
        nome: 'Coordenadora Canônica',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: true,
      );

      final acao = criarAcaoTeste(
        coordenadorId: 'coord-operacional-1',
        coordenadorNome: 'Coordenadora Canônica',
        materialUtilizadoIds: const ['material_cone'],
      ).copyWith(
        regionalId: 'regional-1',
        equipeId: 'equipe-antiga',
        projetoId: 'projeto-antigo',
      );

      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadorCanonico],
        acao: acao,
        escopoAcesso: AccessScope(),
        listarEquipes: () async => [
          _equipeAcl(
            id: 'equipe-1',
            regionalIds: const ['regional-1'],
            coordenadorUserIds: const ['usuario-coordenador-1'],
          ),
        ],
        listarProjetos: () async => [
          _projetoAcl(
            id: 'projeto-1',
            regionalIds: const ['regional-1'],
            equipeIds: const ['equipe-1'],
          ),
        ],
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(resultado.controller.acaoAtual!.equipeId, isEmpty);
      expect(resultado.controller.acaoAtual!.projetoId, isEmpty);
    },
  );
  testWidgets(
    'regional fora do AccessScope limpa equipe e projeto',
    (tester) async {
      final coordenadorCanonico = _membro(
        id: 'coord-operacional-r1',
        usuarioId: 'usuario-coordenador-r1',
        nome: 'Coordenadora R1',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: true,
      );

      final acao = criarAcaoTeste(
        coordenadorId: 'coord-operacional-r1',
        coordenadorNome: 'Coordenadora R1',
        materialUtilizadoIds: const ['material_cone'],
      ).copyWith(
        regionalId: 'regional-1',
        equipeId: 'equipe-antiga',
        projetoId: 'projeto-antigo',
      );

      final resultado = await _pumpPagina(
        tester,
        listarMembros: () async => [coordenadorCanonico],
        acao: acao,
        escopoAcesso: AccessScope(
          regionalIds: const ['regional-2'],
          equipeIds: const ['equipe-1'],
          projetoIds: const ['projeto-1'],
        ),
        listarEquipes: () async => [
          _equipeAcl(
            id: 'equipe-1',
            regionalIds: const ['regional-1'],
            coordenadorUserIds: const ['usuario-coordenador-r1'],
          ),
        ],
        listarProjetos: () async => [
          _projetoAcl(
            id: 'projeto-1',
            regionalIds: const ['regional-1'],
            equipeIds: const ['equipe-1'],
          ),
        ],
      );

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(resultado.controller.acaoAtual!.equipeId, isEmpty);
      expect(resultado.controller.acaoAtual!.projetoId, isEmpty);
    },
  );
}
