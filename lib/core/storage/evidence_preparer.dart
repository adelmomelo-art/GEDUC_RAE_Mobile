import 'package:path/path.dart' as path;

import 'evidence_preparation_models.dart';

abstract interface class EvidencePreparer {
  Future<EvidencePreparedArtifact> prepare(
    EvidencePreparationRequest request,
  );
}

/// Guard contratual entre captura/local storage e qualquer implementacao
/// concreta de preparacao/compressao.
///
/// O guard nao calcula SHA-256 nem tamanho. Esses metadados pertencem aos bytes
/// finais e devem ser calculados somente depois que o artefato preparado for
/// validado e congelado para o upload.
class EvidencePreparationGuard {
  const EvidencePreparationGuard();

  void validateRequest(EvidencePreparationRequest request) {
    if (!request.valido) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.invalidRequest,
        message: 'Requisicao de preparacao de evidencia invalida.',
      );
    }
  }

  void validateArtifactFor({
    required EvidencePreparationRequest request,
    required EvidencePreparedArtifact artifact,
  }) {
    validateRequest(request);

    if (!artifact.valido) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.invalidArtifact,
        message: 'Artefato preparado de evidencia invalido.',
      );
    }

    final normalizedRequestOriginal =
        path.normalize(request.originalFilePath.trim());
    final normalizedArtifactOriginal =
        path.normalize(artifact.originalFilePath.trim());
    final normalizedPrepared =
        path.normalize(artifact.preparedFilePath.trim());

    if (normalizedArtifactOriginal != normalizedRequestOriginal) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.sourceMismatch,
        message: 'O artefato preparado nao corresponde ao original solicitado.',
      );
    }

    if (normalizedPrepared == normalizedRequestOriginal) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.originalArtifactAlias,
        message: 'O artefato preparado deve ser separado do arquivo original.',
      );
    }
  }
}