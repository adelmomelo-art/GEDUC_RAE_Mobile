enum OrigemLocalizacao {
  gps,
  enderecoInformado,
  mapa,
}

extension OrigemLocalizacaoExtension on OrigemLocalizacao {
  String get valorPersistencia {
    switch (this) {
      case OrigemLocalizacao.gps:
        return 'gps';
      case OrigemLocalizacao.enderecoInformado:
        return 'enderecoInformado';
      case OrigemLocalizacao.mapa:
        return 'mapa';
    }
  }

  static OrigemLocalizacao? fromValue(dynamic value) {
    final texto = value?.toString().trim();

    switch (texto) {
      case 'gps':
        return OrigemLocalizacao.gps;
      case 'enderecoInformado':
      case 'endereco_informado':
        return OrigemLocalizacao.enderecoInformado;
      case 'mapa':
        return OrigemLocalizacao.mapa;
      default:
        return null;
    }
  }
}

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

  /// Campo legado preservado para compatibilidade com registros anteriores.
  final String equipamentoReferencia;

  /// Nome institucional ou popular do local da ação.
  final String nomeLocal;

  /// Complemento operacional para facilitar a identificação do ponto.
  final String pontoReferencia;

  final double latitude;
  final double longitude;
  final OrigemLocalizacao? origemLocalizacao;
  final double? precisaoGps;
  final DateTime? dataHoraCaptura;
  final bool localizacaoValidada;
  final bool localizacaoEditadaManualmente;

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
    this.nomeLocal = '',
    this.pontoReferencia = '',
    required this.latitude,
    required this.longitude,
    this.origemLocalizacao,
    this.precisaoGps,
    this.dataHoraCaptura,
    this.localizacaoValidada = false,
    this.localizacaoEditadaManualmente = false,
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
    String? nomeLocal,
    String? pontoReferencia,
    double? latitude,
    double? longitude,
    OrigemLocalizacao? origemLocalizacao,
    double? precisaoGps,
    DateTime? dataHoraCaptura,
    bool? localizacaoValidada,
    bool? localizacaoEditadaManualmente,
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
      nomeLocal: nomeLocal ?? this.nomeLocal,
      pontoReferencia: pontoReferencia ?? this.pontoReferencia,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      origemLocalizacao: origemLocalizacao ?? this.origemLocalizacao,
      precisaoGps: precisaoGps ?? this.precisaoGps,
      dataHoraCaptura: dataHoraCaptura ?? this.dataHoraCaptura,
      localizacaoValidada:
          localizacaoValidada ?? this.localizacaoValidada,
      localizacaoEditadaManualmente: localizacaoEditadaManualmente ??
          this.localizacaoEditadaManualmente,
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
        'nomeLocal': nomeLocal,
        'pontoReferencia': pontoReferencia,
        'latitude': latitude,
        'longitude': longitude,
        'origemLocalizacao': origemLocalizacao?.valorPersistencia,
        'precisaoGps': precisaoGps,
        'dataHoraCaptura': dataHoraCaptura?.toIso8601String(),
        'localizacaoValidada': localizacaoValidada,
        'localizacaoEditadaManualmente': localizacaoEditadaManualmente,
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
    final pontoReferencia = _texto(
      map['pontoReferencia'],
      fallback: _texto(map['equipamentoReferencia']),
    );

    return AcaoModel(
      id: _texto(map['id']),
      numeroRAE: _texto(map['numeroRAE']),
      anoRAE: _inteiro(map['anoRAE']),
      dataAcao: _dataHora(map['dataAcao']) ?? DateTime.now(),
      turno: _texto(map['turno']),
      nomeAcao: _texto(map['nomeAcao']),
      tipoAcao: _texto(map['tipoAcao']),
      publicoEstimado: _inteiro(map['publicoEstimado']),
      publicoMinimo: _inteiro(map['publicoMinimo']),
      acaoPlanejada: _booleano(map['acaoPlanejada']),
      horaInicio: _texto(map['horaInicio']),
      horaFinal: map['horaFinal']?.toString(),
      pessoasAlcancadas: _inteiro(map['pessoasAlcancadas']),
      veiculosAbordados: _inteiro(map['veiculosAbordados']),
      credenciaisEmitidas: _inteiro(map['credenciaisEmitidas']),
      metaAtingida: _booleano(map['metaAtingida']),
      motivoMetaNaoAtingida: map['motivoMetaNaoAtingida']?.toString(),
      endereco: _texto(map['endereco']),
      bairro: _texto(map['bairro']),
      regional: _texto(map['regional']),
      equipamentoReferencia: _texto(map['equipamentoReferencia']),
      nomeLocal: _texto(map['nomeLocal']),
      pontoReferencia: pontoReferencia,
      latitude: _decimal(map['latitude']),
      longitude: _decimal(map['longitude']),
      origemLocalizacao:
          OrigemLocalizacaoExtension.fromValue(map['origemLocalizacao']),
      precisaoGps: _decimalOpcional(map['precisaoGps']),
      dataHoraCaptura: _dataHora(map['dataHoraCaptura']),
      localizacaoValidada: _booleano(map['localizacaoValidada']),
      localizacaoEditadaManualmente:
          _booleano(map['localizacaoEditadaManualmente']),
      fatorRiscoIds: _listaTexto(map['fatorRiscoIds']),
      mudancaComportamentoId: _texto(map['mudancaComportamentoId']),
      formacaoId: _texto(map['formacaoId']),
      publicoId: _texto(map['publicoId']),
      tipoParticipacaoIds: _listaTexto(map['tipoParticipacaoIds']),
      focoTematicoIds: _listaTexto(map['focoTematicoIds']),
      perfilUsuarioIds: _listaTexto(map['perfilUsuarioIds']),
      sexoPredominanteId: _texto(map['sexoPredominanteId']),
      instituicaoParceira: _texto(map['instituicaoParceira']),
      coordenadorId: _texto(map['coordenadorId']),
      coordenadorNome: _texto(map['coordenadorNome']),
      agentesTransito: _inteiro(map['agentesTransito']),
      equipeTerceirizada: _inteiro(map['equipeTerceirizada']),
      materialUtilizadoIds: _listaTexto(map['materialUtilizadoIds']),
      coberturaMidia: _booleano(map['coberturaMidia']),
      houveParticipacaoOutroOrgao:
          _booleano(map['houveParticipacaoOutroOrgao']),
      orgaoParticipanteId: _texto(map['orgaoParticipanteId']),
      pontosPositivos: _texto(map['pontosPositivos']),
      dificuldadesEncontradas: _texto(map['dificuldadesEncontradas']),
      recomendacoes: _texto(map['recomendacoes']),
      fotosUrls: _listaTexto(map['fotosUrls']),
      descricaoEvidencias: _texto(map['descricaoEvidencias']),
      status: _texto(map['status'], fallback: 'rascunho'),
      sincronizado: _booleano(map['sincronizado']),
    );
  }

  factory AcaoModel.fromJson(Map<String, dynamic> json) {
    return AcaoModel.fromMap(json);
  }

  static String _texto(dynamic value, {String fallback = ''}) {
    final texto = value?.toString();
    return texto == null || texto.isEmpty ? fallback : texto;
  }

  static int _inteiro(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _decimal(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _decimalOpcional(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _booleano(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final texto = value?.toString().toLowerCase();
    return texto == 'true' || texto == '1' || texto == 'sim';
  }

  static List<String> _listaTexto(dynamic value) {
    if (value is! Iterable) return const [];
    return value.map((item) => item.toString()).toList(growable: false);
  }

  static DateTime? _dataHora(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    try {
      final dynamic dataConvertida = value.toDate();
      if (dataConvertida is DateTime) return dataConvertida;
    } catch (_) {
      // Mantém compatibilidade sem criar dependência direta do Firestore.
    }

    return DateTime.tryParse(value.toString());
  }
}
