import '../storage/evidence_remote_operation.dart';
import '../storage/remote_evidence_models.dart';
import '../storage/remote_evidence_transport.dart';
import 'evidence_sync_grant_coordinator.dart';
import 'evidence_sync_job.dart';
import 'evidence_sync_store.dart';

/// Executa uma unica tentativa de upload e confirma o sucesso na fila duravel.
///
/// Nao aplica retry/backoff. Falhas do transporte sao propagadas para a camada
/// posterior de politica. O job so e marcado como sincronizado depois que:
///
/// 1. o transporte confirma sucesso;
/// 2. o resultado remoto e coerente com o grant;
/// 3. o snapshot persistido ainda corresponde ao job que foi transferido.
class EvidenceSyncUploadCoordinator {
  EvidenceSyncUploadCoordinator({
    required RemoteEvidenceTransport transport,
    required EvidenceSyncStore store,
    DateTime Function()? clock,
  })  : _transport = transport,
        _store = store,
        _clock = clock ?? DateTime.now;

  final RemoteEvidenceTransport _transport;
  final EvidenceSyncStore _store;
  final DateTime Function() _clock;

  Future<EvidenceSyncJob> executar(
    EvidenceSyncGrantPreparation preparation,
  ) async {
    final job = preparation.job;
    final grant = preparation.grant;
    final startedAt = _clock().toUtc();

    if (!_transport.enabled) {
      throw StateError(
        'Transporte remoto de evidencias esta desabilitado.',
      );
    }

    if (!job.valido || !_statusTentavel(job.status)) {
      throw StateError(
        'Job nao esta apto para uma tentativa de upload.',
      );
    }

    if (!grant.validoPara(
      operacaoEsperada: EvidenceRemoteOperation.upload,
      instante: startedAt,
    )) {
      throw StateError(
        'Grant nao esta valido para upload no momento da tentativa.',
      );
    }

    final request = RemoteEvidenceUploadRequest(
      acaoId: job.acaoId,
      evidenciaId: job.evidenciaId,
      localFilePath: job.localFilePath,
      contentType: job.contentType,
    );

    if (!request.valido) {
      throw StateError(
        'Snapshot nao produz requisicao valida para o transporte.',
      );
    }

    final result = await _transport.upload(
      grant: grant,
      request: request,
    );

    _validarResultado(
      result: result,
      job: job,
      grantObjectKey: grant.objectKey,
    );

    final persisted = await _store.obter(
      acaoId: job.acaoId,
      evidenciaId: job.evidenciaId,
    );

    if (persisted == null) {
      throw StateError(
        'Job desapareceu da fila apos o upload; confirmacao recusada.',
      );
    }

    if (!_mesmoSnapshotPersistido(persisted, job)) {
      throw StateError(
        'Job mudou durante o upload; confirmacao persistida recusada.',
      );
    }

    final confirmado = persisted.copyWith(
      status: EvidenceSyncJobStatus.synced,
      attemptCount: persisted.attemptCount + 1,
      lastAttemptAt: startedAt,
      limparNextAttemptAt: true,
      objectKey: result.objectKey.trim(),
      syncedAt: result.syncedAt.toUtc(),
    );

    if (!confirmado.valido) {
      throw StateError(
        'Resultado de upload nao produz estado sincronizado coerente.',
      );
    }

    await _store.salvar(confirmado);
    return confirmado;
  }

  bool _statusTentavel(EvidenceSyncJobStatus status) =>
      status == EvidenceSyncJobStatus.pending ||
      status == EvidenceSyncJobStatus.retryScheduled;

  void _validarResultado({
    required RemoteEvidenceUploadResult result,
    required EvidenceSyncJob job,
    required String grantObjectKey,
  }) {
    final resultKey = result.objectKey.trim();
    final trustedKey = grantObjectKey.trim();

    if (resultKey.isEmpty || resultKey != trustedKey) {
      throw StateError(
        'objectKey confirmado pelo transporte diverge do grant confiavel.',
      );
    }

    if (result.sizeBytes != null && result.sizeBytes != job.tamanhoBytes) {
      throw StateError(
        'Tamanho confirmado pelo transporte diverge do snapshot local.',
      );
    }
  }

  bool _mesmoSnapshotPersistido(EvidenceSyncJob atual, EvidenceSyncJob origem) {
    return atual.acaoId == origem.acaoId &&
        atual.evidenciaId == origem.evidenciaId &&
        atual.localFilePath == origem.localFilePath &&
        atual.contentType == origem.contentType &&
        atual.tamanhoBytes == origem.tamanhoBytes &&
        atual.sha256 == origem.sha256 &&
        atual.autorUserId == origem.autorUserId &&
        atual.createdAt.toUtc().isAtSameMomentAs(origem.createdAt.toUtc()) &&
        atual.status == origem.status &&
        atual.attemptCount == origem.attemptCount &&
        _sameDate(atual.lastAttemptAt, origem.lastAttemptAt) &&
        _sameDate(atual.nextAttemptAt, origem.nextAttemptAt) &&
        atual.objectKey == origem.objectKey &&
        _sameDate(atual.syncedAt, origem.syncedAt);
  }

  bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return a == null && b == null;
    }
    return a.toUtc().isAtSameMomentAs(b.toUtc());
  }
}
