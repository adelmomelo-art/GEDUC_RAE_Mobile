import 'package:flutter/material.dart';

import 'widgets/coverage_map_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/executive_summary_card.dart';
import 'widgets/faxita_panel.dart';
import 'widgets/kpi_card.dart';
import 'widgets/radar_card.dart';
import 'widgets/ranking_card.dart';
import 'widgets/section_title.dart';
import 'widgets/trend_chart_card.dart';

class DashboardExecutivoPage extends StatelessWidget {
  const DashboardExecutivoPage({super.key});

  static const Color fundo = Color(0xFFF4F7F7);
  static const Color verdeInstitucional = Color(0xFF007A78);

  @override
  Widget build(BuildContext context) {
    final kpis = _kpisSimulados();

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: const Text('Centro de Inteligência'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const DashboardHeader(
            nomeUsuario: 'Adelmo',
            mensagemFaixita:
                'Hoje identifiquei bons resultados e algumas oportunidades de melhoria operacional.',
            ultimaSincronizacao: 'Hoje • 20:45',
          ),
          const SizedBox(height: 12),
          const ExecutiveSummaryCard(
            resumo:
                'Nas últimas 24 horas foram registradas 18 ações educativas, alcançando 2.430 cidadãos e mantendo desempenho acima da meta mínima.',
            destaque:
                'as ações em escolas continuam apresentando o melhor desempenho operacional.',
            recomendacao:
                'reforçar ações voltadas aos motociclistas na Regional VI durante a próxima semana.',
          ),
          const SectionTitle(
            titulo: 'KPIs Estratégicos',
            subtitulo:
                'Indicadores executivos simulados para validação visual.',
            icone: Icons.dashboard,
          ),
          _kpiGrid(kpis),
          const SectionTitle(
            titulo: 'Inteligência Visual',
            subtitulo:
                'Tendências, cobertura territorial e ranking operacional.',
            icone: Icons.query_stats,
          ),
          _visualGrid(),
          const SectionTitle(
            titulo: 'Painel Executivo da Faixita',
            subtitulo:
                'Análise automática baseada nos indicadores consolidados.',
            icone: Icons.psychology,
          ),
          const FaxitaPanel(
            titulo: 'Análise da Faixita',
            mensagem:
                'Analisei os dados dos últimos 30 dias e encontrei três pontos relevantes para apoiar a tomada de decisão.',
            pontos: [
              'As ações educativas em escolas superaram a meta mínima planejada.',
              'As atividades voltadas aos motociclistas apresentaram redução de alcance.',
              'A Regional VI precisa de atenção no planejamento das próximas semanas.',
            ],
            recomendacao:
                'priorizar ações educativas com foco em motociclistas na Regional VI e reforçar a cobertura territorial.',
          ),
          const SectionTitle(
            titulo: 'Radar Executivo',
            subtitulo:
                'Leitura rápida da situação geral da educação para o trânsito.',
            icone: Icons.radar,
          ),
          _radarGrid(),
        ],
      ),
    );
  }

  Widget _kpiGrid(List<_KpiData> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final colunas = largura >= 1100
            ? 4
            : largura >= 760
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kpis.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: colunas == 1 ? 3.4 : 1.8,
          ),
          itemBuilder: (context, index) {
            final kpi = kpis[index];

            return KpiCard(
              titulo: kpi.titulo,
              valor: kpi.valor,
              icone: kpi.icone,
              tendencia: kpi.tendencia,
              descricao: kpi.descricao,
              destaque: index == 0,
            );
          },
        );
      },
    );
  }

  Widget _visualGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        if (!isWide) {
          return const Column(
            children: [
              TrendChartCard(
                titulo: 'Evolução Mensal das Ações',
                subtitulo: 'Comparativo simulado dos últimos seis meses.',
                valores: [124, 158, 181, 196, 220, 254],
                rotulos: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
              ),
              SizedBox(height: 12),
              CoverageMapCard(),
              SizedBox(height: 12),
              RankingCard(
                titulo: 'Top Projetos por Eficiência',
                itens: [
                  RankingItem(
                    titulo: 'AMC nas Escolas',
                    subtitulo: 'Melhor desempenho educacional',
                    valor: '96%',
                  ),
                  RankingItem(
                    titulo: 'Pit Stop da Educação',
                    subtitulo: 'Maior alcance em vias públicas',
                    valor: '91%',
                  ),
                  RankingItem(
                    titulo: 'AMC Kids',
                    subtitulo: 'Alta adesão do público infantil',
                    valor: '88%',
                  ),
                ],
              ),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TrendChartCard(
                titulo: 'Evolução Mensal das Ações',
                subtitulo: 'Comparativo simulado dos últimos seis meses.',
                valores: [124, 158, 181, 196, 220, 254],
                rotulos: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CoverageMapCard(),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: RankingCard(
                titulo: 'Top Projetos por Eficiência',
                itens: [
                  RankingItem(
                    titulo: 'AMC nas Escolas',
                    subtitulo: 'Melhor desempenho educacional',
                    valor: '96%',
                  ),
                  RankingItem(
                    titulo: 'Pit Stop da Educação',
                    subtitulo: 'Maior alcance em vias públicas',
                    valor: '91%',
                  ),
                  RankingItem(
                    titulo: 'AMC Kids',
                    subtitulo: 'Alta adesão do público infantil',
                    valor: '88%',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _radarGrid() {
    const itens = [
      RadarCard(
        titulo: 'Índice Fênix',
        valor: '91,8',
        classificacao: 'Excelente',
        percentual: 0.918,
        icone: Icons.auto_awesome,
      ),
      RadarCard(
        titulo: 'Cobertura Territorial',
        valor: '82%',
        classificacao: 'Boa cobertura',
        percentual: 0.82,
        icone: Icons.map,
      ),
      RadarCard(
        titulo: 'Meta Global',
        valor: '94%',
        classificacao: 'Dentro do esperado',
        percentual: 0.94,
        icone: Icons.flag,
      ),
      RadarCard(
        titulo: 'Risco Operacional',
        valor: 'Baixo',
        classificacao: 'Monitoramento estável',
        percentual: 0.74,
        icone: Icons.health_and_safety,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 700
                ? 2
                : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: colunas,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: colunas == 1 ? 3.2 : 1.7,
          children: itens,
        );
      },
    );
  }

  List<_KpiData> _kpisSimulados() {
    return const [
      _KpiData(
        titulo: 'Ações realizadas',
        valor: '1.254',
        icone: Icons.event_available,
        tendencia: '+12%',
        descricao: 'Últimos 30 dias',
      ),
      _KpiData(
        titulo: 'Pessoas alcançadas',
        valor: '82.540',
        icone: Icons.groups,
        tendencia: '+18%',
        descricao: 'Público total registrado',
      ),
      _KpiData(
        titulo: 'Veículos abordados',
        valor: '18.420',
        icone: Icons.directions_car,
        tendencia: '+9%',
        descricao: 'Abordagens educativas',
      ),
      _KpiData(
        titulo: 'Instituições atendidas',
        valor: '147',
        icone: Icons.account_balance,
        tendencia: '+6%',
        descricao: 'Escolas, empresas e órgãos',
      ),
      _KpiData(
        titulo: 'Meta atingida',
        valor: '94%',
        icone: Icons.flag_circle,
        tendencia: 'estável',
        descricao: 'Cumprimento da meta mínima',
      ),
      _KpiData(
        titulo: 'Eficiência',
        valor: '91%',
        icone: Icons.speed,
        tendencia: '+4%',
        descricao: 'Índice operacional médio',
      ),
      _KpiData(
        titulo: 'Avaliação média',
        valor: '4,8 ★',
        icone: Icons.star,
        tendencia: '+0,3',
        descricao: 'Percepção das ações',
      ),
      _KpiData(
        titulo: 'Regionais cobertas',
        valor: '12',
        icone: Icons.location_city,
        tendencia: '+2',
        descricao: 'Cobertura territorial',
      ),
    ];
  }
}

class _KpiData {
  final String titulo;
  final String valor;
  final IconData icone;
  final String tendencia;
  final String descricao;

  const _KpiData({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.tendencia,
    required this.descricao,
  });
}
