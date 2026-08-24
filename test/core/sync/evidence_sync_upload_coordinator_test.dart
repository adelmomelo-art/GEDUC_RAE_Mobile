import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_models.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_transport.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_grant_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_store.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_upload_coordinator.dart';

void main() {
  group('AUD-L2-R5.5-D - EvidenceSyncUploadCoordinator', () {
    final agora = DateTime.utc(2026, 8, 24, 16, 15);
    const sha =
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

    EvidenceSyncJob job({
      EvidenceSyncJobStatus status = EvidenceSyncJobStatus.pending,
      int attemptCount = 0,
      DateTime? nextAttemptAt,
    }) {
      return EvidenceSyncJob(
        acaoId: 'acao-1',
        evidenciaId: 'ev-1',
        localFilePath: 'C:/evidencias/ev-1.jpg',
        contentType: 'image/jpeg',
        tamanhoBytes: 2048,
        sha256: sha,
        autorUserId: 'user-1',
        createdAt: DateTime.utc(2026, 8, 24, 15),
        status: status,
        attemptCount: attemptCount,
        nextAttemptAt: nextAttemptAt,
      );
    }

    EvidenceAccessGrant grant({
      DateTime? expiresAt,
      String objectKey = 'evidencias/acao-1/ev-1.jpg',
    }) {
      return EvidenceAccessGrant(
        uri: Uri.parse('https://storage.example.test/signed-upload'),
        operation: EvidenceRemoteOperation.upload,
        expiresAt: expiresAt ?? agora.add(const Duration(minutes: 5)),
        objectKey: objectKey,
        requiredHeaders: const {'Content-Type': 'image/jpeg'},
      );
    }

    EvidenceSyncGrantPreparation preparation({
      EvidenceSyncJob? value,
      EvidenceAccessGrant? accessGrant,
    }) {
      return EvidenceSyncGrantPreparation(
        job: value ?? job(),
        grant: accessGrant ?? grant(),
      );
    }

    test('happy path executa um upload e persiste synced', () async {
      final original = job();
      final store = _FakeStore(original);
      final transport = _FakeTransport(
        result: RemoteEvidenceUploadResult(
          objectKey: grant().objectKey,
          syncedAt: agora.add(const Duration(seconds: 2)),
          etag: '"etag-1"',
          sizeBytes: 2048,
        ),
      );

      final result = await EvidenceSyncUploadCoordinator(
        transport: transport,
        store: store,
        clock: () => agora,
      ).executar(preparation(value: original));

      expect(transport.uploadCalls, 1);
      expect(store.saveCalls, 1);
      expect(result.status, EvidenceSyncJobStatus.synced);
      expect(result.attemptCount, 1);
      expect(result.lastAttemptAt, agora);
      expect(result.nextAttemptAt, isNull);
      expect(result.objectKey, 'evidencias/acao-1/ev-1.jpg');
      expect(
        result.syncedAt,
        agora.add(const Duration(seconds: 2)),
      );
      expect(store.saved, same(result));
    });

    test('retryScheduled bem sucedido limpa nextAttemptAt', () async {
      final original = job(
        status: EvidenceSyncJobStatus.retryScheduled,
        attemptCount: 2,
        nextAttemptAt: agora.subtract(const Duration(minutes: 1)),
      );
      final store = _FakeStore(original);
      final transport = _FakeTransport(
        result: RemoteEvidenceUploadResult(
          objectKey: grant().objectKey,
          syncedAt: agora,
          sizeBytes: 2048,
        ),
      );

      final result = await EvidenceSyncUploadCoordinator(
        transport: transport,
        store: store,
        clock: () => agora,
      ).executar(preparation(value: original));

      expect(result.status, EvidenceSyncJobStatus.synced);
      expect(result.attemptCount, 3);
      expect(result.nextAttemptAt, isNull);
      expect(transport.uploadCalls, 1);
      expect(store.saveCalls, 1);
    });

    test('transporte desabilitado falha antes do upload', () async {
      final original = job();
      final store = _FakeStore(original);
      final transport = _FakeTransport(
        enabled: false,
        result: RemoteEvidenceUploadResult(
          objectKey: grant().objectKey,
          syncedAt: agora,
        ),
      );

      await expectLater(
        EvidenceSyncUploadCoordinator(
          transport: transport,
          store: store,
          clock: () => agora,
        ).executar(preparation(value: original)),
        throwsA(isA<StateError>()),
      );

      expect(transport.uploadCalls, 0);
      expect(store.saveCalls, 0);
    });

    test('grant expirado falha antes do upload', () async {
      final original = job();
      final store = _FakeStore(original);
      final transport = _FakeTransport(
        result: RemoteEvidenceUploadResult(
          objectKey: grant().objectKey,
          syncedAt: agora,
        ),
      );

      await expectLater(
        EvidenceSyncUploadCoordinator(
          transport: transport,
          store: store,
          clock: () => agora,
        ).executar(
          preparation(
            value: original,
            accessGrant: grant(
              expiresAt: agora.subtract(const Duration(seconds: 1)),
            ),
          ),
        ),
        throwsA(isA<StateError>()),
      );

      expect(transport.uploadCalls, 0);
      expect(store.saveCalls, 0);
    });

    test('falha do transporte propaga sem confirmar fila', () async {
      final original = job();
      final store = _FakeStore(original);
      final transport = _FakeTransport(
        error: StateError('falha simulada'),
      );

      await expectLater(
        EvidenceSyncUploadCoordinator(
          transport: transport,
          store: store,
          clock: () => agora,
        ).executar(preparation(value: original)),
        throwsA(isA<StateError>()),
      );

      expect(transport.uploadCalls, 1);
      expect(store.saveCalls, 0);
    });

    test('objectKey divergente recusa confirmacao persistida', () async {
      final original = job();
      final store = _FakeStore(original);
      final transport = _FakeTransport(
        result: RemoteEvidenceUploadResult(
          objectKey: 'evidencias/acao-1/outro.jpg',
          syncedAt: agora,
          sizeBytes: 2048,
        ),
      );

      await expectLater(
        EvidenceSyncUploadCoordinator(
          transport: transport,
          store: store,
          clock: () => agora,
        ).executar(preparation(value: original)),
        throwsA(isA<StateError>()),
      );

      expect(transport.uploadCalls, 1);
      expect(store.saveCalls, 0);
    });

    test('sizeBytes divergente recusa confirmacao persistida', () async {
      final original = job();
      final store = _FakeStore(original);
      final transport = _FakeTransport(
        result: RemoteEvidenceUploadResult(
          objectKey: grant().objectKey,
          syncedAt: agora,
          sizeBytes: 999,
        ),
      );

      await expectLater(
        EvidenceSyncUploadCoordinator(
          transport: transport,
          store: store,
          clock: () => agora,
        ).executar(preparation(value: original)),
        throwsA(isA<StateError>()),
      );

      expect(transport.uploadCalls, 1);
      expect(store.saveCalls, 0);
    });

    test('mudanca concorrente do job apos upload impede overwrite', () async {
      final original = job();
      final altered = original.copyWith(
        attemptCount: 1,
        lastAttemptAt: agora.subtract(const Duration(seconds: 10)),
      );
      final store = _FakeStore(
        original,
        valueReturnedByGet: altered,
      );
      final transport = _FakeTransport(
        result: RemoteEvidenceUploadResult(
          objectKey: grant().objectKey,
          syncedAt: agora,
          sizeBytes: 2048,
        ),
      );

      await expectLater(
        EvidenceSyncUploadCoordinator(
          transport: transport,
          store: store,
          clock: () => agora,
        ).executar(preparation(value: original)),
        throwsA(isA<StateError>()),
      );

      expect(transport.uploadCalls, 1);
      expect(store.saveCalls, 0);
    });
  });
}

class _FakeTransport implements RemoteEvidenceTransport {
  _FakeTransport({
    this.enabled = true,
    this.result,
    this.error,
  });

  @override
  final bool enabled;

  final RemoteEvidenceUploadResult? result;
  final Object? error;
  int uploadCalls = 0;

  @override
  Future<RemoteEvidenceUploadResult> upload({
    required EvidenceAccessGrant grant,
    required RemoteEvidenceUploadRequest request,
  }) async {
    uploadCalls++;
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

class _FakeStore implements EvidenceSyncStore {
  _FakeStore(
    this.current, {
    this.valueReturnedByGet,
  });

  EvidenceSyncJob? current;
  final EvidenceSyncJob? valueReturnedByGet;
  int saveCalls = 0;
  EvidenceSyncJob? saved;

  @override
  Future<List<EvidenceSyncJob>> listar() async =>
      current == null ? <EvidenceSyncJob>[] : <EvidenceSyncJob>[current!];

  @override
  Future<EvidenceSyncJob?> obter({
    required String acaoId,
    required String evidenciaId,
  }) async {
    return valueReturnedByGet ?? current;
  }

  @override
  Future<void> salvar(EvidenceSyncJob job) async {
    saveCalls++;
    saved = job;
    current = job;
  }

  @override
  Future<void> remover({
    required String acaoId,
    required String evidenciaId,
  }) async {}
}
