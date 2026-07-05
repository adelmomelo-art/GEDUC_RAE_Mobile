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
  final String equipamentoReferencia;
  final double latitude;
  final double longitude;

  // ============================================================
  // CARACTERIZAÇÃO DA AÇÃO
  // ============================================================

  final List<String> fatorRiscoIds;
  final String mudancaComportamentoId;
  final String formacaoId;
  final String publicoId;
  final List<String> tipoParticipacaoIds;
  final List<String> focoTematicoIds;
  final List<String> perfilUsuarioIds;
  final String sexoPredominanteId;
  final String instituicaoParceira;

  // ============================================================
  // RECURSOS OPERACIONAIS
  // ============================================================

  final String coordenadorId;
  final String coordenadorNome;
  final int agentesTransito;
  final int equipeTerceirizada;
  final List<String> materialUtilizadoIds;
  final bool coberturaMidia;

  // ============================================================
  // INTEGRAÇÃO INSTITUCIONAL
  // ============================================================

  final bool houveParticipacaoOutroOrgao;
  final String orgaoParticipanteId;

  // ============================================================
  // OBSERVAÇÕES OPERACIONAIS
  // ============================================================

  final String pontosPositivos;
  final String dificuldadesEncontradas;
  final String recomendacoes;

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
    this.fatorRiscoIds = const [],
    this.mudancaComportamentoId = '',
    this.formacaoId = '',
    this.publicoId = '',
    this.tipoParticipacaoIds = const [],
    this.focoTematicoIds = const [],
    this.perfilUsuarioIds = const [],
    this.sexoPredominanteId = '',
    this.instituicaoParceira = '',
    required this.coordenadorId,
    required this.coordenadorNome,
    this.agentesTransito = 0,
    this.equipeTerceirizada = 0,
    this.materialUtilizadoIds = const [],
    this.coberturaMidia = false,
    this.houveParticipacaoOutroOrgao = false,
    this.orgaoParticipanteId = '',
    this.pontosPositivos = '',
    this.dificuldadesEncontradas = '',
    this.recomendacoes = '',
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
    String? nomeAcao,
    String? tipoAcao,
    int? publicoEstimado,
    int? publicoMinimo,
    bool? acaoPlanejada,
    String? horaInicio,
    String? horaFinal,
    int? pessoasAlcancadas,
    int? veiculosAbordados,
    int? credenciaisEmitidas,
    bool? metaAtingida,
    String? motivoMetaNaoAtingida,
    String? endereco,
    String? bairro,
    String? regional,
    String? equipamentoReferencia,
    double? latitude,
    double? longitude,
    List<String>? fatorRiscoIds,
    String? mudancaComportamentoId,
    String? formacaoId,
    String? publicoId,
    List<String>? tipoParticipacaoIds,
    List<String>? focoTematicoIds,
    List<String>? perfilUsuarioIds,
    String? sexoPredominanteId,
    String? instituicaoParceira,
    String? coordenadorId,
    String? coordenadorNome,
    int? agentesTransito,
    int? equipeTerceirizada,
    List<String>? materialUtilizadoIds,
    bool? coberturaMidia,
    bool? houveParticipacaoOutroOrgao,
    String? orgaoParticipanteId,
    String? pontosPositivos,
    String? dificuldadesEncontradas,
    String? recomendacoes,
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
      nomeAcao: nomeAcao ?? this.nomeAcao,
      tipoAcao: tipoAcao ?? this.tipoAcao,
      publicoEstimado: publicoEstimado ?? this.publicoEstimado,
      publicoMinimo: publicoMinimo ?? this.publicoMinimo,
      acaoPlanejada: acaoPlanejada ?? this.acaoPlanejada,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFinal: horaFinal ?? this.horaFinal,
      pessoasAlcancadas: pessoasAlcancadas ?? this.pessoasAlcancadas,
      veiculosAbordados: veiculosAbordados ?? this.veiculosAbordados,
      credenciaisEmitidas: credenciaisEmitidas ?? this.credenciaisEmitidas,
      metaAtingida: metaAtingida ?? this.metaAtingida,
      motivoMetaNaoAtingida:
          motivoMetaNaoAtingida ?? this.motivoMetaNaoAtingida,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      regional: regional ?? this.regional,
      equipamentoReferencia:
          equipamentoReferencia ?? this.equipamentoReferencia,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fatorRiscoIds: fatorRiscoIds ?? this.fatorRiscoIds,
      mudancaComportamentoId:
          mudancaComportamentoId ?? this.mudancaComportamentoId,
      formacaoId: formacaoId ?? this.formacaoId,
      publicoId: publicoId ?? this.publicoId,
      tipoParticipacaoIds:
          tipoParticipacaoIds ?? this.tipoParticipacaoIds,
      focoTematicoIds: focoTematicoIds ?? this.focoTematicoIds,
      perfilUsuarioIds: perfilUsuarioIds ?? this.perfilUsuarioIds,
      sexoPredominanteId:
          sexoPredominanteId ?? this.sexoPredominanteId,
      instituicaoParceira:
          instituicaoParceira ?? this.instituicaoParceira,
      coordenadorId: coordenadorId ?? this.coordenadorId,
      coordenadorNome: coordenadorNome ?? this.coordenadorNome,
      agentesTransito: agentesTransito ?? this.agentesTransito,
      equipeTerceirizada:
          equipeTerceirizada ?? this.equipeTerceirizada,
      materialUtilizadoIds:
          materialUtilizadoIds ?? this.materialUtilizadoIds,
      coberturaMidia: coberturaMidia ?? this.coberturaMidia,
      houveParticipacaoOutroOrgao:
          houveParticipacaoOutroOrgao ?? this.houveParticipacaoOutroOrgao,
      orgaoParticipanteId:
          orgaoParticipanteId ?? this.orgaoParticipanteId,
      pontosPositivos: pontosPositivos ?? this.pontosPositivos,
      dificuldadesEncontradas:
          dificuldadesEncontradas ?? this.dificuldadesEncontradas,
      recomendacoes: recomendacoes ?? this.recomendacoes,
      fotosUrls: fotosUrls ?? this.fotosUrls,
      descricaoEvidencias:
          descricaoEvidencias ?? this.descricaoEvidencias,
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
        'nomeAcao': nomeAcao,
        'tipoAcao': tipoAcao,
        'publicoEstimado': publicoEstimado,
        'publicoMinimo': publicoMinimo,
        'acaoPlanejada': acaoPlanejada,
        'horaInicio': horaInicio,
        'horaFinal': horaFinal,
        'pessoasAlcancadas': pessoasAlcancadas,
        'veiculosAbordados': veiculosAbordados,
        'credenciaisEmitidas': credenciaisEmitidas,
        'metaAtingida': metaAtingida,
        'motivoMetaNaoAtingida': motivoMetaNaoAtingida,
        'endereco': endereco,
        'bairro': bairro,
        'regional': regional,
        'equipamentoReferencia': equipamentoReferencia,
        'latitude': latitude,
        'longitude': longitude,
        'fatorRiscoIds': fatorRiscoIds,
        'mudancaComportamentoId': mudancaComportamentoId,
        'formacaoId': formacaoId,
        'publicoId': publicoId,
        'tipoParticipacaoIds': tipoParticipacaoIds,
        'focoTematicoIds': focoTematicoIds,
        'perfilUsuarioIds': perfilUsuarioIds,
        'sexoPredominanteId': sexoPredominanteId,
        'instituicaoParceira': instituicaoParceira,
        'coordenadorId': coordenadorId,
        'coordenadorNome': coordenadorNome,
        'agentesTransito': agentesTransito,
        'equipeTerceirizada': equipeTerceirizada,
        'materialUtilizadoIds': materialUtilizadoIds,
        'coberturaMidia': coberturaMidia,
        'houveParticipacaoOutroOrgao': houveParticipacaoOutroOrgao,
        'orgaoParticipanteId': orgaoParticipanteId,
        'pontosPositivos': pontosPositivos,
        'dificuldadesEncontradas': dificuldadesEncontradas,
        'recomendacoes': recomendacoes,
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
      nomeAcao: map['nomeAcao'] ?? '',
      tipoAcao: map['tipoAcao'] ?? '',
      publicoEstimado: map['publicoEstimado'] ?? 0,
      publicoMinimo: map['publicoMinimo'] ?? 0,
      acaoPlanejada: map['acaoPlanejada'] ?? false,
      horaInicio: map['horaInicio'] ?? '',
      horaFinal: map['horaFinal'],
      pessoasAlcancadas: map['pessoasAlcancadas'] ?? 0,
      veiculosAbordados: map['veiculosAbordados'] ?? 0,
      credenciaisEmitidas: map['credenciaisEmitidas'] ?? 0,
      metaAtingida: map['metaAtingida'] ?? false,
      motivoMetaNaoAtingida: map['motivoMetaNaoAtingida'],
      endereco: map['endereco'] ?? '',
      bairro: map['bairro'] ?? '',
      regional: map['regional'] ?? '',
      equipamentoReferencia: map['equipamentoReferencia'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      fatorRiscoIds: List<String>.from(map['fatorRiscoIds'] ?? []),
      mudancaComportamentoId: map['mudancaComportamentoId'] ?? '',
      formacaoId: map['formacaoId'] ?? '',
      publicoId: map['publicoId'] ?? '',
      tipoParticipacaoIds:
          List<String>.from(map['tipoParticipacaoIds'] ?? []),
      focoTematicoIds: List<String>.from(map['focoTematicoIds'] ?? []),
      perfilUsuarioIds: List<String>.from(map['perfilUsuarioIds'] ?? []),
      sexoPredominanteId: map['sexoPredominanteId'] ?? '',
      instituicaoParceira: map['instituicaoParceira'] ?? '',
      coordenadorId: map['coordenadorId'] ?? '',
      coordenadorNome: map['coordenadorNome'] ?? '',
      agentesTransito: map['agentesTransito'] ?? 0,
      equipeTerceirizada: map['equipeTerceirizada'] ?? 0,
      materialUtilizadoIds:
          List<String>.from(map['materialUtilizadoIds'] ?? []),
      coberturaMidia: map['coberturaMidia'] ?? false,
      houveParticipacaoOutroOrgao:
          map['houveParticipacaoOutroOrgao'] ?? false,
      orgaoParticipanteId: map['orgaoParticipanteId'] ?? '',
      pontosPositivos: map['pontosPositivos'] ?? '',
      dificuldadesEncontradas: map['dificuldadesEncontradas'] ?? '',
      recomendacoes: map['recomendacoes'] ?? '',
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
