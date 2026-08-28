import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:geduc_rae_mobile/core/storage/application_documents_evidence_prepared_path_resolver.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_image_preparation_profile.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_preparation_models.dart';

void main() {
  group('ApplicationDocumentsEvidencePreparedPathResolver', () {
    late Directory temp;
    late ApplicationDocumentsEvidencePreparedPathResolver resolver;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('fenix_r56c_resolver_');
      resolver = ApplicationDocumentsEvidencePreparedPathResolver(
        documentsDirectoryProvider: () async => temp,
      );
    });

    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    test('resolve caminho deterministico por acao e evidencia', () async {
      const request = EvidencePreparationRequest(
        acaoId: 'acao-001',
        evidenciaId: 'evidencia_001',
        originalFilePath: '/original/foto.png',
        originalContentType: 'image/png',
      );

      final resolved = await resolver.resolveFor(request);

      expect(
        resolved,
        path.join(
          temp.path,
          'GEDUC',
          'evidence_upload_artifacts',
          'acao-001',
          'evidencia_001',
          '${EvidenceImagePreparationProfile.id}.jpg',
        ),
      );
      expect(await resolver.resolveFor(request), resolved);
    });

    test('rejeita path traversal', () async {
      const request = EvidencePreparationRequest(
        acaoId: '../acao',
        evidenciaId: 'evidencia-003',
        originalFilePath: '/original/foto.jpg',
        originalContentType: 'image/jpeg',
      );

      expect(() => resolver.resolveFor(request), throwsA(isA<ArgumentError>()));
    });
  });
}
