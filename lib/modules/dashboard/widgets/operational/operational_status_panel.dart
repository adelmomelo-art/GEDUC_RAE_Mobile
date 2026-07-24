import 'package:flutter/material.dart';

import '../common/dashboard_colors.dart';
import '../common/dashboard_badge.dart';
import '../common/dashboard_info_row.dart';
import '../common/dashboard_panel.dart';
import '../common/dashboard_title.dart';

class OperationalStatusPanel extends StatelessWidget {
  const OperationalStatusPanel({
    required this.larguraDisponivel,
    required this.totalPendentes,
    required this.totalSincronizadas,
    required this.online,
    required this.sincronizando,
    required this.ultimaSincronizacao,
    required this.onSincronizar,
    super.key,
  });

  
  

  final double larguraDisponivel;
  final int totalPendentes;
  final int totalSincronizadas;
  final bool online;
  final bool sincronizando;
  final DateTime? ultimaSincronizacao;
  final Future<void> Function() onSincronizar;

  @override
  Widget build(BuildContext context) {
    final sincronizacao = _SyncStatusCard(
      totalPendentes: totalPendentes,
      totalSincronizadas: totalSincronizadas,
      online: online,
      sincronizando: sincronizando,
      ultimaSincronizacao: ultimaSincronizacao,
      onSincronizar: onSincronizar,
    );

    final sistema = _SystemHealthCard(online: online);

    if (larguraDisponivel >= 820) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: sincronizacao),
          const SizedBox(width: 12),
          Expanded(child: sistema),
        ],
      );
    }

    return Column(
      children: [
        sincronizacao,
        const SizedBox(height: 12),
        sistema,
      ],
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({
    required this.totalPendentes,
    required this.totalSincronizadas,
    required this.online,
    required this.sincronizando,
    required this.ultimaSincronizacao,
    required this.onSincronizar,
  });

  final int totalPendentes;
  final int totalSincronizadas;
  final bool online;
  final bool sincronizando;
  final DateTime? ultimaSincronizacao;
  final Future<void> Function() onSincronizar;

  @override
  Widget build(BuildContext context) {
    final status = sincronizando
        ? 'Sincronizando...'
        : online
            ? 'Conectado'
            : 'Sem conexão';

    final cor = sincronizando
        ? DashboardColors.orange
        : online
            ? DashboardColors.primary
            : Colors.redAccent;

    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardTitle(
            title: 'Sincronização operacional',
            subtitle: status,
            icon: online
                ? Icons.cloud_done_outlined
                : Icons.cloud_off_outlined,
            iconColor: cor,
            trailing: DashboardBadge(
              text: status,
              color: cor,
            ),
          ),
          const SizedBox(height: 16),
          DashboardInfoRow(
            title: 'RAEs pendentes',
            value: totalPendentes.toString(),
          ),
          const Divider(height: 22),
          DashboardInfoRow(
            title: 'Sincronizados nesta sessão',
            value: totalSincronizadas.toString(),
          ),
          const Divider(height: 22),
          DashboardInfoRow(
            title: 'Última sincronização',
            value: _formatarDataHora(ultimaSincronizacao),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: sincronizando ? null : onSincronizar,
              style: FilledButton.styleFrom(
                backgroundColor:
                    DashboardColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.sync_rounded),
              label: Text(
                sincronizando
                    ? 'Sincronizando...'
                    : 'Sincronizar agora',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) {
      return 'Ainda não realizada';
    }

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto';
  }
}

class _SystemHealthCard extends StatelessWidget {
  const _SystemHealthCard({
    required this.online,
  });

  final bool online;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardTitle(
            title: 'Status do sistema',
            subtitle: 'Serviços essenciais da Plataforma Fênix',
            icon: Icons.settings_suggest_outlined,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ServiceStatus(
                icone: Icons.cloud_done_outlined,
                titulo: 'Firebase',
                ativo: online,
              ),
              const _ServiceStatus(
                icone: Icons.storage_outlined,
                titulo: 'Offline',
                ativo: true,
              ),
              const _ServiceStatus(
                icone: Icons.qr_code_2_outlined,
                titulo: 'QR Code',
                ativo: true,
              ),
              const _ServiceStatus(
                icone: Icons.picture_as_pdf_outlined,
                titulo: 'PDF',
                ativo: true,
              ),
              const _ServiceStatus(
                icone: Icons.location_on_outlined,
                titulo: 'GPS',
                ativo: true,
              ),
              _ServiceStatus(
                icone: Icons.wifi_outlined,
                titulo: 'Internet',
                ativo: online,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceStatus extends StatelessWidget {
  const _ServiceStatus({
    required this.icone,
    required this.titulo,
    required this.ativo,
  });

  final IconData icone;
  final String titulo;
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    final cor = ativo
        ? DashboardColors.primary
        : Colors.redAccent;

    return Container(
      width: 118,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: cor.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icone,
            color: cor,
            size: 22,
          ),
          const SizedBox(height: 7),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF37474F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          DashboardBadge(
            text: ativo ? 'Ativo' : 'Indisponível',
            color: cor,
          ),
        ],
      ),
    );
  }
}
