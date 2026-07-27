import 'package:flutter/material.dart';

class ReviewSectionCard extends StatelessWidget {
  const ReviewSectionCard({
    super.key,
    required this.titulo,
    required this.icone,
    required this.conteudo,
    this.subtitulo,
    this.acao,
    this.expandidoInicialmente = false,
  });

  final String titulo;
  final IconData icone;
  final String conteudo;
  final String? subtitulo;
  final Widget? acao;
  final bool expandidoInicialmente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texto = conteudo.trim();
    final possuiConteudo = texto.isNotEmpty;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: expandidoInicialmente,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 6,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icone,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          titulo,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: subtitulo == null || subtitulo!.trim().isEmpty
            ? null
            : Text(
                subtitulo!.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: acao,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              possuiConteudo ? texto : 'Nenhuma informação registrada.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: possuiConteudo
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
