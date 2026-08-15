import 'access_scope.dart';
import 'authorization_policy.dart';
import 'permission.dart';
import 'rae_access_record.dart';

/// Política experimental da Etapa 4A.
///
/// Ainda não está conectada às rotas, consultas nem regras produtivas.
class RaeAccessPolicy {
  const RaeAccessPolicy._();

  static bool autoriza({
    required String perfilAcesso,
    required String usuarioId,
    required Permission permissao,
    required RaeAccessRecord rae,
    AccessScope? escopo,
  }) {
    final perfil = AuthorizationPolicy.normalizarPerfil(perfilAcesso);
    final uid = usuarioId.trim();
    if (uid.isEmpty || !AuthorizationPolicy.perfilReconhecido(perfil)) {
      return false;
    }

    if (perfil == 'administrador') return true;

    // Q1 e qualquer registro sem classificação integral ficam disponíveis
    // somente ao Administrador.
    if (!rae.classificacaoCompleta) return false;

    return switch (perfil) {
      'gestor' => _somenteLeitura(permissao),
      'gerente' => _somenteLeitura(permissao) &&
          (escopo?.abrangeGerente(
                regionalId: rae.regionalId,
                equipeId: rae.equipeId,
                projetoId: rae.projetoId,
              ) ??
              false),
      'coordenador' =>
        rae.coordenadorUserId == uid && _acaoDoCoordenador(permissao),
      'agente' => rae.responsavelUserId == uid && _acaoDoAgente(permissao),
      _ => false,
    };
  }

  static bool autorizaCriacao({
    required String perfilAcesso,
    required String usuarioId,
  }) {
    if (usuarioId.trim().isEmpty) return false;
    final perfil = AuthorizationPolicy.normalizarPerfil(perfilAcesso);
    return perfil == 'administrador' ||
        perfil == 'coordenador' ||
        perfil == 'agente';
  }

  static bool _somenteLeitura(Permission permissao) {
    return permissao == Permission.consultarRae ||
        permissao == Permission.compartilharPdfRae ||
        permissao == Permission.acessarCioEscopo;
  }

  static bool _acaoDoCoordenador(Permission permissao) {
    return permissao == Permission.consultarRae ||
        permissao == Permission.editarRae ||
        permissao == Permission.revisarRae ||
        permissao == Permission.finalizarRae ||
        permissao == Permission.compartilharPdfRae ||
        permissao == Permission.acessarCioEscopo;
  }

  static bool _acaoDoAgente(Permission permissao) {
    return permissao == Permission.consultarRae ||
        permissao == Permission.editarRae ||
        permissao == Permission.compartilharPdfRae;
  }
}
