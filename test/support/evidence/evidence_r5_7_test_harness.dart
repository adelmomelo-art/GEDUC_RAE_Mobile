import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geduc_rae_mobile/core/models/evidencia_model.dart';
import 'package:geduc_rae_mobile/core/storage/application_documents_evidence_prepared_path_resolver.dart';
import 'package:geduc_rae_mobile/core/storage/deterministic_image_evidence_preparer.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_broker.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_prepared_artifact_lifecycle.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_upload_identity.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_models.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_transport.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_connectivity_probe.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_grant_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_orchestrator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_pipeline_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_retry_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_upload_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_upload_enrollment_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/shared_preferences_evidence_sync_store.dart';

class EvidenceR57MutableClock {
  EvidenceR57MutableClock(this.now);

  DateTime now;

  void advance(Duration duration) {
    now = now.add(duration);
  }
}

class EvidenceR57Connectivity implements EvidenceSyncConnectivityProbe {
  EvidenceR57Connectivity({required this.connected});

  bool connected;
  int calls = 0;

  @override
  Future<bool> possuiRede() async {
    calls++;
    return connected;
  }
}

class EvidenceR57Broker implements EvidenceAccessBroker {
  EvidenceR57Broker({
    required this.clock,
    List<String>? objectKeys,
    this.invalidIdentityBinding = false,
  }) : objectKeys = List<String>.from(
          objectKeys ??
              const <String>[
                'evidencias/acao-1/evid-1.jpg',
              ],
        );

  final EvidenceR57MutableClock clock;
  final List<String> objectKeys;
  bool invalidIdentityBinding;
  final List<EvidenceUploadAccessRequest> uploadRequests =
      <EvidenceUploadAccessRequest>[];

  @override
  bool get enabled => true;

  @override
  Future<EvidenceAccessGrant> requestUploadAccess(
    EvidenceUploadAccessRequest request,
  ) async {
    uploadRequests.add(request);
    final callIndex = uploadRequests.length - 1;
    final objectKey = objectKeys[
        callIndex < objectKeys.length ? callIndex : objectKeys.length - 1];

    final identity = invalidIdentityBinding
        ? EvidenceUploadIdentity(
            acaoId: request.acaoId,
            evidenciaId: '${request.evidenciaId}-other',
            sha256: request.sha256,
          )
        : request.identity;

    return EvidenceAccessGrant(
      uri: Uri.parse('https://storage.example.test/upload/${callIndex + 1}'),
      operation: EvidenceRemoteOperation.upload,
      expiresAt: clock.now.add(const Duration(minutes: 10)),
      objectKey: objectKey,
      requiredHeaders: <String, String>{
        'Content-Type': request.contentType,
      },
      uploadIdentity: identity,
    );
  }

  @override
  Future<EvidenceAccessGrant> requestReadAccess(
    EvidenceReadAccessRequest request,
  ) {
    throw UnsupportedError('R5.7 exercita somente upload.');
  }
}

class EvidenceR57TransportStep {
  const EvidenceR57TransportStep.success({
    this.objectKeyOverride,
  }) : error = null;

  const EvidenceR57TransportStep.failure(this.error) : objectKeyOverride = null;

  final Object? error;
  final String? objectKeyOverride;
}

class EvidenceR57Transport implements RemoteEvidenceTransport {
  EvidenceR57Transport({
    required this.clock,
    List<EvidenceR57TransportStep>? steps,
  }) : steps = List<EvidenceR57TransportStep>.from(
          steps ?? const <EvidenceR57TransportStep>[],
        );

  final EvidenceR57MutableClock clock;
  final List<EvidenceR57TransportStep> steps;

  int calls = 0;
  final List<EvidenceAccessGrant> grants = <EvidenceAccessGrant>[];
  final List<RemoteEvidenceUploadRequest> requests =
      <RemoteEvidenceUploadRequest>[];
  final List<List<int>> uploadedBytes = <List<int>>[];

  Future<void> Function()? beforeReturn;

  @override
  bool get enabled => true;

  @override
  Future<RemoteEvidenceUploadResult> upload({
    required EvidenceAccessGrant grant,
    required RemoteEvidenceUploadRequest request,
  }) async {
    final callIndex = calls;
    calls++;
    grants.add(grant);
    requests.add(request);

    final bytes = await File(request.localFilePath).readAsBytes();
    uploadedBytes.add(List<int>.unmodifiable(bytes));

    final step = callIndex < steps.length
        ? steps[callIndex]
        : const EvidenceR57TransportStep.success();

    final error = step.error;
    if (error != null) {
      throw error;
    }

    final hook = beforeReturn;
    if (hook != null) {
      await hook();
    }

    return RemoteEvidenceUploadResult(
      objectKey: step.objectKeyOverride ?? grant.objectKey,
      syncedAt: clock.now.add(const Duration(seconds: 2)),
      sizeBytes: bytes.length,
      etag: '"r57-${callIndex + 1}"',
    );
  }
}

class EvidenceR57Harness {
  EvidenceR57Harness._({
    required this.tempDirectory,
    required this.originalFile,
    required this.originalBytes,
    required this.evidencia,
    required this.clock,
    required this.connectivity,
    required this.broker,
    required this.transport,
    required this.store,
    required this.lifecycle,
    required this.enrollmentCoordinator,
    required this.pipelineCoordinator,
  });

  final Directory tempDirectory;
  final File originalFile;
  final List<int> originalBytes;
  final EvidenciaModel evidencia;
  final EvidenceR57MutableClock clock;
  final EvidenceR57Connectivity connectivity;
  final EvidenceR57Broker broker;
  final EvidenceR57Transport transport;
  final SharedPreferencesEvidenceSyncStore store;
  final EvidencePreparedArtifactLifecycle lifecycle;
  final EvidenceUploadEnrollmentCoordinator enrollmentCoordinator;
  final EvidenceSyncPipelineCoordinator pipelineCoordinator;

  static Future<EvidenceR57Harness> create({
    bool connected = true,
    List<String>? brokerObjectKeys,
    bool invalidIdentityBinding = false,
    List<EvidenceR57TransportStep>? transportSteps,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final tempDirectory =
        await Directory.systemTemp.createTemp('fenix_r57_integration_');

    final originalFile = File(
      path.join(
        tempDirectory.path,
        'GEDUC',
        'evidencias',
        'acao-1',
        'original.png',
      ),
    );
    await originalFile.parent.create(recursive: true);

    final image = image_lib.Image(width: 320, height: 180);
    image_lib.fill(
      image,
      color: image_lib.ColorRgb8(32, 96, 160),
    );
    await originalFile.writeAsBytes(
      image_lib.encodePng(image),
      flush: true,
    );
    final originalBytes = await originalFile.readAsBytes();

    final clock = EvidenceR57MutableClock(
      DateTime.utc(2026, 8, 28, 14),
    );

    final pathResolver = ApplicationDocumentsEvidencePreparedPathResolver(
      documentsDirectoryProvider: () async => tempDirectory,
    );
    final preparer = DeterministicImageEvidencePreparer(
      pathResolver: pathResolver,
      clock: () => clock.now,
    );
    final lifecycle = EvidencePreparedArtifactLifecycle(
      documentsDirectoryProvider: () async => tempDirectory,
    );
    final store = SharedPreferencesEvidenceSyncStore();
    final connectivity = EvidenceR57Connectivity(connected: connected);
    final broker = EvidenceR57Broker(
      clock: clock,
      objectKeys: brokerObjectKeys,
      invalidIdentityBinding: invalidIdentityBinding,
    );
    final transport = EvidenceR57Transport(
      clock: clock,
      steps: transportSteps,
    );

    final enrollmentCoordinator = EvidenceUploadEnrollmentCoordinator(
      preparer: preparer,
      store: store,
      artifactLifecycle: lifecycle,
    );

    final orchestrator = EvidenceSyncOrchestrator(
      store: store,
      clock: () => clock.now,
    );
    final grantCoordinator = EvidenceSyncGrantCoordinator(
      orchestrator: orchestrator,
      broker: broker,
      clock: () => clock.now,
    );
    final uploadCoordinator = EvidenceSyncUploadCoordinator(
      transport: transport,
      store: store,
      clock: () => clock.now,
    );
    final retryCoordinator = EvidenceSyncRetryCoordinator(
      connectivity: connectivity,
      grantCoordinator: grantCoordinator,
      uploadCoordinator: uploadCoordinator,
      store: store,
      clock: () => clock.now,
    );
    final pipelineCoordinator = EvidenceSyncPipelineCoordinator(
      retryCoordinator: retryCoordinator,
      artifactLifecycle: lifecycle,
    );

    final evidencia = EvidenciaModel(
      id: 'evid-1',
      acaoId: 'acao-1',
      caminhoArquivo: originalFile.path,
      tipo: 'imagem',
      criadoEm: DateTime.utc(2026, 8, 28, 13, 55),
      sha256: 'original-sha',
      tamanhoBytes: originalBytes.length,
      mimeType: 'image/png',
      autorUserId: 'uid-r57',
    );

    return EvidenceR57Harness._(
      tempDirectory: tempDirectory,
      originalFile: originalFile,
      originalBytes: List<int>.unmodifiable(originalBytes),
      evidencia: evidencia,
      clock: clock,
      connectivity: connectivity,
      broker: broker,
      transport: transport,
      store: store,
      lifecycle: lifecycle,
      enrollmentCoordinator: enrollmentCoordinator,
      pipelineCoordinator: pipelineCoordinator,
    );
  }

  Future<EvidenceUploadEnrollmentResult> enroll() {
    return enrollmentCoordinator.enroll(evidencia);
  }

  Future<EvidenceSyncJob?> loadJob() {
    return store.obter(
      acaoId: evidencia.acaoId,
      evidenciaId: evidencia.id,
    );
  }

  Future<void> saveJob(EvidenceSyncJob job) {
    return store.salvar(job);
  }

  Future<void> expectOriginalIntacto() async {
    expect(
      await originalFile.readAsBytes(),
      orderedEquals(originalBytes),
    );
  }

  Future<void> dispose() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  }
}
