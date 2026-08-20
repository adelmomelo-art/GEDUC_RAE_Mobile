import 'evidence_access_models.dart';

/// Fronteira de autorizacao para acesso remoto a evidencias.
///
/// Implementacoes produtivas devem delegar a emissao de grants a um backend
/// confiavel. O cliente Flutter nao pode conter credenciais de provedor,
/// segredo de assinatura ou autoridade para fabricar URLs assinadas.
abstract interface class EvidenceAccessBroker {
  bool get enabled;

  Future<EvidenceAccessGrant> requestReadAccess(
    EvidenceReadAccessRequest request,
  );

  Future<EvidenceAccessGrant> requestUploadAccess(
    EvidenceUploadAccessRequest request,
  );
}
