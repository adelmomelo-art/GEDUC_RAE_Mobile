import 'permission.dart';

class AuthorizationPolicy {
  AuthorizationPolicy._();

  static const Map<String, Set<Permission>> _permissoesPorPerfil = {
    'administrador': {
      Permission.acessarAdministracao,
      Permission.gerenciarDominios,
      Permission.gerenciarUsuarios,
      Permission.gerenciarTiposAcoes,
      Permission.gerenciarCoordenadores,
      Permission.gerenciarRegionais,
      Permission.gerenciarMateriais,
    },
    'gestor': {
      Permission.acessarAdministracao,
      Permission.gerenciarDominios,
      Permission.gerenciarUsuarios,
      Permission.gerenciarTiposAcoes,
    },
    'coordenador': <Permission>{},
    'agente': <Permission>{},
  };

  static String normalizarPerfil(String? perfilAcesso) {
    final perfil = perfilAcesso?.trim().toLowerCase() ?? '';
    return perfil.isEmpty ? 'nao-identificado' : perfil;
  }

  static bool possuiPermissao({
    required String? perfilAcesso,
    required Permission permissao,
  }) {
    final perfil = normalizarPerfil(perfilAcesso);
    return _permissoesPorPerfil[perfil]?.contains(permissao) ?? false;
  }
}
