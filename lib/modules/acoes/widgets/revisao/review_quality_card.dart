import 'package:flutter/material.dart';

import '../../../../core/services/faxita_insights_service.dart';
import '../../../../core/services/faxita_review_service.dart';

class ReviewQualityCard extends StatelessWidget {
  ReviewQualityCard({
    super.key,
    required this.review,
    FaxitaInsightsService? insightsService,
  }) : insightsService = insightsService ?? FaxitaInsightsService();

  final FaxitaReviewResult review;
  final FaxitaInsightsService insightsService;

  Color _corQualidade(BuildContext context) {
    if (review.indiceQualidade >= 90) {
      return Colors.green.shade700;
    }

    if (review.indiceQualidade >= 70) {
      return Colors.blue.shade700;
    }

    if (review.indiceQualidade >= 40) {
      return Colors.orange.shade800;
    }

    return Theme.of(context).colorScheme.error;
  }

  IconData _iconeQualidade() {
    if (review.indiceQualidade >= 90) {
      return Icons.verified_rounded;
    }

    if (review.indiceQualidade >= 70) {
      return Icons.thumb_up_alt_rounded;
    }

    if (review.indiceQualidade >= 40) {
      return Icons.warning_amber_rounded;
    }

    return Icons.report_problem_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = _corQualidade(context);
    final nivel = insightsService.classificarNivelRae(
      review.indiceQualidade,
    );
    final emoji = insightsService.emojiNivelRae(
      review.indiceQualidade,
    );
    final parecer = insightsService.parecerExecutivo(
      indiceQualidade: review.indiceQualidade,
      classificacao: review.classificacao,
    );

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 700;

            final indice = Container(
              width: compacto ? double.infinity : 210,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cor.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _iconeQualidade(),
                    color: cor,
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${review.indiceQualidade}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: cor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'de 100 pontos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: review.indiceQualidade / 100,
                      minHeight: 10,
                      color: cor,
                      backgroundColor: cor.withValues(alpha: 0.14),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$emoji Nível $nivel',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    review.classificacao,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );

            final parecerFaxita = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.psychology_rounded,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parecer inteligente da Faxita',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Análise automática da consistência operacional',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  parecer,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                  ),
                ),
                if (review.parecer.trim().isNotEmpty &&
                    review.parecer.trim() != parecer.trim()) ...[
                  const SizedBox(height: 12),
                  Text(
                    review.parecer.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            );

            if (compacto) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  indice,
                  const SizedBox(height: 20),
                  parecerFaxita,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                indice,
                const SizedBox(width: 24),
                Expanded(child: parecerFaxita),
              ],
            );
          },
        ),
      ),
    );
  }
}
