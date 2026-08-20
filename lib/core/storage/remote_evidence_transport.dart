import 'evidence_access_models.dart';
import 'remote_evidence_models.dart';

/// Plano de dados para transferencia remota de evidencias.
///
/// Este contrato apenas consome um [EvidenceAccessGrant] previamente emitido
/// por uma fronteira confiavel de autorizacao. Implementacoes de transporte
/// nao podem fabricar grants, assinar URLs, decidir ACL ou conter credenciais
/// permanentes do provedor remoto.
abstract interface class RemoteEvidenceTransport {
  bool get enabled;

  Future<RemoteEvidenceUploadResult> upload({
    required EvidenceAccessGrant grant,
    required RemoteEvidenceUploadRequest request,
  });
}
