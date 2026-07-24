import 'package:flutter/material.dart';

class GpsStatusCard extends StatelessWidget {
  const GpsStatusCard({
    super.key,
    required this.latitude,
    required this.longitude,
    this.precisaoGps,
    this.dataHoraCaptura,
  });

  final double latitude;
  final double longitude;
  final double? precisaoGps;
  final DateTime? dataHoraCaptura;

  String get _qualidade {
    final precisao = precisaoGps;

    if (precisao == null) return 'Não aferida';
    if (precisao < 5) return 'Excelente';
    if (precisao <= 20) return 'Boa';
    if (precisao <= 50) return 'Regular';
    return 'Baixa';
  }

  IconData get _qualityIcon {
    final precisao = precisaoGps;

    if (precisao == null) return Icons.gps_not_fixed;
    if (precisao <= 20) return Icons.gps_fixed;
    if (precisao <= 50) return Icons.gps_not_fixed;
    return Icons.gps_off;
  }

  String _formatarDataHora(DateTime? valor) {
    if (valor == null) return 'Ainda não registrada';

    String doisDigitos(int numero) => numero.toString().padLeft(2, '0');

    return '${doisDigitos(valor.day)}/${doisDigitos(valor.month)}/'
        '${valor.year} às ${doisDigitos(valor.hour)}:'
        '${doisDigitos(valor.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final possuiCoordenadas = latitude != 0 || longitude != 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_qualityIcon),
                const SizedBox(width: 8),
                Text(
                  'Status da localização',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                Chip(label: Text(_qualidade)),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _InfoItem(
                  titulo: 'Latitude',
                  valor: possuiCoordenadas
                      ? latitude.toStringAsFixed(6)
                      : 'Não informada',
                ),
                _InfoItem(
                  titulo: 'Longitude',
                  valor: possuiCoordenadas
                      ? longitude.toStringAsFixed(6)
                      : 'Não informada',
                ),
                _InfoItem(
                  titulo: 'Precisão',
                  valor: precisaoGps == null
                      ? 'Não aferida'
                      : '${precisaoGps!.toStringAsFixed(1)} m',
                ),
                _InfoItem(
                  titulo: 'Captura',
                  valor: _formatarDataHora(dataHoraCaptura),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.titulo,
    required this.valor,
  });

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
