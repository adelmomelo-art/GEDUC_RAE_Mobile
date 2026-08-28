import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:geduc_rae_mobile/core/storage/application_documents_evidence_prepared_path_resolver.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_image_preparation_profile.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_prepared_artifact_lifecycle.dart';

void main() {
  group('EvidencePreparedArtifactLifecycle', () {
    late Directory temp;
    late EvidencePreparedArtifactLifecycle lifecycle;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('fenix_r56c_lifecycle_');
      lifecycle = EvidencePreparedArtifactLifecycle(
        documentsDirectoryProvider: () async => temp,
      );
    });

    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    test('remove somente arquivo dentro da raiz preparada', () async {
      final root = ApplicationDocumentsEvidencePreparedPathResolver
          .preparedArtifactsRootFor(temp);
      final file = File(path.join(
        root.path,
        'acao-1',
        'evid-1',
        '${EvidenceImagePreparationProfile.id}.jpg',
      ));
      await file.parent.create(recursive: true);
      await file.writeAsBytes([1, 2, 3]);

      expect(
        await lifecycle.removePreparedArtifact(file.path),
        EvidencePreparedArtifactRemovalStatus.removed,
      );
      expect(await file.exists(), isFalse);
    });

    test('ausente e idempotente', () async {
      final root = ApplicationDocumentsEvidencePreparedPathResolver
          .preparedArtifactsRootFor(temp);
      final file = File(path.join(
        root.path,
        'acao-2',
        'evid-2',
        '${EvidenceImagePreparationProfile.id}.jpg',
      ));

      expect(
        await lifecycle.removePreparedArtifact(file.path),
        EvidencePreparedArtifactRemovalStatus.alreadyAbsent,
      );
    });

    test('recusa remover original fora da raiz preparada', () async {
      final original = File(path.join(
        temp.path,
        'GEDUC',
        'evidencias',
        'acao-3',
        'original.jpg',
      ));
      await original.parent.create(recursive: true);
      await original.writeAsBytes([9, 9, 9]);

      expect(
        () => lifecycle.removePreparedArtifact(original.path),
        throwsA(isA<StateError>()),
      );
      expect(await original.exists(), isTrue);
    });
  });
}
