enum AdminModuleStatus {
  disponivel,
  emEvolucao,
  planejado,
  indisponivel;

  bool get permiteAcesso =>
      this == AdminModuleStatus.disponivel ||
      this == AdminModuleStatus.emEvolucao;

  String get rotulo {
    switch (this) {
      case AdminModuleStatus.disponivel:
        return 'Disponível';
      case AdminModuleStatus.emEvolucao:
        return 'Em evolução';
      case AdminModuleStatus.planejado:
        return 'Planejado';
      case AdminModuleStatus.indisponivel:
        return 'Indisponível';
    }
  }
}
