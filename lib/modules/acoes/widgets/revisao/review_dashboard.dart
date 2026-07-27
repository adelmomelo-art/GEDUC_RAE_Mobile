import 'package:flutter/material.dart';

import '../../../../data/models/acao_model.dart';

class ReviewDashboard extends StatelessWidget {
  const ReviewDashboard({
    super.key,
    required this.acao,
  });

  final AcaoModel acao;

  @override
  Widget build(BuildContext context) {
    final indicadores = <_ReviewIndicator>[
      _ReviewIndicator(
        titulo: 'Pessoas',
        valor: '${acao.pessoasAlcancadas}',
        complemento: 'alcançadas',
        icone: Icons.groups_rounded,
      ),
      _ReviewIndicator(
        titulo: 'Veículos',
        valor: '${acao.veiculosAbordados}',
        complemento: 'abordados',
        icone: Icons.directions_car_rounded,
      ),
      _ReviewIndicator(
        titulo: 'Evidências',
        valor: '${acao.fotosUrls.length}',
        complemento: 'fotos',
        icone: Icons.photo_library_rounded,
      ),
      _ReviewIndicator(
        titulo: 'Avaliação',
        valor: acao.notaAvaliacao > 0 ? '${acao.notaAvaliacao}/5' : '—',
        complemento: 'nota geral',
        icone: Icons.star_rounded,
      ),
      _ReviewIndicator(
        titulo: 'Equipe',
        valor: '${acao.agentesTransito + acao.equipeTerceirizada}',
        complemento: 'integrantes',
        icone: Icons.badge_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final colunas = largura >= 1100
            ? 5
            : largura >= 760
                ? 3
                : largura >= 480
                    ? 2
                    : 1;

        const espacamento = 12.0;
        final larguraCard =
            (largura - (espacamento * (colunas - 1))) / colunas;

        return Wrap(
          spacing: espacamento,
          runSpacing: espacamento,
          children: indicadores
              .map(
                (indicador) => SizedBox(
                  width: larguraCard,
                  child: _IndicatorCard(indicador: indicador),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  const _IndicatorCard({
    required this.indicador,
  });

  final _ReviewIndicator indicador;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                indicador.icone,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    indicador.titulo,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    indicador.valor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    indicador.complemento,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}

class _ReviewIndicator {
  const _ReviewIndicator({
    required this.titulo,
    required this.valor,
    required this.complemento,
    required this.icone,
  });

  final String titulo;
  final String valor;
  final String complemento;
  final IconData icone;
}
