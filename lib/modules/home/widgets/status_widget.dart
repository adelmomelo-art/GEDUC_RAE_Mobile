import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final itens = <_StatusItem>[
      const _StatusItem(
        icon: Icons.cloud_done_rounded,
        titulo: 'Firebase',
        descricao: 'Banco em nuvem ativo',
        cor: Colors.teal,
      ),
      const _StatusItem(
        icon: Icons.sync_rounded,
        titulo: 'Sincronização',
        descricao: 'Serviços preparados',
        cor: Colors.green,
      ),
      const _StatusItem(
        icon: Icons.qr_code_2_rounded,
        titulo: 'RAE Digital',
        descricao: 'QR Code e PDF disponíveis',
        cor: Colors.blue,
      ),
      const _StatusItem(
        icon: Icons.analytics_rounded,
        titulo: 'BI GEDUC',
        descricao: 'Indicadores disponíveis',
        cor: Colors.purple,
      ),
      const _StatusItem(
        icon: Icons.verified_rounded,
        titulo: 'Plataforma',
        descricao: 'Sistema em evolução',
        cor: Colors.orange,
      ),
      const _StatusItem(
        icon: Icons.gps_fixed_rounded,
        titulo: 'Localização',
        descricao: 'GPS disponível',
        cor: Colors.indigo,
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
                Icon(
                  Icons.monitor_heart_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status Operacional',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const espacamento = 12.0;
                final larguraCard =
                    (constraints.maxWidth - espacamento) / 2;

                return Wrap(
                  spacing: espacamento,
                  runSpacing: espacamento,
                  children: [
                    for (final item in itens)
                      SizedBox(
                        width: larguraCard,
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
}

class _StatusCard extends StatelessWidget {
  final _StatusItem item;

  const _StatusCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 104,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.40,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
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
            child: Icon(
              item.icon,
              color: item.cor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 8),
          Icon(
            Icons.check_circle_rounded,
            color: item.cor,
            size: 21,
          ),
        ],
      ),
    );
  }
}

class _StatusItem {
  final IconData icon;
  final String titulo;
  final String descricao;
  final Color cor;

  const _StatusItem({
    required this.icon,
    required this.titulo,
    required this.descricao,
    required this.cor,
  });
}
