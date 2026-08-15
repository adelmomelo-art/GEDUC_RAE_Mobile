class RaeAccessRecord {
  const RaeAccessRecord({
    required this.responsavelUserId,
    required this.coordenadorUserId,
    required this.regionalId,
    required this.equipeId,
    required this.projetoId,
  });

  final String responsavelUserId;
  final String coordenadorUserId;
  final String regionalId;
  final String equipeId;
  final String projetoId;

  bool get classificacaoCompleta =>
      responsavelUserId.trim().isNotEmpty &&
      coordenadorUserId.trim().isNotEmpty &&
      regionalId.trim().isNotEmpty &&
      equipeId.trim().isNotEmpty &&
      projetoId.trim().isNotEmpty;
}
