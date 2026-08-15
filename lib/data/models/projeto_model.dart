class ProjetoModel {
  const ProjetoModel({
    required this.id,
    required this.nome,
    this.codigo = '',
    this.regionalIds = const <String>[],
    this.equipeIds = const <String>[],
    this.ativo = true,
  });

  final String id;
  final String nome;
  final String codigo;
  final List<String> regionalIds;
  final List<String> equipeIds;
  final bool ativo;

  bool get valido => id.trim().isNotEmpty && nome.trim().isNotEmpty;

  factory ProjetoModel.fromMap(String id, Map<String, dynamic> map) {
    return ProjetoModel(
      id: id,
      nome: map['nome']?.toString().trim() ?? '',
      codigo: map['codigo']?.toString().trim() ?? '',
      regionalIds: _lista(map['regionalIds']),
      equipeIds: _lista(map['equipeIds']),
      ativo: map['ativo'] != false,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'nome': nome.trim(),
        'codigo': codigo.trim(),
        'regionalIds': regionalIds,
        'equipeIds': equipeIds,
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
