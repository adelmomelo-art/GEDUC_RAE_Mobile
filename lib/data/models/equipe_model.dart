class EquipeModel {
  const EquipeModel({
    required this.id,
    required this.nome,
    this.codigo = '',
    this.regionalIds = const <String>[],
    this.membroIds = const <String>[],
    this.coordenadorUserIds = const <String>[],
    this.ativo = true,
  });

  final String id;
  final String nome;
  final String codigo;
  final List<String> regionalIds;
  final List<String> membroIds;
  final List<String> coordenadorUserIds;
  final bool ativo;

  bool get valido => id.trim().isNotEmpty && nome.trim().isNotEmpty;

  factory EquipeModel.fromMap(String id, Map<String, dynamic> map) {
    return EquipeModel(
      id: id,
      nome: map['nome']?.toString().trim() ?? '',
      codigo: map['codigo']?.toString().trim() ?? '',
      regionalIds: _lista(map['regionalIds']),
      membroIds: _lista(map['membroIds']),
      coordenadorUserIds: _lista(map['coordenadorUserIds']),
      ativo: map['ativo'] != false,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'nome': nome.trim(),
        'codigo': codigo.trim(),
        'regionalIds': regionalIds,
        'membroIds': membroIds,
        'coordenadorUserIds': coordenadorUserIds,
        'ativo': ativo,
      };

  static List<String> _lista(Object? valor) {
    if (valor is! Iterable) return const <String>[];
    return valor
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }
}
