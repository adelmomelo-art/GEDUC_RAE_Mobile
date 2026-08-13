import 'package:flutter/material.dart';

import '../models/analytics/alerta_operacional.dart';
import '../models/analytics/insight_operacional.dart';
import '../models/analytics/ranking_item.dart';
import 'common/dashboard_colors.dart';
import 'common/dashboard_panel.dart';
import 'common/dashboard_title.dart';

class CIOIntelligencePanel extends StatelessWidget {
  const CIOIntelligencePanel({
    required this.ranking,
    required this.insights,
    required this.alertas,
    required this.recomendacoes,
    super.key,
  });

  final List<RankingItem> ranking;
  final List<InsightOperacional> insights;
  final List<AlertaOperacional> alertas;
  final List<String> recomendacoes;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardTitle(
            title: 'Inteligência operacional',
            subtitle: 'Leitura produzida pelo Fênix Analytics Engine',
            icon: Icons.insights_rounded,
            iconColor: DashboardColors.blue,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = <Widget>[
                _IntelligenceCard(
                  titulo: 'Ranking regional',
                  icone: Icons.emoji_events_outlined,
                  cor: DashboardColors.primary,
                  itens: ranking
                      .take(3)
                      .map((item) => '${item.posicao}º ${item.nome} — '
                          '${item.indice.toStringAsFixed(1)} pontos')
                      .toList(),
                ),
                _IntelligenceCard(
                  titulo: 'Insights',
                  icone: Icons.auto_awesome_outlined,
                  cor: DashboardColors.purple,
                  itens:
                      insights.take(3).map((item) => item.descricao).toList(),
                ),
                _IntelligenceCard(
                  titulo: 'Alertas',
                  icone: Icons.warning_amber_rounded,
                  cor: DashboardColors.orange,
                  itens: alertas.take(3).map((item) => item.descricao).toList(),
                ),
                _IntelligenceCard(
                  titulo: 'Recomendações',
                  icone: Icons.lightbulb_outline_rounded,
                  cor: DashboardColors.blue,
                  itens: recomendacoes.take(3).toList(),
                ),
              ];

              if (constraints.maxWidth >= 760) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: cards
                      .map(
                        (card) => SizedBox(
                          width: (constraints.maxWidth - 12) / 2,
                          child: card,
                        ),
                      )
                      .toList(),
                );
              }

              return Column(
                children: cards
                    .expand((card) => [card, const SizedBox(height: 12)])
                    .toList()
                  ..removeLast(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IntelligenceCard extends StatelessWidget {
  const _IntelligenceCard({
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.itens,
  });

  final String titulo;
  final IconData icone;
  final Color cor;
  final List<String> itens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 19, color: cor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: cor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (itens.isEmpty)
            const Text(
              'Sem dados suficientes no período selecionado.',
              style: TextStyle(fontSize: 10, color: Colors.black54),
            )
          else
            ...itens.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  '• $item',
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.35,
                    color: Color(0xFF455A64),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
