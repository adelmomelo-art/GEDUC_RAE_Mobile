import 'dart:io';

import '../models/evidencia_model.dart';
import '../storage/evidence_metadata_calculator.dart';
import '../storage/evidence_preparation_models.dart';
import '../storage/evidence_prepared_artifact_lifecycle.dart';
import '../storage/evidence_preparer.dart';
import 'evidence_sync_job.dart';
import 'evidence_sync_store.dart';

enum EvidenceUploadEnrollmentStatus {
  enrolled,
  alreadyEnrolled,
}

class EvidenceUploadEnrollmentResult {
  const EvidenceUploadEnrollmentResult({
    required this.status,
    required this.job,
    required this.artifact,
  });

  final EvidenceUploadEnrollmentStatus status;
  final EvidenceSyncJob job;
  final EvidencePreparedArtifact artifact;
}

class EvidenceUploadEnrollmentCoordinator {
  EvidenceUploadEnrollmentCoordinator({
    required EvidencePreparer preparer,
    required EvidenceSyncStore store,
    required EvidencePreparedArtifactLifecycle artifactLifecycle,
    EvidenceMetadataCalculator metadataCalculator =
        const EvidenceMetadataCalculator(),
    EvidencePreparationGuard guard = const EvidencePreparationGuard(),
  })  : _preparer = preparer,
        _store = store,
        _artifactLifecycle = artifactLifecycle,
        _metadataCalculator = metadataCalculator,
        _guard = guard;

  final EvidencePreparer _preparer;
  final EvidenceSyncStore _store;
  final EvidencePreparedArtifactLifecycle _artifactLifecycle;
  final EvidenceMetadataCalculator _metadataCalculator;
  final EvidencePreparationGuard _guard;

  Future<EvidenceUploadEnrollmentResult> enroll(
      EvidenciaModel evidencia) async {
    _validateEvidence(evidencia);

    final request = EvidencePreparationRequest(
      acaoId: evidencia.acaoId,
      evidenciaId: evidencia.id,
      originalFilePath: evidencia.caminhoArquivo,
      originalContentType: evidencia.mimeType,
    );

    final artifact = await _preparer.prepare(request);
    _guard.validateArtifactFor(request: request, artifact: artifact);

    final metadata =
        await _metadataCalculator.calculate(File(artifact.preparedFilePath));

    if (artifact.contentType.trim().toLowerCase() !=
        metadata.mimeType.trim().toLowerCase()) {
      throw StateError(
        'MIME do artefato preparado diverge dos bytes destinados ao upload.',
      );
    }

    final candidate = EvidenceSyncJob(
      acaoId: evidencia.acaoId.trim(),
      evidenciaId: evidencia.id.trim(),
      localFilePath: artifact.preparedFilePath,
      contentType: artifact.contentType.trim().toLowerCase(),
      tamanhoBytes: metadata.sizeBytes,
      sha256: metadata.sha256.toLowerCase(),
      autorUserId: evidencia.autorUserId.trim(),
      createdAt: evidencia.criadoEm.toUtc(),
    );

    if (!candidate.valido) {
      throw StateError(
        'Artefato preparado nao produz job de sincronizacao valido.',
      );
    }

    final existing = await _store.obter(
      acaoId: candidate.acaoId,
      evidenciaId: candidate.evidenciaId,
    );

    if (existing == null) {
      await _store.salvar(candidate);
      return EvidenceUploadEnrollmentResult(
        status: EvidenceUploadEnrollmentStatus.enrolled,
        job: candidate,
        artifact: artifact,
      );
    }

    if (!existing.valido) {
      throw StateError(
        'Fila contem job invalido para a evidencia em enrollment.',
      );
    }

    if (_sameImmutableSnapshot(existing, candidate)) {
      if (existing.status == EvidenceSyncJobStatus.synced) {
        await _artifactLifecycle.removePreparedArtifact(
          artifact.preparedFilePath,
        );
      }

      return EvidenceUploadEnrollmentResult(
        status: EvidenceUploadEnrollmentStatus.alreadyEnrolled,
        job: existing,
        artifact: artifact,
      );
    }

    if (!_samePreparedBytesSnapshot(existing, candidate)) {
      await _artifactLifecycle.removePreparedArtifact(
        artifact.preparedFilePath,
      );
    }

    throw StateError(
      'Enrollment recusado: snapshot preparado diverge do job duravel existente.',
    );
  }

  void _validateEvidence(EvidenciaModel evidencia) {
    if (evidencia.id.trim().isEmpty ||
        evidencia.acaoId.trim().isEmpty ||
        evidencia.caminhoArquivo.trim().isEmpty ||
        evidencia.mimeType.trim().isEmpty ||
        evidencia.autorUserId.trim().isEmpty) {
      throw ArgumentError('Evidencia incompleta para enrollment de upload.');
    }
  }

  bool _sameImmutableSnapshot(
    EvidenceSyncJob existing,
    EvidenceSyncJob candidate,
  ) {
    return _samePreparedBytesSnapshot(existing, candidate) &&
        existing.acaoId == candidate.acaoId &&
        existing.evidenciaId == candidate.evidenciaId &&
        existing.autorUserId == candidate.autorUserId &&
        existing.createdAt
            .toUtc()
            .isAtSameMomentAs(candidate.createdAt.toUtc());
  }

  bool _samePreparedBytesSnapshot(
    EvidenceSyncJob existing,
    EvidenceSyncJob candidate,
  ) {
    return existing.localFilePath == candidate.localFilePath &&
        existing.contentType.trim().toLowerCase() ==
            candidate.contentType.trim().toLowerCase() &&
        existing.tamanhoBytes == candidate.tamanhoBytes &&
        existing.sha256.trim().toLowerCase() ==
            candidate.sha256.trim().toLowerCase();
  }
}
