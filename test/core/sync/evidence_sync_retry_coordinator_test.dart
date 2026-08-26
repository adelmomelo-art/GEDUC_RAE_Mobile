import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_broker.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_upload_identity.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_models.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_transport.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_upload_exception.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_connectivity_probe.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_grant_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_orchestrator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_retry_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_retry_policy.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_store.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_upload_coordinator.dart';

void main() {
  group('AUD-L2-R5.5-E - EvidenceSyncRetryCoordinator', () {
    final agora = DateTime.utc(2026, 8, 24, 18, 45);
    const sha =
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    const objectKey = 'evidencias/acao-1/ev-1.jpg';

    EvidenceSyncJob job({
      EvidenceSyncJobStatus status = EvidenceSyncJobStatus.pending,
      int attemptCount = 0,
      DateTime? nextAttemptAt,
      String? reconciliationObjectKey,
    }) {
      return EvidenceSyncJob(
        acaoId: 'acao-1',
        evidenciaId: 'ev-1',
        localFilePath: 'C:/evidencias/ev-1.jpg',
        contentType: 'image/jpeg',
        tamanhoBytes: 2048,
        sha256: sha,
        autorUserId: 'user-1',
        createdAt: DateTime.utc(2026, 8, 24, 18),
        status: status,
        attemptCount: attemptCount,
        nextAttemptAt: nextAttemptAt,
        reconciliationObjectKey: reconciliationObjectKey,
      );
    }

    EvidenceAccessGrant grant({
      String key = objectKey,
    }) {
      return EvidenceAccessGrant(
        uri: Uri.parse('https://storage.example.test/signed-upload'),
        operation: EvidenceRemoteOperation.upload,
        expiresAt: agora.add(const Duration(minutes: 10)),
        objectKey: key,
        requiredHeaders: const {'Content-Type': 'image/jpeg'},
        uploadIdentity: const EvidenceUploadIdentity(
          acaoId: 'acao-1',
          evidenciaId: 'ev-1',
          sha256: sha,
        ),
      );
    }

    _Harness harness({
      required EvidenceSyncJob initial,
      bool connected = true,
      EvidenceAccessGrant? accessGrant,
      RemoteEvidenceUploadResult? uploadResult,
      Object? uploadError,
      EvidenceSyncRetryPolicy? policy,
      EvidenceSyncConnectivityProbe? connectivity,
    }) {
      final store = _FakeStore(initial);
      final broker = _FakeBroker(accessGrant ?? grant());
      final transport = _FakeTransport(
        result: uploadResult ??
            RemoteEvidenceUploadResult(
              objectKey: (accessGrant ?? grant()).objectKey,
              syncedAt: agora.add(const Duration(seconds: 2)),
              sizeBytes: 2048,
            ),
        error: uploadError,
      );

      final grantCoordinator = EvidenceSyncGrantCoordinator(
        orchestrator: EvidenceSyncOrchestrator(
          store: store,
          clock: () => agora,
        ),
        broker: broker,
        clock: () => agora,
      );

      final uploadCoordinator = EvidenceSyncUploadCoordinator(
        transport: transport,
        store: store,
        clock: () => agora,
      );

      final retryCoordinator = EvidenceSyncRetryCoordinator(
        connectivity: connectivity ?? _FakeConnectivity(connected),
        grantCoordinator: grantCoordinator,
        uploadCoordinator: uploadCoordinator,
        store: store,
        policy: policy ?? EvidenceSyncRetryPolicy(),
        clock: () => agora,
      );

      return _Harness(
        coordinator: retryCoordinator,
        store: store,
        broker: broker,
        transport: transport,
      );
    }

    test('sem rede nao chama broker nem transporte e nao conta tentativa',
        () async {
      final h = harness(
        initial: job(),
        connected: false,
      );

      final result = await h.coordinator.processarProxima();

      expect(result.status, EvidenceSyncCycleStatus.networkUnavailable);
      expect(h.broker.calls, 0);
      expect(h.transport.calls, 0);
      expect(h.store.saveCalls, 0);
      expect(h.store.current!.attemptCount, 0);
    });

    test('single-flight rejeita segundo ciclo enquanto o primeiro esta ativo',
        () async {
      final controlled = _ControlledConnectivity();
      final h = harness(
        initial: job(),
        connectivity: controlled,
      );

      final first = h.coordinator.processarProxima();
      await controlled.entered.future;

      final second = await h.coordinator.processarProxima();

      expect(second.status, EvidenceSyncCycleStatus.alreadyProcessing);
      expect(h.broker.calls, 0);
      expect(h.transport.calls, 0);

      controlled.release.complete();
      final firstResult = await first;

      expect(firstResult.status, EvidenceSyncCycleStatus.synced);
      expect(h.broker.calls, 1);
      expect(h.transport.calls, 1);
    });

    test('falha retryable agenda primeira tentativa com 30 segundos',
        () async {
      final h = harness(
        initial: job(),
        uploadError: const RemoteEvidenceUploadException(
          failure: RemoteEvidenceUploadFailure.transportFailure,
          message: 'timeout',
        ),
      );

      final result = await h.coordinator.processarProxima();

      expect(result.status, EvidenceSyncCycleStatus.retryScheduled);
      expect(h.transport.calls, 1);
      expect(h.store.current!.status, EvidenceSyncJobStatus.retryScheduled);
      expect(h.store.current!.attemptCount, 1);
      expect(h.store.current!.lastAttemptAt, agora);
      expect(
        h.store.current!.nextAttemptAt,
        agora.add(const Duration(seconds: 30)),
      );
      expect(h.store.current!.reconciliationObjectKey, objectKey);
    });

    test('segunda falha aplica backoff exponencial de 60 segundos', () async {
      final initial = job(
        status: EvidenceSyncJobStatus.retryScheduled,
        attemptCount: 1,
        nextAttemptAt: agora,
        reconciliationObjectKey: objectKey,
      );

      final h = harness(
        initial: initial,
        uploadError: const RemoteEvidenceUploadException(
          failure: RemoteEvidenceUploadFailure.httpRejected,
          message: 'temporario',
          statusCode: 503,
        ),
      );

      final result = await h.coordinator.processarProxima();

      expect(result.status, EvidenceSyncCycleStatus.retryScheduled);
      expect(h.store.current!.attemptCount, 2);
      expect(
        h.store.current!.nextAttemptAt,
        agora.add(const Duration(seconds: 60)),
      );
      expect(h.store.current!.reconciliationObjectKey, objectKey);
    });

    test('falha nao retryable bloqueia e nao agenda nova tentativa', () async {
      final h = harness(
        initial: job(),
        uploadError: const RemoteEvidenceUploadException(
          failure: RemoteEvidenceUploadFailure.httpRejected,
          message: 'proibido',
          statusCode: 403,
        ),
      );

      final result = await h.coordinator.processarProxima();

      expect(result.status, EvidenceSyncCycleStatus.blocked);
      expect(h.store.current!.status, EvidenceSyncJobStatus.blocked);
      expect(h.store.current!.attemptCount, 1);
      expect(h.store.current!.nextAttemptAt, isNull);
    });

    test('limite de tentativas bloqueia em vez de agendar indefinidamente',
        () async {
      final initial = job(
        status: EvidenceSyncJobStatus.retryScheduled,
        attemptCount: 2,
        nextAttemptAt: agora,
        reconciliationObjectKey: objectKey,
      );

      final h = harness(
        initial: initial,
        policy: EvidenceSyncRetryPolicy(maxAttempts: 3),
        uploadError: const RemoteEvidenceUploadException(
          failure: RemoteEvidenceUploadFailure.transportFailure,
          message: 'timeout',
        ),
      );

      final result = await h.coordinator.processarProxima();

      expect(result.status, EvidenceSyncCycleStatus.blocked);
      expect(h.store.current!.attemptCount, 3);
      expect(h.store.current!.reconciliationObjectKey, objectKey);
      expect(h.store.current!.nextAttemptAt, isNull);
    });

    test('grant com chave diferente da reconciliacao bloqueia antes do upload',
        () async {
      final initial = job(
        status: EvidenceSyncJobStatus.retryScheduled,
        attemptCount: 1,
        nextAttemptAt: agora,
        reconciliationObjectKey: objectKey,
      );

      final h = harness(
        initial: initial,
        accessGrant: grant(key: 'evidencias/acao-1/OUTRA.jpg'),
      );

      final result = await h.coordinator.processarProxima();

      expect(result.status, EvidenceSyncCycleStatus.blocked);
      expect(h.transport.calls, 0);
      expect(h.store.current!.status, EvidenceSyncJobStatus.blocked);
      expect(h.store.current!.attemptCount, 1);
      expect(h.store.current!.reconciliationObjectKey, objectKey);
    });

    test('retry com a mesma chave conclui sync e limpa chave de reconciliacao',
        () async {
      final initial = job(
        status: EvidenceSyncJobStatus.retryScheduled,
        attemptCount: 1,
        nextAttemptAt: agora,
        reconciliationObjectKey: objectKey,
      );

      final h = harness(initial: initial);

      final result = await h.coordinator.processarProxima();

      expect(result.status, EvidenceSyncCycleStatus.synced);
      expect(h.transport.calls, 1);
      expect(h.store.current!.status, EvidenceSyncJobStatus.synced);
      expect(h.store.current!.attemptCount, 2);
      expect(h.store.current!.objectKey, objectKey);
      expect(h.store.current!.reconciliationObjectKey, isNull);
    });

    test('resultado remoto incoerente bloqueia preservando chave confiavel',
        () async {
      final h = harness(
        initial: job(),
        uploadResult: RemoteEvidenceUploadResult(
          objectKey: 'evidencias/acao-1/errada.jpg',
          syncedAt: agora,
          sizeBytes: 2048,
        ),
      );

      final result = await h.coordinator.processarProxima();

      expect(result.status, EvidenceSyncCycleStatus.blocked);
      expect(h.store.current!.attemptCount, 1);
      expect(h.store.current!.reconciliationObjectKey, objectKey);
    });
  });
}

class _Harness {
  const _Harness({
    required this.coordinator,
    required this.store,
    required this.broker,
    required this.transport,
  });

  final EvidenceSyncRetryCoordinator coordinator;
  final _FakeStore store;
  final _FakeBroker broker;
  final _FakeTransport transport;
}

class _ControlledConnectivity implements EvidenceSyncConnectivityProbe {
  final Completer<void> entered = Completer<void>();
  final Completer<void> release = Completer<void>();

  @override
  Future<bool> possuiRede() async {
    if (!entered.isCompleted) {
      entered.complete();
    }
    await release.future;
    return true;
  }
}

class _FakeConnectivity implements EvidenceSyncConnectivityProbe {
  const _FakeConnectivity(this.connected);

  final bool connected;

  @override
  Future<bool> possuiRede() async => connected;
}

class _FakeBroker implements EvidenceAccessBroker {
  _FakeBroker(this.grant);

  final EvidenceAccessGrant grant;
  int calls = 0;

  @override
  bool get enabled => true;

  @override
  Future<EvidenceAccessGrant> requestUploadAccess(
    EvidenceUploadAccessRequest request,
  ) async {
    calls++;
    return grant;
  }

  @override
  Future<EvidenceAccessGrant> requestReadAccess(
    EvidenceReadAccessRequest request,
  ) {
    throw UnimplementedError();
  }
}

class _FakeTransport implements RemoteEvidenceTransport {
  _FakeTransport({
    required this.result,
    this.error,
  });

  final RemoteEvidenceUploadResult result;
  final Object? error;
  int calls = 0;

  @override
  bool get enabled => true;

  @override
  Future<RemoteEvidenceUploadResult> upload({
    required EvidenceAccessGrant grant,
    required RemoteEvidenceUploadRequest request,
  }) async {
    calls++;
    if (error != null) {
      throw error!;
    }
    return result;
  }
}

class _FakeStore implements EvidenceSyncStore {
  _FakeStore(this.current);

  EvidenceSyncJob? current;
  int saveCalls = 0;

  @override
  Future<List<EvidenceSyncJob>> listar() async =>
      current == null ? <EvidenceSyncJob>[] : <EvidenceSyncJob>[current!];

  @override
  Future<EvidenceSyncJob?> obter({
    required String acaoId,
    required String evidenciaId,
  }) async =>
      current;

  @override
  Future<void> salvar(EvidenceSyncJob job) async {
    saveCalls++;
    current = job;
  }

  @override
  Future<void> remover({
    required String acaoId,
    required String evidenciaId,
  }) async {
    current = null;
  }
}
