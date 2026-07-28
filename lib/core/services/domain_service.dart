import '../../data/datasources/domain_data_source.dart';
import '../../data/datasources/firestore_domain_data_source.dart';
import '../../data/models/domain_model.dart';

class DomainService {
  final DomainDataSource dataSource;

  DomainService({
    DomainDataSource? dataSource,
  }) : dataSource = dataSource ?? FirestoreDomainDataSource();

  Future<List<DomainModel>> listarTodos() {
    return dataSource.listarTodos();
  }

  Future<List<DomainModel>> listarPorGrupo(String grupo) {
    return dataSource.listarPorGrupo(grupo);
  }

  Future<DomainModel?> buscarPorId(String id) {
    return dataSource.buscarPorId(id);
  }

  Future<DomainModel?> buscarPorCodigo({
    required String grupo,
    required String codigo,
  }) {
    return dataSource.buscarPorCodigo(
      grupo: grupo,
      codigo: codigo,
    );
  }

  Future<void> criar(DomainModel domain) {
    return dataSource.criar(domain);
  }

  Future<void> atualizar(DomainModel domain) {
    return dataSource.atualizar(domain);
  }

  Future<void> salvarTodosSeAusentes(
    List<DomainModel> domains,
  ) {
    return dataSource.salvarTodosSeAusentes(domains);
  }

  Future<void> ativar(String id) {
    return dataSource.ativar(id);
  }

  Future<void> desativar(String id) {
    return dataSource.desativar(id);
  }

  Future<void> limparCache() async {
    // Mantido por compatibilidade com a API pública existente.
  }
}
