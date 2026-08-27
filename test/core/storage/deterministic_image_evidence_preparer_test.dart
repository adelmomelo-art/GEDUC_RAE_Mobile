import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/storage/deterministic_image_evidence_preparer.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_image_preparation_profile.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_preparation_models.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_prepared_path_resolver.dart';
import 'package:image/image.dart' as image_lib;

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('fenix-r56b-');
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  EvidencePreparationRequest requestFor(
    File original, {
    String contentType = 'image/png',
  }) {
    return EvidencePreparationRequest(
      acaoId: 'acao-1',
      evidenciaId: 'evidencia-1',
      originalFilePath: original.path,
      originalContentType: contentType,
    );
  }

  DeterministicImageEvidencePreparer preparerFor(String destination) {
    return DeterministicImageEvidencePreparer(
      pathResolver: _FixedPathResolver(destination),
      clock: () => DateTime.utc(2026, 8, 27, 15),
    );
  }

  Future<File> writePng(
    String name, {
    required int width,
    required int height,
    int numChannels = 3,
  }) async {
    final image = image_lib.Image(
      width: width,
      height: height,
      numChannels: numChannels,
    );
    image_lib.fill(
      image,
      color: numChannels == 4
          ? image_lib.ColorRgba8(32, 96, 160, 255)
          : image_lib.ColorRgb8(32, 96, 160),
    );
    final file = File('${tempDirectory.path}/$name');
    await file.writeAsBytes(image_lib.encodePng(image));
    return file;
  }

  group('EvidenceImagePreparationProfile', () {
    test('fixa a receita JPEG v1', () {
      expect(EvidenceImagePreparationProfile.id, 'evidence-photo-jpeg-v1');
      expect(EvidenceImagePreparationProfile.outputContentType, 'image/jpeg');
      expect(EvidenceImagePreparationProfile.outputExtension, '.jpg');
      expect(EvidenceImagePreparationProfile.maxDimension, 2048);
      expect(EvidenceImagePreparationProfile.jpegQuality, 85);
      expect(
        EvidenceImagePreparationProfile.supportedContentTypes,
        containsAll(<String>['image/jpeg', 'image/png', 'image/webp']),
      );
    });
  });

  group('DeterministicImageEvidencePreparer', () {
    test('reduz maior lado para 2048 e preserva o original byte a byte',
        () async {
      final original = await writePng(
        'grande.png',
        width: 2304,
        height: 1152,
      );
      final originalBytesBefore = await original.readAsBytes();
      final destination = '${tempDirectory.path}/prepared/grande.jpg';

      final artifact =
          await preparerFor(destination).prepare(requestFor(original));

      final preparedBytes = await File(destination).readAsBytes();
      final preparedImage = image_lib.decodeJpg(preparedBytes);
      expect(preparedImage, isNotNull);
      expect(preparedImage!.width, 2048);
      expect(preparedImage.height, 1024);
      expect(await original.readAsBytes(), orderedEquals(originalBytesBefore));
      expect(artifact.originalFilePath, original.path);
      expect(artifact.preparedFilePath, destination);
      expect(artifact.contentType, 'image/jpeg');
      expect(artifact.preparationProfile, 'evidence-photo-jpeg-v1');
      expect(artifact.createdAt, DateTime.utc(2026, 8, 27, 15));
    });

    test('nao faz upscale de imagem menor', () async {
      final original = await writePng(
        'pequena.png',
        width: 640,
        height: 480,
      );
      final destination = '${tempDirectory.path}/prepared/pequena.jpg';

      await preparerFor(destination).prepare(requestFor(original));

      final prepared =
          image_lib.decodeJpg(await File(destination).readAsBytes());
      expect(prepared, isNotNull);
      expect(prepared!.width, 640);
      expect(prepared.height, 480);
    });

    test('normaliza WebP para JPEG', () async {
      final image = image_lib.Image(width: 96, height: 64);
      image_lib.fill(image, color: image_lib.ColorRgb8(12, 80, 140));
      final original = File('${tempDirectory.path}/entrada.webp');
      await original.writeAsBytes(image_lib.encodeWebP(image));
      final destination = '${tempDirectory.path}/prepared/webp.jpg';

      final artifact = await preparerFor(destination).prepare(
        requestFor(original, contentType: 'image/webp'),
      );

      expect(artifact.contentType, 'image/jpeg');
      expect(image_lib.decodeJpg(await File(destination).readAsBytes()),
          isNotNull);
    });

    test('compoe transparencia sobre fundo branco', () async {
      final transparent = image_lib.Image(
        width: 16,
        height: 16,
        numChannels: 4,
      );
      image_lib.fill(
        transparent,
        color: image_lib.ColorRgba8(0, 0, 255, 0),
      );
      final original = File('${tempDirectory.path}/transparente.png');
      await original.writeAsBytes(image_lib.encodePng(transparent));
      final destination = '${tempDirectory.path}/prepared/transparente.jpg';

      await preparerFor(destination).prepare(requestFor(original));

      final prepared =
          image_lib.decodeJpg(await File(destination).readAsBytes());
      expect(prepared, isNotNull);
      final pixel = prepared!.getPixel(8, 8);
      expect(pixel.r, greaterThanOrEqualTo(250));
      expect(pixel.g, greaterThanOrEqualTo(250));
      expect(pixel.b, greaterThanOrEqualTo(250));
    });

    test('aplica orientacao EXIF aos pixels antes de gerar o JPEG', () async {
      final oriented = image_lib.Image(width: 40, height: 80);
      image_lib.fill(oriented, color: image_lib.ColorRgb8(120, 40, 20));
      oriented.exif.imageIfd.orientation = 6;
      final original = File('${tempDirectory.path}/orientada.jpg');
      await original.writeAsBytes(image_lib.encodeJpg(oriented, quality: 95));
      final destination = '${tempDirectory.path}/prepared/orientada.jpg';

      await preparerFor(destination).prepare(
        requestFor(original, contentType: 'image/jpeg'),
      );

      final prepared =
          image_lib.decodeJpg(await File(destination).readAsBytes());
      expect(prepared, isNotNull);
      expect(prepared!.width, 80);
      expect(prepared.height, 40);
      expect(prepared.exif.isEmpty, isTrue);
    });

    test('mesma entrada gera bytes e SHA-256 identicos em destinos distintos',
        () async {
      final original = await writePng(
        'determinismo.png',
        width: 800,
        height: 600,
      );
      final firstDestination = '${tempDirectory.path}/prepared/a.jpg';
      final secondDestination = '${tempDirectory.path}/prepared/b.jpg';

      await preparerFor(firstDestination).prepare(requestFor(original));
      await preparerFor(secondDestination).prepare(requestFor(original));

      final firstBytes = await File(firstDestination).readAsBytes();
      final secondBytes = await File(secondDestination).readAsBytes();
      expect(secondBytes, orderedEquals(firstBytes));
      expect(sha256.convert(secondBytes), sha256.convert(firstBytes));
    });

    test('reutiliza destino existente quando os bytes sao identicos', () async {
      final original = await writePng(
        'reuso.png',
        width: 320,
        height: 240,
      );
      final destination = '${tempDirectory.path}/prepared/reuso.jpg';
      final preparer = preparerFor(destination);

      await preparer.prepare(requestFor(original));
      final firstBytes = await File(destination).readAsBytes();
      final secondArtifact = await preparer.prepare(requestFor(original));

      expect(await File(destination).readAsBytes(), orderedEquals(firstBytes));
      expect(secondArtifact.preparedFilePath, destination);
    });

    test('falha fechado se o destino existente tiver bytes divergentes',
        () async {
      final original = await writePng(
        'conflito.png',
        width: 320,
        height: 240,
      );
      final destination = File('${tempDirectory.path}/prepared/conflito.jpg');
      await destination.parent.create(recursive: true);
      await destination.writeAsBytes(<int>[1, 2, 3, 4]);

      expect(
        () => preparerFor(destination.path).prepare(requestFor(original)),
        throwsA(
          isA<EvidencePreparationException>().having(
            (error) => error.failure,
            'failure',
            EvidencePreparationFailure.preparationFailure,
          ),
        ),
      );
      expect(await destination.readAsBytes(), orderedEquals(<int>[1, 2, 3, 4]));
    });

    test('rejeita arquivo original inexistente', () async {
      final original = File('${tempDirectory.path}/nao-existe.jpg');
      final destination = '${tempDirectory.path}/prepared/nao-existe.jpg';

      expect(
        () => preparerFor(destination).prepare(
          requestFor(original, contentType: 'image/jpeg'),
        ),
        throwsA(isA<EvidencePreparationException>()),
      );
    });

    test('rejeita HEIC no perfil v1', () async {
      final original = File('${tempDirectory.path}/foto.heic');
      await original.writeAsBytes(<int>[0, 1, 2, 3]);
      final destination = '${tempDirectory.path}/prepared/heic.jpg';

      expect(
        () => preparerFor(destination).prepare(
          requestFor(original, contentType: 'image/heic'),
        ),
        throwsA(isA<EvidencePreparationException>()),
      );
    });

    test('rejeita imagem corrompida', () async {
      final original = File('${tempDirectory.path}/corrompida.jpg');
      await original.writeAsBytes(<int>[0, 1, 2, 3, 4, 5]);
      final destination = '${tempDirectory.path}/prepared/corrompida.jpg';

      expect(
        () => preparerFor(destination).prepare(
          requestFor(original, contentType: 'image/jpeg'),
        ),
        throwsA(isA<EvidencePreparationException>()),
      );
    });

    test('rejeita imagem animada mesmo quando o MIME e permitido', () async {
      final animation = image_lib.Image(width: 16, height: 16, numChannels: 4);
      image_lib.fill(animation, color: image_lib.ColorRgba8(255, 0, 0, 255));
      final secondFrame = animation.addFrame();
      image_lib.fill(secondFrame, color: image_lib.ColorRgba8(0, 0, 255, 255));
      final original = File('${tempDirectory.path}/animada.png');
      await original.writeAsBytes(image_lib.encodePng(animation));
      final destination = '${tempDirectory.path}/prepared/animada.jpg';

      expect(
        () => preparerFor(destination).prepare(requestFor(original)),
        throwsA(isA<EvidencePreparationException>()),
      );
    });

    test('rejeita resolver que aponta para o proprio original', () async {
      final original = await writePng(
        'alias.png',
        width: 100,
        height: 100,
      );

      expect(
        () => preparerFor(original.path).prepare(requestFor(original)),
        throwsA(
          isA<EvidencePreparationException>().having(
            (error) => error.failure,
            'failure',
            EvidencePreparationFailure.originalArtifactAlias,
          ),
        ),
      );
    });

    test('rejeita destino que nao termina em .jpg', () async {
      final original = await writePng(
        'destino.png',
        width: 100,
        height: 100,
      );
      final destination = '${tempDirectory.path}/prepared/destino.jpeg';

      expect(
        () => preparerFor(destination).prepare(requestFor(original)),
        throwsA(isA<EvidencePreparationException>()),
      );
    });
  });
}

class _FixedPathResolver implements EvidencePreparedPathResolver {
  const _FixedPathResolver(this.destination);

  final String destination;

  @override
  Future<String> resolveFor(EvidencePreparationRequest request) async =>
      destination;
}
