import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.tendencia,
    required this.descricao,
    this.destaque = false,
  });

  final String titulo;
  final String valor;
  final IconData icone;
  final String tendencia;
  final String descricao;
  final bool destaque;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        destaque ? verdeInstitucional : Colors.white.withValues(alpha: 0.96);

    final foregroundColor = destaque ? Colors.white : Colors.black87;
    final subtitleColor = destaque ? Colors.white70 : Colors.black54;

    return Card(
      elevation: destaque ? 5 : 2,
      child: Container(
        constraints: const BoxConstraints(minHeight: 142),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: destaque
                ? verdeInstitucional
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icone,
              color: destaque ? Colors.white : verdeInstitucional,
              size: 30,
            ),
            const Spacer(),
            Text(
              valor,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  _iconeTendencia(),
                  size: 16,
                  color: destaque ? Colors.white : laranjaInstitucional,
                ),
                const SizedBox(width: 4),
                Text(
                  tendencia,
                  style: TextStyle(
                    color: destaque ? Colors.white : laranjaInstitucional,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              descricao,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconeTendencia() {
    final texto = tendencia.toLowerCase();

    if (texto.contains('-') || texto.contains('queda')) {
      return Icons.trending_down;
    }

    if (texto.contains('estável') || texto.contains('estavel')) {
      return Icons.trending_flat;
    }

    return Icons.trending_up;
  }
}
