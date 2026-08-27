class EvidencePreparationRequest {
  const EvidencePreparationRequest({
    required this.acaoId,
    required this.evidenciaId,
    required this.originalFilePath,
    required this.originalContentType,
  });

  final String acaoId;
  final String evidenciaId;
  final String originalFilePath;
  final String originalContentType;

  bool get valido =>
      acaoId.trim().isNotEmpty &&
      evidenciaId.trim().isNotEmpty &&
      originalFilePath.trim().isNotEmpty &&
      originalContentType.trim().isNotEmpty;
}

class EvidencePreparedArtifact {
  const EvidencePreparedArtifact({
    required this.originalFilePath,
    required this.preparedFilePath,
    required this.contentType,
    required this.preparationProfile,
    required this.createdAt,
  });

  final String originalFilePath;
  final String preparedFilePath;
  final String contentType;

  /// Identificador estavel da politica/receita que produziu o artefato.
  ///
  /// Nao e SHA-256, objectKey, segredo ou credencial.
  final String preparationProfile;

  final DateTime createdAt;

  bool get valido =>
      originalFilePath.trim().isNotEmpty &&
      preparedFilePath.trim().isNotEmpty &&
      contentType.trim().isNotEmpty &&
      preparationProfile.trim().isNotEmpty;
}

enum EvidencePreparationFailure {
  invalidRequest,
  invalidArtifact,
  originalArtifactAlias,
  sourceMismatch,
  preparationFailure,
}

class EvidencePreparationException implements Exception {
  const EvidencePreparationException({
    required this.failure,
    required this.message,
    this.cause,
  });

  final EvidencePreparationFailure failure;
  final String message;
  final Object? cause;

  @override
  String toString() => 'EvidencePreparationException('
      'failure: $failure, message: $message)';
}