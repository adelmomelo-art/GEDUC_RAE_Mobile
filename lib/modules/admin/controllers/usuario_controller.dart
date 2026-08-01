import 'package:flutter/foundation.dart';

import '../../../data/models/usuario_model.dart';
import '../../../repositories/usuario_repository.dart';

class UsuarioController extends ChangeNotifier {
  UsuarioController({
    required UsuarioRepository usuarioRepository,
  }) : _usuarioRepository = usuarioRepository;

  final UsuarioRepository _usuarioRepository;

  List<UsuarioModel> _usuarios = const [];
  bool _carregando = false;
  Object? _erro;

  List<UsuarioModel> get usuarios => List.unmodifiable(_usuarios);
  bool get carregando => _carregando;
  Object? get erro => _erro;
  bool get possuiErro => _erro != null;

  Future<void> carregarUsuarios({bool forcar = false}) async {
    if (_carregando) return;
    if (!forcar && _usuarios.isNotEmpty && _erro == null) return;

    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _usuarios = await _usuarioRepository.listarUsuarios();
    } catch (erro) {
      _erro = erro;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> recarregar() => carregarUsuarios(forcar: true);
}
