import '../core/services/usuario_service.dart';
import '../data/models/usuario_model.dart';

class UsuarioRepository {
  final UsuarioService usuarioService;

  UsuarioRepository({
    required this.usuarioService,
  });

  Future<List<UsuarioModel>> listarUsuarios() async {
    return usuarioService.listarUsuarios();
  }

  Future<UsuarioModel?> buscarUsuario(String uid) async {
    return usuarioService.buscarUsuario(uid);
  }
}