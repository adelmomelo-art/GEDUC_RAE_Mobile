import 'package:flutter/material.dart';

import '../../../../core/services/dashboard_service.dart';
import '../common/dashboard_colors.dart';
import '../common/dashboard_badge.dart';
import '../common/dashboard_panel.dart';

class FaxitaSummaryCard extends StatelessWidget {
  const FaxitaSummaryCard({
    required this.indicadores,
    required this.periodoSelecionado,
    required this.totalPendentes,
    super.key,
  });

  final DashboardIndicadores indicadores;
  final String periodoSelecionado;
  final int totalPendentes;

  @override
  Widget build(BuildContext context) {
    final temInteligencia = indicadores.totalAcoes > 0;
    final resumoExecutivo = FaxitaSyncPresentation.resumo(
      indicadores.resumoExecutivo,
      totalPendentes,
    );
    final alertasSincronizados = FaxitaSyncPresentation.alertas(
      indicadores.alertas,
      totalPendentes,
    );

    return DashboardPanel(
      gradient: LinearGradient(
        colors: [
          DashboardColors.purple.withValues(alpha: 0.11),
          DashboardColors.blue.withValues(alpha: 0.06),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: DashboardColors.purple.withValues(alpha: 0.18),
      boxShadow: [
        BoxShadow(
          color: DashboardColors.purple.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DashboardColors.purple,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Faxita — Inteligência Operacional',
                            style: TextStyle(
                              color: DashboardColors.purple,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DashboardBadge(
                          text: 'IA',
                          color: DashboardColors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leitura automática do período: $periodoSelecionado',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: DashboardColors.purple.withValues(alpha: 0.10),
              ),
            ),
            child: Text(
              resumoExecutivo,
              style: const TextStyle(
                color: Color(0xFF37474F),
                fontSize: 12,
                height: 1.48,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (temInteligencia) ...[
            const SizedBox(height: 13),
            LayoutBuilder(
              builder: (context, constraints) {
                final emLinha = constraints.maxWidth >= 760;

                final destaques = _FaxitaInsightCard(
                  titulo: 'Destaques',
                  icone: Icons.trending_up_rounded,
                  cor: DashboardColors.primary,
                  itens: indicadores.destaques,
                  vazio: 'Nenhum destaque identificado neste período.',
                );

                final alertas = _FaxitaInsightCard(
                  titulo: 'Alertas',
                  icone: Icons.warning_amber_rounded,
                  cor: DashboardColors.orange,
                  itens: alertasSincronizados,
                  vazio: 'Nenhum alerta operacional identificado.',
                );

                final recomendacoes = _FaxitaInsightCard(
                  titulo: 'Recomendações',
                  icone: Icons.lightbulb_outline_rounded,
                  cor: DashboardColors.blue,
                  itens: indicadores.recomendacoes,
                  vazio: 'Nenhuma recomendação adicional neste momento.',
                );

                if (emLinha) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: destaques),
                      const SizedBox(width: 10),
                      Expanded(child: alertas),
                      const SizedBox(width: 10),
                      Expanded(child: recomendacoes),
                    ],
                  );
                }

                return Column(
                  children: [
                    destaques,
                    const SizedBox(height: 10),
                    alertas,
                    const SizedBox(height: 10),
                    recomendacoes,
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class FaxitaSyncPresentation {
  const FaxitaSyncPresentation._();

  static final RegExp _trechoSincronizacao = RegExp(
    r'(?:Existem \d+ registro\(s\) pendente\(s\) de sincronização\.|Todos os registros do período estão sincronizados\.)',
  );

  static List<String> alertas(List<String> alertas, int totalPendentes) {
    final coerentes = alertas
        .where((alerta) => !alerta.contains('aguardam sincronização'))
        .toList();

    if (totalPendentes > 0) {
      coerentes.add('$totalPendentes registro(s) aguardam sincronização.');
    }

    return List<String>.unmodifiable(coerentes);
  }

  static String resumo(String resumo, int totalPendentes) {
    final base = resumo.replaceAll(_trechoSincronizacao, '').trim();
    final situacao = totalPendentes > 0
        ? 'Existem $totalPendentes registro(s) pendente(s) de sincronização.'
        : 'Todos os registros do período estão sincronizados.';

    return '$base $situacao'.trim();
  }
}

class _FaxitaInsightCard extends StatelessWidget {
  const _FaxitaInsightCard({
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.itens,
    required this.vazio,
  });

  final String titulo;
  final IconData icone;
  final Color cor;
  final List<String> itens;
  final String vazio;

  @override
  Widget build(BuildContext context) {
    final itensVisiveis = itens.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cor.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 18,
                ),
              ),
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
              if (itens.length > itensVisiveis.length)
                DashboardBadge(
                  text: '+${itens.length - itensVisiveis.length}',
                  color: cor,
                ),
            ],
          ),
          const SizedBox(height: 9),
          if (itensVisiveis.isEmpty)
            Text(
              vazio,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 10,
                height: 1.35,
              ),
            )
          else
            ...itensVisiveis.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: cor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF455A64),
                          fontSize: 10,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
