import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:geduc_rae_mobile/core/storage/remote_evidence_upload_exception.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_pipeline_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_retry_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/shared_preferences_evidence_sync_store.dart';

import '../../support/evidence/evidence_r5_7_test_harness.dart';

void main() {
  group('AUD-L2-R5.7-B - retry, reconciliation e idempotencia', () {
    test(
      'retry preserva artefato e mesma identidade conclui synced depois',
      () async {
        final harness = await EvidenceR57Harness.create(
          transportSteps: const <EvidenceR57TransportStep>[
            EvidenceR57TransportStep.failure(
              RemoteEvidenceUploadException(
                failure: RemoteEvidenceUploadFailure.transportFailure,
                message: 'timeout controlado R5.7',
              ),
            ),
            EvidenceR57TransportStep.success(),
          ],
        );
        addTearDown(harness.dispose);

        final enrollment = await harness.enroll();
        final preparedFile = File(enrollment.artifact.preparedFilePath);

        final first = await harness.pipelineCoordinator.processarProxima();

        expect(
          first.syncResult.status,
          EvidenceSyncCycleStatus.retryScheduled,
        );
        expect(
          first.cleanupStatus,
          EvidenceSyncArtifactCleanupStatus.notRequired,
        );

        final retryJob = await harness.loadJob();
        expect(retryJob, isNotNull);
        expect(retryJob!.status, EvidenceSyncJobStatus.retryScheduled);
        expect(retryJob.attemptCount, 1);
        expect(
          retryJob.nextAttemptAt,
          harness.clock.now.add(const Duration(seconds: 30)),
        );
        expect(
          retryJob.reconciliationObjectKey,
          'evidencias/acao-1/evid-1.jpg',
        );
        expect(await preparedFile.exists(), isTrue);

        final reopenedStore = SharedPreferencesEvidenceSyncStore();
        final reopened = await reopenedStore.obter(
          acaoId: retryJob.acaoId,
          evidenciaId: retryJob.evidenciaId,
        );
        expect(reopened, isNotNull);
        expect(reopened!.status, EvidenceSyncJobStatus.retryScheduled);
        expect(reopened.sha256, enrollment.job.sha256);
        expect(reopened.localFilePath, preparedFile.path);
        expect(
          reopened.reconciliationObjectKey,
          retryJob.reconciliationObjectKey,
        );

        harness.clock.advance(const Duration(seconds: 30));

        final second = await harness.pipelineCoordinator.processarProxima();

        expect(second.syncResult.status, EvidenceSyncCycleStatus.synced);
        expect(
          second.cleanupStatus,
          EvidenceSyncArtifactCleanupStatus.removed,
        );

        final synced = await harness.loadJob();
        expect(synced, isNotNull);
        expect(synced!.status, EvidenceSyncJobStatus.synced);
        expect(synced.attemptCount, 2);
        expect(
          synced.objectKey,
          'evidencias/acao-1/evid-1.jpg',
        );
        expect(synced.reconciliationObjectKey, isNull);

        expect(harness.broker.uploadRequests, hasLength(2));
        expect(harness.transport.calls, 2);
        expect(
          harness.broker.uploadRequests[0].idempotencyKey,
          harness.broker.uploadRequests[1].idempotencyKey,
        );
        expect(
          harness.broker.uploadRequests[0].identity.equivalenteA(
            harness.broker.uploadRequests[1].identity,
          ),
          isTrue,
        );

        expect(await preparedFile.exists(), isFalse);
        await harness.expectOriginalIntacto();
      },
    );
  });
}
