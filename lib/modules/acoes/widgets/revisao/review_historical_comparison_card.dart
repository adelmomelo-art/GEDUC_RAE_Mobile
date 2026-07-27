import 'package:flutter/material.dart';

import '../../../../core/services/faxita_historical_analysis_result.dart';
import '../../../../core/services/faxita_historical_analysis_service.dart';
import '../../../../data/models/acao_model.dart';

class ReviewHistoricalComparisonCard extends StatelessWidget {
  const ReviewHistoricalComparisonCard({
    super.key,
    required this.acaoAtual,
    required this.historico,
    required this.carregando,
    required this.erro,
    required this.onTentarNovamente,
  });

  final AcaoModel acaoAtual;
  final List<AcaoModel> historico;
  final bool carregando;
  final String? erro;
  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const _HistoricalLoadingCard();
    }

    if (erro != null) {
      return _HistoricalErrorCard(
        mensagem: erro!,
        onTentarNovamente: onTentarNovamente,
      );
    }

    final resultado = const FaxitaHistoricalAnalysisService().analisar(
      acaoAtual: acaoAtual,
      historico: historico,
    );

    return _HistoricalResultCard(resultado: resultado);
  }
}

class _HistoricalLoadingCard extends StatelessWidget {
  const _HistoricalLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'A Faxita está consultando o histórico operacional...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricalErrorCard extends StatelessWidget {
  const _HistoricalErrorCard({
    required this.mensagem,
    required this.onTentarNovamente,
  });

  final String mensagem;
  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: colors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Histórico operacional indisponível',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(mensagem),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('TENTAR NOVAMENTE'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricalResultCard extends StatelessWidget {
  const _HistoricalResultCard({required this.resultado});

  final FaxitaHistoricalAnalysisResult resultado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = _accentColor(colors, resultado.nivel);
    final icon = _levelIcon(resultado.nivel);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inteligência histórica da Faxita',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resultado.criterioComparacao,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _LevelChip(
                  label: resultado.nivel.label,
                  color: accent,
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 4 : 2;
                final width =
                    (constraints.maxWidth - ((columns - 1) * 10)) / columns;

                final metrics = [
                  _MetricData(
                    titulo: 'Ações comparadas',
                    valor: '${resultado.totalAcoesComparadas}',
                    icone: Icons.history_rounded,
                  ),
                  _MetricData(
                    titulo: 'Média de pessoas',
                    valor: '${resultado.mediaPessoasArredondada}',
                    icone: Icons.groups_rounded,
                  ),
                  _MetricData(
                    titulo: 'Média de veículos',
                    valor: '${resultado.mediaVeiculosArredondada}',
                    icone: Icons.directions_car_rounded,
                  ),
                  _MetricData(
                    titulo: 'Metas atingidas',
                    valor: '${resultado.taxaMetaAtingidaPercentual}%',
                    icone: Icons.flag_rounded,
                  ),
                ];

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: metrics
                      .map(
                        (metric) => SizedBox(
                          width: width,
                          child: _MetricCard(data: metric),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            if (resultado.possuiBaseHistorica) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _VariationTile(
                      titulo: 'Pessoas',
                      variacao: resultado.variacaoPessoasArredondada,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _VariationTile(
                      titulo: 'Veículos',
                      variacao: resultado.variacaoVeiculosArredondada,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.smart_toy_rounded, color: accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      resultado.parecer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColor(
    ColorScheme colors,
    FaxitaHistoricalLevel nivel,
  ) {
    switch (nivel) {
      case FaxitaHistoricalLevel.acimaDoPadrao:
        return colors.primary;
      case FaxitaHistoricalLevel.dentroDoPadrao:
        return colors.tertiary;
      case FaxitaHistoricalLevel.abaixoDoPadrao:
        return colors.error;
      case FaxitaHistoricalLevel.semBase:
        return colors.secondary;
    }
  }

  IconData _levelIcon(FaxitaHistoricalLevel nivel) {
    switch (nivel) {
      case FaxitaHistoricalLevel.acimaDoPadrao:
        return Icons.trending_up_rounded;
      case FaxitaHistoricalLevel.dentroDoPadrao:
        return Icons.trending_flat_rounded;
      case FaxitaHistoricalLevel.abaixoDoPadrao:
        return Icons.trending_down_rounded;
      case FaxitaHistoricalLevel.semBase:
        return Icons.query_stats_rounded;
    }
  }
}

class _MetricData {
  const _MetricData({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  final String titulo;
  final String valor;
  final IconData icone;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icone, size: 20, color: colors.primary),
          const SizedBox(height: 10),
          Text(
            data.valor,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.titulo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariationTile extends StatelessWidget {
  const _VariationTile({
    required this.titulo,
    required this.variacao,
  });

  final String titulo;
  final int variacao;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final positivo = variacao > 0;
    final neutro = variacao == 0;
    final color = neutro
        ? colors.onSurfaceVariant
        : positivo
            ? colors.primary
            : colors.error;
    final sinal = variacao > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            neutro
                ? Icons.remove_rounded
                : positivo
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo)),
          Text(
            '$sinal$variacao%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
