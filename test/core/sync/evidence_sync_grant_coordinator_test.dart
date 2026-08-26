import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_broker.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_upload_identity.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_grant_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_orchestrator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_store.dart';

void main() {
  group('AUD-L2-R5.5-C - EvidenceSyncGrantCoordinator', () {
    final agora = DateTime.utc(2026, 8, 21, 19, 30);

    EvidenceSyncJob job({
      String acaoId = 'acao-1',
      String evidenciaId = 'ev-1',
      String contentType = 'image/jpeg',
      int tamanhoBytes = 2048,
      String? sha256,
    }) {
      return EvidenceSyncJob(
        acaoId: acaoId,
        evidenciaId: evidenciaId,
        localFilePath: 'C:/evidencias/$evidenciaId.jpg',
        contentType: contentType,
        tamanhoBytes: tamanhoBytes,
        sha256: sha256 ?? 'a' * 64,
        autorUserId: 'user-1',
        createdAt: DateTime.utc(2026, 8, 21, 18),
      );
    }

    EvidenceAccessGrant uploadGrant({
      DateTime? expiresAt,
      EvidenceRemoteOperation operation = EvidenceRemoteOperation.upload,
      String objectKey = 'evidencias/acao-1/ev-1.jpg',
      String scheme = 'https',
      String host = 'storage.example.test',
      EvidenceUploadIdentity? uploadIdentity,
      bool semUploadIdentity = false,
    }) {
      return EvidenceAccessGrant(
        uri: Uri(
          scheme: scheme,
          host: host,
          path: '/signed-upload',
        ),
        operation: operation,
        expiresAt: expiresAt ?? agora.add(const Duration(minutes: 5)),
        objectKey: objectKey,
        requiredHeaders: const {'Content-Type': 'image/jpeg'},
        uploadIdentity: semUploadIdentity
            ? null
            : uploadIdentity ??
                EvidenceUploadIdentity(
                  acaoId: 'acao-1',
                  evidenciaId: 'ev-1',
                  sha256: 'a' * 64,
                ),
      );
    }

    test('sem candidato retorna null e nao chama broker', () async {
      final store = _FakeEvidenceSyncStore(const []);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(),
      );
      final coordinator = EvidenceSyncGrantCoordinator(
        orchestrator: EvidenceSyncOrchestrator(
          store: store,
          clock: () => agora,
        ),
        broker: broker,
        clock: () => agora,
      );

      final preparation = await coordinator.prepararProximaTentativa();

      expect(preparation, isNull);
      expect(broker.uploadCalls, 0);
      expect(store.saveCalls, 0);
      expect(store.removeCalls, 0);
    });

    test('broker desabilitado falha fechado antes de solicitar grant', () async {
      final store = _FakeEvidenceSyncStore([job()]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: false,
        grant: uploadGrant(),
      );
      final coordinator = EvidenceSyncGrantCoordinator(
        orchestrator: EvidenceSyncOrchestrator(
          store: store,
          clock: () => agora,
        ),
        broker: broker,
        clock: () => agora,
      );

      await expectLater(
        coordinator.prepararProximaTentativa(),
        throwsA(isA<StateError>()),
      );

      expect(broker.uploadCalls, 0);
      expect(store.saveCalls, 0);
      expect(store.removeCalls, 0);
    });

    test('request de upload usa snapshot canonico do job', () async {
      final expectedJob = job(
        acaoId: 'acao-77',
        evidenciaId: 'ev-99',
        contentType: 'image/png',
        tamanhoBytes: 9876,
        sha256: 'b' * 64,
      );
      final store = _FakeEvidenceSyncStore([expectedJob]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(
          objectKey: 'evidencias/acao-77/ev-99.png',
          uploadIdentity: EvidenceUploadIdentity(
            acaoId: 'acao-77',
            evidenciaId: 'ev-99',
            sha256: 'b' * 64,
          ),
        ),
      );

      final preparation = await EvidenceSyncGrantCoordinator(
        orchestrator: EvidenceSyncOrchestrator(
          store: store,
          clock: () => agora,
        ),
        broker: broker,
        clock: () => agora,
      ).prepararProximaTentativa();

      final request = broker.lastUploadRequest;
      expect(request, isNotNull);
      expect(request!.acaoId, 'acao-77');
      expect(request.evidenciaId, 'ev-99');
      expect(request.contentType, 'image/png');
      expect(request.tamanhoBytes, 9876);
      expect(request.sha256, 'b' * 64);
      expect(
        request.idempotencyKey,
        'evidence-upload-v1:acao-77:ev-99:${'b' * 64}',
      );
      expect(preparation?.job, same(expectedJob));
      expect(
        preparation?.grant.objectKey,
        'evidencias/acao-77/ev-99.png',
      );
      expect(broker.uploadCalls, 1);
    });

    test('grant expirado e recusado apos resposta do broker', () async {
      final store = _FakeEvidenceSyncStore([job()]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(
          expiresAt: agora.subtract(const Duration(seconds: 1)),
        ),
      );

      await expectLater(
        EvidenceSyncGrantCoordinator(
          orchestrator: EvidenceSyncOrchestrator(
            store: store,
            clock: () => agora,
          ),
          broker: broker,
          clock: () => agora,
        ).prepararProximaTentativa(),
        throwsA(isA<StateError>()),
      );

      expect(broker.uploadCalls, 1);
      expect(store.saveCalls, 0);
    });

    test('grant de leitura e recusado para tentativa de upload', () async {
      final store = _FakeEvidenceSyncStore([job()]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(operation: EvidenceRemoteOperation.read),
      );

      await expectLater(
        EvidenceSyncGrantCoordinator(
          orchestrator: EvidenceSyncOrchestrator(
            store: store,
            clock: () => agora,
          ),
          broker: broker,
          clock: () => agora,
        ).prepararProximaTentativa(),
        throwsA(isA<StateError>()),
      );

      expect(broker.uploadCalls, 1);
      expect(store.saveCalls, 0);
    });

    test('grant sem https e recusado', () async {
      final store = _FakeEvidenceSyncStore([job()]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(scheme: 'http'),
      );

      await expectLater(
        EvidenceSyncGrantCoordinator(
          orchestrator: EvidenceSyncOrchestrator(
            store: store,
            clock: () => agora,
          ),
          broker: broker,
          clock: () => agora,
        ).prepararProximaTentativa(),
        throwsA(isA<StateError>()),
      );

      expect(store.saveCalls, 0);
    });

    test('grant sem objectKey confiavel e recusado', () async {
      final store = _FakeEvidenceSyncStore([job()]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(objectKey: '   '),
      );

      await expectLater(
        EvidenceSyncGrantCoordinator(
          orchestrator: EvidenceSyncOrchestrator(
            store: store,
            clock: () => agora,
          ),
          broker: broker,
          clock: () => agora,
        ).prepararProximaTentativa(),
        throwsA(isA<StateError>()),
      );

      expect(store.saveCalls, 0);
    });

    test('grant sem binding de upload e recusado pelo sync', () async {
      final store = _FakeEvidenceSyncStore([job()]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(semUploadIdentity: true),
      );

      await expectLater(
        EvidenceSyncGrantCoordinator(
          orchestrator: EvidenceSyncOrchestrator(
            store: store,
            clock: () => agora,
          ),
          broker: broker,
          clock: () => agora,
        ).prepararProximaTentativa(),
        throwsA(isA<StateError>()),
      );
      expect(broker.uploadCalls, 1);
      expect(store.saveCalls, 0);
    });

    test('grant de outro snapshot e recusado', () async {
      final store = _FakeEvidenceSyncStore([job()]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(
          uploadIdentity: EvidenceUploadIdentity(
            acaoId: 'acao-1',
            evidenciaId: 'ev-1',
            sha256: 'c' * 64,
          ),
        ),
      );

      await expectLater(
        EvidenceSyncGrantCoordinator(
          orchestrator: EvidenceSyncOrchestrator(
            store: store,
            clock: () => agora,
          ),
          broker: broker,
          clock: () => agora,
        ).prepararProximaTentativa(),
        throwsA(isA<StateError>()),
      );
      expect(broker.uploadCalls, 1);
      expect(store.saveCalls, 0);
    });

    test('aquisicao valida nao altera fila nem executa transporte', () async {
      final expectedJob = job();
      final store = _FakeEvidenceSyncStore([expectedJob]);
      final broker = _FakeEvidenceAccessBroker(
        enabled: true,
        grant: uploadGrant(),
      );

      final preparation = await EvidenceSyncGrantCoordinator(
        orchestrator: EvidenceSyncOrchestrator(
          store: store,
          clock: () => agora,
        ),
        broker: broker,
        clock: () => agora,
      ).prepararProximaTentativa();

      expect(preparation, isNotNull);
      expect(preparation!.job.evidenciaId, 'ev-1');
      expect(preparation.grant.operation, EvidenceRemoteOperation.upload);
      expect(store.saveCalls, 0);
      expect(store.removeCalls, 0);
      expect(broker.uploadCalls, 1);
      expect(broker.readCalls, 0);
    });
  });
}

class _FakeEvidenceAccessBroker implements EvidenceAccessBroker {
  _FakeEvidenceAccessBroker({
    required this.enabled,
    required this.grant,
  });

  @override
  final bool enabled;

  final EvidenceAccessGrant grant;
  int uploadCalls = 0;
  int readCalls = 0;
  EvidenceUploadAccessRequest? lastUploadRequest;

  @override
  Future<EvidenceAccessGrant> requestUploadAccess(
    EvidenceUploadAccessRequest request,
  ) async {
    uploadCalls++;
    lastUploadRequest = request;
    return grant;
  }

  @override
  Future<EvidenceAccessGrant> requestReadAccess(
    EvidenceReadAccessRequest request,
  ) async {
    readCalls++;
    return grant;
  }
}

class _FakeEvidenceSyncStore implements EvidenceSyncStore {
  _FakeEvidenceSyncStore(List<EvidenceSyncJob> jobs)
      : _jobs = List<EvidenceSyncJob>.from(jobs);

  final List<EvidenceSyncJob> _jobs;
  int saveCalls = 0;
  int removeCalls = 0;

  @override
  Future<List<EvidenceSyncJob>> listar() async =>
      List<EvidenceSyncJob>.from(_jobs);

  @override
  Future<EvidenceSyncJob?> obter({
    required String acaoId,
    required String evidenciaId,
  }) async {
    for (final item in _jobs) {
      if (item.acaoId == acaoId && item.evidenciaId == evidenciaId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<void> salvar(EvidenceSyncJob job) async {
    saveCalls++;
  }

  @override
  Future<void> remover({
    required String acaoId,
    required String evidenciaId,
  }) async {
    removeCalls++;
  }
}
