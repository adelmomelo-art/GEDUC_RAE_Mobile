import '../../data/models/domain_model.dart';

class DomainService {
  final List<DomainModel> _cache = [];

  Future<List<DomainModel>> listarTodos() async {
    return List<DomainModel>.unmodifiable(_cache);
  }

  Future<List<DomainModel>> listarPorGrupo(String grupo) async {
    final dominios = _cache
        .where((domain) => domain.grupo == grupo && domain.vigente)
        .toList();

    dominios.sort((a, b) {
      final comparacaoOrdem = a.ordem.compareTo(b.ordem);

      if (comparacaoOrdem != 0) {
        return comparacaoOrdem;
      }

      return a.nome.compareTo(b.nome);
    });

    return List<DomainModel>.unmodifiable(dominios);
  }

  Future<DomainModel?> buscarPorId(String id) async {
    try {
      return _cache.firstWhere((domain) => domain.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<DomainModel?> buscarPorCodigo({
    required String grupo,
    required String codigo,
  }) async {
    try {
      return _cache.firstWhere(
        (domain) => domain.grupo == grupo && domain.codigo == codigo,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> salvar(DomainModel domain) async {
    final index = _cache.indexWhere((item) => item.id == domain.id);

    if (index >= 0) {
      _cache[index] = domain;
      return;
    }

    _cache.add(domain);
  }

  Future<void> salvarTodos(List<DomainModel> domains) async {
    for (final domain in domains) {
      await salvar(domain);
    }
  }

  Future<void> ativar(String id) async {
    final domain = await buscarPorId(id);

    if (domain == null) {
      return;
    }

    await salvar(domain.copyWith(ativo: true));
  }

  Future<void> desativar(String id) async {
    final domain = await buscarPorId(id);

    if (domain == null) {
      return;
    }

    await salvar(domain.copyWith(ativo: false));
  }

  Future<void> limparCache() async {
    _cache.clear();
  }
}
