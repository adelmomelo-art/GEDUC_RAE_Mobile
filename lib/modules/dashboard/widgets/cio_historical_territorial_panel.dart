import 'package:flutter/material.dart';

import '../services/cio_historical_territorial_service.dart';
import 'common/dashboard_panel.dart';

class CioHistoricalTerritorialPanel extends StatelessWidget {
  const CioHistoricalTerritorialPanel({
    required this.timeline,
    required this.comparison,
    required this.quality,
    required this.territories,
    super.key,
  });

  final CioTemporalAnalysis? timeline;
  final CioTrendComparison? comparison;
  final CioDataQualityReport quality;
  final List<CioTerritorialGroup> territories;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Histórico e território',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text('Leitura baseada nos RAEs do período filtrado.'),
            const SizedBox(height: 16),
            _QualitySummary(quality: quality),
            const SizedBox(height: 20),
            Text('Série de ações',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _Timeline(timeline: timeline),
            if (comparison != null) ...[
              const SizedBox(height: 12),
              _Trend(metric: comparison!.actions),
            ],
            const SizedBox(height: 20),
            Text('Detalhamento territorial',
                style: Theme.of(context).textTheme.titleMedium),
            if (territories.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Nenhum RAE no período selecionado.'),
              )
            else
              ...territories.map((territory) => ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(territory.name),
                    subtitle: Text(_territoryStatus(territory.status)),
                    trailing: Text('${territory.actions.length} RAEs'),
                    children: territory.actions
                        .map((action) => ListTile(
                              dense: true,
                              title: Text(action.numeroRAE.isEmpty
                                  ? 'RAE ${action.id}'
                                  : 'RAE ${action.numeroRAE}'),
                              subtitle: Text(
                                '${action.dataAcao.day.toString().padLeft(2, '0')}/'
                                '${action.dataAcao.month.toString().padLeft(2, '0')}/'
                                '${action.dataAcao.year} · ${action.bairro.isEmpty ? 'Bairro não informado' : action.bairro}',
                              ),
                            ))
                        .toList(growable: false),
                  )),
          ],
        ),
      ),
    );
  }

  static String _territoryStatus(CioTerritorialIdentityStatus status) {
    switch (status) {
      case CioTerritorialIdentityStatus.identified:
        return 'Identidade territorial por ID';
      case CioTerritorialIdentityStatus.legacy:
        return 'Identificação legada';
      case CioTerritorialIdentityStatus.unresolved:
        return 'Identidade não resolvida';
    }
  }
}

class _QualitySummary extends StatelessWidget {
  const _QualitySummary({required this.quality});
  final CioDataQualityReport quality;

  @override
  Widget build(BuildContext context) {
    String percent(double value) => '${(value * 100).round()}%';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
            label: Text(
                'Com ID regional ${percent(quality.regionalIdCoverage)}')),
        Chip(label: Text('Bairro ${percent(quality.neighborhoodCoverage)}')),
        Chip(
            label: Text(
                'Coordenadas ${percent(quality.validCoordinatesCoverage)}')),
        Chip(
            label: Text(
                'Local validado ${percent(quality.validatedLocationCoverage)}')),
        if (quality.legacyTerritorialRecords > 0)
          Chip(label: Text('${quality.legacyTerritorialRecords} legados')),
        if (quality.unresolvedTerritorialRecords > 0)
          Chip(
              label: Text(
                  '${quality.unresolvedTerritorialRecords} não resolvidos')),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.timeline});
  final CioTemporalAnalysis? timeline;

  @override
  Widget build(BuildContext context) {
    final buckets = timeline?.buckets ?? const <CioTemporalBucket>[];
    if (buckets.isEmpty) return const Text('Sem dados para construir a série.');
    final maxValue = buckets.fold<int>(
        0, (max, item) => item.actions > max ? item.actions : max);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: buckets.map((item) {
          final height =
              maxValue == 0 ? 4.0 : 8 + (item.actions / maxValue * 92);
          return SizedBox(
            width: 52,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${item.actions}'),
                Container(
                    width: 22,
                    height: height,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 4),
                Text(item.label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _Trend extends StatelessWidget {
  const _Trend({required this.metric});
  final CioTrendMetric metric;

  @override
  Widget build(BuildContext context) {
    final percentage = metric.percentageChange;
    final text = metric.status == CioTrendStatus.insufficientData
        ? 'Tendência: dados insuficientes para classificação'
        : 'Variação sobre o período comparado: ${percentage!.toStringAsFixed(1)}%';
    return Text(text, key: const Key('cio_trend_summary'));
  }
}
