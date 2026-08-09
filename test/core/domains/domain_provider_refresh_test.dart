import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/domains/domain_groups.dart';
import 'package:geduc_rae_mobile/core/domains/domain_provider.dart';
import 'package:geduc_rae_mobile/core/services/domain_service.dart';
import 'package:geduc_rae_mobile/data/datasources/domain_data_source.dart';
import 'package:geduc_rae_mobile/data/models/domain_model.dart';
import 'package:geduc_rae_mobile/repositories/domain_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('recarregarGrupo substitui catálogo persistido por dados atuais',
      () async {
    SharedPreferences.setMockInitialValues({});
    final dataSource = _FakeDomainDataSource();
    final provider = DomainProvider(
      repository: DomainRepository(
        domainService: DomainService(dataSource: dataSource),
      ),
    );

    dataSource.itens = [
      _domain('sexo_feminino', 'Feminino', 1),
      _domain('sexo_masculino', 'Masculino', 2),
    ];

    await provider.carregarGrupo(DomainGroups.sexoPredominante);
    expect(provider.opcoesDoGrupo(DomainGroups.sexoPredominante), hasLength(2));

    dataSource.itens = [
      ...dataSource.itens,
      _domain('sexo_misto', 'Misto', 3),
    ];

    await provider.recarregarGrupo(DomainGroups.sexoPredominante);

    final opcoes = provider.opcoesDoGrupo(DomainGroups.sexoPredominante);
    expect(opcoes, hasLength(3));
    expect(opcoes['sexo_misto'], 'Misto');
    expect(dataSource.consultas, 2);
  });
}

DomainModel _domain(String id, String nome, int ordem) {
  return DomainModel(
    id: id,
    grupo: DomainGroups.sexoPredominante,
    codigo: id,
    nome: nome,
    ordem: ordem,
  );
}

class _FakeDomainDataSource implements DomainDataSource {
  List<DomainModel> itens = [];
  int consultas = 0;

  @override
  Future<List<DomainModel>> listarPorGrupo(String grupo) async {
    consultas++;
    return itens.where((item) => item.grupo == grupo).toList();
  }

  @override
  Future<List<DomainModel>> listarTodos() async => itens;

  @override
  Future<DomainModel?> buscarPorCodigo({
    required String grupo,
    required String codigo,
  }) async =>
      null;

  @override
  Future<DomainModel?> buscarPorId(String id) async => null;

  @override
  Future<void> atualizar(DomainModel domain) async {}

  @override
  Future<void> criar(DomainModel domain) async {}

  @override
  Future<void> salvarTodosSeAusentes(List<DomainModel> domains) async {}

  @override
  Future<void> ativar(String id) async {}

  @override
  Future<void> desativar(String id) async {}
}
