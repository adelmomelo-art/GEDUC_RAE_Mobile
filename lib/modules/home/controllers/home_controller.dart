import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_acao_service.dart';
import '../../../core/services/offline_service.dart';
import '../../../core/services/sync_service.dart';
import '../../acoes/controllers/acao_controller.dart';
import '../domain/operational_rule.dart';
import '../domain/operational_rule_engine.dart';
import '../models/home_operational_status.dart';
import '../models/home_state.dart';
import '../services/home_loader_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    HomeLoaderService? loaderService,
    SyncService? syncService,
    OperationalRuleEngine? ruleEngine,
  })  : _loaderService = loaderService ?? HomeLoaderService(),
        _syncService = syncService ??
            SyncService(
              offlineService: OfflineService(),
              firebaseService: FirebaseAcaoService(),
            ),
        _ruleEngine = ruleEngine ?? OperationalRuleEngine.standard(),
        _deveDescartarSyncService = syncService == null {
    _syncService.addListener(_observarSyncService);
    unawaited(_iniciarMonitoramento());
  }

  final HomeLoaderService _loaderService;
  final SyncService _syncService;
  final OperationalRuleEngine _ruleEngine;
  final bool _deveDescartarSyncService;

  HomeState _state = const HomeState();
  HomeState get state => _state;

  AcaoController? _acaoControllerAtual;

  bool _sincronizacaoAutomaticaEmAndamento = false;
  int _ultimaReconexaoProcessada = 0;
  DateTime? _ultimaAtualizacaoAutomaticaSolicitadaEm;

  bool _disposed = false;

  Future<void> _iniciarMonitoramento() async {
    await _syncService.iniciarMonitoramento();
    if (_disposed) return;
    _atualizarMonitoramentoOperacional();
  }

  Future<void> carregarPortal({
    required AcaoController acaoController,
  }) async {
    _acaoControllerAtual = acaoController;

    _emitir(
      _state.copyWith(
        status: HomeStatus.carregando,
        removerMensagem: true,
      ),
    );

    try {
      await acaoController
          .carregarRascunhoSeExistir()
          .timeout(const Duration(seconds: 4));

      await _syncService.atualizarTotalPendentes();
      final resultado = await _loaderService.carregar();

      _emitir(_estadoDoResultado(resultado));
    } on TimeoutException {
      _emitir(
        _state.copyWith(
          status: HomeStatus.offline,
          mensagem:
              'O carregamento local demorou além do esperado. O Centro de Operação foi liberado em modo offline.',
        ),
      );
    } catch (_) {
      _emitir(
        _state.copyWith(
          status: HomeStatus.erro,
          mensagem:
              'Não foi possível atualizar os indicadores, mas os recursos locais continuam disponíveis.',
        ),
      );
    } finally {
      if (_state.status == HomeStatus.carregando) {
        _emitir(
          _state.copyWith(
            status: HomeStatus.erro,
            mensagem:
                'O carregamento foi encerrado com segurança. Tente atualizar novamente quando houver conexão.',
          ),
        );
      }
    }
  }

  Future<void> atualizar({
    required AcaoController acaoController,
  }) {
    return carregarPortal(acaoController: acaoController);
  }

  void _observarSyncService() {
    if (_disposed) return;

    _atualizarMonitoramentoOperacional();

    final reconexaoAtual = _syncService.reconexoesDetectadas;

    if (reconexaoAtual <= _ultimaReconexaoProcessada) return;

    _ultimaReconexaoProcessada = reconexaoAtual;
    unawaited(_sincronizarAposReconexao());
  }

  void _atualizarMonitoramentoOperacional() {
    _emitir(
      _state.copyWith(
        monitoramentoOperacional: HomeOperationalStatus(
          conectado: _syncService.conectado,
          monitoramentoAtivo: _syncService.monitoramentoAtivo,
          sincronizando: _syncService.sincronizando,
          totalPendentes: _syncService.totalPendentes,
          totalSincronizadas: _syncService.totalSincronizadas,
          falhasConsecutivasSincronizacao:
              _syncService.falhasConsecutivasSincronizacao,
          erro: _syncService.erro,
          ultimaMudancaConectividadeEm:
              _syncService.ultimaMudancaConectividadeEm,
          ultimaTentativaSincronizacaoEm:
              _syncService.ultimaTentativaSincronizacaoEm,
          ultimaSincronizacaoBemSucedidaEm:
              _syncService.ultimaSincronizacaoBemSucedidaEm,
        ),
      ),
    );
  }

  Future<void> _sincronizarAposReconexao() async {
    final acaoController = _acaoControllerAtual;

    if (acaoController == null || _sincronizacaoAutomaticaEmAndamento) {
      return;
    }

    final agora = DateTime.now();
    final ultimaSolicitacao = _ultimaAtualizacaoAutomaticaSolicitadaEm;

    if (ultimaSolicitacao != null &&
        agora.difference(ultimaSolicitacao) < const Duration(seconds: 20)) {
      return;
    }

    _ultimaAtualizacaoAutomaticaSolicitadaEm = agora;
    _sincronizacaoAutomaticaEmAndamento = true;

    _emitir(
      _state.copyWith(
        sincronizandoDashboard: true,
      ),
    );

    try {
      await _syncService.sincronizarAcoesPendentes();

      final resultado = await _loaderService.carregarRemoto();

      _emitir(
        _estadoDoResultado(
          resultado,
          ultimaSincronizacaoAutomaticaEm: DateTime.now(),
        ),
      );
    } on TimeoutException {
      _finalizarSincronizacaoComFalha(
        'A conexão retornou, mas o servidor não respondeu no tempo esperado. Os dados anteriores foram preservados.',
      );
    } catch (_) {
      _finalizarSincronizacaoComFalha(
        'A conexão retornou, mas não foi possível atualizar o painel. Os dados anteriores foram preservados.',
      );
    } finally {
      _sincronizacaoAutomaticaEmAndamento = false;

      if (_state.sincronizandoDashboard) {
        _emitir(
          _state.copyWith(
            sincronizandoDashboard: false,
          ),
        );
      }
    }
  }

  HomeState _estadoDoResultado(
    HomeLoaderResult resultado, {
    DateTime? ultimaSincronizacaoAutomaticaEm,
  }) {
    return HomeState(
      status: resultado.online ? HomeStatus.online : HomeStatus.offline,
      totalAcoes: resultado.totalAcoes,
      totalPessoas: resultado.totalPessoas,
      totalVeiculos: resultado.totalVeiculos,
      totalCredenciais: resultado.totalCredenciais,
      ultimosRaes: resultado.ultimosRaes,
      mensagem: resultado.mensagem,
      dadosEmCache: resultado.dadosEmCache,
      cacheDisponivel: resultado.cacheDisponivel,
      atualizadoEm: resultado.atualizadoEm,
      sincronizandoDashboard: false,
      ultimaSincronizacaoAutomaticaEm: ultimaSincronizacaoAutomaticaEm ??
          _state.ultimaSincronizacaoAutomaticaEm,
      monitoramentoOperacional: _state.monitoramentoOperacional,
      alertasOperacionais: _state.alertasOperacionais,
    );
  }

  OperationalRuleContext _criarContextoDeRegras(HomeState estado) {
    final monitoramento = estado.monitoramentoOperacional;

    return OperationalRuleContext(
      now: DateTime.now(),
      isConnected: monitoramento.conectado,
      pendingSyncCount: monitoramento.totalPendentes,
      consecutiveSyncFailures: monitoramento.falhasConsecutivasSincronizacao,
      offlineSince: monitoramento.conectado
          ? null
          : monitoramento.ultimaMudancaConectividadeEm,
      lastCacheUpdate: estado.atualizadoEm,
      lastOperationalUpdate: estado.atualizadoEm,
      lastSuccessfulSync: monitoramento.ultimaSincronizacaoBemSucedidaEm ??
          estado.ultimaSincronizacaoAutomaticaEm,
    );
  }

  HomeState _avaliarAlertasOperacionais(HomeState estado) {
    if (estado.status == HomeStatus.inicial ||
        estado.status == HomeStatus.carregando) {
      return estado.copyWith(
        alertasOperacionais: const [],
      );
    }

    final alertas = _ruleEngine.evaluate(
      _criarContextoDeRegras(estado),
    );

    return estado.copyWith(
      alertasOperacionais: alertas,
    );
  }

  void _finalizarSincronizacaoComFalha(String mensagem) {
    _emitir(
      _state.copyWith(
        status:
            _state.possuiDadosOperacionais ? _state.status : HomeStatus.offline,
        sincronizandoDashboard: false,
        mensagem: _state.possuiDadosOperacionais ? _state.mensagem : mensagem,
      ),
    );
  }

  void _emitir(HomeState novoEstado) {
    if (_disposed) return;

    _state = _avaliarAlertasOperacionais(novoEstado);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _syncService.removeListener(_observarSyncService);

    if (_deveDescartarSyncService) {
      _syncService.dispose();
    }

    super.dispose();
  }
}
