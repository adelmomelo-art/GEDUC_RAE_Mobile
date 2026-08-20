import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/disabled_remote_evidence_storage.dart';
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

    test('falha validacao quando qualquer identificador obrigatorio esta vazio',
        () {
      const request = RemoteEvidenceUploadRequest(
        acaoId: '',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.jpg',
        contentType: 'image/jpeg',
      );

      expect(request.valido, isFalse);
    });
  });

  group('AUD-L2-R5.1 - DisabledRemoteEvidenceStorage', () {
    const storage = DisabledRemoteEvidenceStorage();

    test('permanece desabilitado por padrao', () {
      expect(storage.enabled, isFalse);
    });

    test('upload falha fechado sem integracao remota configurada', () async {
      const request = RemoteEvidenceUploadRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        localFilePath: '/local/evidencia-001.jpg',
        contentType: 'image/jpeg',
      );

      await expectLater(
        storage.upload(request),
        throwsA(isA<StateError>()),
      );
    });

    test('leitura remota falha fechado sem integracao configurada', () async {
      await expectLater(
        storage.createReadUri(
          acaoId: 'rae-001',
          evidenciaId: 'evidencia-001',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('exclusao remota falha fechado sem integracao configurada', () async {
      await expectLater(
        storage.delete(
          acaoId: 'rae-001',
          evidenciaId: 'evidencia-001',
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
