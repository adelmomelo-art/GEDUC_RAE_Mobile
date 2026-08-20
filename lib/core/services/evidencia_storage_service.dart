import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/evidencia_model.dart';
import '../storage/evidence_metadata_calculator.dart';

typedef DocumentsDirectoryProvider = Future<Directory> Function();

class EvidenciaStorageService {
  EvidenciaStorageService({
    DocumentsDirectoryProvider? documentsDirectoryProvider,
    EvidenceMetadataCalculator? metadataCalculator,
  })  : _documentsDirectoryProvider =
            documentsDirectoryProvider ?? getApplicationDocumentsDirectory,
        _metadataCalculator =
            metadataCalculator ?? const EvidenceMetadataCalculator();

  static const String _baseFolderName = 'GEDUC';
  static const String _evidenciasFolderName = 'evidencias';

  final DocumentsDirectoryProvider _documentsDirectoryProvider;
  final EvidenceMetadataCalculator _metadataCalculator;

  Future<Directory> _getBaseDirectory() async {
    final Directory appDir = await _documentsDirectoryProvider();

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
    required String autorUserId,
  }) async {
    final autorId = autorUserId.trim();
    if (autorId.isEmpty) {
      throw ArgumentError.value(
        autorUserId,
        'autorUserId',
        'A identidade canonica do autor da evidencia e obrigatoria.',
      );
    }

    final Directory acaoDir = await _getAcaoDirectory(acaoId);

    final String extensao = path.extension(arquivoOrigem.path);
    final String id = DateTime.now().microsecondsSinceEpoch.toString();
    final String nomeArquivo = 'evidencia_$id$extensao';

    final String destinoPath = path.join(acaoDir.path, nomeArquivo);

    final File arquivoSalvo = await arquivoOrigem.copy(destinoPath);
    final metadata = await _metadataCalculator.calculate(arquivoSalvo);

    return EvidenciaModel(
      id: id,
      acaoId: acaoId,
      caminhoArquivo: arquivoSalvo.path,
      tipo: tipo,
      criadoEm: DateTime.now(),
      status: EvidenciaStatus.pendente,
      sha256: metadata.sha256,
      tamanhoBytes: metadata.sizeBytes,
      mimeType: metadata.mimeType,
      objectKey: '',
      sincronizadoEm: null,
      autorUserId: autorId,
    );
  }

  Future<List<EvidenciaModel>> salvarEvidencias({
    required String acaoId,
    required List<File> arquivos,
    required String autorUserId,
    String tipo = 'imagem',
  }) async {
    final List<EvidenciaModel> evidencias = [];

    for (final File arquivo in arquivos) {
      final EvidenciaModel evidencia = await salvarEvidencia(
        acaoId: acaoId,
        arquivoOrigem: arquivo,
        tipo: tipo,
        autorUserId: autorUserId,
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
