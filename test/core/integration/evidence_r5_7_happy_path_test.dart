import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_pipeline_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_retry_coordinator.dart';

import '../../support/evidence/evidence_r5_7_test_harness.dart';

void main() {
  group('AUD-L2-R5.7-A - happy path integrado', () {
    test(
      'original -> preparado -> fila -> grant -> upload -> synced -> cleanup',
      () async {
        final harness = await EvidenceR57Harness.create();
        addTearDown(harness.dispose);

        final enrollment = await harness.enroll();
        final preparedFile = File(enrollment.artifact.preparedFilePath);
        final preparedBytes = await preparedFile.readAsBytes();

        expect(enrollment.job.status, EvidenceSyncJobStatus.pending);
        expect(enrollment.job.localFilePath, preparedFile.path);
        expect(enrollment.job.contentType, 'image/jpeg');
        expect(enrollment.job.tamanhoBytes, preparedBytes.length);
        expect(
          enrollment.job.sha256,
          sha256.convert(preparedBytes).toString(),
        );
        expect(await preparedFile.exists(), isTrue);
        await harness.expectOriginalIntacto();

        final pipelineResult =
            await harness.pipelineCoordinator.processarProxima();

        expect(
          pipelineResult.syncResult.status,
          EvidenceSyncCycleStatus.synced,
        );
        expect(
          pipelineResult.cleanupStatus,
          EvidenceSyncArtifactCleanupStatus.removed,
        );

        final persisted = await harness.loadJob();
        expect(persisted, isNotNull);
        expect(persisted!.status, EvidenceSyncJobStatus.synced);
        expect(
          persisted.objectKey,
          'evidencias/acao-1/evid-1.jpg',
        );
        expect(persisted.syncedAt, isNotNull);
        expect(persisted.reconciliationObjectKey, isNull);

        expect(harness.connectivity.calls, 1);
        expect(harness.broker.uploadRequests, hasLength(1));
        expect(harness.transport.calls, 1);
        expect(
          harness.broker.uploadRequests.single.sha256,
          enrollment.job.sha256,
        );
        expect(
          harness.broker.uploadRequests.single.tamanhoBytes,
          enrollment.job.tamanhoBytes,
        );
        expect(
          harness.transport.uploadedBytes.single,
          orderedEquals(preparedBytes),
        );

        expect(await preparedFile.exists(), isFalse);
        await harness.expectOriginalIntacto();
      },
    );
  });
}
