import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/disabled_remote_evidence_transport.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_storage_policy.dart';
import 'package:geduc_rae_mobile/core/storage/remote_evidence_models.dart';

void main() {
  group('AUD-L2-R5.1 - RemoteEvidenceUploadRequest', () {
    test('aceita contrato completo e neutro de provedor', () {
      const request = RemoteEvidenceUploadRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.jpg',
        contentType: 'image/jpeg',
      );

      expect(request.valido, isTrue);
    });

    test('falha validacao quando identificador obrigatorio esta vazio', () {
      const request = RemoteEvidenceUploadRequest(
        acaoId: '',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.jpg',
        contentType: 'image/jpeg',
      );

      expect(request.valido, isFalse);
    });
  });

  group('AUD-L2-R5.4-A - DisabledRemoteEvidenceTransport', () {
    const transport = DisabledRemoteEvidenceTransport();

    test('permanece desabilitado por padrao', () {
      expect(transport.enabled, isFalse);
    });

    test('upload exige grant previamente emitido e falha fechado', () async {
      final grant = EvidenceAccessGrant(
        uri: Uri.parse('https://example.invalid/evidencia-001.jpg'),
        operation: EvidenceRemoteOperation.upload,
        expiresAt: DateTime.utc(2026, 8, 20, 19),
        requiredHeaders: const <String, String>{
          'Content-Type': 'image/jpeg',
        },
      );

      const request = RemoteEvidenceUploadRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.jpg',
        contentType: 'image/jpeg',
      );

      await expectLater(
        transport.upload(
          grant: grant,
          request: request,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('AUD-L2-R5.1-R1 - EvidenceStoragePolicy', () {
    test('baseline preserva local obrigatorio e remoto desligado', () {
      const policy = EvidenceStoragePolicy();

      expect(policy.localStorageRequired, isTrue);
      expect(policy.localFirst, isTrue);
      expect(policy.remoteStorageEnabled, isFalse);
    });

    test('habilitar remoto nunca remove obrigatoriedade local', () {
      const policy = EvidenceStoragePolicy(
        remoteStorageEnabled: true,
      );

      expect(policy.localStorageRequired, isTrue);
      expect(policy.localFirst, isTrue);
      expect(policy.remoteStorageEnabled, isTrue);
    });
  });
}
