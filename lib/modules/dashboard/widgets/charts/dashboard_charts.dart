import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../common/dashboard_colors.dart';
import '../common/dashboard_empty_state.dart';
import '../common/dashboard_panel.dart';
import '../common/dashboard_title.dart';

class DashboardCharts extends StatelessWidget {
  const DashboardCharts({
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
    super.key,
  });

  
  
  

  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 820) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ResultBarChart(
                  totalPessoas: totalPessoas,
                  totalVeiculos: totalVeiculos,
                  totalCredenciais: totalCredenciais,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DistributionPieChart(
                  totalPessoas: totalPessoas,
                  totalVeiculos: totalVeiculos,
                  totalCredenciais: totalCredenciais,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _ResultBarChart(
              totalPessoas: totalPessoas,
              totalVeiculos: totalVeiculos,
              totalCredenciais: totalCredenciais,
            ),
            const SizedBox(height: 12),
            _DistributionPieChart(
              totalPessoas: totalPessoas,
              totalVeiculos: totalVeiculos,
              totalCredenciais: totalCredenciais,
            ),
          ],
        );
      },
    );
  }
}

class _ResultBarChart extends StatelessWidget {
  const _ResultBarChart({
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
  });

  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;

  @override
  Widget build(BuildContext context) {
    final maiorValor = [
      totalPessoas,
      totalVeiculos,
      totalCredenciais,
    ].reduce((a, b) => a > b ? a : b);

    final maxY = maiorValor == 0 ? 10.0 : maiorValor * 1.2;

    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardTitle(
            title: 'Comparativo de resultados',
            subtitle: 'Volume consolidado por indicador',
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  _bar(
                    0,
                    totalPessoas.toDouble(),
                    DashboardColors.primary,
                  ),
                  _bar(
                    1,
                    totalVeiculos.toDouble(),
                    DashboardColors.orange,
                  ),
                  _bar(
                    2,
                    totalCredenciais.toDouble(),
                    DashboardColors.purple,
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        final titulo = switch (value.toInt()) {
                          0 => 'Pessoas',
                          1 => 'Veículos',
                          2 => 'Cred.',
                          _ => '',
                        };

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF546E7A),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Color(0xFFE5ECEC),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double valor, Color cor) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: valor,
          color: cor,
          width: 24,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(7),
          ),
        ),
      ],
    );
  }
}

class _DistributionPieChart extends StatelessWidget {
  const _DistributionPieChart({
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
  });

  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;

  @override
  Widget build(BuildContext context) {
    final soma = totalPessoas + totalVeiculos + totalCredenciais;

    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardTitle(
            title: 'Distribuição dos indicadores',
            subtitle: 'Participação relativa no resultado',
            icon: Icons.donut_large_outlined,
          ),
          const SizedBox(height: 18),
          if (soma == 0)
            const DashboardEmptyState(
              message: 'Ainda não há dados suficientes para o gráfico.',
              icon: Icons.pie_chart_outline_rounded,
            )
          else
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 48,
                        sections: [
                          PieChartSectionData(
                            value: totalPessoas.toDouble(),
                            title: _percentual(totalPessoas, soma),
                            color: DashboardColors.primary,
                            radius: 66,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          PieChartSectionData(
                            value: totalVeiculos.toDouble(),
                            title: _percentual(totalVeiculos, soma),
                            color: DashboardColors.orange,
                            radius: 66,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          PieChartSectionData(
                            value: totalCredenciais.toDouble(),
                            title: _percentual(totalCredenciais, soma),
                            color: DashboardColors.purple,
                            radius: 66,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ChartLegend(
                        cor: DashboardColors.primary,
                        texto: 'Pessoas',
                      ),
                      SizedBox(height: 10),
                      _ChartLegend(
                        cor: DashboardColors.orange,
                        texto: 'Veículos',
                      ),
                      SizedBox(height: 10),
                      _ChartLegend(
                        cor: DashboardColors.purple,
                        texto: 'Credenciais',
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _percentual(int valor, int total) {
    if (total == 0) return '0%';

    final percentual = (valor / total) * 100;
    return '${percentual.toStringAsFixed(0)}%';
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.cor,
    required this.texto,
  });

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          texto,
          style: const TextStyle(
            color: Color(0xFF455A64),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
