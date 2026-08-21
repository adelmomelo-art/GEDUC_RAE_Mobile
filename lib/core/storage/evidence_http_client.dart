import 'evidence_http_models.dart';

/// Porta HTTP do plano de dados para evidencias.
///
/// Este contrato nao implementa rede, nao conhece Cloudflare R2, nao assina
/// requisicoes e nao possui credenciais permanentes.
abstract interface class EvidenceHttpClient {
  Future<EvidenceHttpResponse> putFile(EvidenceHttpPutRequest request);
}
