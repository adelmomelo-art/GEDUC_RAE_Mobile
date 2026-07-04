import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/qrcode_service.dart';

class RaeQrCodeWidget extends StatelessWidget {
  final String acaoId;
  final String numeroRAE;
  final double size;

  const RaeQrCodeWidget({
    super.key,
    required this.acaoId,
    required this.numeroRAE,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = QrCodeService.gerarTextoQr(
      acaoId: acaoId,
      numeroRAE: numeroRAE,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: size,
          gapless: false,
        ),
        const SizedBox(height: 8),
        Text(
          'RAE Nº $numeroRAE',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}