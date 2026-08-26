import 'evidence_remote_operation.dart';
import 'evidence_upload_identity.dart';

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

  EvidenceUploadIdentity get identity => EvidenceUploadIdentity(
        acaoId: acaoId,
        evidenciaId: evidenciaId,
        sha256: sha256,
      );

  String get idempotencyKey => identity.idempotencyKey;

  bool get valido =>
      identity.valido &&
      contentType.trim().isNotEmpty &&
      tamanhoBytes > 0;
}

class EvidenceAccessGrant {
  const EvidenceAccessGrant({
    required this.uri,
    required this.operation,
    required this.expiresAt,
    required this.objectKey,
    this.requiredHeaders = const <String, String>{},
    this.uploadIdentity,
  });

  final Uri uri;
  final EvidenceRemoteOperation operation;
  final DateTime expiresAt;
  final String objectKey;
  final Map<String, String> requiredHeaders;
  final EvidenceUploadIdentity? uploadIdentity;

  bool validoEm(DateTime instante) {
    final agoraUtc = instante.toUtc();
    final expiracaoUtc = expiresAt.toUtc();

    return uri.scheme.toLowerCase() == 'https' &&
        uri.host.trim().isNotEmpty &&
        objectKey.trim().isNotEmpty &&
        expiracaoUtc.isAfter(agoraUtc);
  }

  bool validoPara({
    required EvidenceRemoteOperation operacaoEsperada,
    required DateTime instante,
  }) {
    return operation == operacaoEsperada && validoEm(instante);
  }

  bool validoUploadPara({
    required EvidenceUploadIdentity identity,
    required DateTime instante,
  }) {
    final binding = uploadIdentity;
    return validoPara(
          operacaoEsperada: EvidenceRemoteOperation.upload,
          instante: instante,
        ) &&
        identity.valido &&
        binding != null &&
        binding.equivalenteA(identity);
  }
}
