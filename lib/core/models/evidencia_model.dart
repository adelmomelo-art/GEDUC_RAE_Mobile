enum EvidenciaStatus {
  pendente,
  sincronizada,
  erro,
}

class EvidenciaModel {
  final String id;
  final String acaoId;
  final String caminhoArquivo;
  final String tipo;
  final DateTime criadoEm;
  final EvidenciaStatus status;

  // Compatibilidade com telas/services que usam evidencia.path
  String get path => caminhoArquivo;

  EvidenciaModel({
    required this.id,
    required this.acaoId,
    required this.caminhoArquivo,
    required this.tipo,
    required this.criadoEm,
    this.status = EvidenciaStatus.pendente,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'acaoId': acaoId,
      'caminhoArquivo': caminhoArquivo,
      'tipo': tipo,
      'criadoEm': criadoEm.toIso8601String(),
      'status': status.name,
    };
  }

  factory EvidenciaModel.fromMap(Map<String, dynamic> map) {
    return EvidenciaModel(
      id: map['id'] as String,
      acaoId: map['acaoId'] as String,
      caminhoArquivo: map['caminhoArquivo'] as String,
      tipo: map['tipo'] as String,
      criadoEm: DateTime.parse(map['criadoEm'] as String),
      status: EvidenciaStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EvidenciaStatus.pendente,
      ),
    );
  }

  EvidenciaModel copyWith({
    String? id,
    String? acaoId,
    String? caminhoArquivo,
    String? tipo,
    DateTime? criadoEm,
    EvidenciaStatus? status,
  }) {
    return EvidenciaModel(
      id: id ?? this.id,
      acaoId: acaoId ?? this.acaoId,
      caminhoArquivo: caminhoArquivo ?? this.caminhoArquivo,
      tipo: tipo ?? this.tipo,
      criadoEm: criadoEm ?? this.criadoEm,
      status: status ?? this.status,
    );
  }
}