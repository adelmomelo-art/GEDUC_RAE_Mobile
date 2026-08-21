import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_job.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_orchestrator.dart';
import 'package:geduc_rae_mobile/core/sync/evidence_sync_store.dart';

void main() {
  group('AUD-L2-R5.5-B - EvidenceSyncOrchestrator', () {
    final agora = DateTime.utc(2026, 8, 21, 18, 0);

    EvidenceSyncJob job({
      required String evidenciaId,
      EvidenceSyncJobStatus status = EvidenceSyncJobStatus.pending,
      DateTime? createdAt,
      DateTime? nextAttemptAt,
      String acaoId = 'acao-1',
      String? objectKey,
      DateTime? syncedAt,
    }) {
      return EvidenceSyncJob(
        acaoId: acaoId,
        evidenciaId: evidenciaId,
        localFilePath: 'C:/evidencias/$evidenciaId.jpg',
        contentType: 'image/jpeg',
        tamanhoBytes: 1024,
        sha256: 'a' * 64,
        autorUserId: 'user-1',
        createdAt: createdAt ?? DateTime.utc(2026, 8, 21, 17),
        status: status,
        nextAttemptAt: nextAttemptAt,
        objectKey: objectKey,
        syncedAt: syncedAt,
      );
    }

    test('pending e elegivel imediatamente', () async {
      final store = _FakeEvidenceSyncStore([
        job(evidenciaId: 'ev-1'),
      ]);
      final orchestrator = EvidenceSyncOrchestrator(
        store: store,
        clock: () => agora,
      );

      final candidatos = await orchestrator.listarCandidatos();

      expect(candidatos.map((item) => item.evidenciaId), ['ev-1']);
      expect(store.saveCalls, 0);
      expect(store.removeCalls, 0);
    });

    test('retryScheduled vencido e elegivel', () async {
      final store = _FakeEvidenceSyncStore([
        job(
          evidenciaId: 'ev-1',
          status: EvidenceSyncJobStatus.retryScheduled,
          nextAttemptAt: agora.subtract(const Duration(seconds: 1)),
        ),
      ]);

      final candidatos = await EvidenceSyncOrchestrator(
        store: store,
        clock: () => agora,
      ).listarCandidatos();

      expect(candidatos.map((item) => item.evidenciaId), ['ev-1']);
    });

    test('retryScheduled exatamente agora e elegivel', () async {
      final store = _FakeEvidenceSyncStore([
        job(
          evidenciaId: 'ev-1',
          status: EvidenceSyncJobStatus.retryScheduled,
          nextAttemptAt: agora,
        ),
      ]);

      final candidato = await EvidenceSyncOrchestrator(
        store: store,
        clock: () => agora,
      ).proximoCandidato();

      expect(candidato?.evidenciaId, 'ev-1');
    });

    test('retryScheduled futuro fica fora dos candidatos', () async {
      final store = _FakeEvidenceSyncStore([
        job(
          evidenciaId: 'ev-1',
          status: EvidenceSyncJobStatus.retryScheduled,
          nextAttemptAt: agora.add(const Duration(minutes: 1)),
        ),
      ]);

      final candidatos = await EvidenceSyncOrchestrator(
        store: store,
        clock: () => agora,
      ).listarCandidatos();

      expect(candidatos, isEmpty);
    });

    test('synced e blocked nao sao elegiveis', () async {
      final store = _FakeEvidenceSyncStore([
        job(
          evidenciaId: 'ev-synced',
          status: EvidenceSyncJobStatus.synced,
          objectKey: 'evidencias/acao-1/ev-synced.jpg',
          syncedAt: agora.subtract(const Duration(minutes: 2)),
        ),
        job(
          evidenciaId: 'ev-blocked',
          status: EvidenceSyncJobStatus.blocked,
        ),
      ]);

      final candidatos = await EvidenceSyncOrchestrator(
        store: store,
        clock: () => agora,
      ).listarCandidatos();

      expect(candidatos, isEmpty);
    });

    test('ordem e deterministica por createdAt, acaoId e evidenciaId', () async {
      final createdAt = DateTime.utc(2026, 8, 21, 17);
      final store = _FakeEvidenceSyncStore([
        job(
          evidenciaId: 'ev-2',
          acaoId: 'acao-b',
          createdAt: createdAt,
        ),
        job(
          evidenciaId: 'ev-2',
          acaoId: 'acao-a',
          createdAt: createdAt,
        ),
        job(
          evidenciaId: 'ev-1',
          acaoId: 'acao-a',
          createdAt: createdAt,
        ),
        job(
          evidenciaId: 'ev-antigo',
          acaoId: 'acao-z',
          createdAt: createdAt.subtract(const Duration(minutes: 1)),
        ),
      ]);

      final candidatos = await EvidenceSyncOrchestrator(
        store: store,
        clock: () => agora,
      ).listarCandidatos();

      expect(
        candidatos.map((item) => '${item.acaoId}/${item.evidenciaId}'),
        [
          'acao-z/ev-antigo',
          'acao-a/ev-1',
          'acao-a/ev-2',
          'acao-b/ev-2',
        ],
      );
    });

    test('proximoCandidato retorna null quando nao ha elegivel', () async {
      final store = _FakeEvidenceSyncStore([
        job(
          evidenciaId: 'ev-1',
          status: EvidenceSyncJobStatus.blocked,
        ),
      ]);

      final candidato = await EvidenceSyncOrchestrator(
        store: store,
        clock: () => agora,
      ).proximoCandidato();

      expect(candidato, isNull);
    });

    test('fila com job invalido falha fechado e nao persiste nada', () async {
      final invalido = EvidenceSyncJob(
        acaoId: '',
        evidenciaId: 'ev-invalida',
        localFilePath: 'C:/evidencias/ev-invalida.jpg',
        contentType: 'image/jpeg',
        tamanhoBytes: 1024,
        sha256: 'a' * 64,
        autorUserId: 'user-1',
        createdAt: agora,
      );
      final store = _FakeEvidenceSyncStore([invalido]);

      final orchestrator = EvidenceSyncOrchestrator(
        store: store,
        clock: () => agora,
      );

      await expectLater(
        orchestrator.listarCandidatos(),
        throwsA(isA<StateError>()),
      );
      expect(store.saveCalls, 0);
      expect(store.removeCalls, 0);
    });
  });
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
    for (final job in _jobs) {
      if (job.acaoId == acaoId && job.evidenciaId == evidenciaId) {
        return job;
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
