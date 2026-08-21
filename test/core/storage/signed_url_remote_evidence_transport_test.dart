import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_http_client.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_http_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_models.dart';
import 'package:geduc_rae_mobile/core/storage/signed_url_remote_evidence_transport.dart';

class _FakeEvidenceHttpClient implements EvidenceHttpClient {
  _FakeEvidenceHttpClient({
    this.response = const EvidenceHttpResponse(statusCode: 200),
  });

  final EvidenceHttpResponse response;
  EvidenceHttpPutRequest? lastRequest;
  int calls = 0;

  @override
  Future<EvidenceHttpResponse> putFile(EvidenceHttpPutRequest request) async {
    calls++;
    lastRequest = request;
    return response;
  }
}

void main() {
  final now = DateTime.utc(2026, 8, 21, 13, 30);

  EvidenceAccessGrant uploadGrant({
    EvidenceRemoteOperation operation = EvidenceRemoteOperation.upload,
    DateTime? expiresAt,
    String objectKey = 'evidencias/rae-001/evidencia-001.jpg',
    Map<String, String> headers = const <String, String>{
      'Content-Type': 'image/jpeg',
      'X-Signed-Header': 'opaque-value',
    },
  }) {
    return EvidenceAccessGrant(
      uri: Uri.parse(
        'https://signed.example.invalid/evidencias/rae-001/evidencia-001.jpg',
      ),
      operation: operation,
      expiresAt: expiresAt ?? now.add(const Duration(minutes: 10)),
      objectKey: objectKey,
      requiredHeaders: headers,
    );
  }

  const request = RemoteEvidenceUploadRequest(
    acaoId: 'rae-001',
    evidenciaId: 'evidencia-001',
    localFilePath: '/local/evidencia-001.jpg',
    contentType: 'image/jpeg',
  );

  group('AUD-L2-R5.4-D - SignedUrlRemoteEvidenceTransport', () {
    test('fica habilitado somente quando instanciado explicitamente', () {
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: _FakeEvidenceHttpClient(),
        now: () => now,
      );

      expect(transport.enabled, isTrue);
    });

    test('consome URI e headers do grant sem fabricar autoridade', () async {
      final httpClient = _FakeEvidenceHttpClient(
        response: const EvidenceHttpResponse(
          statusCode: 200,
          headers: <String, String>{
            'ETag': '"etag-simulado"',
          },
        ),
      );

      var current = now;
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: httpClient,
        now: () => current,
      );

      final grant = uploadGrant();
      current = now.add(const Duration(seconds: 2));

      final result = await transport.upload(
        grant: grant,
        request: request,
      );

      expect(httpClient.calls, 1);
      expect(httpClient.lastRequest?.uri, grant.uri);
      expect(httpClient.lastRequest?.localFilePath, request.localFilePath);
      expect(httpClient.lastRequest?.headers, grant.requiredHeaders);
      expect(
        httpClient.lastRequest?.headers['X-Signed-Header'],
        'opaque-value',
      );

      expect(result.objectKey, grant.objectKey);
      expect(result.syncedAt, current);
      expect(result.etag, '"etag-simulado"');
      expect(result.sizeBytes, isNull);
    });

    test('nao trata ETag como SHA-256 nem exige sua presenca', () async {
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: _FakeEvidenceHttpClient(
          response: const EvidenceHttpResponse(statusCode: 204),
        ),
        now: () => now,
      );

      final result = await transport.upload(
        grant: uploadGrant(),
        request: request,
      );

      expect(result.etag, isNull);
      expect(result.objectKey, 'evidencias/rae-001/evidencia-001.jpg');
    });

    test('falha fechado para grant de leitura sem chamar HTTP', () async {
      final httpClient = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: httpClient,
        now: () => now,
      );

      await expectLater(
        transport.upload(
          grant: uploadGrant(operation: EvidenceRemoteOperation.read),
          request: request,
        ),
        throwsA(isA<StateError>()),
      );

      expect(httpClient.calls, 0);
    });

    test('falha fechado para grant expirado sem chamar HTTP', () async {
      final httpClient = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: httpClient,
        now: () => now,
      );

      await expectLater(
        transport.upload(
          grant: uploadGrant(
            expiresAt: now,
          ),
          request: request,
        ),
        throwsA(isA<StateError>()),
      );

      expect(httpClient.calls, 0);
    });

    test('exige Content-Type autorizado no grant', () async {
      final httpClient = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: httpClient,
        now: () => now,
      );

      await expectLater(
        transport.upload(
          grant: uploadGrant(
            headers: const <String, String>{
              'X-Signed-Header': 'opaque-value',
            },
          ),
          request: request,
        ),
        throwsA(isA<StateError>()),
      );

      expect(httpClient.calls, 0);
    });

    test('rejeita divergencia de Content-Type antes do HTTP', () async {
      final httpClient = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: httpClient,
        now: () => now,
      );

      const pngRequest = RemoteEvidenceUploadRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.png',
        contentType: 'image/png',
      );

      await expectLater(
        transport.upload(
          grant: uploadGrant(),
          request: pngRequest,
        ),
        throwsA(isA<StateError>()),
      );

      expect(httpClient.calls, 0);
    });

    test('nao marca sincronizacao quando HTTP nao e 2xx', () async {
      final httpClient = _FakeEvidenceHttpClient(
        response: const EvidenceHttpResponse(statusCode: 403),
      );

      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: httpClient,
        now: () => now,
      );

      await expectLater(
        transport.upload(
          grant: uploadGrant(),
          request: request,
        ),
        throwsA(isA<StateError>()),
      );

      expect(httpClient.calls, 1);
    });

    test('rejeita request invalido antes de consumir o grant', () async {
      final httpClient = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: httpClient,
        now: () => now,
      );

      const invalidRequest = RemoteEvidenceUploadRequest(
        acaoId: '',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.jpg',
        contentType: 'image/jpeg',
      );

      await expectLater(
        transport.upload(
          grant: uploadGrant(),
          request: invalidRequest,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(httpClient.calls, 0);
    });
  });
}
