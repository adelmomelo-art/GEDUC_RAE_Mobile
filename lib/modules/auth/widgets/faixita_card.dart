import 'package:flutter/material.dart';

class FaixitaCard extends StatelessWidget {
  const FaixitaCard({
    super.key,
    required this.compacto,
    required this.largura,
    required this.imagemAsset,
    required this.onPressed,
  });

  final bool compacto;
  final double largura;
  final String imagemAsset;
  final VoidCallback onPressed;

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color azulSuave = Color(0xFFEAF7F7);

  @override
  Widget build(BuildContext context) {
    final larguraImagem = compacto ? 128.0 : 108.0;
    final alturaImagem = compacto ? 174.0 : 150.0;

    return SizedBox(
      width: largura,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: verdeInstitucional.withValues(alpha: 0.40),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: larguraImagem,
                      height: alturaImagem,
                      child: Image.asset(
                        imagemAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: azulSuave,
                              child: Text(
                                'F',
                                style: TextStyle(
                                  color: verdeInstitucional,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Olá! Eu sou a Faixita!',
                              style: TextStyle(
                                color: verdeInstitucional,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Estou aqui para ajudar durante o registro das suas ações educativas.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: onPressed,
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                ),
                                label: const Text('Falar com a Faixita'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: 6,
                  child: ColoredBox(
                    color: verdeInstitucional,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
