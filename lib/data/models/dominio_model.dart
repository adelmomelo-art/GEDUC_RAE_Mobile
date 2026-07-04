class DominioModel {
  final String id;
  final String tipo;
  final String nome;
  final String descricao;
  final bool ativo;
  final int ordem;

  const DominioModel({
    required this.id,
    required this.tipo,
    required this.nome,
    this.descricao = '',
    this.ativo = true,
    this.ordem = 0,
  });

  DominioModel copyWith({
    String? id,
    String? tipo,
    String? nome,
    String? descricao,
    bool? ativo,
    int? ordem,
  }) {
    return DominioModel(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ativo: ativo ?? this.ativo,
      ordem: ordem ?? this.ordem,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'ordem': ordem,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory DominioModel.fromMap(Map<String, dynamic> map) {
    return DominioModel(
      id: map['id'] ?? '',
      tipo: map['tipo'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      ativo: map['ativo'] ?? true,
      ordem: map['ordem'] ?? 0,
    );
  }

  factory DominioModel.fromJson(Map<String, dynamic> json) {
    return DominioModel.fromMap(json);
  }
}