import 'package:flutter/material.dart';

import '../models/cio_bi_executive_snapshot.dart';
import 'common/dashboard_colors.dart';
import 'common/dashboard_empty_state.dart';
import 'common/dashboard_panel.dart';
import 'common/dashboard_spacing.dart';
import 'common/dashboard_typography.dart';

class CioBiExecutivePanel extends StatelessWidget {
  const CioBiExecutivePanel({
    required this.snapshot,
    super.key,
  });

  final CioBiExecutiveSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Visão executiva', style: DashboardTypography.panelTitle),
          const SizedBox(height: DashboardSpacing.xxs),
          const Text(
            'Distribuição por Tipo de Ação e acompanhamento de metas.',
            style: DashboardTypography.panelSubtitle,
          ),
          const SizedBox(height: DashboardSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final panels = [
                Expanded(child: _TypeDistribution(snapshot: snapshot)),
                Expanded(child: _GoalsSummary(goals: snapshot.goals)),
              ];
              if (constraints.maxWidth >= 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    panels.first,
                    const SizedBox(width: DashboardSpacing.lg),
                    panels.last,
                  ],
                );
              }
              return Column(
                children: [
                  _TypeDistribution(snapshot: snapshot),
                  const SizedBox(height: DashboardSpacing.lg),
                  _GoalsSummary(goals: snapshot.goals),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TypeDistribution extends StatelessWidget {
  const _TypeDistribution({required this.snapshot});

  final CioBiExecutiveSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveCard(
      title: 'Ações por tipo',
      child: snapshot.actionsByType.isEmpty
          ? const DashboardEmptyState(
              message: 'Nenhuma ação no período e filtros selecionados.',
              height: 120,
            )
          : Column(
              children: snapshot.actionsByType
                  .map(
                    (item) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: DashboardSpacing.sm),
                      child: _DistributionRow(item: item),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({required this.item});

  final CioBiDistributionItem item;

  @override
  Widget build(BuildContext context) {
    final progress = (item.percentage / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                overflow: TextOverflow.ellipsis,
                style: DashboardTypography.infoValue,
              ),
            ),
            const SizedBox(width: DashboardSpacing.sm),
            Text(
              '${item.count} · ${item.percentage.toStringAsFixed(1)}%',
              style: DashboardTypography.body,
            ),
          ],
        ),
        const SizedBox(height: DashboardSpacing.xxs),
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          color: DashboardColors.primary,
          backgroundColor: DashboardColors.border,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}

class _GoalsSummary extends StatelessWidget {
  const _GoalsSummary({required this.goals});

  final CioBiGoalsSummary goals;

  @override
  Widget build(BuildContext context) {
    if (goals.total == 0) {
      return const _ExecutiveCard(
        title: 'Metas',
        child: DashboardEmptyState(
          message: 'Nenhuma meta no período e filtros selecionados.',
          height: 120,
        ),
      );
    }
    return _ExecutiveCard(
      title: 'Metas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${goals.achievedPercentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: DashboardColors.primaryDark,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text('de metas atingidas', style: DashboardTypography.body),
          const SizedBox(height: DashboardSpacing.md),
          LinearProgressIndicator(
            value: (goals.achievedPercentage / 100).clamp(0.0, 1.0),
            minHeight: 10,
            color: DashboardColors.success,
            backgroundColor: DashboardColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: DashboardSpacing.md),
          Wrap(
            spacing: DashboardSpacing.lg,
            runSpacing: DashboardSpacing.sm,
            children: [
              _GoalValue(
                label: 'Atingidas',
                value: goals.achieved,
                color: DashboardColors.success,
              ),
              _GoalValue(
                label: 'Não atingidas',
                value: goals.notAchieved,
                color: DashboardColors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalValue extends StatelessWidget {
  const _GoalValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: DashboardSpacing.xs),
        Text('$value $label', style: DashboardTypography.infoValue),
      ],
    );
  }
}

class _ExecutiveCard extends StatelessWidget {
  const _ExecutiveCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DashboardSpacing.md),
      decoration: BoxDecoration(
        color: DashboardColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DashboardTypography.infoValue),
          const SizedBox(height: DashboardSpacing.md),
          child,
        ],
      ),
    );
  }
}
