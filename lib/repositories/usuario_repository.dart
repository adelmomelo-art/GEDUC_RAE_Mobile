import '../core/services/usuario_service.dart';
import '../core/security/access_scope.dart';
import '../core/security/scope_catalogs.dart';
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

  Future<ScopeCatalogs> carregarCatalogosEscopo() {
    return usuarioService.carregarCatalogosEscopo();
  }

  Future<void> atualizarEscopo({
    required String usuarioId,
    required AccessScope escopo,
    required String atualizadoPor,
  }) {
    return usuarioService.atualizarEscopo(
      usuarioId: usuarioId,
      escopo: escopo,
      atualizadoPor: atualizadoPor,
    );
  }
}
