import 'package:flutter/material.dart';

class ReviewActions extends StatelessWidget {
  const ReviewActions({
    super.key,
    required this.onVerDetalhe,
    required this.onGerarPdf,
    required this.onEnviarRelatorio,
    this.podeVerDetalhe = true,
    this.podeGerarPdf = true,
    this.podeEnviar = true,
    this.enviando = false,
  });

  final VoidCallback? onVerDetalhe;
  final Future<void> Function()? onGerarPdf;
  final Future<void> Function()? onEnviarRelatorio;
  final bool podeVerDetalhe;
  final bool podeGerarPdf;
  final bool podeEnviar;
  final bool enviando;

  Future<void> _executar(
    BuildContext context,
    Future<void> Function()? acao,
    String mensagemErro,
  ) async {
    if (acao == null) {
      return;
    }

    try {
      await acao();
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro),
        ),
      );
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ações finais',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Confira o relatório antes do envio definitivo.',
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
            LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth >= 760;

                final detalhe = OutlinedButton.icon(
                  onPressed: podeVerDetalhe && !enviando
                      ? onVerDetalhe
                      : null,
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('VER DETALHE DO RAE'),
                );

                final pdf = OutlinedButton.icon(
                  onPressed: podeGerarPdf && !enviando
                      ? () => _executar(
                            context,
                            onGerarPdf,
                            'Não foi possível gerar o PDF.',
                          )
                      : null,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('GERAR PDF'),
                );

                final enviar = FilledButton.icon(
                  onPressed: podeEnviar && !enviando
                      ? () => _executar(
                            context,
                            onEnviarRelatorio,
                            'Não foi possível enviar o relatório.',
                          )
                      : null,
                  icon: enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    enviando ? 'ENVIANDO...' : 'ENVIAR RELATÓRIO',
                  ),
                );

                if (!horizontal) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 52, child: detalhe),
                      const SizedBox(height: 12),
                      SizedBox(height: 52, child: pdf),
                      const SizedBox(height: 12),
                      SizedBox(height: 54, child: enviar),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(height: 52, child: detalhe),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(height: 52, child: pdf),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(height: 54, child: enviar),
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
