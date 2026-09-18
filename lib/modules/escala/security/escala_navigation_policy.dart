import 'escala_access_policy.dart';
import 'escala_permission.dart';

abstract final class EscalaNavigationPolicy {
  static bool podeConsultar({
    required String? perfilAcesso,
    required String usuarioId,
  }) {
    return EscalaAccessPolicy.autoriza(
      perfilAcesso: perfilAcesso,
      usuarioId: usuarioId,
      responsavelEscalaUsuarioId: '',
      permissao: EscalaPermission.consultarEscalaGeral,
    );
  }

  static bool podeGerenciar({
    required String? perfilAcesso,
    required String usuarioId,
    required String responsavelEscalaUsuarioId,
  }) {
    return EscalaAccessPolicy.autoriza(
      perfilAcesso: perfilAcesso,
      usuarioId: usuarioId,
      responsavelEscalaUsuarioId: responsavelEscalaUsuarioId,
      permissao: EscalaPermission.editarEscala,
    );
  }

  static bool podeConfigurar({
    required String? perfilAcesso,
    required String usuarioId,
  }) {
    return EscalaAccessPolicy.autoriza(
      perfilAcesso: perfilAcesso,
      usuarioId: usuarioId,
      responsavelEscalaUsuarioId: '',
      permissao: EscalaPermission.designarResponsavelEscala,
    );
  }
}
