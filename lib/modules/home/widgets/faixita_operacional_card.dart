import 'package:flutter/material.dart';

import '../theme/home_visual_tokens.dart';

class FaixitaOperacionalCard extends StatelessWidget {
  const FaixitaOperacionalCard({
    super.key,
    required this.possuiRascunho,
    required this.totalAcoes,
    required this.totalPessoas,
    required this.onOrientacoes,
  });

  final bool possuiRascunho;
  final int totalAcoes;
  final int totalPessoas;
  final VoidCallback onOrientacoes;

  static const String imagemFaixita =
      'assets/images/faixita_home_operacional.png';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: HomeVisualTokens.faixitaSurface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: HomeVisualTokens.orange.withValues(alpha: 0.14),
        ),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 390;
            if (narrow) {
              return Column(
                children: [
                  _content(context, includeImage: true),
                  const SizedBox(height: HomeVisualTokens.space12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _orientationButton(),
                  ),
                ],
              );
            }

            return Row(
              children: [
                const _FaixitaImage(),
                const SizedBox(width: HomeVisualTokens.space12),
                Expanded(child: _content(context)),
                const SizedBox(width: HomeVisualTokens.space8),
                _orientationButton(compact: true),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, {bool includeImage = false}) {
    final hasData = totalAcoes > 0 || totalPessoas > 0;
    final message = possuiRascunho
        ? 'Você tem um rascunho. Continue o registro antes de iniciar outra ação.'
        : hasData
            ? 'Operação atualizada: $totalAcoes ações e $totalPessoas pessoas alcançadas.'
            : 'Tudo pronto para registrar sua primeira ação educativa.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (includeImage) ...[
          const _FaixitaImage(),
          const SizedBox(width: HomeVisualTokens.space12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 19,
                    color: HomeVisualTokens.orange,
                  ),
                  const SizedBox(width: HomeVisualTokens.space8),
                  Expanded(
                    child: Text(
                      'Faixita orienta',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: HomeVisualTokens.navy,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: HomeVisualTokens.space4),
              Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HomeVisualTokens.mutedText,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _orientationButton({bool compact = false}) {
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: HomeVisualTokens.teal,
      side: const BorderSide(color: HomeVisualTokens.teal),
    );

    return Semantics(
      button: true,
      label: 'Ver orientações da Faixita',
      child: compact
          ? IconButton.outlined(
              onPressed: onOrientacoes,
              tooltip: 'Ver orientações',
              color: HomeVisualTokens.teal,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
            )
          : OutlinedButton.icon(
              onPressed: onOrientacoes,
              style: buttonStyle,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('VER ORIENTAÇÕES'),
            ),
    );
  }
}

class _FaixitaImage extends StatelessWidget {
  const _FaixitaImage();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 84,
      child: Image.asset(
        FaixitaOperacionalCard.imagemFaixita,
        fit: BoxFit.contain,
        semanticLabel: 'Faixita, assistente educativa da Plataforma Fênix',
        errorBuilder: (_, __, ___) => const CircleAvatar(
          backgroundColor: HomeVisualTokens.tealLight,
          child: Text(
            'F',
            style: TextStyle(
              color: HomeVisualTokens.teal,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
