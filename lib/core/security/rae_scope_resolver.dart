import '../../data/models/equipe_model.dart';
import '../../data/models/projeto_model.dart';

enum RaeScopeResolutionStatus {
  resolvido,
  naoResolvido,
  ambiguo,
}

class RaeScopeResolution {
  const RaeScopeResolution({
    required this.status,
    required this.equipeId,
    required this.projetoId,
    required this.equipesCandidatas,
    required this.projetosCandidatos,
  });

  final RaeScopeResolutionStatus status;

  final String equipeId;
  final String projetoId;

  final List<String> equipesCandidatas;
  final List<String> projetosCandidatos;

  bool get resolvido => status == RaeScopeResolutionStatus.resolvido;

  bool get ambiguo => status == RaeScopeResolutionStatus.ambiguo;

  bool get naoResolvido => status == RaeScopeResolutionStatus.naoResolvido;
}

class RaeScopeResolver {
  const RaeScopeResolver._();

  static RaeScopeResolution resolve({
    required String regionalId,
    required String coordenadorUserId,
    required Iterable<String> equipeIdsPermitidas,
    required Iterable<String> projetoIdsPermitidos,
    required List<EquipeModel> equipes,
    required List<ProjetoModel> projetos,
  }) {
    final regional = regionalId.trim();
    final coordenador = coordenadorUserId.trim();

    final equipesPermitidas = _normalizarIds(
      equipeIdsPermitidas,
    );

    final projetosPermitidos = _normalizarIds(
      projetoIdsPermitidos,
    );

    if (regional.isEmpty || coordenador.isEmpty || equipesPermitidas.isEmpty) {
      return const RaeScopeResolution(
        status: RaeScopeResolutionStatus.naoResolvido,
        equipeId: '',
        projetoId: '',
        equipesCandidatas: <String>[],
        projetosCandidatos: <String>[],
      );
    }

    final equipesCandidatas = equipes.where((equipe) {
      final equipeId = equipe.id.trim();

      if (!equipe.ativo || !equipe.valido) {
        return false;
      }

      if (!equipesPermitidas.contains(equipeId)) {
        return false;
      }

      final atendeRegional =
          equipe.regionalIds.map((item) => item.trim()).contains(regional);

      final coordenadorPertence = equipe.coordenadorUserIds
          .map((item) => item.trim())
          .contains(coordenador);

      return atendeRegional && coordenadorPertence;
    }).toList(growable: false);

    if (equipesCandidatas.isEmpty) {
      return const RaeScopeResolution(
        status: RaeScopeResolutionStatus.naoResolvido,
        equipeId: '',
        projetoId: '',
        equipesCandidatas: <String>[],
        projetosCandidatos: <String>[],
      );
    }

    if (equipesCandidatas.length > 1) {
      return RaeScopeResolution(
        status: RaeScopeResolutionStatus.ambiguo,
        equipeId: '',
        projetoId: '',
        equipesCandidatas: equipesCandidatas
            .map((equipe) => equipe.id.trim())
            .toList(growable: false),
        projetosCandidatos: const <String>[],
      );
    }

    final equipeResolvida = equipesCandidatas.single;
    final equipeId = equipeResolvida.id.trim();

    if (projetosPermitidos.isEmpty) {
      return RaeScopeResolution(
        status: RaeScopeResolutionStatus.naoResolvido,
        equipeId: equipeId,
        projetoId: '',
        equipesCandidatas: <String>[equipeId],
        projetosCandidatos: const <String>[],
      );
    }

    final projetosCandidatos = projetos.where((projeto) {
      final projetoId = projeto.id.trim();

      if (!projeto.ativo || !projeto.valido) {
        return false;
      }

      if (!projetosPermitidos.contains(projetoId)) {
        return false;
      }

      final atendeRegional =
          projeto.regionalIds.map((item) => item.trim()).contains(regional);

      final atendeEquipe =
          projeto.equipeIds.map((item) => item.trim()).contains(equipeId);

      return atendeRegional && atendeEquipe;
    }).toList(growable: false);

    if (projetosCandidatos.isEmpty) {
      return RaeScopeResolution(
        status: RaeScopeResolutionStatus.naoResolvido,
        equipeId: equipeId,
        projetoId: '',
        equipesCandidatas: <String>[equipeId],
        projetosCandidatos: const <String>[],
      );
    }

    if (projetosCandidatos.length > 1) {
      return RaeScopeResolution(
        status: RaeScopeResolutionStatus.ambiguo,
        equipeId: equipeId,
        projetoId: '',
        equipesCandidatas: <String>[equipeId],
        projetosCandidatos: projetosCandidatos
            .map((projeto) => projeto.id.trim())
            .toList(growable: false),
      );
    }

    final projetoId = projetosCandidatos.single.id.trim();

    return RaeScopeResolution(
      status: RaeScopeResolutionStatus.resolvido,
      equipeId: equipeId,
      projetoId: projetoId,
      equipesCandidatas: <String>[equipeId],
      projetosCandidatos: <String>[projetoId],
    );
  }

  static Set<String> _normalizarIds(
    Iterable<String> ids,
  ) {
    return ids
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }
}
