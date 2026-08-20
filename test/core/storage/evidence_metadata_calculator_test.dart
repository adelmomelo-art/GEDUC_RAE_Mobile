import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/models/evidencia_model.dart';
import 'package:geduc_rae_mobile/core/services/evidencia_storage_service.dart';
import 'package:geduc_rae_mobile/core/storage/evidence_metadata_calculator.dart';

void main() {
  group('AUD-L2-R5.2-B - EvidenceMetadataCalculator', () {
    const calculator = EvidenceMetadataCalculator();
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fenix_r5_2_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('calcula SHA-256 conhecido, tamanho e MIME do arquivo definitivo',
        () async {
      final file = File('${tempDir.path}${Platform.pathSeparator}abc.jpg');
      await file.writeAsString('abc');

      final metadata = await calculator.calculate(file);

      expect(
        metadata.sha256,
        'ba7816bf8f01cfea414140de5dae2223'
        'b00361a396177a9cb410ff61f20015ad',
      );
      expect(metadata.sizeBytes, 3);
      expect(metadata.mimeType, 'image/jpeg');
    });

    test('resolve MIME de forma deterministica', () {
      expect(calculator.mimeTypeForPath('foto.JPG'), 'image/jpeg');
      expect(calculator.mimeTypeForPath('foto.jpeg'), 'image/jpeg');
      expect(calculator.mimeTypeForPath('foto.png'), 'image/png');
      expect(calculator.mimeTypeForPath('foto.webp'), 'image/webp');
      expect(calculator.mimeTypeForPath('foto.heic'), 'image/heic');
      expect(
        calculator.mimeTypeForPath('arquivo.bin'),
        'application/octet-stream',
      );
    });

    test('constroi object key canonica sem afirmar upload remoto', () {
      final key = calculator.buildObjectKey(
        acaoId: 'rae-001',
        evidenciaId: 'ev-001',
        localFilePath: '/local/foto.JPG',
      );

      expect(key, 'evidencias/rae-001/ev-001.jpg');
    });

    test('rejeita identificadores com separador de caminho', () {
      expect(
        () => calculator.buildObjectKey(
          acaoId: '../rae',
          evidenciaId: 'ev-001',
          localFilePath: '/local/foto.jpg',
        ),
        throwsArgumentError,
      );
    });

    test('rejeita identificadores reservados ponto e ponto-ponto', () {
      for (final reservado in const <String>['.', '..']) {
        expect(
          () => calculator.buildObjectKey(
            acaoId: reservado,
            evidenciaId: 'ev-001',
            localFilePath: '/local/foto.jpg',
          ),
          throwsArgumentError,
        );

        expect(
          () => calculator.buildObjectKey(
            acaoId: 'rae-001',
            evidenciaId: reservado,
            localFilePath: '/local/foto.jpg',
          ),
          throwsArgumentError,
        );
      }
    });
  });

  group('AUD-L2-R5.2-B - EvidenciaStorageService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fenix_storage_r5_2_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('salva local primeiro e devolve metadados de integridade', () async {
      final source = File(
        '${tempDir.path}${Platform.pathSeparator}origem.jpg',
      );
      await source.writeAsString('abc');

      final service = EvidenciaStorageService(
        documentsDirectoryProvider: () async => tempDir,
      );

      final evidencia = await service.salvarEvidencia(
        acaoId: 'rae-001',
        arquivoOrigem: source,
        tipo: 'imagem',
        autorUserId: 'uid-operacional-001',
      );

      expect(File(evidencia.caminhoArquivo).existsSync(), isTrue);
      expect(evidencia.status, EvidenciaStatus.pendente);
      expect(
        evidencia.sha256,
        'ba7816bf8f01cfea414140de5dae2223'
        'b00361a396177a9cb410ff61f20015ad',
      );
      expect(evidencia.tamanhoBytes, 3);
      expect(evidencia.mimeType, 'image/jpeg');
      expect(evidencia.objectKey, isEmpty);
      expect(evidencia.sincronizadoEm, isNull);
      expect(evidencia.autorUserId, 'uid-operacional-001');
    });
  });
}
