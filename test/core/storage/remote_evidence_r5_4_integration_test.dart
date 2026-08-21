import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_http_client.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_http_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_models.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_upload_exception.dart';
import 'package:geduc_rae_mobile/core/storage/signed_url_remote_evidence_transport.dart';

class _IntegrationHttpClient implements EvidenceHttpClient {
  _IntegrationHttpClient({
    this.response = const EvidenceHttpResponse(statusCode: 200),
    this.error,
  });

  final EvidenceHttpResponse response;
  final Object? error;

  int calls = 0;
  EvidenceHttpPutRequest? lastRequest;

  @override
  Future<EvidenceHttpResponse> putFile(EvidenceHttpPutRequest request) async {
    calls++;
    lastRequest = request;

    final currentError = error;
    if (currentError != null) {
      throw currentError;
    }

    return response;
  }
}

void main() {
  final now = DateTime.utc(2026, 8, 21, 16, 40);

  EvidenceAccessGrant grant({
    EvidenceRemoteOperation operation = EvidenceRemoteOperation.upload,
    DateTime? expiresAt,
    Map<String, String> headers = const <String, String>{
      'Content-Type': 'image/jpeg',
      'X-Opaque-Signed-Header': 'signed-value',
    },
  }) {
    return EvidenceAccessGrant(
      uri: Uri.parse(
        'https://signed.example.invalid/evidencias/rae-001/evidencia-001.jpg',
      ),
      operation: operation,
      expiresAt: expiresAt ?? now.add(const Duration(minutes: 10)),
      objectKey: 'evidencias/rae-001/evidencia-001.jpg',
      requiredHeaders: headers,
    );
  }

  const request = RemoteEvidenceUploadRequest(
    acaoId: 'rae-001',
    evidenciaId: 'evidencia-001',
    localFilePath: '/local/evidencia-001.jpg',
    contentType: 'image/jpeg',
  );

  group('AUD-L2-R5.4-F - contrato integrado A-E', () {
    test('happy path preserva autoridade do grant e executa um unico PUT',
        () async {
      final http = _IntegrationHttpClient(
        response: const EvidenceHttpResponse(
          statusCode: 201,
          headers: <String, String>{
            'ETag': '"etag-opaco"',
          },
        ),
      );

      var current = now;
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: http,
        now: () => current,
      );

      final trustedGrant = grant();
      current = now.add(const Duration(seconds: 3));

      final result = await transport.upload(
        grant: trustedGrant,
        request: request,
      );

      expect(http.calls, 1);
      expect(http.lastRequest?.uri, trustedGrant.uri);
      expect(http.lastRequest?.localFilePath, request.localFilePath);
      expect(http.lastRequest?.headers, trustedGrant.requiredHeaders);
      expect(
        http.lastRequest?.headers['X-Opaque-Signed-Header'],
        'signed-value',
      );

      expect(result.objectKey, trustedGrant.objectKey);
      expect(result.syncedAt, current);
      expect(result.etag, '"etag-opaco"');
      expect(result.sizeBytes, isNull);
    });

    test('grant expirado falha fechado antes do plano de dados HTTP', () async {
      final http = _IntegrationHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: http,
        now: () => now,
      );

      await expectLater(
        transport.upload(
          grant: grant(expiresAt: now),
          request: request,
        ),
        throwsA(
          isA<RemoteEvidenceUploadException>().having(
            (error) => error.failure,
            'failure',
            RemoteEvidenceUploadFailure.invalidGrant,
          ),
        ),
      );

      expect(http.calls, 0);
    });

    test('grant de leitura nao pode ser reutilizado para upload', () async {
      final http = _IntegrationHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: http,
        now: () => now,
      );

      await expectLater(
        transport.upload(
          grant: grant(operation: EvidenceRemoteOperation.read),
          request: request,
        ),
        throwsA(
          isA<RemoteEvidenceUploadException>().having(
            (error) => error.failure,
            'failure',
            RemoteEvidenceUploadFailure.invalidGrant,
          ),
        ),
      );

      expect(http.calls, 0);
    });

    test('Content-Type divergente falha antes do HTTP', () async {
      final http = _IntegrationHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: http,
        now: () => now,
      );

      const png = RemoteEvidenceUploadRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.png',
        contentType: 'image/png',
      );

      await expectLater(
        transport.upload(
          grant: grant(),
          request: png,
        ),
        throwsA(
          isA<RemoteEvidenceUploadException>().having(
            (error) => error.failure,
            'failure',
            RemoteEvidenceUploadFailure.contentTypeMismatch,
          ),
        ),
      );

      expect(http.calls, 0);
    });

    test('HTTP 403 e definitivo e nao recebe retry dentro do transporte',
        () async {
      final http = _IntegrationHttpClient(
        response: const EvidenceHttpResponse(statusCode: 403),
      );
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: http,
        now: () => now,
      );

      RemoteEvidenceUploadException? captured;

      try {
        await transport.upload(grant: grant(), request: request);
      } on RemoteEvidenceUploadException catch (error) {
        captured = error;
      }

      expect(http.calls, 1);
      expect(captured, isNotNull);
      expect(captured?.failure, RemoteEvidenceUploadFailure.httpRejected);
      expect(captured?.statusCode, 403);
      expect(captured?.retryCandidate, isFalse);
    });

    test('HTTP 503 e apenas candidato a retry externo e continua uma tentativa',
        () async {
      final http = _IntegrationHttpClient(
        response: const EvidenceHttpResponse(statusCode: 503),
      );
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: http,
        now: () => now,
      );

      RemoteEvidenceUploadException? captured;

      try {
        await transport.upload(grant: grant(), request: request);
      } on RemoteEvidenceUploadException catch (error) {
        captured = error;
      }

      expect(http.calls, 1);
      expect(captured, isNotNull);
      expect(captured?.failure, RemoteEvidenceUploadFailure.httpRejected);
      expect(captured?.statusCode, 503);
      expect(captured?.retryCandidate, isTrue);
    });

    test('falha do cliente HTTP preserva causa e nao gera retry automatico',
        () async {
      final timeout = TimeoutException('timeout simulado');
      final http = _IntegrationHttpClient(error: timeout);
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: http,
        now: () => now,
      );

      RemoteEvidenceUploadException? captured;

      try {
        await transport.upload(grant: grant(), request: request);
      } on RemoteEvidenceUploadException catch (error) {
        captured = error;
      }

      expect(http.calls, 1);
      expect(captured, isNotNull);
      expect(captured?.failure, RemoteEvidenceUploadFailure.transportFailure);
      expect(captured?.retryCandidate, isTrue);
      expect(captured?.cause, same(timeout));
    });
  });
}