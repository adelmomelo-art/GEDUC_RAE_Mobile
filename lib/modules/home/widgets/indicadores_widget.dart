import 'package:flutter/material.dart';

import '../theme/home_visual_tokens.dart';

class IndicadoresWidget extends StatelessWidget {
  const IndicadoresWidget({
    super.key,
    required this.totalAcoes,
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
  });

  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;

  @override
  Widget build(BuildContext context) {
    final indicators = <_IndicatorData>[
      _IndicatorData(
        label: 'Ações',
        value: totalAcoes,
        icon: Icons.assignment_turned_in_outlined,
        color: HomeVisualTokens.teal,
      ),
      _IndicatorData(
        label: 'Pessoas',
        value: totalPessoas,
        icon: Icons.groups_2_outlined,
        color: HomeVisualTokens.blue,
      ),
      _IndicatorData(
        label: 'Veículos',
        value: totalVeiculos,
        icon: Icons.directions_car_filled_outlined,
        color: HomeVisualTokens.orange,
      ),
      _IndicatorData(
        label: 'Credenciais',
        value: totalCredenciais,
        icon: Icons.badge_outlined,
        color: HomeVisualTokens.navy,
      ),
    ];

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: HomeVisualTokens.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: HomeVisualTokens.border),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HomeVisualTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: HomeVisualTokens.teal,
                ),
                const SizedBox(width: HomeVisualTokens.space8),
                Expanded(
                  child: Text(
                    'Indicadores operacionais',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: HomeVisualTokens.text,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: HomeVisualTokens.space12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= HomeVisualTokens.tabletBreakpoint
                        ? 4
                        : 2;
                const spacing = HomeVisualTokens.space12;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final indicator in indicators)
                      SizedBox(
                        width: width,
                        child: _KpiCard(indicator: indicator),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.indicator});

  final _IndicatorData indicator;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: HomeVisualTokens.kpiMinHeight,
      ),
      padding: const EdgeInsets.all(HomeVisualTokens.space12),
      decoration: BoxDecoration(
        color: HomeVisualTokens.surface,
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
        border: Border.all(color: HomeVisualTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: indicator.color.withValues(alpha: 0.11),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  indicator.icon,
                  color: indicator.color,
                  size: 22,
                ),
              ),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatNumber(indicator.value),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: indicator.color,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: HomeVisualTokens.space8),
          Text(
            indicator.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HomeVisualTokens.text,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    final digits = value.toString();
    return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }
}

class _IndicatorData {
  const _IndicatorData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}
