import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class EscalaCodigos {
  static const statusRascunho = 'rascunho';
  static const statusPublicada = 'publicada';
  static const statusArquivada = 'arquivada';

  static const naturezaEducativa = 'educativa';
  static const naturezaAdministrativa = 'administrativa';

  static const atividadePlanejada = 'planejada';
  static const atividadePublicada = 'publicada';
  static const atividadeEmExecucao = 'em_execucao';
  static const atividadeConcluida = 'concluida';
  static const atividadeCancelada = 'cancelada';

  static const execucaoEmExecucao = 'em_execucao';
  static const execucaoConcluida = 'concluida';
  static const execucaoCancelada = 'cancelada';

  static const jornadaNormal = 'normal';
  static const jornadaHoraExtra = 'hora_extra';
  static const jornadaBancoHoras = 'banco_horas';
}

class EscalaConfiguracaoModel {
  const EscalaConfiguracaoModel({
    required this.id,
    required this.responsavelEscalaUsuarioId,
    required this.responsavelEscalaMembroEquipeId,
    required this.ativo,
    required this.designadoPor,
    required this.designadoEm,
  });

  final String id;
  final String responsavelEscalaUsuarioId;
  final String responsavelEscalaMembroEquipeId;
  final bool ativo;
  final String designadoPor;
  final DateTime designadoEm;

  factory EscalaConfiguracaoModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return EscalaConfiguracaoModel(
      id: documentId,
      responsavelEscalaUsuarioId:
          map['responsavelEscalaUsuarioId']?.toString() ?? '',
      responsavelEscalaMembroEquipeId:
          map['responsavelEscalaMembroEquipeId']?.toString() ?? '',
      ativo: map['ativo'] == true,
      designadoPor: map['designadoPor']?.toString() ?? '',
      designadoEm: _dataObrigatoria(map['designadoEm']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'responsavelEscalaUsuarioId': responsavelEscalaUsuarioId.trim(),
        'responsavelEscalaMembroEquipeId':
            responsavelEscalaMembroEquipeId.trim(),
        'ativo': ativo,
        'designadoPor': designadoPor.trim(),
        'designadoEm': Timestamp.fromDate(designadoEm),
      };
}

class EscalaPerfilOperacionalModel {
  const EscalaPerfilOperacionalModel({
    required this.id,
    required this.membroEquipeId,
    required this.usuarioId,
    required this.setorCodigo,
    required this.cargaHorariaCodigo,
    required this.ativo,
    required this.criadoPor,
    required this.criadoEm,
    required this.atualizadoPor,
    required this.atualizadoEm,
  });

  final String id;
  final String membroEquipeId;
  final String usuarioId;
  final String setorCodigo;
  final String cargaHorariaCodigo;
  final bool ativo;
  final String criadoPor;
  final DateTime criadoEm;
  final String atualizadoPor;
  final DateTime atualizadoEm;

  factory EscalaPerfilOperacionalModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return EscalaPerfilOperacionalModel(
      id: documentId,
      membroEquipeId: map['membroEquipeId']?.toString() ?? '',
      usuarioId: map['usuarioId']?.toString() ?? '',
      setorCodigo: map['setorCodigo']?.toString() ?? '',
      cargaHorariaCodigo: map['cargaHorariaCodigo']?.toString() ?? '',
      ativo: map['ativo'] == true,
      criadoPor: map['criadoPor']?.toString() ?? '',
      criadoEm: _dataObrigatoria(map['criadoEm']),
      atualizadoPor: map['atualizadoPor']?.toString() ?? '',
      atualizadoEm: _dataObrigatoria(map['atualizadoEm']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'membroEquipeId': membroEquipeId.trim(),
        'usuarioId': usuarioId.trim(),
        'setorCodigo': setorCodigo.trim(),
        'cargaHorariaCodigo': cargaHorariaCodigo.trim(),
        'ativo': ativo,
        'criadoPor': criadoPor.trim(),
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoPor': atualizadoPor.trim(),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      };
}

class EscalaModel {
  const EscalaModel({
    required this.id,
    required this.data,
    required this.status,
    required this.versao,
    required this.observacaoGeral,
    required this.motivoRevisao,
    this.revisaoDeEscalaId = '',
    this.revisaoPreparada = true,
    required this.criadoPor,
    required this.criadoEm,
    required this.atualizadoPor,
    required this.atualizadoEm,
    required this.publicadoPor,
    required this.publicadoEm,
  });

  final String id;
  final DateTime data;
  final String status;
  final int versao;
  final String observacaoGeral;
  final String motivoRevisao;
  final String revisaoDeEscalaId;
  final bool revisaoPreparada;
  final String criadoPor;
  final DateTime criadoEm;
  final String atualizadoPor;
  final DateTime atualizadoEm;
  final String publicadoPor;
  final DateTime? publicadoEm;

  factory EscalaModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return EscalaModel(
      id: documentId,
      data: _dataObrigatoria(map['data']),
      status: map['status']?.toString() ?? '',
      versao: _inteiro(map['versao'], fallback: 1),
      observacaoGeral: map['observacaoGeral']?.toString() ?? '',
      motivoRevisao: map['motivoRevisao']?.toString() ?? '',
      revisaoDeEscalaId: map['revisaoDeEscalaId']?.toString() ?? '',
      revisaoPreparada: map['revisaoPreparada'] != false,
      criadoPor: map['criadoPor']?.toString() ?? '',
      criadoEm: _dataObrigatoria(map['criadoEm']),
      atualizadoPor: map['atualizadoPor']?.toString() ?? '',
      atualizadoEm: _dataObrigatoria(map['atualizadoEm']),
      publicadoPor: map['publicadoPor']?.toString() ?? '',
      publicadoEm: _dataOpcional(map['publicadoEm']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'data': Timestamp.fromDate(data),
        'status': status.trim(),
        'versao': versao,
        'observacaoGeral': observacaoGeral.trim(),
        'motivoRevisao': motivoRevisao.trim(),
        'revisaoDeEscalaId': revisaoDeEscalaId.trim(),
        'revisaoPreparada': revisaoPreparada,
        'criadoPor': criadoPor.trim(),
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoPor': atualizadoPor.trim(),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
        'publicadoPor': publicadoPor.trim(),
        'publicadoEm':
            publicadoEm == null ? null : Timestamp.fromDate(publicadoEm!),
      };
}

class EscalaAtividadeModel {
  EscalaAtividadeModel({
    required this.id,
    required this.escalaId,
    required this.data,
    required this.secaoId,
    required this.tipoAtividadeId,
    required this.naturezaAtividade,
    required this.titulo,
    required this.descricao,
    required this.turnoId,
    required this.qtrHorario,
    required this.horaInicio,
    required this.horaFim,
    required this.qthLocal,
    required this.qthEndereco,
    required this.qthRegionalId,
    required this.qthPontoReferencia,
    required this.orientacaoOperacional,
    required this.coordenadorMembroEquipeId,
    required this.coordenadorUsuarioId,
    required this.coordenadorNomeSnapshot,
    required Iterable<String> participanteUsuarioIds,
    required this.geraRae,
    required this.contabilizaProdutividade,
    required this.raeId,
    required this.execucaoMissaoId,
    required this.status,
    required this.criadoPor,
    required this.criadoEm,
    required this.atualizadoPor,
    required this.atualizadoEm,
  }) : participanteUsuarioIds = List<String>.unmodifiable(
          participanteUsuarioIds
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty),
        );

  final String id;
  final String escalaId;
  final DateTime data;
  final String secaoId;
  final String tipoAtividadeId;
  final String naturezaAtividade;
  final String titulo;
  final String descricao;
  final String turnoId;
  final String qtrHorario;
  final String horaInicio;
  final String horaFim;
  final String qthLocal;
  final String qthEndereco;
  final String qthRegionalId;
  final String qthPontoReferencia;
  final String orientacaoOperacional;
  final String coordenadorMembroEquipeId;
  final String coordenadorUsuarioId;
  final String coordenadorNomeSnapshot;
  final List<String> participanteUsuarioIds;
  final bool geraRae;
  final bool contabilizaProdutividade;
  final String raeId;
  final String execucaoMissaoId;
  final String status;
  final String criadoPor;
  final DateTime criadoEm;
  final String atualizadoPor;
  final DateTime atualizadoEm;

  bool get educativa => naturezaAtividade == EscalaCodigos.naturezaEducativa;
  bool get administrativa =>
      naturezaAtividade == EscalaCodigos.naturezaAdministrativa;

  factory EscalaAtividadeModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return EscalaAtividadeModel(
      id: documentId,
      escalaId: map['escalaId']?.toString() ?? '',
      data: _dataObrigatoria(map['data']),
      secaoId: map['secaoId']?.toString() ?? '',
      tipoAtividadeId: map['tipoAtividadeId']?.toString() ?? '',
      naturezaAtividade: map['naturezaAtividade']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      turnoId: map['turnoId']?.toString() ?? '',
      qtrHorario: map['qtrHorario']?.toString() ?? '',
      horaInicio: map['horaInicio']?.toString() ?? '',
      horaFim: map['horaFim']?.toString() ?? '',
      qthLocal: map['qthLocal']?.toString() ?? '',
      qthEndereco: map['qthEndereco']?.toString() ?? '',
      qthRegionalId: map['qthRegionalId']?.toString() ?? '',
      qthPontoReferencia: map['qthPontoReferencia']?.toString() ?? '',
      orientacaoOperacional: map['orientacaoOperacional']?.toString() ?? '',
      coordenadorMembroEquipeId:
          map['coordenadorMembroEquipeId']?.toString() ?? '',
      coordenadorUsuarioId: map['coordenadorUsuarioId']?.toString() ?? '',
      coordenadorNomeSnapshot: map['coordenadorNomeSnapshot']?.toString() ?? '',
      participanteUsuarioIds: _listaStrings(map['participanteUsuarioIds']),
      geraRae: map['geraRae'] == true,
      contabilizaProdutividade: map['contabilizaProdutividade'] == true,
      raeId: map['raeId']?.toString() ?? '',
      execucaoMissaoId: map['execucaoMissaoId']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      criadoPor: map['criadoPor']?.toString() ?? '',
      criadoEm: _dataObrigatoria(map['criadoEm']),
      atualizadoPor: map['atualizadoPor']?.toString() ?? '',
      atualizadoEm: _dataObrigatoria(map['atualizadoEm']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'escalaId': escalaId.trim(),
        'data': Timestamp.fromDate(data),
        'secaoId': secaoId.trim(),
        'tipoAtividadeId': tipoAtividadeId.trim(),
        'naturezaAtividade': naturezaAtividade.trim(),
        'titulo': titulo.trim(),
        'descricao': descricao.trim(),
        'turnoId': turnoId.trim(),
        'qtrHorario': qtrHorario.trim(),
        'horaInicio': horaInicio.trim(),
        'horaFim': horaFim.trim(),
        'qthLocal': qthLocal.trim(),
        'qthEndereco': qthEndereco.trim(),
        'qthRegionalId': qthRegionalId.trim(),
        'qthPontoReferencia': qthPontoReferencia.trim(),
        'orientacaoOperacional': orientacaoOperacional.trim(),
        'coordenadorMembroEquipeId': coordenadorMembroEquipeId.trim(),
        'coordenadorUsuarioId': coordenadorUsuarioId.trim(),
        'coordenadorNomeSnapshot': coordenadorNomeSnapshot.trim(),
        'participanteUsuarioIds': participanteUsuarioIds,
        'geraRae': geraRae,
        'contabilizaProdutividade': contabilizaProdutividade,
        'raeId': raeId.trim(),
        'execucaoMissaoId': execucaoMissaoId.trim(),
        'status': status.trim(),
        'criadoPor': criadoPor.trim(),
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoPor': atualizadoPor.trim(),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      };
}

class EscalaAlocacaoModel {
  const EscalaAlocacaoModel({
    required this.id,
    required this.escalaId,
    required this.atividadeId,
    required this.data,
    required this.membroEquipeId,
    required this.usuarioId,
    required this.nomeSnapshot,
    required this.vinculoSnapshot,
    required this.setorSnapshot,
    required this.cargaHorariaSnapshot,
    required this.funcaoNaAtividade,
    required this.turnoId,
    required this.horaInicio,
    required this.horaFim,
    required this.tipoJornada,
    required this.horaInicioReal,
    required this.horaFimReal,
    required this.minutosPrevistos,
    required this.minutosRealizados,
    required this.motivoJornadaComplementar,
    required this.classificadoPor,
    required this.classificadoEm,
    this.origemAlocacaoId = '',
    required this.observacao,
    required this.criadoPor,
    required this.criadoEm,
    required this.atualizadoPor,
    required this.atualizadoEm,
  });

  final String id;
  final String escalaId;
  final String atividadeId;
  final DateTime data;
  final String membroEquipeId;
  final String usuarioId;
  final String nomeSnapshot;
  final String vinculoSnapshot;
  final String setorSnapshot;
  final String cargaHorariaSnapshot;
  final String funcaoNaAtividade;
  final String turnoId;
  final String horaInicio;
  final String horaFim;
  final String tipoJornada;
  final String horaInicioReal;
  final String horaFimReal;
  final int minutosPrevistos;
  final int? minutosRealizados;
  final String motivoJornadaComplementar;
  final String classificadoPor;
  final DateTime? classificadoEm;
  final String origemAlocacaoId;
  final String observacao;
  final String criadoPor;
  final DateTime criadoEm;
  final String atualizadoPor;
  final DateTime atualizadoEm;

  bool get jornadaComplementar =>
      tipoJornada == EscalaCodigos.jornadaHoraExtra ||
      tipoJornada == EscalaCodigos.jornadaBancoHoras;

  factory EscalaAlocacaoModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    final minutosRealizadosValor = map['minutosRealizados'];
    return EscalaAlocacaoModel(
      id: documentId,
      escalaId: map['escalaId']?.toString() ?? '',
      atividadeId: map['atividadeId']?.toString() ?? '',
      data: _dataObrigatoria(map['data']),
      membroEquipeId: map['membroEquipeId']?.toString() ?? '',
      usuarioId: map['usuarioId']?.toString() ?? '',
      nomeSnapshot: map['nomeSnapshot']?.toString() ?? '',
      vinculoSnapshot: map['vinculoSnapshot']?.toString() ?? '',
      setorSnapshot: map['setorSnapshot']?.toString() ?? '',
      cargaHorariaSnapshot: map['cargaHorariaSnapshot']?.toString() ?? '',
      funcaoNaAtividade: map['funcaoNaAtividade']?.toString() ?? '',
      turnoId: map['turnoId']?.toString() ?? '',
      horaInicio: map['horaInicio']?.toString() ?? '',
      horaFim: map['horaFim']?.toString() ?? '',
      tipoJornada:
          map['tipoJornada']?.toString() ?? EscalaCodigos.jornadaNormal,
      horaInicioReal: map['horaInicioReal']?.toString() ?? '',
      horaFimReal: map['horaFimReal']?.toString() ?? '',
      minutosPrevistos: _inteiro(map['minutosPrevistos'], fallback: 0),
      minutosRealizados: minutosRealizadosValor == null
          ? null
          : _inteiro(minutosRealizadosValor, fallback: 0),
      motivoJornadaComplementar:
          map['motivoJornadaComplementar']?.toString() ?? '',
      classificadoPor: map['classificadoPor']?.toString() ?? '',
      classificadoEm: _dataOpcional(map['classificadoEm']),
      origemAlocacaoId: map['origemAlocacaoId']?.toString() ?? '',
      observacao: map['observacao']?.toString() ?? '',
      criadoPor: map['criadoPor']?.toString() ?? '',
      criadoEm: _dataObrigatoria(map['criadoEm']),
      atualizadoPor: map['atualizadoPor']?.toString() ?? '',
      atualizadoEm: _dataObrigatoria(map['atualizadoEm']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'escalaId': escalaId.trim(),
        'atividadeId': atividadeId.trim(),
        'data': Timestamp.fromDate(data),
        'membroEquipeId': membroEquipeId.trim(),
        'usuarioId': usuarioId.trim(),
        'nomeSnapshot': nomeSnapshot.trim(),
        'vinculoSnapshot': vinculoSnapshot.trim(),
        'setorSnapshot': setorSnapshot.trim(),
        'cargaHorariaSnapshot': cargaHorariaSnapshot.trim(),
        'funcaoNaAtividade': funcaoNaAtividade.trim(),
        'turnoId': turnoId.trim(),
        'horaInicio': horaInicio.trim(),
        'horaFim': horaFim.trim(),
        'tipoJornada': tipoJornada.trim(),
        'horaInicioReal': horaInicioReal.trim(),
        'horaFimReal': horaFimReal.trim(),
        'minutosPrevistos': minutosPrevistos,
        'minutosRealizados': minutosRealizados,
        'motivoJornadaComplementar': motivoJornadaComplementar.trim(),
        'classificadoPor': classificadoPor.trim(),
        'classificadoEm':
            classificadoEm == null ? null : Timestamp.fromDate(classificadoEm!),
        'origemAlocacaoId': origemAlocacaoId.trim(),
        'observacao': observacao.trim(),
        'criadoPor': criadoPor.trim(),
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoPor': atualizadoPor.trim(),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      };
}

class EscalaIndisponibilidadeModel {
  const EscalaIndisponibilidadeModel({
    required this.id,
    required this.dataInicio,
    required this.dataFim,
    required this.membroEquipeId,
    required this.usuarioId,
    required this.nomeSnapshot,
    required this.tipoId,
    required this.turnoId,
    required this.horaInicio,
    required this.horaFim,
    required this.observacao,
    required this.criadoPor,
    required this.criadoEm,
    required this.atualizadoPor,
    required this.atualizadoEm,
  });

  final String id;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String membroEquipeId;
  final String usuarioId;
  final String nomeSnapshot;
  final String tipoId;
  final String turnoId;
  final String horaInicio;
  final String horaFim;
  final String observacao;
  final String criadoPor;
  final DateTime criadoEm;
  final String atualizadoPor;
  final DateTime atualizadoEm;

  factory EscalaIndisponibilidadeModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return EscalaIndisponibilidadeModel(
      id: documentId,
      dataInicio: _dataObrigatoria(map['dataInicio']),
      dataFim: _dataObrigatoria(map['dataFim']),
      membroEquipeId: map['membroEquipeId']?.toString() ?? '',
      usuarioId: map['usuarioId']?.toString() ?? '',
      nomeSnapshot: map['nomeSnapshot']?.toString() ?? '',
      tipoId: map['tipoId']?.toString() ?? '',
      turnoId: map['turnoId']?.toString() ?? '',
      horaInicio: map['horaInicio']?.toString() ?? '',
      horaFim: map['horaFim']?.toString() ?? '',
      observacao: map['observacao']?.toString() ?? '',
      criadoPor: map['criadoPor']?.toString() ?? '',
      criadoEm: _dataObrigatoria(map['criadoEm']),
      atualizadoPor: map['atualizadoPor']?.toString() ?? '',
      atualizadoEm: _dataObrigatoria(map['atualizadoEm']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'dataInicio': Timestamp.fromDate(dataInicio),
        'dataFim': Timestamp.fromDate(dataFim),
        'membroEquipeId': membroEquipeId.trim(),
        'usuarioId': usuarioId.trim(),
        'nomeSnapshot': nomeSnapshot.trim(),
        'tipoId': tipoId.trim(),
        'turnoId': turnoId.trim(),
        'horaInicio': horaInicio.trim(),
        'horaFim': horaFim.trim(),
        'observacao': observacao.trim(),
        'criadoPor': criadoPor.trim(),
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoPor': atualizadoPor.trim(),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      };
}

class MissaoEvidenciaModel {
  const MissaoEvidenciaModel({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.referencia,
    required this.criadoPor,
    required this.criadoEm,
  });

  final String id;
  final String tipo;
  final String descricao;
  final String referencia;
  final String criadoPor;
  final DateTime criadoEm;

  factory MissaoEvidenciaModel.fromMap(Map<String, dynamic> map) {
    return MissaoEvidenciaModel(
      id: map['id']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      referencia: map['referencia']?.toString() ?? '',
      criadoPor: map['criadoPor']?.toString() ?? '',
      criadoEm: _dataObrigatoria(map['criadoEm']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id.trim(),
        'tipo': tipo.trim(),
        'descricao': descricao.trim(),
        'referencia': referencia.trim(),
        'criadoPor': criadoPor.trim(),
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}

class ExecucaoMissaoModel {
  ExecucaoMissaoModel({
    required this.id,
    required this.escalaAtividadeId,
    required this.escalaId,
    required this.data,
    required this.status,
    required this.resultadoResumo,
    required this.observacao,
    required Iterable<MissaoEvidenciaModel> evidencias,
    required this.executadoPorUsuarioId,
    required this.executadoPorMembroEquipeId,
    required this.executadoPorNomeSnapshot,
    required this.concluidoEm,
    required this.criadoEm,
    required this.atualizadoEm,
  }) : evidencias = List<MissaoEvidenciaModel>.unmodifiable(evidencias);

  final String id;
  final String escalaAtividadeId;
  final String escalaId;
  final DateTime data;
  final String status;
  final String resultadoResumo;
  final String observacao;
  final List<MissaoEvidenciaModel> evidencias;
  final String executadoPorUsuarioId;
  final String executadoPorMembroEquipeId;
  final String executadoPorNomeSnapshot;
  final DateTime? concluidoEm;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  factory ExecucaoMissaoModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    final evidenciasRaw = map['evidencias'];
    final evidencias = <MissaoEvidenciaModel>[];
    if (evidenciasRaw is Iterable) {
      for (final item in evidenciasRaw) {
        if (item is Map) {
          evidencias.add(
            MissaoEvidenciaModel.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return ExecucaoMissaoModel(
      id: documentId,
      escalaAtividadeId: map['escalaAtividadeId']?.toString() ?? '',
      escalaId: map['escalaId']?.toString() ?? '',
      data: _dataObrigatoria(map['data']),
      status: map['status']?.toString() ?? '',
      resultadoResumo: map['resultadoResumo']?.toString() ?? '',
      observacao: map['observacao']?.toString() ?? '',
      evidencias: evidencias,
      executadoPorUsuarioId: map['executadoPorUsuarioId']?.toString() ?? '',
      executadoPorMembroEquipeId:
          map['executadoPorMembroEquipeId']?.toString() ?? '',
      executadoPorNomeSnapshot:
          map['executadoPorNomeSnapshot']?.toString() ?? '',
      concluidoEm: _dataOpcional(map['concluidoEm']),
      criadoEm: _dataObrigatoria(map['criadoEm']),
      atualizadoEm: _dataObrigatoria(map['atualizadoEm']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'escalaAtividadeId': escalaAtividadeId.trim(),
        'escalaId': escalaId.trim(),
        'data': Timestamp.fromDate(data),
        'status': status.trim(),
        'resultadoResumo': resultadoResumo.trim(),
        'observacao': observacao.trim(),
        'evidencias': evidencias.map((item) => item.toMap()).toList(),
        'executadoPorUsuarioId': executadoPorUsuarioId.trim(),
        'executadoPorMembroEquipeId': executadoPorMembroEquipeId.trim(),
        'executadoPorNomeSnapshot': executadoPorNomeSnapshot.trim(),
        'concluidoEm':
            concluidoEm == null ? null : Timestamp.fromDate(concluidoEm!),
        'criadoEm': Timestamp.fromDate(criadoEm),
        'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      };
}

DateTime _dataObrigatoria(Object? valor) {
  if (valor is Timestamp) return valor.toDate();
  if (valor is DateTime) return valor;
  if (valor is String) {
    final data = DateTime.tryParse(valor);
    if (data != null) return data;
  }
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

DateTime? _dataOpcional(Object? valor) {
  if (valor == null) return null;
  return _dataObrigatoria(valor);
}

int _inteiro(Object? valor, {required int fallback}) {
  if (valor is int) return valor;
  return int.tryParse(valor?.toString() ?? '') ?? fallback;
}

List<String> _listaStrings(Object? valor) {
  if (valor is! Iterable) return const <String>[];
  return valor
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
