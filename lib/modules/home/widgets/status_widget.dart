import 'package:flutter/material.dart';

import '../domain/alert_level.dart';
import '../domain/operational_alert.dart';
import '../models/home_state.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({
    super.key,
    required this.homeState,
  });

  final HomeState homeState;

  @override
  Widget build(BuildContext context) {
    final status = homeState.monitoramentoOperacional;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final itens = <_StatusItem>[
      _StatusItem(
        icon: status.conectado
            ? Icons.cloud_done_rounded
            : Icons.cloud_off_rounded,
        titulo: 'Conectividade',
        descricao:
            status.conectado ? 'Rede disponível' : 'Operação sem conexão',
        cor: status.conectado ? Colors.teal : Colors.orange,
      ),
      _StatusItem(
        icon: homeState.dadosEmCache
            ? Icons.storage_rounded
            : Icons.cloud_sync_rounded,
        titulo: 'Origem dos dados',
        descricao: homeState.dadosEmCache
            ? 'Cache local • ${_formatarData(homeState.atualizadoEm)}'
            : 'Servidor • ${_formatarData(homeState.atualizadoEm)}',
        cor: homeState.dadosEmCache ? Colors.orange : Colors.green,
      ),
      _StatusItem(
        icon:
            status.sincronizando ? Icons.sync_rounded : Icons.task_alt_rounded,
        titulo: 'Sincronização',
        descricao: status.sincronizando
            ? 'Sincronização em andamento'
            : status.possuiErro
                ? status.erro!
                : 'Serviço disponível',
        cor: status.possuiErro
            ? Colors.red
            : status.sincronizando
                ? Colors.blue
                : Colors.green,
        carregando: status.sincronizando,
      ),
      _StatusItem(
        icon: status.possuiPendencias
            ? Icons.pending_actions_rounded
            : Icons.verified_rounded,
        titulo: 'Pendências',
        descricao: status.possuiPendencias
            ? '${status.totalPendentes} ação(ões) aguardando envio'
            : 'Nenhuma ação aguardando envio',
        cor: status.possuiPendencias ? Colors.orange : Colors.green,
      ),
      _StatusItem(
        icon: Icons.schedule_rounded,
        titulo: 'Última sincronização',
        descricao: _formatarData(
          status.ultimaSincronizacaoBemSucedidaEm ??
              homeState.ultimaSincronizacaoAutomaticaEm,
        ),
        cor: Colors.indigo,
      ),
      _StatusItem(
        icon: Icons.monitor_heart_rounded,
        titulo: 'Monitoramento',
        descricao: status.monitoramentoAtivo
            ? 'Acompanhamento automático ativo'
            : 'Inicializando acompanhamento',
        cor: status.monitoramentoAtivo ? Colors.purple : Colors.grey,
      ),
    ];

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart_rounded, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Monitoramento Operacional',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AlertasOperacionaisSection(
              alertas: homeState.alertasOperacionais,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final colunas = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                const espacamento = 12.0;
                final largura =
                    (constraints.maxWidth - espacamento * (colunas - 1)) /
                        colunas;

                return Wrap(
                  spacing: espacamento,
                  runSpacing: espacamento,
                  children: [
                    for (final item in itens)
                      SizedBox(
                        width: largura,
                        child: _StatusCard(item: item),
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

  static String _formatarData(DateTime? data) {
    if (data == null) return 'Ainda não registrada';

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes às $hora:$minuto';
  }
}

class _AlertasOperacionaisSection extends StatelessWidget {
  const _AlertasOperacionaisSection({
    required this.alertas,
  });

  final List<OperationalAlert> alertas;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (alertas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.25),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.verified_rounded,
              color: Colors.green,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nenhum alerta operacional identificado.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final alertasVisiveis = alertas.take(3).toList(growable: false);
    final quantidadeOculta = alertas.length - alertasVisiveis.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.rule_rounded,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Alertas inteligentes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${alertas.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < alertasVisiveis.length; index++) ...[
          _OperationalAlertCard(
            alerta: alertasVisiveis[index],
          ),
          if (index < alertasVisiveis.length - 1) const SizedBox(height: 8),
        ],
        if (quantidadeOculta > 0) ...[
          const SizedBox(height: 8),
          Text(
            '+ $quantidadeOculta alerta(s) adicional(is), ordenado(s) por prioridade.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _OperationalAlertCard extends StatelessWidget {
  const _OperationalAlertCard({
    required this.alerta,
  });

  final OperationalAlert alerta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visual = _AlertVisual.fromLevel(alerta.level);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: visual.cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: visual.cor.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: visual.cor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              visual.icone,
              color: visual.cor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      alerta.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: visual.cor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        alerta.level.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: visual.cor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  alerta.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alerta.recommendation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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

class _AlertVisual {
  const _AlertVisual({
    required this.cor,
    required this.icone,
  });

  final Color cor;
  final IconData icone;

  factory _AlertVisual.fromLevel(AlertLevel level) {
    switch (level) {
      case AlertLevel.info:
        return const _AlertVisual(
          cor: Colors.blue,
          icone: Icons.info_outline_rounded,
        );
      case AlertLevel.warning:
        return const _AlertVisual(
          cor: Colors.orange,
          icone: Icons.warning_amber_rounded,
        );
      case AlertLevel.critical:
        return const _AlertVisual(
          cor: Colors.red,
          icone: Icons.error_outline_rounded,
        );
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.item});

  final _StatusItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.cor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: item.carregando
                ? Padding(
                    padding: const EdgeInsets.all(11),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: item.cor,
                    ),
                  )
                : Icon(item.icon, color: item.cor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titulo,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.2,
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

class _StatusItem {
  const _StatusItem({
    required this.icon,
    required this.titulo,
    required this.descricao,
    required this.cor,
    this.carregando = false,
  });

  final IconData icon;
  final String titulo;
  final String descricao;
  final Color cor;
  final bool carregando;
}
