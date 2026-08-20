import '../../data/models/membro_equipe_model.dart';

class RaeIdentityResolution {
  const RaeIdentityResolution({
    required this.responsavelUserId,
    required this.coordenadorUserId,
  });

  final String responsavelUserId;
  final String coordenadorUserId;

  bool get completa =>
      responsavelUserId.isNotEmpty && coordenadorUserId.isNotEmpty;
}

class RaeIdentityResolver {
  const RaeIdentityResolver._();

  static RaeIdentityResolution resolve({
    required String responsavelUserId,
    required String coordenadorId,
    required List<MembroEquipeModel> membros,
  }) {
    final responsavelNormalizado = responsavelUserId.trim();
    final coordenadorIdNormalizado = coordenadorId.trim();

    if (responsavelNormalizado.isEmpty || coordenadorIdNormalizado.isEmpty) {
      return RaeIdentityResolution(
        responsavelUserId: responsavelNormalizado,
        coordenadorUserId: '',
      );
    }

    final coordenador = _resolverCoordenadorCanonico(
      coordenadorId: coordenadorIdNormalizado,
      membros: membros,
    );

    return RaeIdentityResolution(
      responsavelUserId: responsavelNormalizado,
      coordenadorUserId: coordenador?.usuarioId.trim() ?? '',
    );
  }

  static MembroEquipeModel? _resolverCoordenadorCanonico({
    required String coordenadorId,
    required List<MembroEquipeModel> membros,
  }) {
    for (final membro in membros) {
      final membroId = membro.id.trim();
      final usuarioId = membro.usuarioId.trim();

      if (membroId == coordenadorId || usuarioId == coordenadorId) {
        return membro;
      }
    }

    return null;
  }
}
