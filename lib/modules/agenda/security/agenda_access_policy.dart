import '../../escala/models/escala_models.dart';

abstract final class AgendaAccessPolicy {
  static bool autoriza({
    required String usuarioId,
    required String perfilAcesso,
    required EscalaConfiguracaoModel? configuracao,
  }) =>
      usuarioId.trim().isNotEmpty &&
      perfilAcesso.trim().toLowerCase() == 'agente' &&
      configuracao?.ativo == true &&
      configuracao!.responsavelEscalaUsuarioId.trim() == usuarioId.trim();
}
