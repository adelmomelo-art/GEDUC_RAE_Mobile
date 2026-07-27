import 'package:flutter/material.dart';

import '../../../../core/widgets/status_acao_chip.dart';
import '../../../../data/models/acao_model.dart';

class ReviewHeader extends StatelessWidget {
  const ReviewHeader({
    super.key,
    required this.acao,
  });

  final AcaoModel acao;

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numeroRae =
        acao.numeroRAE.trim().isEmpty ? 'Em geração' : acao.numeroRAE.trim();

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 720;

            final identificacao = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CENTRO INTELIGENTE DE REVISÃO',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  acao.nomeAcao.trim().isEmpty
                      ? 'Ação educativa'
                      : acao.nomeAcao.trim(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    if (acao.tipoAcao.trim().isNotEmpty) acao.tipoAcao.trim(),
                    if (acao.turno.trim().isNotEmpty) acao.turno.trim(),
                    _formatarData(acao.dataAcao),
                  ].join(' • '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );

            final identificadorRae = Container(
              constraints: const BoxConstraints(minWidth: 190),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: compacto
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    'ETAPA FINAL • 9/9',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RAE Nº $numeroRae',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatusAcaoChip(
                    status: acao.status,
                    sincronizado: acao.sincronizado,
                  ),
                ],
              ),
            );

            if (compacto) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identificacao,
                  const SizedBox(height: 18),
                  identificadorRae,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: identificacao),
                const SizedBox(width: 24),
                identificadorRae,
              ],
            );
          },
        ),
      ),
    );
  }
}
