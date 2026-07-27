import 'package:flutter/material.dart';

class ReviewTimeline extends StatelessWidget {
  const ReviewTimeline({
    super.key,
    required this.planejamento,
    required this.localizacao,
    required this.caracterizacao,
    required this.recursos,
    required this.resultados,
    required this.evidencias,
    required this.avaliacao,
  });

  final bool planejamento;
  final bool localizacao;
  final bool caracterizacao;
  final bool recursos;
  final bool resultados;
  final bool evidencias;
  final bool avaliacao;

  @override
  Widget build(BuildContext context) {
    final etapas = <_ReviewStage>[
      _ReviewStage(
        titulo: 'Planejamento',
        subtitulo: 'Identificação, público e coordenação',
        concluida: planejamento,
        icone: Icons.event_note_rounded,
      ),
      _ReviewStage(
        titulo: 'Localização',
        subtitulo: 'Endereço, regional e validação',
        concluida: localizacao,
        icone: Icons.location_on_rounded,
      ),
      _ReviewStage(
        titulo: 'Caracterização',
        subtitulo: 'Público, formação e foco temático',
        concluida: caracterizacao,
        icone: Icons.category_rounded,
      ),
      _ReviewStage(
        titulo: 'Recursos',
        subtitulo: 'Equipe e materiais utilizados',
        concluida: recursos,
        icone: Icons.inventory_2_rounded,
      ),
      _ReviewStage(
        titulo: 'Resultados',
        subtitulo: 'Indicadores e alcance da ação',
        concluida: resultados,
        icone: Icons.insights_rounded,
      ),
      _ReviewStage(
        titulo: 'Evidências',
        subtitulo: 'Fotos e descrição documental',
        concluida: evidencias,
        icone: Icons.photo_camera_rounded,
      ),
      _ReviewStage(
        titulo: 'Avaliação',
        subtitulo: 'Aprendizagem e análise operacional',
        concluida: avaliacao,
        icone: Icons.fact_check_rounded,
      ),
    ];

    final concluidas = etapas.where((etapa) => etapa.concluida).length;
    final progresso = concluidas / etapas.length;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checklist operacional',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$concluidas de ${etapas.length} etapas concluídas',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progresso * 100).round()}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progresso,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              etapas.length,
              (index) => _TimelineItem(
                etapa: etapas[index],
                mostrarLinha: index < etapas.length - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.etapa,
    required this.mostrarLinha,
  });

  final _ReviewStage etapa;
  final bool mostrarLinha;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = etapa.concluida
        ? Colors.green.shade700
        : Colors.orange.shade800;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    etapa.concluida
                        ? Icons.check_rounded
                        : Icons.priority_high_rounded,
                    color: cor,
                    size: 20,
                  ),
                ),
                if (mostrarLinha)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    etapa.icone,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          etapa.titulo,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          etapa.subtitulo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    etapa.concluida ? 'Concluído' : 'Revisar',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStage {
  const _ReviewStage({
    required this.titulo,
    required this.subtitulo,
    required this.concluida,
    required this.icone,
  });

  final String titulo;
  final String subtitulo;
  final bool concluida;
  final IconData icone;
}
