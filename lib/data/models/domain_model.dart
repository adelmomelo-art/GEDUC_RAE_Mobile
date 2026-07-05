class DomainModel {
  final String id;
  final String grupo;
  final String codigo;
  final String nome;
  final String descricao;
  final int ordem;
  final bool ativo;
  final DateTime? inicioVigencia;
  final DateTime? fimVigencia;
  final Map<String, dynamic> metadados;

  const DomainModel({
    required this.id,
    required this.grupo,
    required this.codigo,
    required this.nome,
    this.descricao = '',
    this.ordem = 0,
    this.ativo = true,
    this.inicioVigencia,
    this.fimVigencia,
    this.metadados = const {},
  });

  DomainModel copyWith({
    String? id,
    String? grupo,
    String? codigo,
    String? nome,
    String? descricao,
    int? ordem,
    bool? ativo,
    DateTime? inicioVigencia,
    DateTime? fimVigencia,
    Map<String, dynamic>? metadados,
  }) {
    return DomainModel(
      id: id ?? this.id,
      grupo: grupo ?? this.grupo,
      codigo: codigo ?? this.codigo,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ordem: ordem ?? this.ordem,
      ativo: ativo ?? this.ativo,
      inicioVigencia: inicioVigencia ?? this.inicioVigencia,
      fimVigencia: fimVigencia ?? this.fimVigencia,
      metadados: metadados ?? this.metadados,
    );
  }

  bool get vigente {
    final agora = DateTime.now();

    final iniciou = inicioVigencia == null || !agora.isBefore(inicioVigencia!);
    final naoEncerrou = fimVigencia == null || !agora.isAfter(fimVigencia!);

    return ativo && iniciou && naoEncerrou;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grupo': grupo,
      'codigo': codigo,
      'nome': nome,
      'descricao': descricao,
      'ordem': ordem,
      'ativo': ativo,
      'inicioVigencia': inicioVigencia?.toIso8601String(),
      'fimVigencia': fimVigencia?.toIso8601String(),
      'metadados': metadados,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory DomainModel.fromMap(Map<String, dynamic> map) {
    return DomainModel(
      id: map['id'] ?? '',
      grupo: map['grupo'] ?? '',
      codigo: map['codigo'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      ordem: map['ordem'] ?? 0,
      ativo: map['ativo'] ?? true,
      inicioVigencia: _parseDate(map['inicioVigencia']),
      fimVigencia: _parseDate(map['fimVigencia']),
      metadados: Map<String, dynamic>.from(map['metadados'] ?? {}),
    );
  }

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel.fromMap(json);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    final texto = value.toString();

    if (texto.isEmpty) {
      return null;
    }

    return DateTime.tryParse(texto);
  }
}
