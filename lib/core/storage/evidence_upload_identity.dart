class EvidenceUploadIdentity {
  const EvidenceUploadIdentity({
    required this.acaoId,
    required this.evidenciaId,
    required this.sha256,
  });

  final String acaoId;
  final String evidenciaId;
  final String sha256;

  String get normalizedAcaoId => acaoId.trim();
  String get normalizedEvidenciaId => evidenciaId.trim();
  String get normalizedSha256 => sha256.trim().toLowerCase();

  bool get valido =>
      normalizedAcaoId.isNotEmpty &&
      normalizedEvidenciaId.isNotEmpty &&
      RegExp(r'^[a-f0-9]{64}$').hasMatch(normalizedSha256);

  String get idempotencyKey =>
      'evidence-upload-v1:$normalizedAcaoId:$normalizedEvidenciaId:'
      '$normalizedSha256';

  bool equivalenteA(EvidenceUploadIdentity other) =>
      valido &&
      other.valido &&
      normalizedAcaoId == other.normalizedAcaoId &&
      normalizedEvidenciaId == other.normalizedEvidenciaId &&
      normalizedSha256 == other.normalizedSha256;
}
