import 'package:flutter/material.dart';

import '../../../core/widgets/rae_qrcode_widget.dart';
import '../../../data/models/acao_model.dart';

class QrRaeCard extends StatelessWidget {
  final AcaoModel acao;

  const QrRaeCard({
    super.key,
    required this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'QR CODE DO RAE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RaeQrCodeWidget(
              acaoId: acao.id,
              numeroRAE: acao.numeroRAE,
            ),
          ],
        ),
      ),
    );
  }
}