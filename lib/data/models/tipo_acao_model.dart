class TipoAcaoModel {
  final String id;
  final String nomeAcao;
  final String tipoAcao;
  final int publicoEstimadoPadrao;
  final int publicoMinimoPadrao;
  final List<String> materiaisSugeridos;
  final bool ativo;

  const TipoAcaoModel({required this.id, required this.nomeAcao, required this.tipoAcao, required this.publicoEstimadoPadrao, required this.publicoMinimoPadrao, required this.materiaisSugeridos, required this.ativo});

  factory TipoAcaoModel.fromMap(Map<String, dynamic> map) => TipoAcaoModel(
    id: map['id'] ?? '', nomeAcao: map['nomeAcao'] ?? '', tipoAcao: map['tipoAcao'] ?? '',
    publicoEstimadoPadrao: map['publicoEstimadoPadrao'] ?? 0, publicoMinimoPadrao: map['publicoMinimoPadrao'] ?? 0,
    materiaisSugeridos: List<String>.from(map['materiaisSugeridos'] ?? []), ativo: map['ativo'] ?? true,
  );
  Map<String, dynamic> toMap() => {'id':id,'nomeAcao':nomeAcao,'tipoAcao':tipoAcao,'publicoEstimadoPadrao':publicoEstimadoPadrao,'publicoMinimoPadrao':publicoMinimoPadrao,'materiaisSugeridos':materiaisSugeridos,'ativo':ativo};
}
