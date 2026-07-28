class HomeOperationalStatus {
  const HomeOperationalStatus({
    this.conectado = false,
    this.monitoramentoAtivo = false,
    this.sincronizando = false,
    this.totalPendentes = 0,
    this.totalSincronizadas = 0,
    this.erro,
    this.ultimaMudancaConectividadeEm,
    this.ultimaTentativaSincronizacaoEm,
    this.ultimaSincronizacaoBemSucedidaEm,
  });

  final bool conectado;
  final bool monitoramentoAtivo;
  final bool sincronizando;
  final int totalPendentes;
  final int totalSincronizadas;
  final String? erro;
  final DateTime? ultimaMudancaConectividadeEm;
  final DateTime? ultimaTentativaSincronizacaoEm;
  final DateTime? ultimaSincronizacaoBemSucedidaEm;

  bool get possuiPendencias => totalPendentes > 0;
  bool get possuiErro => erro != null && erro!.trim().isNotEmpty;
}
