import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class EvidenceFileMetadata {
  const EvidenceFileMetadata({
    required this.sha256,
    required this.sizeBytes,
    required this.mimeType,
  });

  final String sha256;
  final int sizeBytes;
  final String mimeType;
}

class EvidenceMetadataCalculator {
  const EvidenceMetadataCalculator();

  Future<EvidenceFileMetadata> calculate(File file) async {
    if (!await file.exists()) {
      throw StateError('Arquivo de evidência local não encontrado.');
    }

    final digest = await sha256.bind(file.openRead()).first;
    final sizeBytes = await file.length();

    return EvidenceFileMetadata(
      sha256: digest.toString(),
      sizeBytes: sizeBytes,
      mimeType: mimeTypeForPath(file.path),
    );
  }

  String mimeTypeForPath(String filePath) {
    switch (path.extension(filePath).toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      default:
        return 'application/octet-stream';
    }
  }

  String buildObjectKey({
    required String acaoId,
    required String evidenciaId,
    required String localFilePath,
  }) {
    final acao = acaoId.trim();
    final evidencia = evidenciaId.trim();

    if (acao.isEmpty || evidencia.isEmpty) {
      throw ArgumentError('acaoId e evidenciaId são obrigatórios.');
    }

    if (_contemSeparadorDeCaminho(acao) ||
        _contemSeparadorDeCaminho(evidencia)) {
      throw ArgumentError(
        'acaoId e evidenciaId não podem conter separadores de caminho.',
      );
    }

    final extension = path.extension(localFilePath).toLowerCase();

    return 'evidencias/$acao/$evidencia$extension';
  }

  bool _contemSeparadorDeCaminho(String value) {
    return value.contains('/') || value.contains(r'\');
  }
}
