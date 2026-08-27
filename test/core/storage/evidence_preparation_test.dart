import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_preparation_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_preparer.dart';

void main() {
  const guard = EvidencePreparationGuard();

  const request = EvidencePreparationRequest(
    acaoId: 'acao-1',
    evidenciaId: 'evidencia-1',
    originalFilePath: 'dados/originais/foto.heic',
    originalContentType: 'image/heic',
  );

  EvidencePreparedArtifact artifact({
    String originalFilePath = 'dados/originais/foto.heic',
    String preparedFilePath = 'dados/preparados/foto.jpg',
    String contentType = 'image/jpeg',
    String preparationProfile = 'image-upload-v1',
  }) {
    return EvidencePreparedArtifact(
      originalFilePath: originalFilePath,
      preparedFilePath: preparedFilePath,
      contentType: contentType,
      preparationProfile: preparationProfile,
      createdAt: DateTime.utc(2026, 8, 26, 12),
    );
  }

  group('EvidencePreparationGuard', () {
    test('aceita artefato separado e vinculado ao original correto', () {
      expect(
        () => guard.validateArtifactFor(
          request: request,
          artifact: artifact(),
        ),
        returnsNormally,
      );
    });

    test('rejeita requisicao incompleta', () {
      const invalid = EvidencePreparationRequest(
        acaoId: '',
        evidenciaId: 'evidencia-1',
        originalFilePath: 'dados/originais/foto.jpg',
        originalContentType: 'image/jpeg',
      );

      expect(
        () => guard.validateRequest(invalid),
        throwsA(
          isA<EvidencePreparationException>().having(
            (error) => error.failure,
            'failure',
            EvidencePreparationFailure.invalidRequest,
          ),
        ),
      );
    });

    test('rejeita artefato que reutiliza o caminho do original', () {
      expect(
        () => guard.validateArtifactFor(
          request: request,
          artifact: artifact(
            preparedFilePath: 'dados/originais/foto.heic',
          ),
        ),
        throwsA(
          isA<EvidencePreparationException>().having(
            (error) => error.failure,
            'failure',
            EvidencePreparationFailure.originalArtifactAlias,
          ),
        ),
      );
    });

    test('rejeita artefato produzido para outro original', () {
      expect(
        () => guard.validateArtifactFor(
          request: request,
          artifact: artifact(
            originalFilePath: 'dados/originais/outra-foto.heic',
          ),
        ),
        throwsA(
          isA<EvidencePreparationException>().having(
            (error) => error.failure,
            'failure',
            EvidencePreparationFailure.sourceMismatch,
          ),
        ),
      );
    });

    test('rejeita artefato sem content type', () {
      expect(
        () => guard.validateArtifactFor(
          request: request,
          artifact: artifact(contentType: '   '),
        ),
        throwsA(
          isA<EvidencePreparationException>().having(
            (error) => error.failure,
            'failure',
            EvidencePreparationFailure.invalidArtifact,
          ),
        ),
      );
    });

    test('preparationProfile e identificador de receita, nao hash remoto', () {
      final prepared = artifact(preparationProfile: 'image-upload-v1');

      expect(prepared.preparationProfile, 'image-upload-v1');
      expect(prepared.preparationProfile.length, isNot(64));
    });
  });
}