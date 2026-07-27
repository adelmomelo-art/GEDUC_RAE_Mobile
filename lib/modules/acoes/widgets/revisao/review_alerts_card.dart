import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/faxita_insights_service.dart';

class ReviewAlertsCard extends StatelessWidget {
  const ReviewAlertsCard({
    super.key,
    required this.alertas,
    this.titulo = 'Alertas priorizados',
    this.mensagemVazia = 'Nenhum alerta identificado pela Faxita.',
  });

  final List<FaxitaInsight> alertas;
  final String titulo;
  final String mensagemVazia;

  Color _corPorSeveridade(
    BuildContext context,
    String severidade,
  ) {
    switch (severidade.trim().toLowerCase()) {
      case 'critico':
        return Theme.of(context).colorScheme.error;
      case 'importante':
        return Colors.orange.shade800;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _iconePorSeveridade(String severidade) {
    switch (severidade.trim().toLowerCase()) {
      case 'critico':
        return Icons.report_problem_rounded;
      case 'importante':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.notification_important_rounded,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (alertas.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${alertas.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (alertas.isEmpty)
              _EmptyAlertState(mensagem: mensagemVazia)
            else
              ...List.generate(
                alertas.length,
                (index) {
                  final alerta = alertas[index];
                  final cor = _corPorSeveridade(
                    context,
                    alerta.severidade,
                  );

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == alertas.length - 1 ? 0 : 12,
                    ),
                    child: _AlertItem(
                      alerta: alerta,
                      cor: cor,
                      icone: _iconePorSeveridade(alerta.severidade),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({
    required this.alerta,
    required this.cor,
    required this.icone,
  });

  final FaxitaInsight alerta;
  final Color cor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final possuiRota = alerta.rotaCorrecao.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cor.withValues(alpha: 0.20),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth < 560;

          final conteudo = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icone,
                color: cor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerta.titulo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alerta.mensagem,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final botao = OutlinedButton.icon(
            onPressed: possuiRota
                ? () {
                    context.go(alerta.rotaCorrecao);
                  }
                : null,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Corrigir'),
          );

          if (compacto) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                conteudo,
                if (possuiRota) ...[
                  const SizedBox(height: 12),
                  botao,
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: conteudo),
              if (possuiRota) ...[
                const SizedBox(width: 16),
                botao,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyAlertState extends StatelessWidget {
  const _EmptyAlertState({
    required this.mensagem,
  });

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_rounded,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensagem,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
