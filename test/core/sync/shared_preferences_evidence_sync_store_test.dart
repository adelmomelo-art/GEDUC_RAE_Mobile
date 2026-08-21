import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/shared_preferences_evidence_sync_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  EvidenceSyncJob job({
    String acaoId = 'rae-001',
    String evidenciaId = 'ev-001',
    EvidenceSyncJobStatus status = EvidenceSyncJobStatus.pending,
    int attemptCount = 0,
    DateTime? lastAttemptAt,
    DateTime? nextAttemptAt,
    String? objectKey,
    DateTime? syncedAt,
  }) {
    return EvidenceSyncJob(
      acaoId: acaoId,
      evidenciaId: evidenciaId,
      localFilePath: '/local/$evidenciaId.jpg',
      contentType: 'image/jpeg',
      tamanhoBytes: 1234,
      sha256:
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      autorUserId: 'user-001',
      createdAt: DateTime.utc(2026, 8, 21, 15),
      status: status,
      attemptCount: attemptCount,
      lastAttemptAt: lastAttemptAt,
      nextAttemptAt: nextAttemptAt,
      objectKey: objectKey,
      syncedAt: syncedAt,
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('AUD-L2-R5.5-A - SharedPreferencesEvidenceSyncStore', () {
    test('persiste job e sobrevive a nova instancia do store', () async {
      final first = SharedPreferencesEvidenceSyncStore();
      final original = job();

      await first.salvar(original);

      final second = SharedPreferencesEvidenceSyncStore();
      final restored = await second.obter(
        acaoId: original.acaoId,
        evidenciaId: original.evidenciaId,
      );

      expect(restored, isNotNull);
      expect(restored?.acaoId, original.acaoId);
      expect(restored?.evidenciaId, original.evidenciaId);
      expect(restored?.localFilePath, original.localFilePath);
      expect(restored?.sha256, original.sha256);
      expect(restored?.autorUserId, original.autorUserId);
      expect(restored?.status, EvidenceSyncJobStatus.pending);
    });

    test('upsert substitui o mesmo job sem duplicar', () async {
      final store = SharedPreferencesEvidenceSyncStore();
      final original = job();

      await store.salvar(original);

      final retry = original.copyWith(
        status: EvidenceSyncJobStatus.retryScheduled,
        attemptCount: 1,
        lastAttemptAt: DateTime.utc(2026, 8, 21, 15, 1),
        nextAttemptAt: DateTime.utc(2026, 8, 21, 15, 2),
      );

      await store.salvar(retry);

      final jobs = await store.listar();

      expect(jobs, hasLength(1));
      expect(jobs.single.status, EvidenceSyncJobStatus.retryScheduled);
      expect(jobs.single.attemptCount, 1);
      expect(
        jobs.single.nextAttemptAt,
        DateTime.utc(2026, 8, 21, 15, 2),
      );
    });

    test('remove somente a evidencia solicitada', () async {
      final store = SharedPreferencesEvidenceSyncStore();

      await store.salvar(job(evidenciaId: 'ev-001'));
      await store.salvar(job(evidenciaId: 'ev-002'));

      await store.remover(
        acaoId: 'rae-001',
        evidenciaId: 'ev-001',
      );

      final jobs = await store.listar();

      expect(jobs, hasLength(1));
      expect(jobs.single.evidenciaId, 'ev-002');
    });

    test('estado synced exige objectKey e syncedAt', () {
      final invalid = job(status: EvidenceSyncJobStatus.synced);

      expect(invalid.valido, isFalse);
    });

    test('estado retryScheduled exige nextAttemptAt', () {
      final invalid = job(status: EvidenceSyncJobStatus.retryScheduled);

      expect(invalid.valido, isFalse);
    });

    test('salvar recusa job invalido antes da persistencia', () async {
      final store = SharedPreferencesEvidenceSyncStore();

      final invalid = EvidenceSyncJob(
        acaoId: 'rae-001',
        evidenciaId: 'ev-001',
        localFilePath: '',
        contentType: 'image/jpeg',
        tamanhoBytes: 1234,
        sha256:
            '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
        autorUserId: 'user-001',
        createdAt: DateTime.utc(2026, 8, 21, 15),
      );

      await expectLater(
        store.salvar(invalid),
        throwsArgumentError,
      );

      expect(await store.listar(), isEmpty);
    });

    test('fila corrompida falha fechado e nao e apagada silenciosamente',
        () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          SharedPreferencesEvidenceSyncStore.storageKey: '{json-invalido',
        },
      );

      final store = SharedPreferencesEvidenceSyncStore();

      await expectLater(
        store.listar(),
        throwsA(isA<StateError>()),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(SharedPreferencesEvidenceSyncStore.storageKey),
        '{json-invalido',
      );
    });

    test('operacoes concorrentes sao serializadas sem perder jobs', () async {
      final store = SharedPreferencesEvidenceSyncStore();

      await Future.wait(
        <Future<void>>[
          store.salvar(job(evidenciaId: 'ev-001')),
          store.salvar(job(evidenciaId: 'ev-002')),
          store.salvar(job(evidenciaId: 'ev-003')),
        ],
      );

      final jobs = await store.listar();
      final ids = jobs.map((item) => item.evidenciaId).toSet();

      expect(jobs, hasLength(3));
      expect(ids, <String>{'ev-001', 'ev-002', 'ev-003'});
    });
  });
}