import 'package:flutter/material.dart';

enum ReviewPointsType {
  pontosFortes,
  recomendacoes,
}

class ReviewPointsCard extends StatelessWidget {
  const ReviewPointsCard({
    super.key,
    required this.itens,
    required this.tipo,
    this.titulo,
    this.mensagemVazia,
  });

  final List<String> itens;
  final ReviewPointsType tipo;
  final String? titulo;
  final String? mensagemVazia;

  String get _tituloPadrao {
    switch (tipo) {
      case ReviewPointsType.pontosFortes:
        return 'Pontos fortes';
      case ReviewPointsType.recomendacoes:
        return 'Recomendações';
    }
  }

  String get _mensagemVaziaPadrao {
    switch (tipo) {
      case ReviewPointsType.pontosFortes:
        return 'Nenhum ponto forte identificado.';
      case ReviewPointsType.recomendacoes:
        return 'Nenhuma recomendação adicional.';
    }
  }

  IconData get _icone {
    switch (tipo) {
      case ReviewPointsType.pontosFortes:
        return Icons.verified_rounded;
      case ReviewPointsType.recomendacoes:
        return Icons.lightbulb_rounded;
    }
  }

  Color _cor(BuildContext context) {
    switch (tipo) {
      case ReviewPointsType.pontosFortes:
        return Colors.green.shade700;
      case ReviewPointsType.recomendacoes:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = _cor(context);

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
                    color: cor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _icone,
                    color: cor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo ?? _tituloPadrao,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (itens.isNotEmpty)
                  Text(
                    '${itens.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (itens.isEmpty)
              Text(
                mensagemVazia ?? _mensagemVaziaPadrao,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...List.generate(
                itens.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == itens.length - 1 ? 0 : 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cor.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            itens[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
