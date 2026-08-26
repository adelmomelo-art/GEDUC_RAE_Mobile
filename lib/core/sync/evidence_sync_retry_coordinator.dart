import '../storage/remote_evidence_upload_exception.dart';
import 'evidence_sync_connectivity_probe.dart';
import 'evidence_sync_grant_coordinator.dart';
import 'evidence_sync_job.dart';
import 'evidence_sync_retry_policy.dart';
import 'evidence_sync_store.dart';
import 'evidence_sync_upload_confirmation_exception.dart';
import 'evidence_sync_upload_coordinator.dart';

enum EvidenceSyncCycleStatus {
  noCandidate,
  networkUnavailable,
  alreadyProcessing,
  synced,
  retryScheduled,
  blocked,
}

class EvidenceSyncCycleResult {
  const EvidenceSyncCycleResult({
    required this.status,
    this.job,
  });

  final EvidenceSyncCycleStatus status;
  final EvidenceSyncJob? job;
}

/// Dono unico da politica de tentativa para evidencias.
///
/// O transporte continua fazendo uma unica chamada por invocacao. Esta camada
/// decide quando agendar nova tentativa, quando bloquear e quando preservar a
/// identidade remota para reconciliacao.
class EvidenceSyncRetryCoordinator {
  EvidenceSyncRetryCoordinator({
    required EvidenceSyncConnectivityProbe connectivity,
    required EvidenceSyncGrantCoordinator grantCoordinator,
    required EvidenceSyncUploadCoordinator uploadCoordinator,
    required EvidenceSyncStore store,
    EvidenceSyncRetryPolicy? policy,
    DateTime Function()? clock,
  })  : _connectivity = connectivity,
        _grantCoordinator = grantCoordinator,
        _uploadCoordinator = uploadCoordinator,
        _store = store,
        _policy = policy ?? EvidenceSyncRetryPolicy(),
        _clock = clock ?? DateTime.now;

  final EvidenceSyncConnectivityProbe _connectivity;
  final EvidenceSyncGrantCoordinator _grantCoordinator;
  final EvidenceSyncUploadCoordinator _uploadCoordinator;
  final EvidenceSyncStore _store;
  final EvidenceSyncRetryPolicy _policy;
  final DateTime Function() _clock;

  bool _processing = false;

  Future<EvidenceSyncCycleResult> processarProxima() async {
    if (_processing) {
      return const EvidenceSyncCycleResult(
        status: EvidenceSyncCycleStatus.alreadyProcessing,
      );
    }

    _processing = true;
    try {
      return await _processarProximaInterno();
    } finally {
      _processing = false;
    }
  }

  Future<EvidenceSyncCycleResult> _processarProximaInterno() async {
    if (!await _connectivity.possuiRede()) {
      return const EvidenceSyncCycleResult(
        status: EvidenceSyncCycleStatus.networkUnavailable,
      );
    }

    final preparation = await _grantCoordinator.prepararProximaTentativa();
    if (preparation == null) {
      return const EvidenceSyncCycleResult(
        status: EvidenceSyncCycleStatus.noCandidate,
      );
    }

    final job = preparation.job;
    final grantKey = preparation.grant.objectKey.trim();
    final reconciliationKey = job.reconciliationObjectKey?.trim();

    if (reconciliationKey != null &&
        reconciliationKey.isNotEmpty &&
        reconciliationKey != grantKey) {
      final blocked = job.copyWith(
        status: EvidenceSyncJobStatus.blocked,
        limparNextAttemptAt: true,
      );

      if (!blocked.valido) {
        throw StateError(
          'Divergencia de objectKey nao produz estado bloqueado coerente.',
        );
      }

      await _store.salvar(blocked);
      return EvidenceSyncCycleResult(
        status: EvidenceSyncCycleStatus.blocked,
        job: blocked,
      );
    }

    try {
      final synced = await _uploadCoordinator.executar(preparation);
      return EvidenceSyncCycleResult(
        status: EvidenceSyncCycleStatus.synced,
        job: synced,
      );
    } on RemoteEvidenceUploadException catch (error) {
      if (error.retryCandidate) {
        return _agendarOuBloquear(
          job: job,
          reconciliationObjectKey: grantKey,
        );
      }

      return _bloquearAposTentativa(job);
    } on EvidenceSyncConfirmationException catch (error) {
      if (error.concurrentStateConflict) {
        rethrow;
      }

      if (error.retryCandidate) {
        return _agendarOuBloquear(
          job: job,
          reconciliationObjectKey: error.trustedObjectKey,
        );
      }

      return _bloquearAposTentativa(
        job,
        reconciliationObjectKey: error.trustedObjectKey,
      );
    }
  }

  Future<EvidenceSyncCycleResult> _agendarOuBloquear({
    required EvidenceSyncJob job,
    required String reconciliationObjectKey,
  }) async {
    final now = _clock().toUtc();
    final attemptCount = job.attemptCount + 1;
    final trustedKey = reconciliationObjectKey.trim();

    if (trustedKey.isEmpty) {
      throw StateError(
        'Retry de evidencia exige objectKey confiavel para reconciliacao.',
      );
    }

    if (!_policy.podeAgendarAposFalha(attemptCount)) {
      final blocked = job.copyWith(
        status: EvidenceSyncJobStatus.blocked,
        attemptCount: attemptCount,
        lastAttemptAt: now,
        limparNextAttemptAt: true,
        reconciliationObjectKey: trustedKey,
      );

      await _store.salvar(blocked);
      return EvidenceSyncCycleResult(
        status: EvidenceSyncCycleStatus.blocked,
        job: blocked,
      );
    }

    final nextAttemptAt = now.add(
      _policy.delayForAttempt(attemptCount),
    );

    final scheduled = job.copyWith(
      status: EvidenceSyncJobStatus.retryScheduled,
      attemptCount: attemptCount,
      lastAttemptAt: now,
      nextAttemptAt: nextAttemptAt,
      reconciliationObjectKey: trustedKey,
    );

    if (!scheduled.valido) {
      throw StateError(
        'Falha retryable nao produz estado retryScheduled coerente.',
      );
    }

    await _store.salvar(scheduled);
    return EvidenceSyncCycleResult(
      status: EvidenceSyncCycleStatus.retryScheduled,
      job: scheduled,
    );
  }

  Future<EvidenceSyncCycleResult> _bloquearAposTentativa(
    EvidenceSyncJob job, {
    String? reconciliationObjectKey,
  }) async {
    final now = _clock().toUtc();
    final trustedKey = reconciliationObjectKey?.trim();

    final blocked = job.copyWith(
      status: EvidenceSyncJobStatus.blocked,
      attemptCount: job.attemptCount + 1,
      lastAttemptAt: now,
      limparNextAttemptAt: true,
      reconciliationObjectKey:
          trustedKey == null || trustedKey.isEmpty ? null : trustedKey,
    );

    if (!blocked.valido) {
      throw StateError(
        'Falha nao retryable nao produz estado blocked coerente.',
      );
    }

    await _store.salvar(blocked);
    return EvidenceSyncCycleResult(
      status: EvidenceSyncCycleStatus.blocked,
      job: blocked,
    );
  }
}
