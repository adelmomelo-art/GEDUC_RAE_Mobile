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

    if (acao.endereco.isEmpty && acao.latitude == 0) {
      return '/localizacao';
    }

    if (acao.pessoasAlcancadas <= 0) {
      return '/resultados';
    }

    if (acao.fotosUrls.isEmpty) {
      return '/evidencias';
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
      latitude: 0,
      longitude: 0,
      coordenadorId: '',
      coordenadorNome: '',
      agentesTransito: 0,
      equipeTerceirizada: 0,
      materialUtilizadoIds: const [],
      houveParticipacaoOutroOrgao: false,
      orgaoParticipanteId: '',
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
  }) {
    if (acaoAtual == null) criarRascunhoInicial();

    acaoAtual = acaoAtual!.copyWith(
      endereco: endereco,
      bairro: bairro,
      regional: regional,
      equipamentoReferencia: equipamentoReferencia,
      latitude: latitude,
      longitude: longitude,
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

    if (acao.endereco.isEmpty && acao.latitude == 0) {
      erro = 'Informe a localização.';
      return false;
    }

    if (acao.equipamentoReferencia.isEmpty) {
      erro = 'Informe o equipamento ou ponto de referência.';
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
