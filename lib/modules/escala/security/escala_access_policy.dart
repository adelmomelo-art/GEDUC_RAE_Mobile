import '../../../core/security/authorization_policy.dart';
import 'escala_permission.dart';

class EscalaAccessPolicy {
  const EscalaAccessPolicy._();

  static const Set<String> _perfisEscala = {
    'administrador',
    'gestor',
    'gerente',
    'coordenador',
    'agente',
  };

  static bool autoriza({
    required String? perfilAcesso,
    required String usuarioId,
    required String responsavelEscalaUsuarioId,
    required EscalaPermission permissao,
    bool ehParticipanteAtividade = false,
    bool ehCoordenadorAtividade = false,
  }) {
    final perfil = AuthorizationPolicy.normalizarPerfil(perfilAcesso);
    final uid = usuarioId.trim();
    final responsavelUid = responsavelEscalaUsuarioId.trim();

    if (uid.isEmpty || !_perfisEscala.contains(perfil)) return false;

    if (permissao == EscalaPermission.consultarEscalaGeral ||
        permissao == EscalaPermission.consultarPropriaEscala) {
      return true;
    }

    final administrador = perfil == 'administrador';
    final gerente = perfil == 'gerente';
    final agenteResponsavel = perfil == 'agente' &&
        responsavelUid.isNotEmpty &&
        uid == responsavelUid;

    switch (permissao) {
      case EscalaPermission.criarEscala:
        return agenteResponsavel;
      case EscalaPermission.editarEscala:
      case EscalaPermission.revisarEscala:
      case EscalaPermission.publicarEscala:
        return gerente || agenteResponsavel;
      case EscalaPermission.designarResponsavelEscala:
        return administrador || gerente;
      case EscalaPermission.registrarExecucaoMissao:
      case EscalaPermission.anexarEvidenciaMissao:
        return ehParticipanteAtividade || ehCoordenadorAtividade;
      case EscalaPermission.consultarEscalaGeral:
      case EscalaPermission.consultarPropriaEscala:
        return true;
    }
  }
}
