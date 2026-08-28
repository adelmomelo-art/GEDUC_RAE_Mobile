import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:geduc_rae_mobile/core/storage/remote_evidence_upload_exception.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_pipeline_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_retry_coordinator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_upload_confirmation_exception.dart';

import '../../support/evidence/evidence_r5_7_test_harness.dart';

void main() {
  group('AUD-L2-R5.7-C - fail closed e lifecycle', () {
    test('sem rede nao chama broker/upload nem remove preparado', () async {
      final harness = await EvidenceR57Harness.create(connected: false);
      addTearDown(harness.dispose);

      final enrollment = await harness.enroll();
      final preparedFile = File(enrollment.artifact.preparedFilePath);

      final result = await harness.pipelineCoordinator.processarProxima();

      expect(
        result.syncResult.status,
        EvidenceSyncCycleStatus.networkUnavailable,
      );
      expect(
        result.cleanupStatus,
        EvidenceSyncArtifactCleanupStatus.notRequired,
      );
      expect(harness.broker.uploadRequests, isEmpty);
      expect(harness.transport.calls, 0);
      expect(await preparedFile.exists(), isTrue);

      final persisted = await harness.loadJob();
      expect(persisted!.status, EvidenceSyncJobStatus.pending);
      expect(persisted.attemptCount, 0);
      await harness.expectOriginalIntacto();
    });

    test('grant com identity divergente falha antes do transporte', () async {
      final harness = await EvidenceR57Harness.create(
        invalidIdentityBinding: true,
      );
      addTearDown(harness.dispose);

      final enrollment = await harness.enroll();
      final preparedFile = File(enrollment.artifact.preparedFilePath);

      await expectLater(
        harness.pipelineCoordinator.processarProxima(),
        throwsA(isA<StateError>()),
      );

      expect(harness.broker.uploadRequests, hasLength(1));
      expect(harness.transport.calls, 0);
      expect(await preparedFile.exists(), isTrue);

      final persisted = await harness.loadJob();
      expect(persisted!.status, EvidenceSyncJobStatus.pending);
      await harness.expectOriginalIntacto();
    });

    test(
      'reconciliation com objectKey divergente bloqueia sem segundo upload',
      () async {
        final harness = await EvidenceR57Harness.create(
          brokerObjectKeys: const <String>[
            'evidencias/acao-1/key-a.jpg',
            'evidencias/acao-1/key-b.jpg',
          ],
          transportSteps: const <EvidenceR57TransportStep>[
            EvidenceR57TransportStep.failure(
              RemoteEvidenceUploadException(
                failure: RemoteEvidenceUploadFailure.transportFailure,
                message: 'timeout controlado',
              ),
            ),
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
        expect(harness.transport.calls, 1);
        expect(await preparedFile.exists(), isTrue);

        harness.clock.advance(const Duration(seconds: 30));

        final second = await harness.pipelineCoordinator.processarProxima();

        expect(second.syncResult.status, EvidenceSyncCycleStatus.blocked);
        expect(
          second.cleanupStatus,
          EvidenceSyncArtifactCleanupStatus.notRequired,
        );
        expect(harness.broker.uploadRequests, hasLength(2));
        expect(harness.transport.calls, 1);

        final blocked = await harness.loadJob();
        expect(blocked!.status, EvidenceSyncJobStatus.blocked);
        expect(blocked.objectKey, isNull);
        expect(
          blocked.reconciliationObjectKey,
          'evidencias/acao-1/key-a.jpg',
        );
        expect(await preparedFile.exists(), isTrue);
        await harness.expectOriginalIntacto();
      },
    );

    test('resultado remoto com objectKey incoerente nao confirma synced',
        () async {
      final harness = await EvidenceR57Harness.create(
        transportSteps: const <EvidenceR57TransportStep>[
          EvidenceR57TransportStep.success(
            objectKeyOverride: 'evidencias/acao-1/wrong.jpg',
          ),
        ],
      );
      addTearDown(harness.dispose);

      final enrollment = await harness.enroll();
      final preparedFile = File(enrollment.artifact.preparedFilePath);

      final result = await harness.pipelineCoordinator.processarProxima();

      expect(result.syncResult.status, EvidenceSyncCycleStatus.blocked);
      expect(
        result.cleanupStatus,
        EvidenceSyncArtifactCleanupStatus.notRequired,
      );

      final blocked = await harness.loadJob();
      expect(blocked!.status, EvidenceSyncJobStatus.blocked);
      expect(blocked.objectKey, isNull);
      expect(
        blocked.reconciliationObjectKey,
        'evidencias/acao-1/evid-1.jpg',
      );
      expect(await preparedFile.exists(), isTrue);
      await harness.expectOriginalIntacto();
    });

    test('mudanca concorrente do job recusa confirmacao e preserva artefato',
        () async {
      final harness = await EvidenceR57Harness.create();
      addTearDown(harness.dispose);

      final enrollment = await harness.enroll();
      final preparedFile = File(enrollment.artifact.preparedFilePath);

      harness.transport.beforeReturn = () async {
        final current = await harness.loadJob();
        await harness.saveJob(
          current!.copyWith(
            status: EvidenceSyncJobStatus.retryScheduled,
            nextAttemptAt: harness.clock.now.add(const Duration(minutes: 1)),
            reconciliationObjectKey: 'evidencias/acao-1/evid-1.jpg',
          ),
        );
      };

      await expectLater(
        harness.pipelineCoordinator.processarProxima(),
        throwsA(
          isA<EvidenceSyncConfirmationException>().having(
            (error) => error.failure,
            'failure',
            EvidenceSyncConfirmationFailure.jobChanged,
          ),
        ),
      );

      final persisted = await harness.loadJob();
      expect(persisted!.status, EvidenceSyncJobStatus.retryScheduled);
      expect(persisted.objectKey, isNull);
      expect(await preparedFile.exists(), isTrue);
      await harness.expectOriginalIntacto();
    });

    test('lifecycle recusa apagar original fora da raiz preparada', () async {
      final harness = await EvidenceR57Harness.create();
      addTearDown(harness.dispose);

      await expectLater(
        harness.lifecycle.removePreparedArtifact(harness.originalFile.path),
        throwsA(isA<StateError>()),
      );

      expect(await harness.originalFile.exists(), isTrue);
      await harness.expectOriginalIntacto();
    });
  });
}
