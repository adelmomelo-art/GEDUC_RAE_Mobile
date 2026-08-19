class RaeAclClassification {
  const RaeAclClassification({
    required this.regionalId,
    required this.responsavelUserId,
    required this.coordenadorUserId,
    required this.equipeId,
    required this.projetoId,
    required this.completa,
    required this.aclScopeKey,
  });

  final String regionalId;
  final String responsavelUserId;
  final String coordenadorUserId;
  final String equipeId;
  final String projetoId;
  final bool completa;
  final String aclScopeKey;

  bool get aclClassificacaoCompleta => completa;
}

class RaeAclClassifier {
  const RaeAclClassifier._();

  static RaeAclClassification classify({
    required String regionalId,
    required String responsavelUserId,
    required String coordenadorUserId,
    required String equipeId,
    required String projetoId,
  }) {
    return classificar(
      regionalId: regionalId,
      responsavelUserId: responsavelUserId,
      coordenadorUserId: coordenadorUserId,
      equipeId: equipeId,
      projetoId: projetoId,
    );
  }

  static RaeAclClassification classificar({
    required String regionalId,
    required String responsavelUserId,
    required String coordenadorUserId,
    required String equipeId,
    required String projetoId,
  }) {
    final regional = regionalId.trim();
    final responsavel = responsavelUserId.trim();
    final coordenador = coordenadorUserId.trim();
    final equipe = equipeId.trim();
    final projeto = projetoId.trim();

    final completa = regional.isNotEmpty &&
        responsavel.isNotEmpty &&
        coordenador.isNotEmpty &&
        equipe.isNotEmpty &&
        projeto.isNotEmpty;

    return RaeAclClassification(
      regionalId: regional,
      responsavelUserId: responsavel,
      coordenadorUserId: coordenador,
      equipeId: equipe,
      projetoId: projeto,
      completa: completa,
      aclScopeKey: completa ? 'r:$regional|e:$equipe|p:$projeto' : '',
    );
  }
}
