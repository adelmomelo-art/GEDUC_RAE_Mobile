import 'package:flutter/material.dart';

class LocalizacaoActionBar extends StatelessWidget {
  const LocalizacaoActionBar({
    super.key,
    required this.onVoltar,
    required this.onAcaoPrincipal,
    required this.rotuloAcaoPrincipal,
    this.onAtualizarLocalizacao,
    this.processando = false,
  });

  final VoidCallback? onVoltar;
  final VoidCallback? onAtualizarLocalizacao;
  final VoidCallback? onAcaoPrincipal;
  final String rotuloAcaoPrincipal;
  final bool processando;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxWidth < 620;

              final voltar = OutlinedButton.icon(
                onPressed: processando ? null : onVoltar,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              );

              final atualizar = OutlinedButton.icon(
                onPressed:
                    processando ? null : onAtualizarLocalizacao,
                icon: const Icon(Icons.my_location),
                label: const Text('Atualizar localização'),
              );

              final avancar = FilledButton.icon(
                onPressed: processando ? null : onAcaoPrincipal,
                icon: processando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Text(rotuloAcaoPrincipal),
              );

              if (compacto) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    avancar,
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: voltar),
                        const SizedBox(width: 8),
                        Expanded(child: atualizar),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  voltar,
                  const SizedBox(width: 8),
                  atualizar,
                  const Spacer(),
                  avancar,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
