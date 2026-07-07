import 'package:flutter/material.dart';

class ExecutiveSummaryCard extends StatelessWidget {
  const ExecutiveSummaryCard({
    super.key,
    required this.resumo,
    required this.destaque,
    required this.recomendacao,
  });

  final String resumo;
  final String destaque;
  final String recomendacao;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: laranjaInstitucional.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.summarize,
              color: laranjaInstitucional,
              size: 42,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Resumo Executivo\n',
                      style: TextStyle(
                        color: verdeInstitucional,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '$resumo\n\n'),
                    const TextSpan(
                      text: 'Destaque: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                   TextSpan(text: '$destaque\n'),
                    const TextSpan(
                     text: 'Recomendação: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: recomendacao),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
