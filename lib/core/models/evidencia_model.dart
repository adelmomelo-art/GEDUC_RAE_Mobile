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

  final String sha256;
  final int tamanhoBytes;
  final String mimeType;
  final String objectKey;
  final DateTime? sincronizadoEm;
  final String autorUserId;

  String get path => caminhoArquivo;

  EvidenciaModel({
    required this.id,
    required this.acaoId,
    required this.caminhoArquivo,
    required this.tipo,
    required this.criadoEm,
    this.status = EvidenciaStatus.pendente,
    this.sha256 = '',
    this.tamanhoBytes = 0,
    this.mimeType = '',
    this.objectKey = '',
    this.sincronizadoEm,
    this.autorUserId = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'acaoId': acaoId,
      'caminhoArquivo': caminhoArquivo,
      'tipo': tipo,
      'criadoEm': criadoEm.toIso8601String(),
      'status': status.name,
      'sha256': sha256,
      'tamanhoBytes': tamanhoBytes,
      'mimeType': mimeType,
      'objectKey': objectKey,
      'sincronizadoEm': sincronizadoEm?.toIso8601String(),
      'autorUserId': autorUserId,
    };
  }

  factory EvidenciaModel.fromMap(Map<String, dynamic> map) {
    final statusPersistido = map['status']?.toString();
    final sincronizadoEmPersistido = map['sincronizadoEm']?.toString();

    return EvidenciaModel(
      id: map['id'] as String,
      acaoId: map['acaoId'] as String,
      caminhoArquivo: map['caminhoArquivo'] as String,
      tipo: map['tipo'] as String,
      criadoEm: DateTime.parse(map['criadoEm'] as String),
      status: EvidenciaStatus.values.firstWhere(
        (e) => e.name == statusPersistido,
        orElse: () => EvidenciaStatus.pendente,
      ),
      sha256: map['sha256']?.toString() ?? '',
      tamanhoBytes: (map['tamanhoBytes'] as num?)?.toInt() ?? 0,
      mimeType: map['mimeType']?.toString() ?? '',
      objectKey: map['objectKey']?.toString() ?? '',
      sincronizadoEm: sincronizadoEmPersistido == null ||
              sincronizadoEmPersistido.trim().isEmpty
          ? null
          : DateTime.tryParse(sincronizadoEmPersistido),
      autorUserId: map['autorUserId']?.toString() ?? '',
    );
  }

  EvidenciaModel copyWith({
    String? id,
    String? acaoId,
    String? caminhoArquivo,
    String? tipo,
    DateTime? criadoEm,
    EvidenciaStatus? status,
    String? sha256,
    int? tamanhoBytes,
    String? mimeType,
    String? objectKey,
    DateTime? sincronizadoEm,
    bool limparSincronizadoEm = false,
    String? autorUserId,
  }) {
    return EvidenciaModel(
      id: id ?? this.id,
      acaoId: acaoId ?? this.acaoId,
      caminhoArquivo: caminhoArquivo ?? this.caminhoArquivo,
      tipo: tipo ?? this.tipo,
      criadoEm: criadoEm ?? this.criadoEm,
      status: status ?? this.status,
      sha256: sha256 ?? this.sha256,
      tamanhoBytes: tamanhoBytes ?? this.tamanhoBytes,
      mimeType: mimeType ?? this.mimeType,
      objectKey: objectKey ?? this.objectKey,
      sincronizadoEm:
          limparSincronizadoEm ? null : (sincronizadoEm ?? this.sincronizadoEm),
      autorUserId: autorUserId ?? this.autorUserId,
    );
  }
}
