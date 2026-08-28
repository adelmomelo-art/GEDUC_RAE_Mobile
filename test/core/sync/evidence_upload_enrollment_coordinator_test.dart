import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geduc_rae_mobile/core/models/evidencia_model.dart';
import 'package:geduc_rae_mobile/core/storage/application_documents_evidence_prepared_path_resolver.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_preparation_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_prepared_artifact_lifecycle.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_preparer.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_store.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_upload_enrollment_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/shared_preferences_evidence_sync_store.dart';

class _StubPreparer implements EvidencePreparer {
  _StubPreparer(this.artifact);
  final EvidencePreparedArtifact artifact;

  @override
  Future<EvidencePreparedArtifact> prepare(
      EvidencePreparationRequest request) async {
    return artifact;
  }
}

class _MemoryStore implements EvidenceSyncStore {
  final Map<String, EvidenceSyncJob> jobs = {};
  int saveCount = 0;
  String _key(String a, String e) => '$a::$e';
  void seed(EvidenceSyncJob job) =>
      jobs[_key(job.acaoId, job.evidenciaId)] = job;

  @override
  Future<List<EvidenceSyncJob>> listar() async => jobs.values.toList();

  @override
  Future<EvidenceSyncJob?> obter(
      {required String acaoId, required String evidenciaId}) async {
    return jobs[_key(acaoId, evidenciaId)];
  }

  @override
  Future<void> salvar(EvidenceSyncJob job) async {
    saveCount++;
    seed(job);
  }

  @override
  Future<void> remover(
      {required String acaoId, required String evidenciaId}) async {
    jobs.remove(_key(acaoId, evidenciaId));
  }
}

void main() {
  group('EvidenceUploadEnrollmentCoordinator', () {
    late Directory temp;
    late Directory preparedRoot;
    late EvidencePreparedArtifactLifecycle lifecycle;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('fenix_r56c_enroll_');
      preparedRoot = ApplicationDocumentsEvidencePreparedPathResolver
          .preparedArtifactsRootFor(temp);
      lifecycle = EvidencePreparedArtifactLifecycle(
        documentsDirectoryProvider: () async => temp,
      );
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    Future<({EvidenciaModel evidencia, EvidencePreparedArtifact artifact})>
        fixture() async {
      final original = File(path.join(
        temp.path,
        'GEDUC',
        'evidencias',
        'acao-1',
        'original.png',
      ));
      await original.parent.create(recursive: true);
      await original.writeAsBytes([1, 2, 3]);

      final prepared = File(path.join(
        preparedRoot.path,
        'acao-1',
        'evid-1',
        'evidence-photo-jpeg-v1.jpg',
      ));
      await prepared.parent.create(recursive: true);
      await prepared.writeAsBytes([10, 20, 30, 40, 50]);

      return (
        evidencia: EvidenciaModel(
          id: 'evid-1',
          acaoId: 'acao-1',
          caminhoArquivo: original.path,
          tipo: 'imagem',
          criadoEm: DateTime.utc(2026, 8, 27, 12),
          sha256: 'original-sha',
          tamanhoBytes: 3,
          mimeType: 'image/png',
          autorUserId: 'uid-001',
        ),
        artifact: EvidencePreparedArtifact(
          originalFilePath: original.path,
          preparedFilePath: prepared.path,
          contentType: 'image/jpeg',
          preparationProfile: 'evidence-photo-jpeg-v1',
          createdAt: DateTime.utc(2026, 8, 27, 12, 1),
        ),
      );
    }

    test('job usa metadata do preparado e preserva original', () async {
      final data = await fixture();
      final store = _MemoryStore();
      final coordinator = EvidenceUploadEnrollmentCoordinator(
        preparer: _StubPreparer(data.artifact),
        store: store,
        artifactLifecycle: lifecycle,
      );

      final result = await coordinator.enroll(data.evidencia);

      expect(result.status, EvidenceUploadEnrollmentStatus.enrolled);
      expect(result.job.localFilePath, data.artifact.preparedFilePath);
      expect(result.job.contentType, 'image/jpeg');
      expect(result.job.tamanhoBytes, 5);
      expect(result.job.sha256, hasLength(64));
      expect(result.job.sha256, isNot('original-sha'));
      expect(
          await File(data.evidencia.caminhoArquivo).readAsBytes(), [1, 2, 3]);
    });

    test('re-enrollment identico preserva retry e nao salva pending', () async {
      final data = await fixture();
      final store = _MemoryStore();
      final coordinator = EvidenceUploadEnrollmentCoordinator(
        preparer: _StubPreparer(data.artifact),
        store: store,
        artifactLifecycle: lifecycle,
      );

      final first = await coordinator.enroll(data.evidencia);
      final retry = first.job.copyWith(
        status: EvidenceSyncJobStatus.retryScheduled,
        attemptCount: 2,
        lastAttemptAt: DateTime.utc(2026, 8, 27, 12, 5),
        nextAttemptAt: DateTime.utc(2026, 8, 27, 12, 10),
        reconciliationObjectKey: 'server/key.jpg',
      );
      store.seed(retry);
      final savesBefore = store.saveCount;

      final second = await coordinator.enroll(data.evidencia);

      expect(second.status, EvidenceUploadEnrollmentStatus.alreadyEnrolled);
      expect(second.job.status, EvidenceSyncJobStatus.retryScheduled);
      expect(second.job.attemptCount, 2);
      expect(store.saveCount, savesBefore);
    });

    test(
        'snapshot de bytes divergente falha fechado e remove derivado perigoso',
        () async {
      final data = await fixture();
      final store = _MemoryStore();
      final coordinator = EvidenceUploadEnrollmentCoordinator(
        preparer: _StubPreparer(data.artifact),
        store: store,
        artifactLifecycle: lifecycle,
      );

      final first = await coordinator.enroll(data.evidencia);
      final divergent = EvidenceSyncJob(
        acaoId: first.job.acaoId,
        evidenciaId: first.job.evidenciaId,
        localFilePath: first.job.localFilePath,
        contentType: first.job.contentType,
        tamanhoBytes: first.job.tamanhoBytes,
        sha256: 'a' * 64,
        autorUserId: first.job.autorUserId,
        createdAt: first.job.createdAt,
      );
      store.seed(divergent);

      await expectLater(
        coordinator.enroll(data.evidencia),
        throwsA(isA<StateError>()),
      );
      expect(await File(data.artifact.preparedFilePath).exists(), isFalse);
      expect(await File(data.evidencia.caminhoArquivo).exists(), isTrue);
    });

    test('job salvo sobrevive a nova instancia do store duravel', () async {
      final data = await fixture();
      final store = SharedPreferencesEvidenceSyncStore();
      final coordinator = EvidenceUploadEnrollmentCoordinator(
        preparer: _StubPreparer(data.artifact),
        store: store,
        artifactLifecycle: lifecycle,
      );

      final result = await coordinator.enroll(data.evidencia);
      final reopened = SharedPreferencesEvidenceSyncStore();
      final loaded = await reopened.obter(
        acaoId: result.job.acaoId,
        evidenciaId: result.job.evidenciaId,
      );

      expect(loaded, isNotNull);
      expect(loaded!.localFilePath, result.job.localFilePath);
      expect(loaded.sha256, result.job.sha256);
      expect(loaded.tamanhoBytes, result.job.tamanhoBytes);
      expect(loaded.contentType, result.job.contentType);
    });
  });
}
