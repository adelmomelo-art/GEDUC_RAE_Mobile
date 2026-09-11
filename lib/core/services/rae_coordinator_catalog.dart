import '../../data/models/membro_equipe_model.dart';

class RaeCoordinatorOption {
  const RaeCoordinatorOption({
    required this.membroId,
    required this.usuarioId,
    required this.nome,
  });

  final String membroId;
  final String usuarioId;
  final String nome;
}

class RaeCoordinatorCatalog {
  const RaeCoordinatorCatalog._();

  static List<RaeCoordinatorOption> fromMembers(
    Iterable<MembroEquipeModel> membros,
  ) {
    final porUsuarioId = <String, RaeCoordinatorOption>{};

    for (final membro in membros) {
      final usuarioId = membro.usuarioId.trim();
      final nome = membro.nome.trim();

      if (!membro.ativo ||
          !membro.podeCoordenar ||
          usuarioId.isEmpty ||
          nome.isEmpty) {
        continue;
      }

      porUsuarioId.putIfAbsent(
        usuarioId,
        () => RaeCoordinatorOption(
          membroId: membro.id.trim(),
          usuarioId: usuarioId,
          nome: nome,
        ),
      );
    }

    final resultado = porUsuarioId.values.toList(growable: false)
      ..sort((a, b) {
        final porNome = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());

        if (porNome != 0) {
          return porNome;
        }

        return a.usuarioId.compareTo(b.usuarioId);
      });

    return List<RaeCoordinatorOption>.unmodifiable(resultado);
  }

  static RaeCoordinatorOption? resolveExisting({
    required String coordenadorId,
    required Iterable<RaeCoordinatorOption> coordenadores,
  }) {
    final identidade = coordenadorId.trim();

    if (identidade.isEmpty) {
      return null;
    }

    for (final coordenador in coordenadores) {
      if (coordenador.usuarioId == identidade ||
          coordenador.membroId == identidade) {
        return coordenador;
      }
    }

    return null;
  }
}
