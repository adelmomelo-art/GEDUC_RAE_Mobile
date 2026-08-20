import 'evidence_remote_operation.dart';

class EvidenceReadAccessRequest {
  const EvidenceReadAccessRequest({
    required this.acaoId,
    required this.evidenciaId,
  });

  final String acaoId;
  final String evidenciaId;

  bool get valido => acaoId.trim().isNotEmpty && evidenciaId.trim().isNotEmpty;
}

class EvidenceUploadAccessRequest {
  const EvidenceUploadAccessRequest({
    required this.acaoId,
    required this.evidenciaId,
    required this.contentType,
    required this.tamanhoBytes,
    required this.sha256,
  });

  final String acaoId;
  final String evidenciaId;
  final String contentType;
  final int tamanhoBytes;
  final String sha256;

  bool get valido =>
      acaoId.trim().isNotEmpty &&
      evidenciaId.trim().isNotEmpty &&
      contentType.trim().isNotEmpty &&
      tamanhoBytes > 0 &&
      _sha256Valido(sha256);

  static bool _sha256Valido(String valor) {
    final normalizado = valor.trim().toLowerCase();
    return RegExp(r'^[a-f0-9]{64}$').hasMatch(normalizado);
  }
}

class EvidenceAccessGrant {
  const EvidenceAccessGrant({
    required this.uri,
    required this.operation,
    required this.expiresAt,
    this.requiredHeaders = const <String, String>{},
  });

  final Uri uri;
  final EvidenceRemoteOperation operation;
  final DateTime expiresAt;
  final Map<String, String> requiredHeaders;

  bool validoEm(DateTime instante) =>
      uri.hasScheme && expiresAt.isAfter(instante.toUtc());
}
