import 'package:flutter/material.dart';

import '../common/dashboard_colors.dart';
import '../common/dashboard_radius.dart';
import '../common/dashboard_spacing.dart';

/// Cabeçalho executivo do Centro de Inteligência Operacional.
class ExecutiveHeader extends StatelessWidget {
  const ExecutiveHeader({required this.online, super.key});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(DashboardSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DashboardColors.primary, DashboardColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DashboardRadius.hero),
        boxShadow: [
          BoxShadow(
            color: DashboardColors.primaryDark.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(DashboardRadius.large),
            ),
            child: const Icon(
              Icons.monitor_heart_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: DashboardSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Centro de Inteligência Operacional',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_nomeDiaSemana(agora.weekday)}, '
                  '${agora.day.toString().padLeft(2, '0')}/'
                  '${agora.month.toString().padLeft(2, '0')}/'
                  '${agora.year}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DashboardSpacing.sm),
          _StatusOnlineCompacto(online: online),
        ],
      ),
    );
  }

  String _nomeDiaSemana(int dia) {
    const dias = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    return dias[dia - 1];
  }
}

class _StatusOnlineCompacto extends StatelessWidget {
  const _StatusOnlineCompacto({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) {
    final cor = online ? const Color(0xFF78E08F) : const Color(0xFFFFA3A3);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.sm,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DashboardRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            online ? 'ONLINE' : 'OFFLINE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
