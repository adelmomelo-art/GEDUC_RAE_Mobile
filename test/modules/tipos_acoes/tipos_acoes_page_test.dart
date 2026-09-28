import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/tipo_acao_service.dart';
import 'package:geduc_rae_mobile/data/models/tipo_acao_model.dart';
import 'package:geduc_rae_mobile/modules/tipos_acoes/controllers/tipo_acao_controller.dart';
import 'package:geduc_rae_mobile/modules/tipos_acoes/tipo_acao_form_args.dart';
import 'package:geduc_rae_mobile/modules/tipos_acoes/tipo_acao_form_page.dart';
import 'package:geduc_rae_mobile/modules/tipos_acoes/tipos_acoes_page.dart';
import 'package:geduc_rae_mobile/repositories/tipo_acao_repository.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('lista, resume e filtra o catálogo sem acessar Firestore', (
    tester,
  ) async {
    final fonte = _FakeDataSource(<TipoAcaoModel>[
      _tipo(id: 'palestra', nome: 'Palestra Escolar', material: 'Faixa'),
      _tipo(id: 'blitz', nome: 'Blitz Educativa', ativo: false),
    ]);

    await _pumpLista(tester, fonte);

    expect(find.text('Palestra Escolar'), findsOneWidget);
    expect(find.text('Blitz Educativa'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('tipo-acao-total')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('tipo-acao-busca')),
      'faixa',
    );
    await tester.pump();

    expect(find.text('Palestra Escolar'), findsOneWidget);
    expect(find.text('Blitz Educativa'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('filtro-inativos')));
    await tester.pump();
    expect(find.text('Palestra Escolar'), findsNothing);
    expect(find.text('Blitz Educativa'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('tipo-acao-limpar-filtros')),
    );
    await tester.pump();
    expect(find.text('Blitz Educativa'), findsOneWidget);
  });

  testWidgets('inativação exige confirmação e preserva o item', (tester) async {
    final fonte = _FakeDataSource(<TipoAcaoModel>[
      _tipo(id: 'palestra', nome: 'Palestra Escolar'),
    ]);
    await _pumpLista(tester, fonte);

    final botao = find.byKey(const ValueKey('tipo-acao-status-palestra'));
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pumpAndSettle();

    expect(find.text('Inativar tipo de ação?'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('tipo-acao-status-confirmar')),
    );
    await tester.pumpAndSettle();

    expect(fonte.tipos.single.ativo, isFalse);
    expect(find.text('Palestra Escolar'), findsOneWidget);
  });

  testWidgets('formulário cria tipo normalizado pelo controller',
      (tester) async {
    final fonte = _FakeDataSource(<TipoAcaoModel>[]);
    final controller = _controller(fonte);

    await tester.pumpWidget(
      ChangeNotifierProvider<TipoAcaoController>.value(
        value: controller,
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const TipoAcaoFormPage(args: TipoAcaoFormArgs()),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('tipo-acao-nome')),
      '  Palestra   Educativa ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('tipo-acao-classificacao')),
      ' Escola ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('tipo-acao-estimado')),
      '100',
    );
    await tester.enterText(
      find.byKey(const ValueKey('tipo-acao-minimo')),
      '20',
    );
    await tester.enterText(
      find.byKey(const ValueKey('tipo-acao-materiais')),
      'Cone, Faixa; cone',
    );

    final salvar = find.byKey(const ValueKey('tipo-acao-salvar'));
    await tester.ensureVisible(salvar);
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    expect(fonte.salvos, hasLength(1));
    expect(fonte.salvos.single.nomeAcao, 'Palestra Educativa');
    expect(fonte.salvos.single.tipoAcao, 'Escola');
    expect(fonte.salvos.single.materiaisSugeridos, <String>['Cone', 'Faixa']);
  });

  for (final tamanho in <Size>[const Size(360, 800), const Size(800, 1280)]) {
    testWidgets('não gera overflow em ${tamanho.width.toInt()}px',
        (tester) async {
      await tester.binding.setSurfaceSize(tamanho);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpLista(
        tester,
        _FakeDataSource(<TipoAcaoModel>[
          _tipo(
            id: 'item',
            nome: 'Atividade educativa com título responsivo',
            material: 'Material educativo de apoio',
          ),
        ]),
      );

      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpLista(
  WidgetTester tester,
  _FakeDataSource fonte,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<TipoAcaoController>.value(
      value: _controller(fonte),
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const TiposAcoesPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TipoAcaoController _controller(_FakeDataSource fonte) {
  return TipoAcaoController(
    tipoAcaoRepository: TipoAcaoRepository(dataSource: fonte),
  );
}

TipoAcaoModel _tipo({
  required String id,
  required String nome,
  bool ativo = true,
  String material = 'Cone',
}) {
  return TipoAcaoModel(
    id: id,
    nomeAcao: nome,
    tipoAcao: 'Educação',
    publicoEstimadoPadrao: 100,
    publicoMinimoPadrao: 10,
    materiaisSugeridos: <String>[material],
    ativo: ativo,
  );
}

class _FakeDataSource implements TipoAcaoDataSource {
  _FakeDataSource(List<TipoAcaoModel> tipos)
      : tipos = <TipoAcaoModel>[...tipos];

  final List<TipoAcaoModel> tipos;
  final List<TipoAcaoModel> salvos = <TipoAcaoModel>[];

  @override
  Future<void> alterarStatus(String id, bool ativo) async {
    final indice = tipos.indexWhere((tipo) => tipo.id == id);
    if (indice >= 0) tipos[indice] = tipos[indice].copyWith(ativo: ativo);
  }

  @override
  Future<void> atualizarTipoAcao(TipoAcaoModel tipoAcao) async {
    final indice = tipos.indexWhere((tipo) => tipo.id == tipoAcao.id);
    if (indice >= 0) tipos[indice] = tipoAcao;
  }

  @override
  Future<List<TipoAcaoModel>> listarTiposAcoes({
    bool somenteAtivos = false,
  }) async {
    return tipos
        .where((tipo) => !somenteAtivos || tipo.ativo)
        .toList(growable: false);
  }

  @override
  Future<TipoAcaoModel> salvarTipoAcao(TipoAcaoModel tipoAcao) async {
    final salvo = tipoAcao.normalizado().copyWith(id: 'novo-id');
    tipos.add(salvo);
    salvos.add(salvo);
    return salvo;
  }
}
