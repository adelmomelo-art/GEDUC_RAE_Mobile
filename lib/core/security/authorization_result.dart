import 'permission.dart';

class AuthorizationResult {
  final bool autorizado;
  final Permission permissao;
  final String perfilAcesso;
  final String motivo;

  const AuthorizationResult._({
    required this.autorizado,
    required this.permissao,
    required this.perfilAcesso,
    required this.motivo,
  });

  const AuthorizationResult.autorizado({
    required Permission permissao,
    required String perfilAcesso,
  }) : this._(
          autorizado: true,
          permissao: permissao,
          perfilAcesso: perfilAcesso,
          motivo: 'Acesso autorizado.',
        );

  const AuthorizationResult.negado({
    required Permission permissao,
    required String perfilAcesso,
    required String motivo,
  }) : this._(
          autorizado: false,
          permissao: permissao,
          perfilAcesso: perfilAcesso,
          motivo: motivo,
        );
}
