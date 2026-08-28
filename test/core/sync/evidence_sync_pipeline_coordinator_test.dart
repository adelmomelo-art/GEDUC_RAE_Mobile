import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:geduc_rae_mobile/core/storage/application_documents_evidence_prepared_path_resolver.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_prepared_artifact_lifecycle.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_pipeline_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_retry_coordinator.dart';

void main() {
  group('EvidenceSyncPipelineCoordinator', () {
    late Directory temp;
    late EvidencePreparedArtifactLifecycle lifecycle;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('fenix_r56c_pipeline_');
      lifecycle = EvidencePreparedArtifactLifecycle(
        documentsDirectoryProvider: () async => temp,
      );
    });

    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    EvidenceSyncJob syncedJob(String filePath) => EvidenceSyncJob(
          acaoId: 'acao-1',
          evidenciaId: 'evid-1',
          localFilePath: filePath,
          contentType: 'image/jpeg',
          tamanhoBytes: 3,
          sha256: 'a' * 64,
          autorUserId: 'uid-1',
          createdAt: DateTime.utc(2026, 8, 27, 12),
          status: EvidenceSyncJobStatus.synced,
          attemptCount: 1,
          lastAttemptAt: DateTime.utc(2026, 8, 27, 12, 1),
          objectKey: 'server/key.jpg',
          syncedAt: DateTime.utc(2026, 8, 27, 12, 1),
        );

    Future<File> preparedFile() async {
      final root = ApplicationDocumentsEvidencePreparedPathResolver
          .preparedArtifactsRootFor(temp);
      final file = File(path.join(
        root.path,
        'acao-1',
        'evid-1',
        'evidence-photo-jpeg-v1.jpg',
      ));
      await file.parent.create(recursive: true);
      await file.writeAsBytes([1, 2, 3]);
      return file;
    }

    test('synced duravel remove artefato preparado', () async {
      final file = await preparedFile();
      final coordinator = EvidenceSyncPipelineCoordinator.withProcessor(
        processNext: () async => EvidenceSyncCycleResult(
          status: EvidenceSyncCycleStatus.synced,
          job: syncedJob(file.path),
        ),
        artifactLifecycle: lifecycle,
      );

      final result = await coordinator.processarProxima();
      expect(result.syncResult.status, EvidenceSyncCycleStatus.synced);
      expect(result.cleanupStatus, EvidenceSyncArtifactCleanupStatus.removed);
      expect(await file.exists(), isFalse);
    });

    test('retry preserva artefato preparado', () async {
      final file = await preparedFile();
      final coordinator = EvidenceSyncPipelineCoordinator.withProcessor(
        processNext: () async => const EvidenceSyncCycleResult(
          status: EvidenceSyncCycleStatus.retryScheduled,
        ),
        artifactLifecycle: lifecycle,
      );

      final result = await coordinator.processarProxima();
      expect(
          result.cleanupStatus, EvidenceSyncArtifactCleanupStatus.notRequired);
      expect(await file.exists(), isTrue);
    });

    test('falha de cleanup nao reabre upload confirmado', () async {
      final original = File(path.join(
        temp.path,
        'GEDUC',
        'evidencias',
        'acao-1',
        'original.jpg',
      ));
      await original.parent.create(recursive: true);
      await original.writeAsBytes([1, 2, 3]);

      final coordinator = EvidenceSyncPipelineCoordinator.withProcessor(
        processNext: () async => EvidenceSyncCycleResult(
          status: EvidenceSyncCycleStatus.synced,
          job: syncedJob(original.path),
        ),
        artifactLifecycle: lifecycle,
      );

      final result = await coordinator.processarProxima();
      expect(result.syncResult.status, EvidenceSyncCycleStatus.synced);
      expect(result.cleanupStatus, EvidenceSyncArtifactCleanupStatus.failed);
      expect(await original.exists(), isTrue);
    });
  });
}
