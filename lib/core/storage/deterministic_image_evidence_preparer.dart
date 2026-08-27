import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart' as path;

import 'evidence_image_preparation_profile.dart';
import 'evidence_preparation_models.dart';
import 'evidence_prepared_path_resolver.dart';
import 'evidence_preparer.dart';

typedef EvidencePreparationClock = DateTime Function();

/// Implementacao deterministica do perfil [EvidenceImagePreparationProfile.id].
///
/// O arquivo original nunca e substituido. Os bytes JPEG produzidos por esta
/// classe sao o artefato que devera seguir para metadata/SHA-256 no R5.6-C.
class DeterministicImageEvidencePreparer implements EvidencePreparer {
  DeterministicImageEvidencePreparer({
    required EvidencePreparedPathResolver pathResolver,
    EvidencePreparationGuard guard = const EvidencePreparationGuard(),
    EvidencePreparationClock? clock,
  })  : _pathResolver = pathResolver,
        _guard = guard,
        _clock = clock ?? DateTime.now;

  final EvidencePreparedPathResolver _pathResolver;
  final EvidencePreparationGuard _guard;
  final EvidencePreparationClock _clock;

  @override
  Future<EvidencePreparedArtifact> prepare(
    EvidencePreparationRequest request,
  ) async {
    _guard.validateRequest(request);

    final normalizedContentType =
        request.originalContentType.trim().toLowerCase();
    if (!EvidenceImagePreparationProfile.supportedContentTypes
        .contains(normalizedContentType)) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.preparationFailure,
        message: 'Tipo de imagem nao suportado pelo perfil JPEG v1.',
      );
    }

    final originalFile = File(request.originalFilePath);
    if (!await originalFile.exists()) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.preparationFailure,
        message: 'Arquivo original de evidencia nao encontrado.',
      );
    }

    final preparedPath = (await _pathResolver.resolveFor(request)).trim();
    _validatePreparedPath(
      originalPath: originalFile.path,
      preparedPath: preparedPath,
    );

    final sourceBytes = await _readOriginal(originalFile);
    final decoded = _decode(sourceBytes);

    if (decoded.frames.length != 1) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.preparationFailure,
        message: 'Imagens animadas nao sao aceitas pelo perfil JPEG v1.',
      );
    }

    final oriented = image_lib.bakeOrientation(decoded);
    final resized = _resizeIfNeeded(oriented);
    final normalizedRgb = _compositeOnWhite(resized);
    final preparedBytes = image_lib.encodeJpg(
      normalizedRgb,
      quality: EvidenceImagePreparationProfile.jpegQuality,
      chroma: image_lib.JpegChroma.yuv420,
    );

    final preparedFile = File(preparedPath);
    final createdAt = await _persistImmutable(
      preparedFile: preparedFile,
      preparedBytes: preparedBytes,
    );

    final artifact = EvidencePreparedArtifact(
      originalFilePath: originalFile.path,
      preparedFilePath: preparedFile.path,
      contentType: EvidenceImagePreparationProfile.outputContentType,
      preparationProfile: EvidenceImagePreparationProfile.id,
      createdAt: createdAt,
    );

    _guard.validateArtifactFor(request: request, artifact: artifact);
    return artifact;
  }

  Future<Uint8List> _readOriginal(File originalFile) async {
    try {
      return await originalFile.readAsBytes();
    } catch (cause) {
      throw EvidencePreparationException(
        failure: EvidencePreparationFailure.preparationFailure,
        message: 'Falha ao ler o arquivo original de evidencia.',
        cause: cause,
      );
    }
  }

  image_lib.Image _decode(Uint8List sourceBytes) {
    try {
      final decoded = image_lib.decodeImage(sourceBytes);
      if (decoded == null) {
        throw const EvidencePreparationException(
          failure: EvidencePreparationFailure.preparationFailure,
          message: 'Nao foi possivel decodificar a imagem original.',
        );
      }
      return decoded;
    } on EvidencePreparationException {
      rethrow;
    } catch (cause) {
      throw EvidencePreparationException(
        failure: EvidencePreparationFailure.preparationFailure,
        message: 'Falha ao decodificar a imagem original.',
        cause: cause,
      );
    }
  }

  image_lib.Image _resizeIfNeeded(image_lib.Image source) {
    final width = source.width;
    final height = source.height;
    final largestDimension = width > height ? width : height;

    if (largestDimension <= EvidenceImagePreparationProfile.maxDimension) {
      return source;
    }

    final scale =
        EvidenceImagePreparationProfile.maxDimension / largestDimension;
    final targetWidth = (width * scale)
        .round()
        .clamp(
          1,
          EvidenceImagePreparationProfile.maxDimension,
        )
        .toInt();
    final targetHeight = (height * scale)
        .round()
        .clamp(
          1,
          EvidenceImagePreparationProfile.maxDimension,
        )
        .toInt();

    return image_lib.copyResize(
      source,
      width: targetWidth,
      height: targetHeight,
      interpolation: image_lib.Interpolation.average,
    );
  }

  image_lib.Image _compositeOnWhite(image_lib.Image source) {
    final canvas = image_lib.Image(
      width: source.width,
      height: source.height,
      numChannels: 3,
    );
    image_lib.fill(
      canvas,
      color: image_lib.ColorRgb8(255, 255, 255),
    );
    image_lib.compositeImage(
      canvas,
      source,
      blend: image_lib.BlendMode.alpha,
    );
    return canvas;
  }

  void _validatePreparedPath({
    required String originalPath,
    required String preparedPath,
  }) {
    if (path.normalize(preparedPath) == path.normalize(originalPath)) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.originalArtifactAlias,
        message: 'O artefato preparado nao pode substituir o arquivo original.',
      );
    }

    if (preparedPath.isEmpty ||
        path.extension(preparedPath).toLowerCase() !=
            EvidenceImagePreparationProfile.outputExtension) {
      throw const EvidencePreparationException(
        failure: EvidencePreparationFailure.preparationFailure,
        message: 'Destino preparado invalido; o perfil v1 exige extensao .jpg.',
      );
    }
  }

  Future<DateTime> _persistImmutable({
    required File preparedFile,
    required Uint8List preparedBytes,
  }) async {
    try {
      if (await preparedFile.exists()) {
        final existingBytes = await preparedFile.readAsBytes();
        if (!_sameBytes(existingBytes, preparedBytes)) {
          throw const EvidencePreparationException(
            failure: EvidencePreparationFailure.preparationFailure,
            message: 'Destino preparado ja existe com bytes divergentes.',
          );
        }
        return (await preparedFile.lastModified()).toUtc();
      }

      await preparedFile.parent.create(recursive: true);
      await preparedFile.writeAsBytes(preparedBytes, flush: true);
      return _clock().toUtc();
    } on EvidencePreparationException {
      rethrow;
    } catch (cause) {
      throw EvidencePreparationException(
        failure: EvidencePreparationFailure.preparationFailure,
        message: 'Falha ao materializar o artefato preparado.',
        cause: cause,
      );
    }
  }

  bool _sameBytes(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }
}
