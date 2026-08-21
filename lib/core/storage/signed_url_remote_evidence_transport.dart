import 'evidence_access_models.dart';
import 'evidence_http_client.dart';
import 'evidence_http_models.dart';
import 'evidence_remote_operation.dart';
import 'remote_evidence_models.dart';
import 'remote_evidence_transport.dart';

/// Transporte remoto por URL previamente autorizada.
///
/// Esta classe:
/// - nao cria grants;
/// - nao assina URLs;
/// - nao decide ACL;
/// - nao conhece Cloudflare R2, B2 ou outro provedor;
/// - nao possui credenciais permanentes;
/// - nao inventa object keys.
class SignedUrlRemoteEvidenceTransport implements RemoteEvidenceTransport {
  SignedUrlRemoteEvidenceTransport({
    required EvidenceHttpClient httpClient,
    DateTime Function()? now,
  })  : _httpClient = httpClient,
        _now = now ?? DateTime.now;

  final EvidenceHttpClient _httpClient;
  final DateTime Function() _now;

  @override
  bool get enabled => true;

  @override
  Future<RemoteEvidenceUploadResult> upload({
    required EvidenceAccessGrant grant,
    required RemoteEvidenceUploadRequest request,
  }) async {
    final instante = _now().toUtc();

    if (!request.valido) {
      throw ArgumentError('Requisicao de upload remoto invalida.');
    }

    if (!grant.validoPara(
      operacaoEsperada: EvidenceRemoteOperation.upload,
      instante: instante,
    )) {
      throw StateError(
        'Grant remoto invalido, expirado ou incompativel com upload.',
      );
    }

    final contentTypeAutorizado = _header(
      grant.requiredHeaders,
      'Content-Type',
    );

    if (contentTypeAutorizado == null || contentTypeAutorizado.trim().isEmpty) {
      throw StateError(
        'Grant de upload deve autorizar explicitamente Content-Type.',
      );
    }

    if (contentTypeAutorizado.trim().toLowerCase() !=
        request.contentType.trim().toLowerCase()) {
      throw StateError(
        'Content-Type local diverge do Content-Type autorizado no grant.',
      );
    }

    final httpRequest = EvidenceHttpPutRequest(
      uri: grant.uri,
      localFilePath: request.localFilePath,
      headers: Map<String, String>.unmodifiable(
        Map<String, String>.from(grant.requiredHeaders),
      ),
    );

    if (!httpRequest.valido) {
      throw StateError('Requisicao HTTP derivada do grant e invalida.');
    }

    final response = await _httpClient.putFile(httpRequest);

    if (!response.sucesso) {
      throw StateError(
        'Upload remoto rejeitado com HTTP ${response.statusCode}.',
      );
    }

    return RemoteEvidenceUploadResult(
      objectKey: grant.objectKey,
      syncedAt: _now().toUtc(),
      etag: _normalizarHeaderOpcional(response.header('ETag')),
    );
  }

  String? _header(Map<String, String> headers, String name) {
    final procurado = name.trim().toLowerCase();

    for (final entry in headers.entries) {
      if (entry.key.trim().toLowerCase() == procurado) {
        return entry.value;
      }
    }

    return null;
  }

  String? _normalizarHeaderOpcional(String? value) {
    final normalizado = value?.trim();

    if (normalizado == null || normalizado.isEmpty) {
      return null;
    }

    return normalizado;
  }
}
