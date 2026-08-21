import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_http_client.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_http_models.dart';

class _FakeEvidenceHttpClient implements EvidenceHttpClient {
  EvidenceHttpPutRequest? lastRequest;

  @override
  Future<EvidenceHttpResponse> putFile(EvidenceHttpPutRequest request) async {
    lastRequest = request;

    return const EvidenceHttpResponse(
      statusCode: 200,
      headers: <String, String>{
        'ETag': '"etag-simulado"',
      },
    );
  }
}

void main() {
  group('AUD-L2-R5.4-C - EvidenceHttpPutRequest', () {
    test('aceita HTTPS, arquivo local e headers opacos', () {
      final request = EvidenceHttpPutRequest(
        uri: Uri.parse('https://example.invalid/object'),
        localFilePath: '/local/evidencia.jpg',
        headers: const <String, String>{
          'Content-Type': 'image/jpeg',
          'X-Signed-Header': 'opaque-value',
        },
      );

      expect(request.valido, isTrue);
      expect(request.headers['X-Signed-Header'], 'opaque-value');
    });

    test('rejeita HTTP, URI sem host e caminho local vazio', () {
      expect(
        EvidenceHttpPutRequest(
          uri: Uri.parse('http://example.invalid/object'),
          localFilePath: '/local/evidencia.jpg',
          headers: const <String, String>{},
        ).valido,
        isFalse,
      );

      expect(
        EvidenceHttpPutRequest(
          uri: Uri.parse('https:///object'),
          localFilePath: '/local/evidencia.jpg',
          headers: const <String, String>{},
        ).valido,
        isFalse,
      );

      expect(
        EvidenceHttpPutRequest(
          uri: Uri.parse('https://example.invalid/object'),
          localFilePath: ' ',
          headers: const <String, String>{},
        ).valido,
        isFalse,
      );
    });
  });

  group('AUD-L2-R5.4-C - EvidenceHttpResponse', () {
    test('considera somente 2xx como sucesso', () {
      expect(const EvidenceHttpResponse(statusCode: 200).sucesso, isTrue);
      expect(const EvidenceHttpResponse(statusCode: 204).sucesso, isTrue);
      expect(const EvidenceHttpResponse(statusCode: 299).sucesso, isTrue);
      expect(const EvidenceHttpResponse(statusCode: 300).sucesso, isFalse);
      expect(const EvidenceHttpResponse(statusCode: 403).sucesso, isFalse);
      expect(const EvidenceHttpResponse(statusCode: 500).sucesso, isFalse);
    });

    test('consulta header sem depender de capitalizacao', () {
      const response = EvidenceHttpResponse(
        statusCode: 200,
        headers: <String, String>{
          'ETag': '"abc"',
        },
      );

      expect(response.header('etag'), '"abc"');
      expect(response.header('ETAG'), '"abc"');
      expect(response.header('x-missing'), isNull);
    });
  });

  group('AUD-L2-R5.4-C - EvidenceHttpClient', () {
    test('porta pode ser exercitada por fake sem trafego real', () async {
      final client = _FakeEvidenceHttpClient();
      final request = EvidenceHttpPutRequest(
        uri: Uri.parse('https://example.invalid/object'),
        localFilePath: '/local/evidencia.jpg',
        headers: const <String, String>{
          'Content-Type': 'image/jpeg',
        },
      );

      final response = await client.putFile(request);

      expect(response.sucesso, isTrue);
      expect(response.header('etag'), '"etag-simulado"');
      expect(client.lastRequest, same(request));
    });
  });
}
