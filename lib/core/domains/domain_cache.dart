import '../../data/models/domain_model.dart';

class DomainCache {
  final Duration validade;

  final Map<String, DomainCacheEntry> _grupos = {};

  DomainCache({
    this.validade = const Duration(minutes: 10),
  });

  /// Retorna somente uma entrada ainda válida.
  List<DomainModel>? obter(String grupo) {
    final entrada = obterEntrada(grupo);

    if (entrada == null || entrada.expirado) {
      return null;
    }

    return entrada.itens;
  }

  /// Retorna a entrada mesmo que o TTL já tenha expirado.
  ///
  /// É usado como fallback quando a fonte remota está indisponível.
  List<DomainModel>? obterMesmoExpirado(String grupo) {
    return obterEntrada(grupo)?.itens;
  }

  DomainCacheEntry? obterEntrada(String grupo) {
    return _grupos[grupo];
  }

  void armazenar(String grupo, List<DomainModel> itens) {
    final armazenadoEm = DateTime.now();

    _grupos[grupo] = DomainCacheEntry(
      itens: itens,
      armazenadoEm: armazenadoEm,
      expiraEm: armazenadoEm.add(validade),
    );
  }

  bool contem(String grupo) {
    return obter(grupo) != null;
  }

  bool contemMesmoExpirado(String grupo) {
    return _grupos.containsKey(grupo);
  }

  bool expirou(String grupo) {
    return obterEntrada(grupo)?.expirado ?? false;
  }

  Duration? idade(String grupo) {
    final entrada = obterEntrada(grupo);

    if (entrada == null) {
      return null;
    }

    return DateTime.now().difference(entrada.armazenadoEm);
  }

  void invalidarGrupo(String grupo) {
    _grupos.remove(grupo);
  }

  void limparExpirados() {
    final gruposExpirados = _grupos.entries
        .where((entry) => entry.value.expirado)
        .map((entry) => entry.key)
        .toList(growable: false);

    for (final grupo in gruposExpirados) {
      _grupos.remove(grupo);
    }
  }

  void limpar() {
    _grupos.clear();
  }
}

class DomainCacheEntry {
  final List<DomainModel> itens;
  final DateTime armazenadoEm;
  final DateTime expiraEm;

  DomainCacheEntry({
    required List<DomainModel> itens,
    required this.armazenadoEm,
    required this.expiraEm,
  }) : itens = List<DomainModel>.unmodifiable(itens);

  bool get expirado {
    return !DateTime.now().isBefore(expiraEm);
  }
}
