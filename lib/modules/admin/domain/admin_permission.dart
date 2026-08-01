import '../../../core/security/authorization_policy.dart';
import '../../../core/security/permission.dart';

@Deprecated('Use Permission em lib/core/security/permission.dart.')
typedef AdminPermission = Permission;

@Deprecated('Use AuthorizationService e AuthorizationPolicy.')
class AdminPermissionPolicy {
  AdminPermissionPolicy._();

  static bool possuiPermissao({
    required String perfilAcesso,
    required Permission permissao,
  }) {
    return AuthorizationPolicy.possuiPermissao(
      perfilAcesso: perfilAcesso,
      permissao: permissao,
    );
  }
}
