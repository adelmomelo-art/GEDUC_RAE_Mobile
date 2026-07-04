import 'package:flutter/material.dart';

import '../../../data/models/usuario_model.dart';
import '../../../repositories/usuario_repository.dart';

class UsuarioController extends ChangeNotifier {
  final UsuarioRepository usuarioRepository;

  UsuarioController({
    required this.usuarioRepository,
  });

  List<UsuarioModel> usuarios = [];
  bool carregando = false;

  Future<void> carregarUsuarios() async {
    carregando = true;
    notifyListeners();

    usuarios = await usuarioRepository.listarUsuarios();

    carregando = false;
    notifyListeners();
  }
}