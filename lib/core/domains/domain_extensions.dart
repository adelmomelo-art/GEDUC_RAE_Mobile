import '../../data/models/domain_model.dart';

extension DomainModelListExtensions on Iterable<DomainModel> {
  List<DomainModel> somenteVigentes() {
    return where((domain) => domain.vigente).toList();
  }

  List<DomainModel> ordenados() {
    final lista = toList();

    lista.sort((a, b) {
      final ordemCompare = a.ordem.compareTo(b.ordem);

      if (ordemCompare != 0) {
        return ordemCompare;
      }

      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });

    return lista;
  }

  Map<String, String> paraMapaDeOpcoes() {
    return {
      for (final domain in this) domain.id: domain.nome,
    };
  }

  DomainModel? buscarPorId(String? id) {
    if (id == null || id.trim().isEmpty) {
      return null;
    }

    for (final domain in this) {
      if (domain.id == id) {
        return domain;
      }
    }

    return null;
  }

  DomainModel? buscarPorCodigo(String? codigo) {
    if (codigo == null || codigo.trim().isEmpty) {
      return null;
    }

    final codigoNormalizado = codigo.trim().toLowerCase();

    for (final domain in this) {
      if (domain.codigo.trim().toLowerCase() == codigoNormalizado) {
        return domain;
      }
    }

    return null;
  }

  String nomePorId(
    String? id, {
    String valorPadrao = 'Não informado',
  }) {
    return buscarPorId(id)?.nome ?? valorPadrao;
  }

  List<String> nomesPorIds(Iterable<String> ids) {
    final mapa = paraMapaDeOpcoes();

    return ids.map((id) => mapa[id]).whereType<String>().toList();
  }
}
