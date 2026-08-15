class ScopeCatalogItem {
  const ScopeCatalogItem({required this.id, required this.nome});

  final String id;
  final String nome;
}

class ScopeCatalogs {
  const ScopeCatalogs({
    required this.regionais,
    required this.equipes,
    required this.projetos,
  });

  final List<ScopeCatalogItem> regionais;
  final List<ScopeCatalogItem> equipes;
  final List<ScopeCatalogItem> projetos;
}
