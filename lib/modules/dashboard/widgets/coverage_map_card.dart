import 'package:flutter/material.dart';

class CoverageMapCard extends StatelessWidget {
  const CoverageMapCard({
    super.key,
  });

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        height: 310,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mapa Executivo de Cobertura',
              style: TextStyle(
                color: verdeInstitucional,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Visualização territorial simulada para Fortaleza.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.map,
                        size: 120,
                        color: verdeInstitucional,
                      ),
                    ),
                  ),
                  _ponto(
                    left: 36,
                    top: 42,
                    cor: verdeInstitucional,
                    label: 'I',
                  ),
                  _ponto(
                    right: 52,
                    top: 64,
                    cor: verdeInstitucional,
                    label: 'II',
                  ),
                  _ponto(
                    left: 120,
                    bottom: 52,
                    cor: laranjaInstitucional,
                    label: 'VI',
                  ),
                  _ponto(
                    right: 112,
                    bottom: 80,
                    cor: Colors.red,
                    label: 'V',
                  ),
                  Positioned(
                    right: 14,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '🟢 Coberta\n🟡 Atenção\n🔴 Prioritária',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ponto({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required Color cor,
    required String label,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: cor.withValues(alpha: 0.35),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
