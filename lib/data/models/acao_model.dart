class AcaoModel {
  // ============================================================
  // IDENTIFICAÇÃO
  // ============================================================

  final String id;
  final String numeroRAE;
  final int anoRAE;

  // ============================================================
  // PLANEJAMENTO
  // ============================================================

  final DateTime dataAcao;
  final String turno;
  final String nomeAcao;
  final String tipoAcao;

  final int publicoEstimado;
  final int publicoMinimo;

  final bool acaoPlanejada;

  // ============================================================
  // EXECUÇÃO
  // ============================================================

  final String horaInicio;
  final String? horaFinal;

  final int pessoasAlcancadas;
  final int veiculosAbordados;
  final int credenciaisEmitidas;

  final bool metaAtingida;
  final String? motivoMetaNaoAtingida;

  // ============================================================
  // LOCALIZAÇÃO
  // ============================================================

  final String endereco;
  final String bairro;
  final String regional;

  /// Escola, praça, terminal, shopping, empresa...
  final String equipamentoReferencia;

  final double latitude;
  final double longitude;

  // ============================================================
  // RECURSOS
  // ============================================================

  final String coordenadorId;
  final String coordenadorNome;

  final int agentesTransito;
  final int equipeTerceirizada;

  // ============================================================
  // EVIDÊNCIAS
  // ============================================================

  final List<String> fotosUrls;
  final String descricaoEvidencias;

  // ============================================================
  // SINCRONIZAÇÃO
  // ============================================================

  final String status;
  final bool sincronizado;

  const AcaoModel({
    required this.id,

    this.numeroRAE = '',
    this.anoRAE = 0,

    required this.dataAcao,
    required this.turno,
    required this.nomeAcao,
    required this.tipoAcao,

    required this.publicoEstimado,
    required this.publicoMinimo,

    this.acaoPlanejada = false,

    required this.horaInicio,
    this.horaFinal,

    required this.pessoasAlcancadas,
    required this.veiculosAbordados,
    required this.credenciaisEmitidas,

    required this.metaAtingida,
    this.motivoMetaNaoAtingida,

    required this.endereco,
    required this.bairro,
    required this.regional,

    this.equipamentoReferencia = '',

    required this.latitude,
    required this.longitude,

    required this.coordenadorId,
    required this.coordenadorNome,

    this.agentesTransito = 0,
    this.equipeTerceirizada = 0,

    this.fotosUrls = const [],
    this.descricaoEvidencias = '',

    required this.status,
    required this.sincronizado,
  });
    AcaoModel copyWith({
    // IDENTIFICAÇÃO
    String? id,
    String? numeroRAE,
    int? anoRAE,

    // PLANEJAMENTO
    DateTime? dataAcao,
    String? turno,
    String? nomeAcao,
    String? tipoAcao,
    int? publicoEstimado,
    int? publicoMinimo,
    bool? acaoPlanejada,

    // EXECUÇÃO
    String? horaInicio,
    String? horaFinal,
    int? pessoasAlcancadas,
    int? veiculosAbordados,
    int? credenciaisEmitidas,
    bool? metaAtingida,
    String? motivoMetaNaoAtingida,

    // LOCALIZAÇÃO
    String? endereco,
    String? bairro,
    String? regional,
    String? equipamentoReferencia,
    double? latitude,
    double? longitude,

    // RECURSOS
    String? coordenadorId,
    String? coordenadorNome,
    int? agentesTransito,
    int? equipeTerceirizada,

    // EVIDÊNCIAS
    List<String>? fotosUrls,
    String? descricaoEvidencias,

    // SINCRONIZAÇÃO
    String? status,
    bool? sincronizado,
  }) {
    return AcaoModel(
      // IDENTIFICAÇÃO
      id: id ?? this.id,
      numeroRAE: numeroRAE ?? this.numeroRAE,
      anoRAE: anoRAE ?? this.anoRAE,

      // PLANEJAMENTO
      dataAcao: dataAcao ?? this.dataAcao,
      turno: turno ?? this.turno,
      nomeAcao: nomeAcao ?? this.nomeAcao,
      tipoAcao: tipoAcao ?? this.tipoAcao,
      publicoEstimado: publicoEstimado ?? this.publicoEstimado,
      publicoMinimo: publicoMinimo ?? this.publicoMinimo,
      acaoPlanejada: acaoPlanejada ?? this.acaoPlanejada,

      // EXECUÇÃO
      horaInicio: horaInicio ?? this.horaInicio,
      horaFinal: horaFinal ?? this.horaFinal,
      pessoasAlcancadas: pessoasAlcancadas ?? this.pessoasAlcancadas,
      veiculosAbordados: veiculosAbordados ?? this.veiculosAbordados,
      credenciaisEmitidas:
          credenciaisEmitidas ?? this.credenciaisEmitidas,
      metaAtingida: metaAtingida ?? this.metaAtingida,
      motivoMetaNaoAtingida:
          motivoMetaNaoAtingida ?? this.motivoMetaNaoAtingida,

      // LOCALIZAÇÃO
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      regional: regional ?? this.regional,
      equipamentoReferencia:
          equipamentoReferencia ?? this.equipamentoReferencia,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,

      // RECURSOS
      coordenadorId: coordenadorId ?? this.coordenadorId,
      coordenadorNome: coordenadorNome ?? this.coordenadorNome,
      agentesTransito: agentesTransito ?? this.agentesTransito,
      equipeTerceirizada:
          equipeTerceirizada ?? this.equipeTerceirizada,

      // EVIDÊNCIAS
      fotosUrls: fotosUrls ?? this.fotosUrls,
      descricaoEvidencias:
          descricaoEvidencias ?? this.descricaoEvidencias,

      // SINCRONIZAÇÃO
      status: status ?? this.status,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }
    Map<String, dynamic> toMap() => {
        // IDENTIFICAÇÃO
        'id': id,
        'numeroRAE': numeroRAE,
        'anoRAE': anoRAE,

        // PLANEJAMENTO
        'dataAcao': dataAcao.toIso8601String(),
        'turno': turno,
        'nomeAcao': nomeAcao,
        'tipoAcao': tipoAcao,
        'publicoEstimado': publicoEstimado,
        'publicoMinimo': publicoMinimo,
        'acaoPlanejada': acaoPlanejada,

        // EXECUÇÃO
        'horaInicio': horaInicio,
        'horaFinal': horaFinal,
        'pessoasAlcancadas': pessoasAlcancadas,
        'veiculosAbordados': veiculosAbordados,
        'credenciaisEmitidas': credenciaisEmitidas,
        'metaAtingida': metaAtingida,
        'motivoMetaNaoAtingida': motivoMetaNaoAtingida,

        // LOCALIZAÇÃO
        'endereco': endereco,
        'bairro': bairro,
        'regional': regional,
        'equipamentoReferencia': equipamentoReferencia,
        'latitude': latitude,
        'longitude': longitude,

        // RECURSOS
        'coordenadorId': coordenadorId,
        'coordenadorNome': coordenadorNome,
        'agentesTransito': agentesTransito,
        'equipeTerceirizada': equipeTerceirizada,

        // EVIDÊNCIAS
        'fotosUrls': fotosUrls,
        'descricaoEvidencias': descricaoEvidencias,

        // SINCRONIZAÇÃO
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
      // IDENTIFICAÇÃO
      id: map['id'] ?? '',
      numeroRAE: map['numeroRAE'] ?? '',
      anoRAE: map['anoRAE'] ?? 0,

      // PLANEJAMENTO
      dataAcao: dataAcao,
      turno: map['turno'] ?? '',
      nomeAcao: map['nomeAcao'] ?? '',
      tipoAcao: map['tipoAcao'] ?? '',
      publicoEstimado: map['publicoEstimado'] ?? 0,
      publicoMinimo: map['publicoMinimo'] ?? 0,
      acaoPlanejada: map['acaoPlanejada'] ?? false,

      // EXECUÇÃO
      horaInicio: map['horaInicio'] ?? '',
      horaFinal: map['horaFinal'],
      pessoasAlcancadas: map['pessoasAlcancadas'] ?? 0,
      veiculosAbordados: map['veiculosAbordados'] ?? 0,
      credenciaisEmitidas: map['credenciaisEmitidas'] ?? 0,
      metaAtingida: map['metaAtingida'] ?? false,
      motivoMetaNaoAtingida: map['motivoMetaNaoAtingida'],

      // LOCALIZAÇÃO
      endereco: map['endereco'] ?? '',
      bairro: map['bairro'] ?? '',
      regional: map['regional'] ?? '',
      equipamentoReferencia: map['equipamentoReferencia'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),

      // RECURSOS
      coordenadorId: map['coordenadorId'] ?? '',
      coordenadorNome: map['coordenadorNome'] ?? '',
      agentesTransito: map['agentesTransito'] ?? 0,
      equipeTerceirizada: map['equipeTerceirizada'] ?? 0,

      // EVIDÊNCIAS
      fotosUrls: List<String>.from(map['fotosUrls'] ?? []),
      descricaoEvidencias: map['descricaoEvidencias'] ?? '',

      // SINCRONIZAÇÃO
      status: map['status'] ?? 'rascunho',
      sincronizado: map['sincronizado'] ?? false,
    );
  }

  factory AcaoModel.fromJson(Map<String, dynamic> json) {
    return AcaoModel.fromMap(json);
  }
}    