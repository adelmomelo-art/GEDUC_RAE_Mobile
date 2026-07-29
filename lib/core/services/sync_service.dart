import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/acao_model.dart';
import 'firebase_acao_service.dart';
import 'offline_service.dart';

class SyncService extends ChangeNotifier {
  static const _keyAcoesPendentes = 'acoes_pendentes';

  SyncService({
    required this.offlineService,
    required this.firebaseService,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final OfflineService offlineService;
  final FirebaseAcaoService firebaseService;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool sincronizando = false;
  int totalPendentes = 0;
  int totalSincronizadas = 0;
  String? erro;

  int _falhasConsecutivasSincronizacao = 0;
  int get falhasConsecutivasSincronizacao => _falhasConsecutivasSincronizacao;

  bool? _conectado;
  bool get conectado => _conectado ?? false;

  bool get monitoramentoAtivo => _connectivitySubscription != null;

  int _reconexoesDetectadas = 0;
  int get reconexoesDetectadas => _reconexoesDetectadas;

  DateTime? _ultimaMudancaConectividadeEm;
  DateTime? get ultimaMudancaConectividadeEm => _ultimaMudancaConectividadeEm;

  DateTime? _ultimaTentativaSincronizacaoEm;
  DateTime? get ultimaTentativaSincronizacaoEm =>
      _ultimaTentativaSincronizacaoEm;

  DateTime? _ultimaSincronizacaoBemSucedidaEm;
  DateTime? get ultimaSincronizacaoBemSucedidaEm =>
      _ultimaSincronizacaoBemSucedidaEm;

  Future<void> iniciarMonitoramento() async {
    if (_connectivitySubscription != null) return;

    final resultadoInicial = await _connectivity.checkConnectivity();
    _registrarConectividade(resultadoInicial, contarReconexao: false);
    await atualizarTotalPendentes();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _registrarConectividade,
      onError: (_) {
        _registrarConectividade(const [ConnectivityResult.none]);
      },
    );
  }

  Future<bool> temInternet() async {
    try {
      final resultado = await _connectivity
          .checkConnectivity()
          .timeout(const Duration(seconds: 5));

      _registrarConectividade(resultado, contarReconexao: false);
      return _possuiRede(resultado);
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> atualizarTotalPendentes() async {
    try {
      final pendentes = await offlineService.listarAcoesPendentes();
      final novoTotal = pendentes.length;

      if (novoTotal == totalPendentes) return;

      totalPendentes = novoTotal;
      notifyListeners();
    } catch (_) {
      // O monitoramento não deve falhar por uma leitura local.
    }
  }

  Future<void> sincronizarAcoesPendentes() async {
    if (sincronizando) return;

    erro = null;
    _ultimaTentativaSincronizacaoEm = DateTime.now();
    notifyListeners();

    final conectadoAgora = await temInternet();

    if (!conectadoAgora) {
      erro = 'Sem conexão com a internet.';
      _registrarFalhaSincronizacao();
      notifyListeners();
      return;
    }

    final pendentes = await offlineService.listarAcoesPendentes();

    if (pendentes.isEmpty) {
      totalPendentes = 0;
      totalSincronizadas = 0;
      _registrarSincronizacaoBemSucedida();
      notifyListeners();
      return;
    }

    sincronizando = true;
    totalPendentes = pendentes.length;
    totalSincronizadas = 0;
    notifyListeners();

    final naoSincronizadas = <AcaoModel>[];

    for (final acao in pendentes) {
      try {
        await firebaseService.salvarAcao(
          acao.copyWith(
            sincronizado: true,
            status: 'enviado',
          ),
        );

        totalSincronizadas++;
        notifyListeners();
      } catch (_) {
        naoSincronizadas.add(acao);
      }
    }

    await _salvarPendenciasRestantes(naoSincronizadas);

    sincronizando = false;
    totalPendentes = naoSincronizadas.length;

    if (naoSincronizadas.isNotEmpty) {
      erro =
          '${naoSincronizadas.length} ação(ões) não puderam ser sincronizadas.';
      _registrarFalhaSincronizacao();
    } else {
      _registrarSincronizacaoBemSucedida();
    }

    notifyListeners();
  }

  void _registrarFalhaSincronizacao() {
    _falhasConsecutivasSincronizacao++;
  }

  void _registrarSincronizacaoBemSucedida() {
    _falhasConsecutivasSincronizacao = 0;
    erro = null;
    _ultimaSincronizacaoBemSucedidaEm = DateTime.now();
  }

  void _registrarConectividade(
    List<ConnectivityResult> resultados, {
    bool contarReconexao = true,
  }) {
    final novoEstado = _possuiRede(resultados);
    final estadoAnterior = _conectado;

    if (estadoAnterior == novoEstado) return;

    _conectado = novoEstado;
    _ultimaMudancaConectividadeEm = DateTime.now();

    if (contarReconexao && estadoAnterior == false && novoEstado) {
      _reconexoesDetectadas++;
    }

    notifyListeners();
  }

  bool _possuiRede(List<ConnectivityResult> resultados) {
    return resultados.isNotEmpty &&
        resultados.any((resultado) => resultado != ConnectivityResult.none);
  }

  Future<void> _salvarPendenciasRestantes(List<AcaoModel> acoes) async {
    final prefs = await SharedPreferences.getInstance();

    if (acoes.isEmpty) {
      await prefs.remove(_keyAcoesPendentes);
      return;
    }

    final lista = acoes.map((acao) => jsonEncode(acao.toMap())).toList();

    await prefs.setStringList(_keyAcoesPendentes, lista);
  }

  @override
  void dispose() {
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
    super.dispose();
  }
}
