class AcaoModel {
  final String id;
  final String numeroRAE;
  final int anoRAE;
  final DateTime dataAcao;
  final String turno;
  final String horaInicio;
  final String? horaFinal;
  final String nomeAcao;
  final String tipoAcao;
  final int publicoEstimado;
  final int publicoMinimo;
  final int pessoasAlcancadas;
  final int veiculosAbordados;
  final int credenciaisEmitidas;
  final bool metaAtingida;
  final String? motivoMetaNaoAtingida;
  final String endereco;
  final String bairro;
  final String regional;
  final double latitude;
  final double longitude;
  final String coordenadorId;
  final String coordenadorNome;
  final List<String> fotosUrls;
  final String descricaoEvidencias;
  final String status;
  final bool sincronizado;

  const AcaoModel({
    required this.id,
    this.numeroRAE = '',
    this.anoRAE = 0,
    required this.dataAcao,
    required this.turno,
    required this.horaInicio,
    this.horaFinal,
    required this.nomeAcao,
    required this.tipoAcao,
    required this.publicoEstimado,
    required this.publicoMinimo,
    required this.pessoasAlcancadas,
    required this.veiculosAbordados,
    required this.credenciaisEmitidas,
    required this.metaAtingida,
    this.motivoMetaNaoAtingida,
    required this.endereco,
    required this.bairro,
    required this.regional,
    required this.latitude,
    required this.longitude,
    required this.coordenadorId,
    required this.coordenadorNome,
    this.fotosUrls = const [],
    this.descricaoEvidencias = '',
    required this.status,
    required this.sincronizado,
  });

  AcaoModel copyWith({
    String? id,
    String? numeroRAE,
    int? anoRAE,
    DateTime? dataAcao,
    String? turno,
    String? horaInicio,
    String? horaFinal,
    String? nomeAcao,
    String? tipoAcao,
    int? publicoEstimado,
    int? publicoMinimo,
    int? pessoasAlcancadas,
    int? veiculosAbordados,
    int? credenciaisEmitidas,
    bool? metaAtingida,
    String? motivoMetaNaoAtingida,
    String? endereco,
    String? bairro,
    String? regional,
    double? latitude,
    double? longitude,
    String? coordenadorId,
    String? coordenadorNome,
    List<String>? fotosUrls,
    String? descricaoEvidencias,
    String? status,
    bool? sincronizado,
  }) {
    return AcaoModel(
      id: id ?? this.id,
      numeroRAE: numeroRAE ?? this.numeroRAE,
      anoRAE: anoRAE ?? this.anoRAE,
      dataAcao: dataAcao ?? this.dataAcao,
      turno: turno ?? this.turno,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFinal: horaFinal ?? this.horaFinal,
      nomeAcao: nomeAcao ?? this.nomeAcao,
      tipoAcao: tipoAcao ?? this.tipoAcao,
      publicoEstimado: publicoEstimado ?? this.publicoEstimado,
      publicoMinimo: publicoMinimo ?? this.publicoMinimo,
      pessoasAlcancadas: pessoasAlcancadas ?? this.pessoasAlcancadas,
      veiculosAbordados: veiculosAbordados ?? this.veiculosAbordados,
      credenciaisEmitidas: credenciaisEmitidas ?? this.credenciaisEmitidas,
      metaAtingida: metaAtingida ?? this.metaAtingida,
      motivoMetaNaoAtingida:
          motivoMetaNaoAtingida ?? this.motivoMetaNaoAtingida,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      regional: regional ?? this.regional,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coordenadorId: coordenadorId ?? this.coordenadorId,
      coordenadorNome: coordenadorNome ?? this.coordenadorNome,
      fotosUrls: fotosUrls ?? this.fotosUrls,
      descricaoEvidencias: descricaoEvidencias ?? this.descricaoEvidencias,
      status: status ?? this.status,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'numeroRAE': numeroRAE,
        'anoRAE': anoRAE,
        'dataAcao': dataAcao.toIso8601String(),
        'turno': turno,
        'horaInicio': horaInicio,
        'horaFinal': horaFinal,
        'nomeAcao': nomeAcao,
        'tipoAcao': tipoAcao,
        'publicoEstimado': publicoEstimado,
        'publicoMinimo': publicoMinimo,
        'pessoasAlcancadas': pessoasAlcancadas,
        'veiculosAbordados': veiculosAbordados,
        'credenciaisEmitidas': credenciaisEmitidas,
        'metaAtingida': metaAtingida,
        'motivoMetaNaoAtingida': motivoMetaNaoAtingida,
        'endereco': endereco,
        'bairro': bairro,
        'regional': regional,
        'latitude': latitude,
        'longitude': longitude,
        'coordenadorId': coordenadorId,
        'coordenadorNome': coordenadorNome,
        'fotosUrls': fotosUrls,
        'descricaoEvidencias': descricaoEvidencias,
        'status': status,
        'sincronizado': sincronizado,
      };

  Map<String, dynamic> toJson() => toMap();

  factory AcaoModel.fromMap(Map<String, dynamic> map) {
    final dataAcaoTexto = map['dataAcao']?.toString();
    final dataAcao = dataAcaoTexto == null || dataAcaoTexto.isEmpty
        ? DateTime.now()
        : DateTime.tryParse(dataAcaoTexto) ?? DateTime.now();

    return AcaoModel(
      id: map['id'] ?? '',
      numeroRAE: map['numeroRAE'] ?? '',
      anoRAE: map['anoRAE'] ?? 0,
      dataAcao: dataAcao,
      turno: map['turno'] ?? '',
      horaInicio: map['horaInicio'] ?? '',
      horaFinal: map['horaFinal'],
      nomeAcao: map['nomeAcao'] ?? '',
      tipoAcao: map['tipoAcao'] ?? '',
      publicoEstimado: map['publicoEstimado'] ?? 0,
      publicoMinimo: map['publicoMinimo'] ?? 0,
      pessoasAlcancadas: map['pessoasAlcancadas'] ?? 0,
      veiculosAbordados: map['veiculosAbordados'] ?? 0,
      credenciaisEmitidas: map['credenciaisEmitidas'] ?? 0,
      metaAtingida: map['metaAtingida'] ?? false,
      motivoMetaNaoAtingida: map['motivoMetaNaoAtingida'],
      endereco: map['endereco'] ?? '',
      bairro: map['bairro'] ?? '',
      regional: map['regional'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      coordenadorId: map['coordenadorId'] ?? '',
      coordenadorNome: map['coordenadorNome'] ?? '',
      fotosUrls: List<String>.from(map['fotosUrls'] ?? []),
      descricaoEvidencias: map['descricaoEvidencias'] ?? '',
      status: map['status'] ?? 'rascunho',
      sincronizado: map['sincronizado'] ?? false,
    );
  }

  factory AcaoModel.fromJson(Map<String, dynamic> json) {
    return AcaoModel.fromMap(json);
  }
}