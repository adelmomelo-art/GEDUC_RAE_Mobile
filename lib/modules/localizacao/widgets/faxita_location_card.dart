import 'package:flutter/material.dart';

enum FaxitaLocationTone {
  informativo,
  sucesso,
  atencao,
  erro,
}

class FaxitaLocationCard extends StatelessWidget {
  const FaxitaLocationCard({
    super.key,
    required this.mensagem,
    this.titulo = 'Faixita',
    this.tone = FaxitaLocationTone.informativo,
  });

  final String titulo;
  final String mensagem;
  final FaxitaLocationTone tone;

  Color _backgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return switch (tone) {
      FaxitaLocationTone.informativo => scheme.primaryContainer,
      FaxitaLocationTone.sucesso => Colors.green.shade50,
      FaxitaLocationTone.atencao => Colors.amber.shade50,
      FaxitaLocationTone.erro => scheme.errorContainer,
    };
  }

  Color _foregroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return switch (tone) {
      FaxitaLocationTone.informativo => scheme.onPrimaryContainer,
      FaxitaLocationTone.sucesso => Colors.green.shade900,
      FaxitaLocationTone.atencao => Colors.amber.shade900,
      FaxitaLocationTone.erro => scheme.onErrorContainer,
    };
  }

  IconData get _icon {
    return switch (tone) {
      FaxitaLocationTone.informativo => Icons.assistant_outlined,
      FaxitaLocationTone.sucesso => Icons.check_circle_outline,
      FaxitaLocationTone.atencao => Icons.hourglass_top_outlined,
      FaxitaLocationTone.erro => Icons.error_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _foregroundColor(context);

    return Card(
      elevation: 0,
      color: _backgroundColor(context),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: foreground.withValues(alpha: 0.12),
              foregroundColor: foreground,
              child: Icon(_icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mensagem,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foreground,
                          height: 1.35,
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
