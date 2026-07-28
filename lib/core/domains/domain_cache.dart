import '../../data/models/domain_model.dart';

class DomainCache {
  final Duration validade;

  final Map<String, _DomainCacheEntry> _grupos = {};

  DomainCache({
    this.validade = const Duration(minutes: 10),
  });

  List<DomainModel>? obter(String grupo) {
    final entrada = _grupos[grupo];

    if (entrada == null || entrada.expirou(validade)) {
      _grupos.remove(grupo);
      return null;
    }

    return List<DomainModel>.unmodifiable(entrada.itens);
  }

  void armazenar(String grupo, List<DomainModel> itens) {
    _grupos[grupo] = _DomainCacheEntry(
      itens: List<DomainModel>.unmodifiable(itens),
      criadoEm: DateTime.now(),
    );
  }

  bool contem(String grupo) {
    return obter(grupo) != null;
  }

  void invalidarGrupo(String grupo) {
    _grupos.remove(grupo);
  }

  void limpar() {
    _grupos.clear();
  }
}

class _DomainCacheEntry {
  final List<DomainModel> itens;
  final DateTime criadoEm;

  const _DomainCacheEntry({
    required this.itens,
    required this.criadoEm,
  });

  bool expirou(Duration validade) {
    return DateTime.now().difference(criadoEm) >= validade;
  }
}
