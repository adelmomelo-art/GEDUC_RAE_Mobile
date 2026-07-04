import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ThumbnailService {
  static const String _diretorio = 'thumbnails';

  Future<Directory> _obterDiretorio() async {
    final base = await getApplicationDocumentsDirectory();

    final pasta = Directory(
      path.join(base.path, _diretorio),
    );

    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }

    return pasta;
  }

  Future<File> salvarThumbnail({
    required File imagemOriginal,
  }) async {
    final pasta = await _obterDiretorio();

    final nome = path.basename(imagemOriginal.path);

    final destino = File(
      path.join(pasta.path, nome),
    );

    return imagemOriginal.copy(destino.path);
  }

  Future<File?> obterThumbnail(String nomeArquivo) async {
    final pasta = await _obterDiretorio();

    final arquivo = File(
      path.join(pasta.path, nomeArquivo),
    );

    if (await arquivo.exists()) {
      return arquivo;
    }

    return null;
  }

  Future<List<File>> listarThumbnails() async {
    final pasta = await _obterDiretorio();

    return pasta
        .listSync()
        .whereType<File>()
        .toList()
      ..sort(
        (a, b) => a.path.compareTo(b.path),
      );
  }

  Future<void> excluirThumbnail(String nomeArquivo) async {
    final thumb = await obterThumbnail(nomeArquivo);

    if (thumb != null) {
      await thumb.delete();
    }
  }

  Future<void> limparCache() async {
    final pasta = await _obterDiretorio();

    if (await pasta.exists()) {
      await pasta.delete(recursive: true);
      await pasta.create(recursive: true);
    }
  }
}