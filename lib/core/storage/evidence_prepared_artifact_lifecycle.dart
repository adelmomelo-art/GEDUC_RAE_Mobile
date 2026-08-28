import 'dart:io';

import 'package:path/path.dart' as path;

import 'application_documents_evidence_prepared_path_resolver.dart';
import 'evidence_image_preparation_profile.dart';

enum EvidencePreparedArtifactRemovalStatus {
  removed,
  alreadyAbsent,
}

class EvidencePreparedArtifactLifecycle {
  EvidencePreparedArtifactLifecycle({
    required EvidenceDocumentsDirectoryProvider documentsDirectoryProvider,
  }) : _documentsDirectoryProvider = documentsDirectoryProvider;

  final EvidenceDocumentsDirectoryProvider _documentsDirectoryProvider;

  Future<EvidencePreparedArtifactRemovalStatus> removePreparedArtifact(
    String preparedFilePath,
  ) async {
    final rawTarget = preparedFilePath.trim();
    if (rawTarget.isEmpty || !path.isAbsolute(rawTarget)) {
      throw StateError('Caminho de artefato preparado invalido.');
    }

    final documentsDirectory = await _documentsDirectoryProvider();
    final root = ApplicationDocumentsEvidencePreparedPathResolver
        .preparedArtifactsRootFor(documentsDirectory);

    final normalizedRoot = path.normalize(path.absolute(root.path));
    final normalizedTarget = path.normalize(path.absolute(rawTarget));

    if (!path.isWithin(normalizedRoot, normalizedTarget)) {
      throw StateError(
        'Remocao recusada: arquivo fora da raiz de artefatos preparados.',
      );
    }

    if (path.extension(normalizedTarget).toLowerCase() !=
        EvidenceImagePreparationProfile.outputExtension) {
      throw StateError(
        'Remocao recusada: artefato nao possui a extensao preparada esperada.',
      );
    }

    final file = File(normalizedTarget);
    if (!await file.exists()) {
      return EvidencePreparedArtifactRemovalStatus.alreadyAbsent;
    }

    await file.delete();
    return EvidencePreparedArtifactRemovalStatus.removed;
  }
}
