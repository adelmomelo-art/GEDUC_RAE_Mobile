import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/disabled_evidence_access_broker.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_access_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_remote_operation.dart';

void main() {
  group('AUD-L2-R5.3 - EvidenceReadAccessRequest', () {
    test('aceita identificadores canonicos preenchidos', () {
      const request = EvidenceReadAccessRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
      );

      expect(request.valido, isTrue);
    });

    test('rejeita identificador vazio', () {
      const request = EvidenceReadAccessRequest(
        acaoId: ' ',
        evidenciaId: 'evidencia-001',
      );

      expect(request.valido, isFalse);
    });
  });

  group('AUD-L2-R5.3 - EvidenceUploadAccessRequest', () {
    const sha = 'ba7816bf8f01cfea414140de5dae2223'
        'b00361a396177a9cb410ff61f20015ad';

    test('aceita integridade e metadados completos', () {
      const request = EvidenceUploadAccessRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        contentType: 'image/jpeg',
        tamanhoBytes: 3,
        sha256: sha,
      );

      expect(request.valido, isTrue);
    });

    test('rejeita tamanho nao positivo', () {
      const request = EvidenceUploadAccessRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        contentType: 'image/jpeg',
        tamanhoBytes: 0,
        sha256: sha,
      );

      expect(request.valido, isFalse);
    });

    test('rejeita sha256 malformado', () {
      const request = EvidenceUploadAccessRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        contentType: 'image/jpeg',
        tamanhoBytes: 3,
        sha256: 'abc',
      );

      expect(request.valido, isFalse);
    });
  });

  group('AUD-L2-R5.3 - EvidenceAccessGrant', () {
    test('e valido somente antes da expiracao e com URI absoluta', () {
      final now = DateTime.utc(2026, 8, 20, 14);
      final grant = EvidenceAccessGrant(
        uri: Uri.parse('https://example.invalid/object'),
        operation: EvidenceRemoteOperation.read,
        expiresAt: now.add(const Duration(minutes: 5)),
      );

      expect(grant.validoEm(now), isTrue);
      expect(
        grant.validoEm(now.add(const Duration(minutes: 6))),
        isFalse,
      );
    });
  });

  group('AUD-L2-R5.3 - DisabledEvidenceAccessBroker', () {
    const broker = DisabledEvidenceAccessBroker();

    test('permanece desabilitado por padrao', () {
      expect(broker.enabled, isFalse);
    });

    test('leitura falha fechado', () async {
      const request = EvidenceReadAccessRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
      );

      await expectLater(
        broker.requestReadAccess(request),
        throwsA(isA<StateError>()),
      );
    });

    test('upload falha fechado', () async {
      const request = EvidenceUploadAccessRequest(
        acaoId: 'rae-001',
        evidenciaId: 'evidencia-001',
        contentType: 'image/jpeg',
        tamanhoBytes: 3,
        sha256: 'ba7816bf8f01cfea414140de5dae2223'
            'b00361a396177a9cb410ff61f20015ad',
      );

      await expectLater(
        broker.requestUploadAccess(request),
        throwsA(isA<StateError>()),
      );
    });
  });
}
