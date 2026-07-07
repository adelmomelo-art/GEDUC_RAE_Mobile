import 'package:flutter/material.dart';

class TrendChartCard extends StatelessWidget {
  const TrendChartCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.valores,
    required this.rotulos,
  });

  final String titulo;
  final String subtitulo;
  final List<double> valores;
  final List<String> rotulos;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);

  @override
  Widget build(BuildContext context) {
    final maiorValor = valores.isEmpty
        ? 1.0
        : valores.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);

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
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: verdeInstitucional,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(valores.length, (index) {
                  final valor = valores[index];
                  final altura = (valor / maiorValor).clamp(0.08, 1.0);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            valor.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: altura,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: index == valores.length - 1
                                        ? laranjaInstitucional
                                        : verdeInstitucional,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            index < rotulos.length ? rotulos[index] : '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
