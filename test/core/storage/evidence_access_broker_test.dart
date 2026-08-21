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

  group('AUD-L2-R5.4-B - EvidenceAccessGrant', () {
    final now = DateTime.utc(2026, 8, 20, 16);

    EvidenceAccessGrant grant({
      required String uri,
      EvidenceRemoteOperation operation = EvidenceRemoteOperation.read,
      Duration validade = const Duration(minutes: 5),
    }) {
      return EvidenceAccessGrant(
        uri: Uri.parse(uri),
        operation: operation,
        expiresAt: now.add(validade),
        objectKey: 'evidencias/rae-001/evidencia-001.jpg',
      );
    }

    test('aceita somente HTTPS com host e expiracao futura', () {
      expect(
        grant(uri: 'https://example.invalid/object').validoEm(now),
        isTrue,
      );
    });

    test('rejeita HTTP, FTP e FILE', () {
      expect(
        grant(uri: 'http://example.invalid/object').validoEm(now),
        isFalse,
      );
      expect(
        grant(uri: 'ftp://example.invalid/object').validoEm(now),
        isFalse,
      );
      expect(
        grant(uri: 'file:///tmp/object').validoEm(now),
        isFalse,
      );
    });

    test('rejeita URI HTTPS sem host', () {
      expect(
        grant(uri: 'https:///object').validoEm(now),
        isFalse,
      );
    });

    test('rejeita grant expirado ou exatamente no instante de expiracao', () {
      expect(
        grant(
          uri: 'https://example.invalid/object',
          validade: Duration.zero,
        ).validoEm(now),
        isFalse,
      );

      expect(
        grant(
          uri: 'https://example.invalid/object',
          validade: const Duration(seconds: -1),
        ).validoEm(now),
        isFalse,
      );
    });

    test('validoPara exige operacao compativel', () {
      final readGrant = grant(uri: 'https://example.invalid/object');

      expect(
        readGrant.validoPara(
          operacaoEsperada: EvidenceRemoteOperation.read,
          instante: now,
        ),
        isTrue,
      );

      expect(
        readGrant.validoPara(
          operacaoEsperada: EvidenceRemoteOperation.upload,
          instante: now,
        ),
        isFalse,
      );
    });
    test('rejeita objectKey vazia mesmo com HTTPS e validade futura', () {
      final invalidGrant = EvidenceAccessGrant(
        uri: Uri.parse('https://example.invalid/object'),
        operation: EvidenceRemoteOperation.upload,
        expiresAt: now.add(const Duration(minutes: 5)),
        objectKey: ' ',
      );

      expect(invalidGrant.validoEm(now), isFalse);
    });

    test('preserva objectKey emitida pela fronteira confiavel', () {
      final validGrant = grant(uri: 'https://example.invalid/object');

      expect(
        validGrant.objectKey,
        'evidencias/rae-001/evidencia-001.jpg',
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
