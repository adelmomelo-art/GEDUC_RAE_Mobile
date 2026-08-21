import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_http_client.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_http_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_models.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_upload_exception.dart';
import 'package:geduc_rae_mobile/core/storage/signed_url_remote_evidence_transport.dart';

class _FakeEvidenceHttpClient implements EvidenceHttpClient {
  _FakeEvidenceHttpClient({
    this.response = const EvidenceHttpResponse(statusCode: 200),
    this.error,
  });

  final EvidenceHttpResponse response;
  final Object? error;
  int calls = 0;

  @override
  Future<EvidenceHttpResponse> putFile(EvidenceHttpPutRequest request) async {
    calls++;

    final currentError = error;
    if (currentError != null) {
      throw currentError;
    }

    return response;
  }
}

void main() {
  final now = DateTime.utc(2026, 8, 21, 16);

  EvidenceAccessGrant grant({
    EvidenceRemoteOperation operation = EvidenceRemoteOperation.upload,
    DateTime? expiresAt,
    Map<String, String> headers = const <String, String>{
      'Content-Type': 'image/jpeg',
    },
  }) {
    return EvidenceAccessGrant(
      uri: Uri.parse('https://signed.example.invalid/object'),
      operation: operation,
      expiresAt: expiresAt ?? now.add(const Duration(minutes: 10)),
      objectKey: 'evidencias/rae-001/evidencia-001.jpg',
      requiredHeaders: headers,
    );
  }

  const validRequest = RemoteEvidenceUploadRequest(
    acaoId: 'rae-001',
    evidenciaId: 'evidencia-001',
    localFilePath: '/local/evidencia-001.jpg',
    contentType: 'image/jpeg',
  );

  group('AUD-L2-R5.4-E - falhas tipadas pre-HTTP', () {
    test('request invalido nao chama HTTP e nao e retry candidate', () async {
      final client = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: client,
        now: () => now,
      );

      const invalid = RemoteEvidenceUploadRequest(
        acaoId: '',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.jpg',
        contentType: 'image/jpeg',
      );

      final error = await _capture(
        () => transport.upload(grant: grant(), request: invalid),
      );

      expect(error.failure, RemoteEvidenceUploadFailure.invalidRequest);
      expect(error.retryCandidate, isFalse);
      expect(client.calls, 0);
    });

    test('grant expirado nao chama HTTP e nao e retry candidate', () async {
      final client = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: client,
        now: () => now,
      );

      final error = await _capture(
        () => transport.upload(
          grant: grant(expiresAt: now),
          request: validRequest,
        ),
      );

      expect(error.failure, RemoteEvidenceUploadFailure.invalidGrant);
      expect(error.retryCandidate, isFalse);
      expect(client.calls, 0);
    });

    test('operacao read nao chama HTTP', () async {
      final client = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: client,
        now: () => now,
      );

      final error = await _capture(
        () => transport.upload(
          grant: grant(operation: EvidenceRemoteOperation.read),
          request: validRequest,
        ),
      );

      expect(error.failure, RemoteEvidenceUploadFailure.invalidGrant);
      expect(client.calls, 0);
    });

    test('Content-Type ausente nao chama HTTP', () async {
      final client = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: client,
        now: () => now,
      );

      final error = await _capture(
        () => transport.upload(
          grant: grant(headers: const <String, String>{}),
          request: validRequest,
        ),
      );

      expect(error.failure, RemoteEvidenceUploadFailure.missingContentType);
      expect(error.retryCandidate, isFalse);
      expect(client.calls, 0);
    });

    test('Content-Type divergente nao chama HTTP', () async {
      final client = _FakeEvidenceHttpClient();
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: client,
        now: () => now,
      );

      final error = await _capture(
        () => transport.upload(
          grant: grant(),
          request: const RemoteEvidenceUploadRequest(
            acaoId: 'rae-001',
            evidenciaId: 'evidencia-001',
            localFilePath: '/local/evidencia-001.png',
            contentType: 'image/png',
          ),
        ),
      );

      expect(error.failure, RemoteEvidenceUploadFailure.contentTypeMismatch);
      expect(error.retryCandidate, isFalse);
      expect(client.calls, 0);
    });
  });

  group('AUD-L2-R5.4-E - HTTP e retry candidate', () {
    test('403 e rejeicao definitiva e executa uma unica tentativa', () async {
      final client = _FakeEvidenceHttpClient(
        response: const EvidenceHttpResponse(statusCode: 403),
      );
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: client,
        now: () => now,
      );

      final error = await _capture(
        () => transport.upload(grant: grant(), request: validRequest),
      );

      expect(error.failure, RemoteEvidenceUploadFailure.httpRejected);
      expect(error.statusCode, 403);
      expect(error.retryCandidate, isFalse);
      expect(client.calls, 1);
    });

    for (final status in <int>[408, 425, 429, 500, 502, 503, 504]) {
      test(
        'HTTP $status e candidato a retry externo sem retry automatico',
        () async {
          final client = _FakeEvidenceHttpClient(
            response: EvidenceHttpResponse(statusCode: status),
          );
          final transport = SignedUrlRemoteEvidenceTransport(
            httpClient: client,
            now: () => now,
          );

          final error = await _capture(
            () => transport.upload(grant: grant(), request: validRequest),
          );

          expect(error.failure, RemoteEvidenceUploadFailure.httpRejected);
          expect(error.statusCode, status);
          expect(error.retryCandidate, isTrue);
          expect(client.calls, 1);
        },
      );
    }

    test('falha de transporte preserva causa e nao faz retry automatico',
        () async {
      final timeout = TimeoutException('simulado');
      final client = _FakeEvidenceHttpClient(error: timeout);
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: client,
        now: () => now,
      );

      final error = await _capture(
        () => transport.upload(grant: grant(), request: validRequest),
      );

      expect(error.failure, RemoteEvidenceUploadFailure.transportFailure);
      expect(error.retryCandidate, isTrue);
      expect(error.cause, same(timeout));
      expect(client.calls, 1);
    });

    test('2xx continua produzindo sucesso sem alterar politica de retry',
        () async {
      final client = _FakeEvidenceHttpClient(
        response: const EvidenceHttpResponse(
          statusCode: 200,
          headers: <String, String>{'ETag': '"etag-r5-4-e"'},
        ),
      );
      final transport = SignedUrlRemoteEvidenceTransport(
        httpClient: client,
        now: () => now,
      );

      final result = await transport.upload(
        grant: grant(),
        request: validRequest,
      );

      expect(result.objectKey, 'evidencias/rae-001/evidencia-001.jpg');
      expect(result.etag, '"etag-r5-4-e"');
      expect(client.calls, 1);
    });
  });

  group('AUD-L2-R5.4-E - classificacao pura', () {
    test('4xx comum nao e retry candidate', () {
      const error = RemoteEvidenceUploadException(
        failure: RemoteEvidenceUploadFailure.httpRejected,
        message: 'rejeitado',
        statusCode: 422,
      );

      expect(error.retryCandidate, isFalse);
    });

    test('599 ainda e retry candidate e 600 nao e', () {
      const retry = RemoteEvidenceUploadException(
        failure: RemoteEvidenceUploadFailure.httpRejected,
        message: 'rejeitado',
        statusCode: 599,
      );
      const noRetry = RemoteEvidenceUploadException(
        failure: RemoteEvidenceUploadFailure.httpRejected,
        message: 'rejeitado',
        statusCode: 600,
      );

      expect(retry.retryCandidate, isTrue);
      expect(noRetry.retryCandidate, isFalse);
    });
  });
}

Future<RemoteEvidenceUploadException> _capture(
  Future<RemoteEvidenceUploadResult> Function() action,
) async {
  try {
    await action();
  } on RemoteEvidenceUploadException catch (error) {
    return error;
  }

  throw StateError('Era esperada RemoteEvidenceUploadException.');
}
