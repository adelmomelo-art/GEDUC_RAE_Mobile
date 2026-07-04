import '../data/models/dominio_model.dart';

class DominioRepository {
  final List<DominioModel> _dominios = [];

  List<DominioModel> listarTodos() {
    final lista = List<DominioModel>.from(_dominios);

    lista.sort((a, b) {
      final ordemComparacao = a.ordem.compareTo(b.ordem);

      if (ordemComparacao != 0) {
        return ordemComparacao;
      }

      return a.nome.compareTo(b.nome);
    });

    return lista;
  }

  List<DominioModel> listarPorTipo(String tipo) {
    final lista = _dominios
        .where(
          (dominio) =>
              dominio.tipo == tipo &&
              dominio.ativo,
        )
        .toList();

    lista.sort((a, b) {
      final ordemComparacao = a.ordem.compareTo(b.ordem);

      if (ordemComparacao != 0) {
        return ordemComparacao;
      }

      return a.nome.compareTo(b.nome);
    });

    return lista;
  }

  DominioModel? buscarPorId(String id) {
    try {
      return _dominios.firstWhere(
        (dominio) => dominio.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  void carregarDominiosIniciais(List<DominioModel> dominios) {
    _dominios
      ..clear()
      ..addAll(dominios);
  }

  void salvar(DominioModel dominio) {
    final index = _dominios.indexWhere(
      (item) => item.id == dominio.id,
    );

    if (index >= 0) {
      _dominios[index] = dominio;
      return;
    }

    _dominios.add(dominio);
  }
}