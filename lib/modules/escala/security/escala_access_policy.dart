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

    if (permissao == EscalaPermission.consultarHistoricoHorasProprio) {
      return true;
    }

    if (permissao == EscalaPermission.consultarHistoricoHorasGeral) {
      return perfil == 'administrador' ||
          perfil == 'gestor' ||
          perfil == 'gerente';
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
      case EscalaPermission.registrarHorasRealizadas:
        return ehParticipanteAtividade;
      case EscalaPermission.registrarExecucaoMissao:
      case EscalaPermission.anexarEvidenciaMissao:
        return !administrador &&
            (ehParticipanteAtividade || ehCoordenadorAtividade);
      case EscalaPermission.consultarEscalaGeral:
      case EscalaPermission.consultarPropriaEscala:
      case EscalaPermission.consultarHistoricoHorasGeral:
      case EscalaPermission.consultarHistoricoHorasProprio:
        return true;
    }
  }
}
