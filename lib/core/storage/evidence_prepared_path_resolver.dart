import 'evidence_preparation_models.dart';

/// Resolve onde o artefato derivado de upload sera materializado.
///
/// O R5.6-B define somente o contrato. A politica de ciclo de vida e limpeza
/// do diretorio de producao pertence ao R5.6-C.
abstract interface class EvidencePreparedPathResolver {
  Future<String> resolveFor(EvidencePreparationRequest request);
}
