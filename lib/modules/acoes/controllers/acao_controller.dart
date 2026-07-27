import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/acao_rules_service.dart';
import '../../../data/models/acao_model.dart';
import '../../../repositories/acao_repository.dart';

class AcaoController extends ChangeNotifier {
  final AcaoRepository acaoRepository;

  AcaoController({
    required this.acaoRepository,
  });

  AcaoModel? acaoAtual;
  String? erro;
  bool gerandoNumeroRae = false;
  bool carregandoRascunho = false;

  List<AcaoModel> pendentesSincronizacao = [];
  bool carregandoPendentes = false;
  bool sincronizandoPendentes = false;
  String? erroSincronizacao;

  List<AcaoModel> historicoComparacao = [];
  bool carregandoHistoricoComparacao = false;
  String? erroHistoricoComparacao;

  bool get possuiRascunhoEmAndamento {
    final acao = acaoAtual;

    if (acao == null) {
      return false;
    }

    return acao.status == 'rascunho' &&
        (acao.turno.isNotEmpty ||
            acao.nomeAcao.isNotEmpty ||
            acao.endereco.isNotEmpty ||
            acao.pessoasAlcancadas > 0 ||
            acao.fotosUrls.isNotEmpty);
  }

  String get resumoRascunho {
    final acao = acaoAtual;

    if (acao == null) {
      return 'Nenhum rascunho encontrado.';
    }

    if (acao.nomeAcao.isNotEmpty) {
      return acao.nomeAcao;
    }

    if (acao.turno.isNotEmpty) {
      return 'Ação iniciada no turno ${acao.turno}';
    }

    return 'Rascunho de ação educativa em andamento.';
  }

  String get rotaContinuacaoRascunho {
    final acao = acaoAtual;

    if (acao == null) {
      return '/nova-acao';
    }

    if (acao.turno.isEmpty || acao.nomeAcao.isEmpty) {
      return '/nova-acao';
    }

    if (!acao.localizacaoValidada ||
        (acao.endereco.isEmpty && acao.latitude == 0)) {
      return '/localizacao';
    }

    if (acao.formacaoId.isEmpty || acao.publicoId.isEmpty) {
      return '/caracterizacao';
    }

    if (acao.materialUtilizadoIds.isEmpty) {
      return '/recursos-operacionais';
    }

    if (acao.pessoasAlcancadas <= 0) {
      return '/resultados';
    }

    if (acao.fotosUrls.isEmpty) {
      return '/evidencias';
    }

    if (acao.notaAvaliacao < 1 ||
        acao.mudancaComportamentoId.isEmpty ||
        acao.pontosPositivos.trim().isEmpty ||
        acao.dificuldadesEncontradas.trim().isEmpty ||
        acao.recomendacoes.trim().isEmpty) {
      return '/avaliacao';
    }

    return '/revisao';
  }

  Future<bool> carregarRascunhoSeExistir() async {
    carregandoRascunho = true;
    notifyListeners();

    final rascunho = await acaoRepository.recuperarRascunho();

    acaoAtual = rascunho;

    carregandoRascunho = false;
    notifyListeners();

    return rascunho != null;
  }

  Future<void> carregarRascunhoOuCriarNovo() async {
    carregandoRascunho = true;
    notifyListeners();

    final rascunho = await acaoRepository.recuperarRascunho();

    if (rascunho != null) {
      acaoAtual = rascunho;
    } else {
      criarRascunhoInicial();
    }

    carregandoRascunho = false;
    notifyListeners();
  }

  Future<void> descartarRascunho() async {
    await acaoRepository.excluirRascunho();
    acaoAtual = null;
    notifyListeners();
  }

  void criarRascunhoInicial() {
    final agora = DateTime.now();

    acaoAtual = AcaoModel(
      id: const Uuid().v4(),
      numeroRAE: '',
      anoRAE: agora.year,
      dataAcao: agora,
      turno: '',
      nomeAcao: '',
      tipoAcao: '',
      publicoEstimado: 0,
      publicoMinimo: 0,
      acaoPlanejada: false,
      horaInicio: '${agora.hour}:${agora.minute}',
      pessoasAlcancadas: 0,
      veiculosAbordados: 0,
      credenciaisEmitidas: 0,
      metaAtingida: false,
      endereco: '',
      bairro: '',
      regional: '',
      equipamentoReferencia: '',
      nomeLocal: '',
      pontoReferencia: '',
      latitude: 0,
      longitude: 0,
      origemLocalizacao: null,
      precisaoGps: null,
      dataHoraCaptura: null,
      localizacaoValidada: false,
      localizacaoEditadaManualmente: false,
      fatorRiscoIds: const [],
      mudancaComportamentoId: '',
      formacaoId: '',
      publicoId: '',
      tipoParticipacaoIds: const [],
      focoTematicoIds: const [],
      perfilUsuarioIds: const [],
      sexoPredominanteId: '',
      instituicaoParceira: '',
      coordenadorId: '',
      coordenadorNome: '',
      agentesTransito: 0,
      equipeTerceirizada: 0,
      materialUtilizadoIds: const [],
      coberturaMidia: false,
      houveParticipacaoOutroOrgao: false,
      orgaoParticipanteId: '',
      notaAvaliacao: 0,
      pontosPositivos: '',
      dificuldadesEncontradas: '',
      recomendacoes: '',
      fotosUrls: const [],
      descricaoEvidencias: '',
      status: 'rascunho',
      sincronizado: false,
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  Future<void> _salvarRascunhoAtual() async {
    final acao = acaoAtual;

    if (acao == null) {
      return;
    }

    await acaoRepository.salvarRascunho(acao);
  }

  Future<void> garantirNumeroRae() async {
    if (acaoAtual == null) {
      criarRascunhoInicial();
    }

    if (acaoAtual!.numeroRAE.isNotEmpty) {
      return;
    }

    gerandoNumeroRae = true;
    notifyListeners();

    try {
      final numero = await acaoRepository.gerarNumeroRaeAutomatico();
      final ano = DateTime.now().year;

      acaoAtual = acaoAtual!.copyWith(
        numeroRAE: numero,
        anoRAE: ano,
      );

      await _salvarRascunhoAtual();
    } finally {
      gerandoNumeroRae = false;
      notifyListeners();
    }
  }

  void preencherDadosAcao({
    required DateTime dataAcao,
    required String turno,
    required String nomeAcao,
    required String tipoAcao,
    required int publicoEstimado,
    required int publicoMinimo,
    required bool acaoPlanejada,
    String? coordenadorId,
    String? coordenadorNome,
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    acaoAtual = acaoAtual!.copyWith(
      dataAcao: dataAcao,
      turno: turno,
      nomeAcao: nomeAcao,
      tipoAcao: tipoAcao,
      publicoEstimado: publicoEstimado,
      publicoMinimo: publicoMinimo,
      acaoPlanejada: acaoPlanejada,
      coordenadorId: coordenadorId,
      coordenadorNome: coordenadorNome,
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  void preencherLocalizacao({
    required String endereco,
    required String bairro,
    required String regional,
    required String equipamentoReferencia,
    required double latitude,
    required double longitude,
    String nomeLocal = '',
    String? pontoReferencia,
    OrigemLocalizacao? origemLocalizacao,
    double? precisaoGps,
    DateTime? dataHoraCaptura,
    bool localizacaoValidada = true,
    bool localizacaoEditadaManualmente = false,
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    final referenciaNormalizada =
        (pontoReferencia ?? equipamentoReferencia).trim();

    final origemNormalizada = origemLocalizacao ??
        ((latitude != 0 || longitude != 0)
            ? OrigemLocalizacao.gps
            : OrigemLocalizacao.enderecoInformado);

    acaoAtual = acaoAtual!.copyWith(
      endereco: endereco.trim(),
      bairro: bairro.trim(),
      regional: regional.trim(),
      equipamentoReferencia: referenciaNormalizada,
      nomeLocal: nomeLocal.trim(),
      pontoReferencia: referenciaNormalizada,
      latitude: latitude,
      longitude: longitude,
      origemLocalizacao: origemNormalizada,
      precisaoGps: precisaoGps,
      dataHoraCaptura: dataHoraCaptura ?? DateTime.now(),
      localizacaoValidada: localizacaoValidada,
      localizacaoEditadaManualmente: localizacaoEditadaManualmente,
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  void invalidarLocalizacao() {
    final acao = acaoAtual;

    if (acao == null || !acao.localizacaoValidada) {
      return;
    }

    acaoAtual = acao.copyWith(localizacaoValidada: false);
    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  void preencherCaracterizacao({
    required List<String> fatorRiscoIds,
    required String mudancaComportamentoId,
    required String formacaoId,
    required String publicoId,
    required List<String> tipoParticipacaoIds,
    required List<String> focoTematicoIds,
    required List<String> perfilUsuarioIds,
    required String sexoPredominanteId,
    required String instituicaoParceira,
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    acaoAtual = acaoAtual!.copyWith(
      fatorRiscoIds: fatorRiscoIds,
      mudancaComportamentoId: mudancaComportamentoId,
      formacaoId: formacaoId,
      publicoId: publicoId,
      tipoParticipacaoIds: tipoParticipacaoIds,
      focoTematicoIds: focoTematicoIds,
      perfilUsuarioIds: perfilUsuarioIds,
      sexoPredominanteId: sexoPredominanteId,
      instituicaoParceira: instituicaoParceira,
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  void preencherRecursosOperacionais({
    required int agentesTransito,
    required int equipeTerceirizada,
    required List<String> materialUtilizadoIds,
    required bool coberturaMidia,
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    acaoAtual = acaoAtual!.copyWith(
      agentesTransito: agentesTransito,
      equipeTerceirizada: equipeTerceirizada,
      materialUtilizadoIds: materialUtilizadoIds,
      coberturaMidia: coberturaMidia,
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  void preencherIntegracaoObservacoes({
    required bool houveParticipacaoOutroOrgao,
    required String orgaoParticipanteId,
    required String pontosPositivos,
    required String dificuldadesEncontradas,
    required String recomendacoes,
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    acaoAtual = acaoAtual!.copyWith(
      houveParticipacaoOutroOrgao: houveParticipacaoOutroOrgao,
      orgaoParticipanteId: orgaoParticipanteId,
      pontosPositivos: pontosPositivos,
      dificuldadesEncontradas: dificuldadesEncontradas,
      recomendacoes: recomendacoes,
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  void preencherResultados({
    required int pessoasAlcancadas,
    required int veiculosAbordados,
    required int credenciaisEmitidas,
    String? motivoMetaNaoAtingida,
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    final meta = AcaoRulesService.calcularMeta(
      pessoasAlcancadas: pessoasAlcancadas,
      publicoMinimo: acaoAtual!.publicoMinimo,
    );

    final agora = DateTime.now();

    acaoAtual = acaoAtual!.copyWith(
      pessoasAlcancadas: pessoasAlcancadas,
      veiculosAbordados: veiculosAbordados,
      credenciaisEmitidas: credenciaisEmitidas,
      metaAtingida: meta,
      motivoMetaNaoAtingida: motivoMetaNaoAtingida,
      horaFinal: '${agora.hour}:${agora.minute}',
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  void preencherEvidencias({
    required List<String> fotosUrls,
    required String descricaoEvidencias,
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    acaoAtual = acaoAtual!.copyWith(
      fotosUrls: fotosUrls,
      descricaoEvidencias: descricaoEvidencias,
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  void preencherAvaliacao({
    required int notaAvaliacao,
    required String mudancaComportamentoId,
    required List<String> fatorRiscoIds,
    required String pontosPositivos,
    required String dificuldadesEncontradas,
    required String recomendacoes,
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    final notaNormalizada = notaAvaliacao.clamp(0, 5);

    acaoAtual = acaoAtual!.copyWith(
      notaAvaliacao: notaNormalizada,
      mudancaComportamentoId: mudancaComportamentoId.trim(),
      fatorRiscoIds: fatorRiscoIds
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      pontosPositivos: pontosPositivos.trim(),
      dificuldadesEncontradas: dificuldadesEncontradas.trim(),
      recomendacoes: recomendacoes.trim(),
    );

    unawaited(_salvarRascunhoAtual());
    notifyListeners();
  }

  Future<void> carregarPendentesSincronizacao() async {
    carregandoPendentes = true;
    erroSincronizacao = null;
    notifyListeners();

    try {
      pendentesSincronizacao = await acaoRepository.listarPendentes();
    } catch (e) {
      erroSincronizacao = 'Erro ao carregar pendências: $e';
    }

    carregandoPendentes = false;
    notifyListeners();
  }

  Future<void> sincronizarPendentes() async {
    sincronizandoPendentes = true;
    erroSincronizacao = null;
    notifyListeners();

    try {
      await acaoRepository.sincronizarPendentes();
      pendentesSincronizacao = await acaoRepository.listarPendentes();
    } catch (e) {
      erroSincronizacao = 'Erro ao sincronizar pendências: $e';
    }

    sincronizandoPendentes = false;
    notifyListeners();
  }

  Future<void> carregarHistoricoComparacao() async {
    if (carregandoHistoricoComparacao) {
      return;
    }

    carregandoHistoricoComparacao = true;
    erroHistoricoComparacao = null;
    notifyListeners();

    try {
      historicoComparacao =
          await acaoRepository.listarAcoesOnlineFuture();
    } catch (e) {
      historicoComparacao = [];
      erroHistoricoComparacao =
          'Não foi possível carregar o histórico operacional: $e';
    } finally {
      carregandoHistoricoComparacao = false;
      notifyListeners();
    }
  }

  bool validarAntesDoEnvio() {
    erro = null;
    final acao = acaoAtual;

    if (acao == null) {
      erro = 'Nenhuma ação foi criada.';
      return false;
    }

    if (acao.turno.isEmpty) {
      erro = 'Informe o turno.';
      return false;
    }

    if (acao.nomeAcao.isEmpty) {
      erro = 'Informe o nome da ação.';
      return false;
    }

    if (!acao.localizacaoValidada ||
        (acao.endereco.isEmpty && acao.latitude == 0)) {
      erro = 'Confirme e valide a localização da ação.';
      return false;
    }

    if (acao.pontoReferencia.isEmpty &&
        acao.equipamentoReferencia.isEmpty) {
      erro = 'Informe o ponto de referência.';
      return false;
    }

    if (acao.formacaoId.isEmpty || acao.publicoId.isEmpty) {
      erro = 'Informe a caracterização da ação.';
      return false;
    }

    if (acao.materialUtilizadoIds.isEmpty) {
      erro = 'Informe os recursos operacionais utilizados.';
      return false;
    }

    if (acao.pessoasAlcancadas <= 0) {
      erro = 'Informe as pessoas alcançadas.';
      return false;
    }

    if (AcaoRulesService.motivoMetaObrigatorio(
      metaAtingida: acao.metaAtingida,
      motivo: acao.motivoMetaNaoAtingida,
    )) {
      erro = 'Informe o motivo da meta não atingida.';
      return false;
    }

    if (acao.notaAvaliacao < 1 || acao.notaAvaliacao > 5) {
      erro = 'Informe a avaliação geral da ação.';
      return false;
    }

    if (acao.mudancaComportamentoId.isEmpty) {
      erro = 'Informe a mudança de comportamento observada.';
      return false;
    }

    if (acao.fatorRiscoIds.isEmpty) {
      erro = 'Informe os fatores de risco observados.';
      return false;
    }

    if (acao.pontosPositivos.trim().isEmpty) {
      erro = 'Informe os pontos positivos da ação.';
      return false;
    }

    if (acao.dificuldadesEncontradas.trim().isEmpty) {
      erro = 'Informe as dificuldades encontradas.';
      return false;
    }

    if (acao.recomendacoes.trim().isEmpty) {
      erro = 'Informe as recomendações para ações futuras.';
      return false;
    }

    return true;
  }

  Future<bool> enviarRelatorio() async {
    if (!validarAntesDoEnvio()) {
      notifyListeners();
      return false;
    }

    await garantirNumeroRae();

    final conectado = await acaoRepository.temInternet();

    await acaoRepository.enviarAcao(acaoAtual!);

    acaoAtual = acaoAtual!.copyWith(
      status: conectado ? 'enviado' : 'pendente',
      sincronizado: conectado,
    );

    await acaoRepository.excluirRascunho();

    notifyListeners();
    return true;
  }
}
