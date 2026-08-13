import 'package:flutter/material.dart';

import '../../data/models/acao_model.dart';
import 'controllers/dashboard_controller.dart';
import 'widgets/executive/executive_filters.dart';
import 'widgets/executive/executive_header.dart';
import 'widgets/executive/executive_kpi_grid.dart';
import 'widgets/faxita/faxita_summary_card.dart';
import 'widgets/operational/operational_status_panel.dart';
import 'widgets/charts/dashboard_charts.dart';
import 'widgets/cio_intelligence_panel.dart';
import 'widgets/common/dashboard_colors.dart';
import 'widgets/common/dashboard_section.dart';
import 'widgets/common/dashboard_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController controller;

  int get totalAcoes => controller.metricasOficiais.totalRecords;
  int get totalPessoas => controller.metricasOficiais.totalPeople;
  int get metasAtingidas => controller.metricasOficiais.recordsTargetAchieved;
  int get profissionaisMobilizados =>
      controller.metricasOficiais.totalHumanResources;

  int get totalPendentes => controller.totalPendentes;
  int get totalSincronizadas => controller.totalSincronizadas;
  bool get online => controller.online;
  DateTime? get ultimaSincronizacao => controller.ultimaSincronizacao;

  bool get carregando => controller.carregando;

  @override
  void initState() {
    super.initState();

    controller = DashboardController();
    controller.addListener(_atualizarTela);
    controller.carregarDashboard();
  }

  @override
  void dispose() {
    controller.removeListener(_atualizarTela);
    controller.dispose();
    super.dispose();
  }

  void _atualizarTela() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> carregarIndicadores() async {
    await controller.carregarDashboard();

    if (!mounted || controller.erro == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(controller.erro!),
      ),
    );

    controller.limparErro();
  }

  Future<void> sincronizarAgora() async {
    final mensagem = await controller.sincronizarAgora();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.pageBackground,
      appBar: AppBar(
        title: const Text('CIO - Centro de Inteligência Operacional'),
        backgroundColor: DashboardColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Atualizar indicadores',
            onPressed: carregando ? null : carregarIndicadores,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: carregarIndicadores,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final largura = constraints.maxWidth;
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: DashboardTheme.pagePadding(largura),
                    children: [
                      DashboardSection(
                        child: ExecutiveHeader(online: online),
                      ),
                      DashboardSection(
                        child: ExecutiveFilters(
                          filtros: controller.filtros,
                          regionais: _opcoes((acao) => acao.regional),
                          tiposAcao: _opcoes((acao) => acao.tipoAcao),
                          statusDisponiveis: _opcoes((acao) => acao.status),
                          coordenadores:
                              _opcoes((acao) => acao.coordenadorNome),
                          onAplicar: controller.aplicarFiltros,
                        ),
                      ),
                      DashboardSection(
                        child: ExecutiveKpiGrid(
                          larguraDisponivel: largura,
                          totalAcoes: totalAcoes,
                          totalPessoas: totalPessoas,
                          metasAtingidas: metasAtingidas,
                          profissionaisMobilizados: profissionaisMobilizados,
                          comparacaoAcoes:
                              controller.metricasComparacao?.totalRecords,
                          comparacaoPessoas:
                              controller.metricasComparacao?.totalPeople,
                          comparacaoMetas: controller
                              .metricasComparacao?.recordsTargetAchieved,
                          comparacaoProfissionais: controller
                              .metricasComparacao?.totalHumanResources,
                        ),
                      ),
                      DashboardSection(
                        child: FaxitaSummaryCard(
                          indicadores: controller.indicadores,
                          periodoSelecionado:
                              controller.periodoSelecionadoLabel,
                          totalPendentes: controller.totalPendentes,
                        ),
                      ),
                      DashboardSection(
                        child: CIOIntelligencePanel(
                          ranking: controller.rankingRegionais,
                          insights: controller.insights,
                          alertas: controller.alertasCio,
                          recomendacoes: controller.recomendacoesCio,
                        ),
                      ),
                      DashboardSection(
                        child: DashboardCharts(
                          totalPessoas: totalPessoas,
                          totalVeiculos:
                              controller.indicadores.veiculosAbordados,
                          totalCredenciais:
                              controller.indicadores.credenciaisEmitidas,
                        ),
                      ),
                      OperationalStatusPanel(
                        larguraDisponivel: largura,
                        totalPendentes: totalPendentes,
                        totalSincronizadas: totalSincronizadas,
                        online: online,
                        sincronizando: controller.sincronizando,
                        ultimaSincronizacao: ultimaSincronizacao,
                        onSincronizar: sincronizarAgora,
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  List<String> _opcoes(String Function(AcaoModel acao) valor) {
    final itens = controller.todasAsAcoes
        .map(valor)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return itens;
  }
}
