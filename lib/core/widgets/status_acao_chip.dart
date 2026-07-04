import 'package:flutter/material.dart';

class StatusAcaoChip extends StatelessWidget {
  const StatusAcaoChip({
    super.key,
    required this.status,
    this.sincronizado = false,
  });

  final String status;
  final bool sincronizado;

  @override
  Widget build(BuildContext context) {
    final config = _StatusAcaoConfig.fromStatus(
      status: status,
      sincronizado: sincronizado,
    );

    return Chip(
      avatar: Icon(
        config.icon,
        size: 18,
        color: config.color,
      ),
      label: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: config.backgroundColor,
      side: BorderSide(
        color: config.color.withValues(alpha: 0.35),
      ),
    );
  }
}

class _StatusAcaoConfig {
  const _StatusAcaoConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  factory _StatusAcaoConfig.fromStatus({
    required String status,
    required bool sincronizado,
  }) {
    final statusNormalizado = status.trim().toLowerCase();

    if (sincronizado || statusNormalizado == 'sincronizado') {
      return _StatusAcaoConfig(
        label: 'Sincronizado',
        icon: Icons.cloud_done,
        color: Colors.green.shade700,
        backgroundColor: Colors.green.shade50,
      );
    }

    switch (statusNormalizado) {
      case 'rascunho':
        return _StatusAcaoConfig(
          label: 'Rascunho',
          icon: Icons.edit_note,
          color: Colors.orange.shade800,
          backgroundColor: Colors.orange.shade50,
        );

      case 'pendente':
        return _StatusAcaoConfig(
          label: 'Pendente',
          icon: Icons.cloud_upload,
          color: Colors.blue.shade700,
          backgroundColor: Colors.blue.shade50,
        );

      case 'enviado':
        return _StatusAcaoConfig(
          label: 'Enviado',
          icon: Icons.send,
          color: Colors.green.shade700,
          backgroundColor: Colors.green.shade50,
        );

      case 'erro':
        return _StatusAcaoConfig(
          label: 'Erro',
          icon: Icons.error_outline,
          color: Colors.red.shade700,
          backgroundColor: Colors.red.shade50,
        );

      default:
        return _StatusAcaoConfig(
          label: status.isEmpty ? 'Indefinido' : status,
          icon: Icons.info_outline,
          color: Colors.grey.shade700,
          backgroundColor: Colors.grey.shade100,
        );
    }
  }
}