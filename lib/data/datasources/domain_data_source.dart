import '../models/domain_model.dart';

abstract class DomainDataSource {
  Future<List<DomainModel>> listarTodos();

  Future<List<DomainModel>> listarPorGrupo(String grupo);

  Future<DomainModel?> buscarPorId(String id);

  Future<DomainModel?> buscarPorCodigo({
    required String grupo,
    required String codigo,
  });

  Future<void> salvar(DomainModel domain);

  Future<void> salvarTodos(List<DomainModel> domains);

  Future<void> ativar(String id);

  Future<void> desativar(String id);
}
