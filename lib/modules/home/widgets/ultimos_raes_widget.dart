import 'package:flutter/material.dart';

import '../../../core/widgets/status_acao_chip.dart';
import '../../../data/models/acao_model.dart';

class UltimosRaesWidget extends StatelessWidget {
  final List<AcaoModel> acoes;

  const UltimosRaesWidget({
    super.key,
    required this.acoes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Últimos RAEs',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (acoes.isNotEmpty)
                  _QuantidadeRaes(
                    quantidade: acoes.length,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (acoes.isEmpty)
              const _EstadoVazio()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  const colunas = 2;
                  const espacamento = 12.0;

                  final larguraCard =
                      (constraints.maxWidth -
                              (espacamento * (colunas - 1))) /
                          colunas;

                  return Wrap(
                    spacing: espacamento,
                    runSpacing: espacamento,
                    children: [
                      for (final acao in acoes)
                        SizedBox(
                          width: larguraCard,
                          child: _RaeExecutivoCard(
                            acao: acao,
                          ),
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

class _QuantidadeRaes extends StatelessWidget {
  final int quantidade;

  const _QuantidadeRaes({
    required this.quantidade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        quantidade.toString(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'Nenhum RAE cadastrado.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RaeExecutivoCard extends StatelessWidget {
  final AcaoModel acao;

  const _RaeExecutivoCard({
    required this.acao,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final corStatus = _corStatus(
      context,
      status: acao.status,
      sincronizado: acao.sincronizado,
    );

    return Container(
      constraints: const BoxConstraints(
        minHeight: 196,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.38,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: corStatus,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  14,
                  14,
                  14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.description_rounded,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RAE ${acao.numeroRAE}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                acao.nomeAcao,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _InformacaoLocal(
                      icon: Icons.location_on_outlined,
                      texto: _localizacaoAcao(acao),
                    ),
                    const Spacer(),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: StatusAcaoChip(
                        status: acao.status,
                        sincronizado: acao.sincronizado,
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

  String _localizacaoAcao(AcaoModel acao) {
    final regional = acao.regional.trim();
    final bairro = acao.bairro.trim();

    if (regional.isEmpty && bairro.isEmpty) {
      return 'Localização não informada';
    }

    if (regional.isEmpty) {
      return bairro;
    }

    if (bairro.isEmpty) {
      return regional;
    }

    return '$regional • $bairro';
  }

  Color _corStatus(
    BuildContext context, {
    required String status,
    required bool sincronizado,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusNormalizado = status.trim().toLowerCase();

    if (!sincronizado) {
      return Colors.orange.shade700;
    }

    if (statusNormalizado.contains('rascunho')) {
      return Colors.orange.shade700;
    }

    if (statusNormalizado.contains('andamento') ||
        statusNormalizado.contains('execução') ||
        statusNormalizado.contains('execucao')) {
      return Colors.blue.shade700;
    }

    if (statusNormalizado.contains('pendente') ||
        statusNormalizado.contains('erro')) {
      return colorScheme.error;
    }

    if (statusNormalizado.contains('conclu') ||
        statusNormalizado.contains('finaliz') ||
        statusNormalizado.contains('sincroniz')) {
      return Colors.green.shade700;
    }

    return colorScheme.primary;
  }
}

class _InformacaoLocal extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _InformacaoLocal({
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
