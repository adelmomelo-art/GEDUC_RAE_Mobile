import '../storage/evidence_prepared_artifact_lifecycle.dart';
import 'evidence_sync_job.dart';
import 'evidence_sync_retry_coordinator.dart';

typedef EvidenceSyncNextProcessor = Future<EvidenceSyncCycleResult> Function();

enum EvidenceSyncArtifactCleanupStatus {
  notRequired,
  removed,
  alreadyAbsent,
  failed,
}

class EvidenceSyncPipelineResult {
  const EvidenceSyncPipelineResult({
    required this.syncResult,
    required this.cleanupStatus,
    this.cleanupError,
  });

  final EvidenceSyncCycleResult syncResult;
  final EvidenceSyncArtifactCleanupStatus cleanupStatus;
  final Object? cleanupError;
}

class EvidenceSyncPipelineCoordinator {
  EvidenceSyncPipelineCoordinator({
    required EvidenceSyncRetryCoordinator retryCoordinator,
    required EvidencePreparedArtifactLifecycle artifactLifecycle,
  })  : _processNext = retryCoordinator.processarProxima,
        _artifactLifecycle = artifactLifecycle;

  EvidenceSyncPipelineCoordinator.withProcessor({
    required EvidenceSyncNextProcessor processNext,
    required EvidencePreparedArtifactLifecycle artifactLifecycle,
  })  : _processNext = processNext,
        _artifactLifecycle = artifactLifecycle;

  final EvidenceSyncNextProcessor _processNext;
  final EvidencePreparedArtifactLifecycle _artifactLifecycle;

  Future<EvidenceSyncPipelineResult> processarProxima() async {
    final syncResult = await _processNext();

    if (syncResult.status != EvidenceSyncCycleStatus.synced) {
      return EvidenceSyncPipelineResult(
        syncResult: syncResult,
        cleanupStatus: EvidenceSyncArtifactCleanupStatus.notRequired,
      );
    }

    final job = syncResult.job;
    if (job == null || job.status != EvidenceSyncJobStatus.synced) {
      return EvidenceSyncPipelineResult(
        syncResult: syncResult,
        cleanupStatus: EvidenceSyncArtifactCleanupStatus.failed,
        cleanupError: StateError(
          'Resultado synced sem job duravelmente sincronizado; cleanup recusado.',
        ),
      );
    }

    try {
      final status = await _artifactLifecycle.removePreparedArtifact(
        job.localFilePath,
      );

      return EvidenceSyncPipelineResult(
        syncResult: syncResult,
        cleanupStatus: status == EvidencePreparedArtifactRemovalStatus.removed
            ? EvidenceSyncArtifactCleanupStatus.removed
            : EvidenceSyncArtifactCleanupStatus.alreadyAbsent,
      );
    } catch (error) {
      return EvidenceSyncPipelineResult(
        syncResult: syncResult,
        cleanupStatus: EvidenceSyncArtifactCleanupStatus.failed,
        cleanupError: error,
      );
    }
  }
}
