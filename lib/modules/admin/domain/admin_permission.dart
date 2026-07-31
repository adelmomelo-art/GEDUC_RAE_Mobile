enum AdminPermission {
  acessarAdministracao,
  gerenciarDominios,
  gerenciarUsuarios,
  gerenciarTiposAcoes,
  gerenciarCoordenadores,
  gerenciarRegionais,
  gerenciarMateriais;
}

class AdminPermissionPolicy {
  AdminPermissionPolicy._();

  static bool possuiPermissao({
    required String perfilAcesso,
    required AdminPermission permissao,
  }) {
    final perfil = perfilAcesso.trim().toLowerCase();

    // Fundação inicial. A fonte oficial do perfil e a proteção de rota serão
    // consolidadas em pacote próprio de autorização administrativa.
    if (perfil == 'administrador') {
      return true;
    }

    if (perfil == 'gestor') {
      return permissao == AdminPermission.acessarAdministracao;
    }

    return false;
  }
}
