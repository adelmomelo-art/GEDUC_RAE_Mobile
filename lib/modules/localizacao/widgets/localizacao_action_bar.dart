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
      child: Padding(
        // EST-003B.1
        // A altura externa é definida pela LocalizacaoPage:
        // 108 px no modo compacto e 60 px no modo horizontal.
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 620;

            const alturaPrincipal = 48.0;
            const alturaSecundaria = 44.0;

            final voltar = OutlinedButton.icon(
              onPressed: processando ? null : onVoltar,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, alturaSecundaria),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            );

            final atualizar = OutlinedButton.icon(
              onPressed: processando ? null : onAtualizarLocalizacao,
              icon: const Icon(Icons.my_location),
              label: const Text('Atualizar localização'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, alturaSecundaria),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
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
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, alturaPrincipal),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            );

            if (compacto) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: alturaPrincipal, child: avancar),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: alturaSecundaria,
                    child: Row(
                      children: [
                        Expanded(child: voltar),
                        const SizedBox(width: 8),
                        Expanded(child: atualizar),
                      ],
                    ),
                  ),
                ],
              );
            }

            return SizedBox(
              height: alturaPrincipal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  voltar,
                  const SizedBox(width: 8),
                  atualizar,
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 220),
                    child: avancar,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
