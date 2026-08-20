import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/evidencia_storage_service.dart';

void main() {
  group('EvidenciaStorageService author identity', () {
    late Directory temp;
    late EvidenciaStorageService service;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('fenix_identity_');
      service =
          EvidenciaStorageService(documentsDirectoryProvider: () async => temp);
    });
    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    test('persiste autor canonico normalizado', () async {
      final f = File('${temp.path}/foto.jpg');
      await f.writeAsBytes([1, 2, 3, 4]);
      final e = await service.salvarEvidencia(
        acaoId: 'rae-1',
        arquivoOrigem: f,
        tipo: 'imagem',
        autorUserId: '  uid-001  ',
      );
      expect(e.autorUserId, 'uid-001');
      expect(e.sha256, isNotEmpty);
      expect(e.tamanhoBytes, 4);
    });

    test('rejeita autor vazio', () async {
      final f = File('${temp.path}/foto.jpg');
      await f.writeAsBytes([1]);
      expect(
        () => service.salvarEvidencia(
          acaoId: 'rae-2',
          arquivoOrigem: f,
          tipo: 'imagem',
          autorUserId: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('propaga autor no lote', () async {
      final a = File('${temp.path}/a.jpg');
      final b = File('${temp.path}/b.png');
      await a.writeAsBytes([1]);
      await b.writeAsBytes([2]);
      final itens = await service.salvarEvidencias(
        acaoId: 'rae-3',
        arquivos: [a, b],
        autorUserId: 'uid-003',
      );
      expect(itens.map((e) => e.autorUserId).toSet(), {'uid-003'});
    });
  });
}
