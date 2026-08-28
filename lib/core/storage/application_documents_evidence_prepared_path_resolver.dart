import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'evidence_image_preparation_profile.dart';
import 'evidence_preparation_models.dart';
import 'evidence_prepared_path_resolver.dart';

typedef EvidenceDocumentsDirectoryProvider = Future<Directory> Function();

class ApplicationDocumentsEvidencePreparedPathResolver
    implements EvidencePreparedPathResolver {
  ApplicationDocumentsEvidencePreparedPathResolver({
    EvidenceDocumentsDirectoryProvider? documentsDirectoryProvider,
  }) : _documentsDirectoryProvider =
            documentsDirectoryProvider ?? getApplicationDocumentsDirectory;

  static const String baseFolderName = 'GEDUC';
  static const String preparedArtifactsFolderName = 'evidence_upload_artifacts';

  final EvidenceDocumentsDirectoryProvider _documentsDirectoryProvider;

  static Directory preparedArtifactsRootFor(Directory documentsDirectory) {
    return Directory(
      path.join(
        documentsDirectory.path,
        baseFolderName,
        preparedArtifactsFolderName,
      ),
    );
  }

  @override
  Future<String> resolveFor(EvidencePreparationRequest request) async {
    if (!request.valido) {
      throw ArgumentError('Requisicao de preparacao de evidencia invalida.');
    }

    final acaoId = _safeSegment(request.acaoId, fieldName: 'acaoId');
    final evidenciaId =
        _safeSegment(request.evidenciaId, fieldName: 'evidenciaId');

    final documentsDirectory = await _documentsDirectoryProvider();
    final root = preparedArtifactsRootFor(documentsDirectory);

    return path.join(
      root.path,
      acaoId,
      evidenciaId,
      '${EvidenceImagePreparationProfile.id}'
      '${EvidenceImagePreparationProfile.outputExtension}',
    );
  }

  String _safeSegment(String raw, {required String fieldName}) {
    final value = raw.trim();

    if (value.isEmpty ||
        value == '.' ||
        value == '..' ||
        value.contains('/') ||
        value.contains(r'\\') ||
        !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value)) {
      throw ArgumentError.value(
        raw,
        fieldName,
        'Identificador inseguro para caminho de artefato preparado.',
      );
    }

    return value;
  }
}
