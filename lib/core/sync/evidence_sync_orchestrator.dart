import 'dart:collection';

import 'evidence_sync_job.dart';
import 'evidence_sync_store.dart';

/// Orquestra exclusivamente a selecao de candidatos da fila de evidencias.
///
/// R5.5-B nao solicita grants, nao executa upload, nao decide ACL e nao aplica
/// retry/backoff. Sua responsabilidade e produzir uma ordem deterministica de
/// jobs que podem ser considerados por uma tentativa posterior.
class EvidenceSyncOrchestrator {
  EvidenceSyncOrchestrator({
    required EvidenceSyncStore store,
    DateTime Function()? clock,
  })  : _store = store,
        _clock = clock ?? DateTime.now;

  final EvidenceSyncStore _store;
  final DateTime Function() _clock;

  Future<List<EvidenceSyncJob>> listarCandidatos() async {
    final agora = _clock().toUtc();
    final jobs = await _store.listar();

    for (final job in jobs) {
      if (!job.valido) {
        throw StateError(
          'Fila de evidencias contem job invalido; selecao interrompida.',
        );
      }
    }

    final candidatos = jobs.where((job) => _elegivel(job, agora)).toList()
      ..sort(_comparar);

    return UnmodifiableListView<EvidenceSyncJob>(candidatos);
  }

  Future<EvidenceSyncJob?> proximoCandidato() async {
    final candidatos = await listarCandidatos();
    return candidatos.isEmpty ? null : candidatos.first;
  }

  bool _elegivel(EvidenceSyncJob job, DateTime agora) {
    switch (job.status) {
      case EvidenceSyncJobStatus.pending:
        return true;
      case EvidenceSyncJobStatus.retryScheduled:
        final nextAttemptAt = job.nextAttemptAt;
        if (nextAttemptAt == null) {
          throw StateError(
            'Job retryScheduled sem nextAttemptAt; selecao interrompida.',
          );
        }
        return !nextAttemptAt.toUtc().isAfter(agora);
      case EvidenceSyncJobStatus.synced:
      case EvidenceSyncJobStatus.blocked:
        return false;
    }
  }

  int _comparar(EvidenceSyncJob a, EvidenceSyncJob b) {
    final createdComparison =
        a.createdAt.toUtc().compareTo(b.createdAt.toUtc());
    if (createdComparison != 0) {
      return createdComparison;
    }

    final actionComparison = a.acaoId.compareTo(b.acaoId);
    if (actionComparison != 0) {
      return actionComparison;
    }

    return a.evidenciaId.compareTo(b.evidenciaId);
  }
}
