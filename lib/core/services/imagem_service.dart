import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagemService {
  final ImagePicker _picker = ImagePicker();

  /// Captura uma imagem utilizando a câmera.
  Future<File?> capturarCamera() async {
    final XFile? imagem = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (imagem == null) {
      return null;
    }

    return File(imagem.path);
  }

  /// Seleciona uma imagem da galeria.
  Future<File?> selecionarGaleria() async {
    final XFile? imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (imagem == null) {
      return null;
    }

    return File(imagem.path);
  }

  /// Seleciona várias imagens da galeria.
  Future<List<File>> selecionarMultiplasImagens() async {
    final List<XFile> imagens = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    return imagens.map((imagem) => File(imagem.path)).toList();
  }

  /// Verifica se o arquivo existe.
  Future<bool> arquivoExiste(File arquivo) async {
    return arquivo.exists();
  }

  /// Obtém o tamanho do arquivo em bytes.
  Future<int> tamanhoArquivo(File arquivo) async {
    return arquivo.length();
  }

  /// Remove uma imagem do armazenamento temporário.
  Future<void> excluirImagem(File arquivo) async {
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}