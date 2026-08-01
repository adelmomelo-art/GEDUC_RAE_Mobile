import '../security/authorization_service.dart';
import '../security/permission.dart';

class RouteGuard {
  RouteGuard._();

  static Future<String?> proteger({
    required Permission permissao,
    required String loginPath,
    required String acessoNegadoPath,
  }) async {
    final authorizationService = AuthorizationService.instance;

    if (!authorizationService.autenticado) {
      return loginPath;
    }

    final resultado = await authorizationService.avaliarAtualizando(permissao);
    return resultado.autorizado ? null : acessoNegadoPath;
  }
}
