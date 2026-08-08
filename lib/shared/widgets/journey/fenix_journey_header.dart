import 'package:flutter/material.dart';

import '../../../core/theme/fenix_visual_tokens.dart';

/// Cabeçalho responsivo para etapas da jornada de criação do RAE.
class FenixJourneyHeader extends StatelessWidget {
  const FenixJourneyHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final progress = step / totalSteps;

    return Container(
      padding: const EdgeInsets.all(FenixVisualTokens.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FenixVisualTokens.teal, FenixVisualTokens.tealDark],
        ),
        borderRadius: BorderRadius.circular(FenixVisualTokens.radiusLarge),
        boxShadow: FenixVisualTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth <
                  FenixVisualTokens.headerCompactBreakpoint;
              final identity = _Identity(
                icon: icon,
                title: title,
                subtitle: subtitle,
              );
              final badge = _StepBadge(step: step, totalSteps: totalSteps);

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    badge,
                    const SizedBox(height: FenixVisualTokens.space12),
                    identity,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: FenixVisualTokens.space16),
                  badge,
                ],
              );
            },
          ),
          const SizedBox(height: FenixVisualTokens.space16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation(FenixVisualTokens.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.white,
          foregroundColor: FenixVisualTokens.orange,
          child: Icon(icon, size: 28),
        ),
        const SizedBox(width: FenixVisualTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: FenixVisualTokens.space4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.step, required this.totalSteps});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FenixVisualTokens.space12,
        vertical: FenixVisualTokens.space8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Etapa $step de $totalSteps',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: FenixVisualTokens.navy,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
