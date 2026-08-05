import 'package:flutter/material.dart';

import '../../../core/widgets/status_acao_chip.dart';
import '../../../data/models/acao_model.dart';
import '../theme/home_visual_tokens.dart';

class UltimosRaesWidget extends StatelessWidget {
  const UltimosRaesWidget({
    super.key,
    required this.acoes,
    required this.onAbrirRae,
  });

  final List<AcaoModel> acoes;
  final ValueChanged<AcaoModel> onAbrirRae;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: HomeVisualTokens.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: HomeVisualTokens.border),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HomeVisualTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded, color: HomeVisualTokens.teal),
                const SizedBox(width: HomeVisualTokens.space8),
                Expanded(
                  child: Text(
                    'Últimos RAEs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: HomeVisualTokens.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (acoes.isNotEmpty) _CountBadge(count: acoes.length),
              ],
            ),
            const SizedBox(height: HomeVisualTokens.space12),
            if (acoes.isEmpty)
              const _EmptyState()
            else
              Column(
                children: [
                  for (var index = 0; index < acoes.length; index++) ...[
                    _RecentRaeRow(
                      acao: acoes[index],
                      onTap: () => onAbrirRae(acoes[index]),
                    ),
                    if (index < acoes.length - 1)
                      const SizedBox(height: HomeVisualTokens.space8),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentRaeRow extends StatelessWidget {
  const _RecentRaeRow({required this.acao, required this.onTap});

  final AcaoModel acao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(acao);

    return Semantics(
      button: true,
      label: 'Abrir RAE ${acao.numeroRAE}',
      hint: 'Exibe os detalhes completos do registro',
      child: Material(
        color: statusColor.withValues(alpha: 0.045),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HomeVisualTokens.border),
          borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(HomeVisualTokens.radiusMedium),
                      bottomLeft: Radius.circular(
                        HomeVisualTokens.radiusMedium,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: HomeVisualTokens.recentRaeMinHeight,
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: HomeVisualTokens.tealLight,
                                borderRadius: BorderRadius.circular(
                                  HomeVisualTokens.radiusSmall,
                                ),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: HomeVisualTokens.teal,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: HomeVisualTokens.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RAE ${acao.numeroRAE}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: HomeVisualTokens.tealDark,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    acao.nomeAcao,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: HomeVisualTokens.text,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: HomeVisualTokens.space8),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: HomeVisualTokens.mutedText,
                            ),
                          ],
                        ),
                        const SizedBox(height: HomeVisualTokens.space8),
                        Wrap(
                          spacing: HomeVisualTokens.space12,
                          runSpacing: HomeVisualTokens.space8,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _LocationLabel(text: _location(acao)),
                            StatusAcaoChip(
                              status: acao.status,
                              sincronizado: acao.sincronizado,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _location(AcaoModel acao) {
    final regional = acao.regional.trim();
    final bairro = acao.bairro.trim();
    if (regional.isEmpty && bairro.isEmpty) return 'Local não informado';
    if (regional.isEmpty) return bairro;
    if (bairro.isEmpty) return regional;
    return '$regional • $bairro';
  }

  static Color _statusColor(AcaoModel acao) {
    final status = acao.status.trim().toLowerCase();
    if (!acao.sincronizado || status.contains('rascunho')) {
      return HomeVisualTokens.warning;
    }
    if (status.contains('erro') || status.contains('pendente')) {
      return const Color(0xFFC62828);
    }
    if (status.contains('andamento') || status.contains('execu')) {
      return HomeVisualTokens.blue;
    }
    return HomeVisualTokens.success;
  }
}

class _LocationLabel extends StatelessWidget {
  const _LocationLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 16,
            color: HomeVisualTokens.mutedText,
          ),
          const SizedBox(width: HomeVisualTokens.space4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HomeVisualTokens.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: HomeVisualTokens.tealLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: HomeVisualTokens.tealDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HomeVisualTokens.space20),
      decoration: BoxDecoration(
        color: HomeVisualTokens.tealLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: HomeVisualTokens.teal),
          const SizedBox(width: HomeVisualTokens.space12),
          Expanded(
            child: Text(
              'Nenhum RAE cadastrado.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HomeVisualTokens.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
