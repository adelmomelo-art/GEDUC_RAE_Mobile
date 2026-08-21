import 'evidence_sync_job.dart';

abstract interface class EvidenceSyncStore {
  Future<List<EvidenceSyncJob>> listar();

  Future<EvidenceSyncJob?> obter({
    required String acaoId,
    required String evidenciaId,
  });

  Future<void> salvar(EvidenceSyncJob job);

  Future<void> remover({
    required String acaoId,
    required String evidenciaId,
  });
}