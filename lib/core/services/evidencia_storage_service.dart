import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/evidencia_model.dart';

class EvidenciaStorageService {
  static const String _baseFolderName = 'GEDUC';
  static const String _evidenciasFolderName = 'evidencias';

  Future<Directory> _getBaseDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();

    final Directory baseDir = Directory(
      path.join(appDir.path, _baseFolderName, _evidenciasFolderName),
    );

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    return baseDir;
  }

  Future<Directory> _getAcaoDirectory(String acaoId) async {
    final Directory baseDir = await _getBaseDirectory();

    final Directory acaoDir = Directory(
      path.join(baseDir.path, acaoId),
    );

    if (!await acaoDir.exists()) {
      await acaoDir.create(recursive: true);
    }

    return acaoDir;
  }

  Future<EvidenciaModel> salvarEvidencia({
    required String acaoId,
    required File arquivoOrigem,
    required String tipo,
  }) async {
    final Directory acaoDir = await _getAcaoDirectory(acaoId);

    final String extensao = path.extension(arquivoOrigem.path);
    final String id = DateTime.now().microsecondsSinceEpoch.toString();
    final String nomeArquivo = 'evidencia_$id$extensao';

    final String destinoPath = path.join(acaoDir.path, nomeArquivo);

    final File arquivoSalvo = await arquivoOrigem.copy(destinoPath);

    return EvidenciaModel(
      id: id,
      acaoId: acaoId,
      caminhoArquivo: arquivoSalvo.path,
      tipo: tipo,
      criadoEm: DateTime.now(),
      status: EvidenciaStatus.pendente,
    );
  }

  Future<List<EvidenciaModel>> salvarEvidencias({
    required String acaoId,
    required List<File> arquivos,
    String tipo = 'imagem',
  }) async {
    final List<EvidenciaModel> evidencias = [];

    for (final File arquivo in arquivos) {
      final EvidenciaModel evidencia = await salvarEvidencia(
        acaoId: acaoId,
        arquivoOrigem: arquivo,
        tipo: tipo,
      );

      evidencias.add(evidencia);
    }

    return evidencias;
  }

  Future<List<File>> listarArquivosDaAcao(String acaoId) async {
    final Directory acaoDir = await _getAcaoDirectory(acaoId);

    final List<FileSystemEntity> entidades = await acaoDir.list().toList();

    return entidades.whereType<File>().toList();
  }

  Future<bool> excluirArquivo(String caminhoArquivo) async {
    final File arquivo = File(caminhoArquivo);

    if (await arquivo.exists()) {
      await arquivo.delete();
      return true;
    }

    return false;
  }

  Future<bool> excluirTodasEvidenciasDaAcao(String acaoId) async {
    final Directory acaoDir = await _getAcaoDirectory(acaoId);

    if (await acaoDir.exists()) {
      await acaoDir.delete(recursive: true);
      return true;
    }

    return false;
  }
}