import 'permission.dart';

class AuthorizationPolicy {
  AuthorizationPolicy._();

  static const Map<String, Set<Permission>> _permissoesPorPerfil = {
    'administrador': {
      Permission.criarRae,
      Permission.editarRae,
      Permission.consultarRae,
      Permission.revisarRae,
      Permission.finalizarRae,
      Permission.compartilharPdfRae,
      Permission.acessarCioEscopo,
      Permission.acessarCioExecutivo,
      Permission.acessarAdministracao,
      Permission.gerenciarDominios,
      Permission.gerenciarUsuarios,
      Permission.gerenciarTiposAcoes,
      Permission.gerenciarCoordenadores,
      Permission.gerenciarRegionais,
      Permission.gerenciarMateriais,
    },
    'gestor': {
      Permission.consultarRae,
      Permission.compartilharPdfRae,
      Permission.acessarCioEscopo,
      Permission.acessarCioExecutivo,
      Permission.acessarAdministracao,
      Permission.gerenciarDominios,
      Permission.gerenciarTiposAcoes,
    },
    'gerente': {
      Permission.consultarRae,
      Permission.compartilharPdfRae,
      Permission.acessarCioEscopo,
    },
    'coordenador': {
      Permission.criarRae,
      Permission.editarRae,
      Permission.consultarRae,
      Permission.revisarRae,
      Permission.finalizarRae,
      Permission.compartilharPdfRae,
      Permission.acessarCioEscopo,
      Permission.acessarCioExecutivo,
    },
    'agente': {
      Permission.criarRae,
      Permission.editarRae,
      Permission.consultarRae,
      Permission.compartilharPdfRae,
    },
  };

  static String normalizarPerfil(String? perfilAcesso) {
    final perfil = perfilAcesso?.trim().toLowerCase() ?? '';
    return perfil.isEmpty ? 'nao-identificado' : perfil;
  }

  static bool perfilReconhecido(String? perfilAcesso) {
    final perfil = normalizarPerfil(perfilAcesso);
    return _permissoesPorPerfil.containsKey(perfil);
  }

  static bool possuiPermissao({
    required String? perfilAcesso,
    required Permission permissao,
  }) {
    final perfil = normalizarPerfil(perfilAcesso);
    return _permissoesPorPerfil[perfil]?.contains(permissao) ?? false;
  }

  static bool exigeEscopoCompletoDoGerente(Permission permissao) {
    return permissao == Permission.consultarRae ||
        permissao == Permission.compartilharPdfRae ||
        permissao == Permission.acessarCioEscopo;
  }
}
