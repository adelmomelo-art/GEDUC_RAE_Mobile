import '../core/services/domain_service.dart';
import '../data/models/domain_model.dart';

class DomainRepository {
  final DomainService domainService;

  DomainRepository({
    required this.domainService,
  });

  Future<List<DomainModel>> listarTodos() {
    return domainService.listarTodos();
  }

  Future<List<DomainModel>> listarPorGrupo(String grupo) {
    return domainService.listarPorGrupo(grupo);
  }

  Future<DomainModel?> buscarPorId(String id) {
    return domainService.buscarPorId(id);
  }

  Future<DomainModel?> buscarPorCodigo({
    required String grupo,
    required String codigo,
  }) {
    return domainService.buscarPorCodigo(
      grupo: grupo,
      codigo: codigo,
    );
  }

  Future<void> criar(DomainModel domain) {
    return domainService.criar(domain);
  }

  Future<void> atualizar(DomainModel domain) {
    return domainService.atualizar(domain);
  }

  Future<void> salvarTodosSeAusentes(
    List<DomainModel> domains,
  ) {
    return domainService.salvarTodosSeAusentes(domains);
  }

  Future<void> ativar(String id) {
    return domainService.ativar(id);
  }

  Future<void> desativar(String id) {
    return domainService.desativar(id);
  }

  Future<void> limparCache() {
    return domainService.limparCache();
  }
}
