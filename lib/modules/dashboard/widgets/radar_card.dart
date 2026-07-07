import 'package:flutter/material.dart';

class RadarCard extends StatelessWidget {
  const RadarCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.classificacao,
    required this.percentual,
    required this.icone,
  });

  final String titulo;
  final String valor;
  final String classificacao;
  final double percentual;
  final IconData icone;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);

  @override
  Widget build(BuildContext context) {
    final progresso = percentual.clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icone,
              color: verdeInstitucional,
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: verdeInstitucional,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progresso,
              minHeight: 10,
              backgroundColor: const Color(0xFFEAEAEA),
              color:
                  progresso >= 0.80 ? verdeInstitucional : laranjaInstitucional,
            ),
            const SizedBox(height: 8),
            Text(
              classificacao,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
