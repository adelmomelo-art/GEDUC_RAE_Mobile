import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/tipo_acao_service.dart';
import 'package:geduc_rae_mobile/data/models/tipo_acao_model.dart';
import 'package:geduc_rae_mobile/modules/admin/controllers/tipo_acao_controller.dart';
import 'package:geduc_rae_mobile/repositories/tipo_acao_repository.dart';

void main() {
  group('TipoAcaoController', () {
    test('carrega tipos e sempre encerra o loading', () async {
      final fonte = _FakeTipoAcaoDataSource(
        tipos: <TipoAcaoModel>[_tipo(id: '1', nome: 'Palestra')],
      );
      final controller = _controller(fonte);

      await controller.carregar();

      expect(controller.carregando, isFalse);
      expect(controller.tipos, hasLength(1));
      expect(controller.erro, isNull);
    });

    test('registra erro e encerra o loading quando a fonte falha', () async {
      final controller = _controller(
        _FakeTipoAcaoDataSource(erroAoListar: Exception('falha')),
      );

      await controller.carregar();

      expect(controller.carregando, isFalse);
      expect(controller.tipos, isEmpty);
      expect(controller.erro, isNotNull);
    });

    test('filtra por texto, material e situação', () async {
      final controller = _controller(
        _FakeTipoAcaoDataSource(
          tipos: <TipoAcaoModel>[
            _tipo(
              id: '1',
              nome: 'Palestra Escolar',
              material: 'Faixa educativa',
            ),
            _tipo(id: '2', nome: 'Blitz', ativo: false),
          ],
        ),
      );
      await controller.carregar();

      controller.definirFiltroTexto('faixa');
      expect(controller.tiposFiltrados.single.id, '1');

      controller.definirFiltroTexto('');
      controller.definirFiltroStatus(TipoAcaoFiltroStatus.inativos);
      expect(controller.tiposFiltrados.single.id, '2');
    });

    test('impede criação duplicada por nome e tipo normalizados', () async {
      final fonte = _FakeTipoAcaoDataSource(
        tipos: <TipoAcaoModel>[_tipo(id: '1', nome: 'Ação Educativa')],
      );
      final controller = _controller(fonte);
      await controller.carregar();

      final resultado = await controller.criar(
        _tipo(id: '', nome: 'acao   educativa'),
      );

      expect(resultado, isNull);
      expect(controller.salvando, isFalse);
      expect(controller.erro, contains('Já existe'));
      expect(fonte.salvos, isEmpty);
    });

    test('cria, atualiza e altera status mantendo o estado local', () async {
      final fonte = _FakeTipoAcaoDataSource();
      final controller = _controller(fonte);

      final criado = await controller.criar(_tipo(id: '', nome: 'Palestra'));
      expect(criado, isNotNull);
      expect(controller.tipos.single.id, 'novo-id');

      final atualizado = controller.tipos.single.copyWith(
        nomeAcao: 'Seminário',
      );
      expect(await controller.atualizar(atualizado), isTrue);
      expect(controller.tipos.single.nomeAcao, 'Seminário');

      expect(await controller.alterarStatus(atualizado, false), isTrue);
      expect(controller.tipos.single.ativo, isFalse);
    });
  });
}

TipoAcaoController _controller(_FakeTipoAcaoDataSource fonte) {
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

class _FakeTipoAcaoDataSource implements TipoAcaoDataSource {
  _FakeTipoAcaoDataSource({List<TipoAcaoModel>? tipos, this.erroAoListar})
    : tipos = <TipoAcaoModel>[...?tipos];

  final List<TipoAcaoModel> tipos;
  final Object? erroAoListar;
  final List<TipoAcaoModel> salvos = <TipoAcaoModel>[];

  @override
  Future<void> alterarStatus(String id, bool ativo) async {
    final indice = tipos.indexWhere((tipo) => tipo.id == id);
    if (indice >= 0) {
      tipos[indice] = tipos[indice].copyWith(ativo: ativo);
    }
  }

  @override
  Future<void> atualizarTipoAcao(TipoAcaoModel tipoAcao) async {
    final indice = tipos.indexWhere((tipo) => tipo.id == tipoAcao.id);
    if (indice >= 0) {
      tipos[indice] = tipoAcao;
    }
  }

  @override
  Future<List<TipoAcaoModel>> listarTiposAcoes({
    bool somenteAtivos = false,
  }) async {
    if (erroAoListar != null) {
      throw erroAoListar!;
    }
    return tipos
        .where((tipo) => !somenteAtivos || tipo.ativo)
        .toList(growable: false);
  }

  @override
  Future<TipoAcaoModel> salvarTipoAcao(TipoAcaoModel tipoAcao) async {
    final salvo = tipoAcao.copyWith(
      id: tipoAcao.id.isEmpty ? 'novo-id' : tipoAcao.id,
    );
    tipos.add(salvo);
    salvos.add(salvo);
    return salvo;
  }
}
