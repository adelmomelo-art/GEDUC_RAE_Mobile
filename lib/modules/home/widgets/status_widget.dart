import 'package:flutter/material.dart';

import '../domain/alert_level.dart';
import '../domain/operational_alert.dart';
import '../models/home_state.dart';
import '../theme/home_visual_tokens.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key, required this.homeState});

  final HomeState homeState;

  @override
  Widget build(BuildContext context) {
    final status = homeState.monitoramentoOperacional;
    final hasAttention =
        homeState.alertasOperacionais.isNotEmpty ||
        homeState.estaOffline ||
        homeState.possuiErro ||
        status.possuiErro ||
        status.possuiPendencias ||
        status.sincronizando;
    final details = _buildDetails();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: HomeVisualTokens.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: HomeVisualTokens.border),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusLarge),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _SystemSummary(hasAttention: hasAttention),
            ),
            if (homeState.alertasOperacionais.isNotEmpty) ...[
              const SizedBox(height: HomeVisualTokens.space12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _OperationalAlerts(
                  alerts: homeState.alertasOperacionais,
                ),
              ),
            ],
            const SizedBox(height: HomeVisualTokens.space8),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: HomeVisualTokens.tealLight,
              ),
              child: ExpansionTile(
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                leading: const Icon(
                  Icons.monitor_heart_outlined,
                  color: HomeVisualTokens.teal,
                ),
                title: Text(
                  'Monitoramento operacional',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HomeVisualTokens.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  'Toque para ver conectividade, origem e sincronização',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HomeVisualTokens.mutedText,
                  ),
                ),
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 840
                          ? 3
                          : constraints.maxWidth >= 520
                          ? 2
                          : 1;
                      const spacing = HomeVisualTokens.space12;
                      final width =
                          (constraints.maxWidth - spacing * (columns - 1)) /
                          columns;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final detail in details)
                            SizedBox(
                              width: width,
                              child: _StatusDetail(detail: detail),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_StatusData> _buildDetails() {
    final status = homeState.monitoramentoOperacional;
    return [
      _StatusData(
        icon: status.conectado
            ? Icons.cloud_done_rounded
            : Icons.cloud_off_rounded,
        title: 'Conectividade',
        description: status.conectado
            ? 'Rede disponível'
            : 'Operação sem conexão',
        color: status.conectado
            ? HomeVisualTokens.success
            : HomeVisualTokens.warning,
      ),
      _StatusData(
        icon: homeState.dadosEmCache
            ? Icons.storage_rounded
            : Icons.cloud_sync_rounded,
        title: 'Origem dos dados',
        description: homeState.dadosEmCache
            ? 'Cache local • ${_formatDate(homeState.atualizadoEm)}'
            : 'Servidor • ${_formatDate(homeState.atualizadoEm)}',
        color: homeState.dadosEmCache
            ? HomeVisualTokens.warning
            : HomeVisualTokens.teal,
      ),
      _StatusData(
        icon: status.sincronizando
            ? Icons.sync_rounded
            : status.possuiErro
            ? Icons.sync_problem_rounded
            : Icons.task_alt_rounded,
        title: 'Sincronização',
        description: status.sincronizando
            ? 'Sincronização em andamento'
            : status.possuiErro
            ? status.erro!
            : 'Serviço disponível',
        color: status.possuiErro
            ? const Color(0xFFC62828)
            : status.sincronizando
            ? HomeVisualTokens.blue
            : HomeVisualTokens.success,
      ),
      _StatusData(
        icon: status.possuiPendencias
            ? Icons.pending_actions_rounded
            : Icons.verified_rounded,
        title: 'Pendências',
        description: status.possuiPendencias
            ? '${status.totalPendentes} ação(ões) aguardando envio'
            : 'Nenhuma ação aguardando envio',
        color: status.possuiPendencias
            ? HomeVisualTokens.warning
            : HomeVisualTokens.success,
      ),
      _StatusData(
        icon: Icons.schedule_rounded,
        title: 'Última sincronização',
        description: _formatDate(
          status.ultimaSincronizacaoBemSucedidaEm ??
              homeState.ultimaSincronizacaoAutomaticaEm,
        ),
        color: HomeVisualTokens.blue,
      ),
      _StatusData(
        icon: Icons.monitor_heart_rounded,
        title: 'Monitoramento',
        description: status.monitoramentoAtivo
            ? 'Acompanhamento automático ativo'
            : 'Inicializando acompanhamento',
        color: status.monitoramentoAtivo
            ? HomeVisualTokens.purple
            : HomeVisualTokens.mutedText,
      ),
    ];
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Ainda não registrada';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month às $hour:$minute';
  }
}

class _SystemSummary extends StatelessWidget {
  const _SystemSummary({required this.hasAttention});

  final bool hasAttention;

  @override
  Widget build(BuildContext context) {
    final color = hasAttention
        ? HomeVisualTokens.warning
        : HomeVisualTokens.success;
    return Container(
      padding: const EdgeInsets.all(HomeVisualTokens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            hasAttention
                ? Icons.notification_important_outlined
                : Icons.verified_rounded,
            color: color,
          ),
          const SizedBox(width: HomeVisualTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAttention
                      ? 'Sistema requer atenção'
                      : 'Sistema operacional',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HomeVisualTokens.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasAttention
                      ? 'Consulte os alertas e detalhes abaixo.'
                      : 'Tudo funcionando normalmente.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HomeVisualTokens.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationalAlerts extends StatelessWidget {
  const _OperationalAlerts({required this.alerts});

  final List<OperationalAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final visible = alerts.take(3).toList(growable: false);
    final hidden = alerts.length - visible.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < visible.length; index++) ...[
          _AlertRow(alert: visible[index]),
          if (index < visible.length - 1)
            const SizedBox(height: HomeVisualTokens.space8),
        ],
        if (hidden > 0) ...[
          const SizedBox(height: HomeVisualTokens.space8),
          Text(
            '+ $hidden alerta(s) adicional(is), ordenado(s) por prioridade.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HomeVisualTokens.mutedText),
          ),
        ],
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});

  final OperationalAlert alert;

  @override
  Widget build(BuildContext context) {
    final visual = _AlertVisual.fromLevel(alert.level);
    return Container(
      padding: const EdgeInsets.all(HomeVisualTokens.space12),
      decoration: BoxDecoration(
        color: visual.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
        border: Border.all(color: visual.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(visual.icon, color: visual.color, size: 22),
          const SizedBox(width: HomeVisualTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HomeVisualTokens.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: HomeVisualTokens.space4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HomeVisualTokens.mutedText,
                    height: 1.3,
                  ),
                ),
                if (alert.recommendation.trim().isNotEmpty) ...[
                  const SizedBox(height: HomeVisualTokens.space4),
                  Text(
                    'Orientação: ${alert.recommendation}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: visual.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDetail extends StatelessWidget {
  const _StatusDetail({required this.detail});

  final _StatusData detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(HomeVisualTokens.space12),
      decoration: BoxDecoration(
        color: detail.color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
        border: Border.all(color: detail.color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(detail.icon, color: detail.color, size: 24),
          const SizedBox(width: HomeVisualTokens.space12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HomeVisualTokens.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HomeVisualTokens.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusData {
  const _StatusData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

class _AlertVisual {
  const _AlertVisual({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  factory _AlertVisual.fromLevel(AlertLevel level) {
    switch (level) {
      case AlertLevel.info:
        return const _AlertVisual(
          color: HomeVisualTokens.blue,
          icon: Icons.info_outline_rounded,
        );
      case AlertLevel.warning:
        return const _AlertVisual(
          color: HomeVisualTokens.warning,
          icon: Icons.warning_amber_rounded,
        );
      case AlertLevel.critical:
        return const _AlertVisual(
          color: Color(0xFFC62828),
          icon: Icons.error_outline_rounded,
        );
    }
  }
}
