import 'package:flutter/foundation.dart';

import '../../../core/services/dashboard_service.dart';
import '../../../core/services/firebase_acao_service.dart';
import '../../../core/services/offline_service.dart';
import '../../../core/services/sync_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    FirebaseAcaoService? firebaseService,
    OfflineService? offlineService,
    DashboardService? dashboardService,
  })  : _firebaseService = firebaseService ?? FirebaseAcaoService(),
        _offlineService = offlineService ?? OfflineService(),
        _dashboardService = dashboardService ?? const DashboardService() {
    _syncService = SyncService(
      offlineService: _offlineService,
      firebaseService: _firebaseService,
    );

    _syncService.addListener(_onSyncServiceChanged);
  }

  final FirebaseAcaoService _firebaseService;
  final OfflineService _offlineService;
  final DashboardService _dashboardService;

  late final SyncService _syncService;

  DashboardIndicadores _indicadores = DashboardIndicadores.vazio();
  DashboardPeriodo _periodoSelecionado = DashboardPeriodo.geral;

  bool _carregando = false;
  bool _online = false;
  String? _erro;
  int _totalPendentes = 0;
  int _totalSincronizadas = 0;
  DateTime? _ultimaSincronizacao;
  bool _disposed = false;

  DashboardIndicadores get indicadores => _indicadores;
  DashboardPeriodo get periodoSelecionado => _periodoSelecionado;

  bool get carregando => _carregando;
  bool get sincronizando => _syncService.sincronizando;
  bool get online => _online;
  String? get erro => _erro;

  int get totalPendentes => _totalPendentes;
  int get totalSincronizadas => _totalSincronizadas;
  DateTime? get ultimaSincronizacao => _ultimaSincronizacao;

  String get periodoSelecionadoLabel => _periodoSelecionado.label;

  Future<void> carregarDashboard({
    bool notificarInicio = true,
  }) async {
    if (notificarInicio) {
      _carregando = true;
      _erro = null;
      _notificar();
    }

    try {
      final resultados = await Future.wait<dynamic>([
        _firebaseService.listarAcoesFuture(),
        _offlineService.listarAcoesPendentes(),
        _syncService.temInternet(),
      ]);

      final acoes = resultados[0];
      final pendentes = resultados[1];
      final conectado = resultados[2];

      _indicadores = _dashboardService.calcularIndicadores(
        acoes,
        periodo: _periodoSelecionado,
      );

      _totalPendentes = pendentes.length;
      _online = conectado;
      _totalSincronizadas = _syncService.totalSincronizadas;
      _erro = null;
    } catch (e) {
      _erro = 'Não foi possível atualizar o dashboard: $e';
    } finally {
      _carregando = false;
      _notificar();
    }
  }

  Future<void> alterarPeriodo(
    DashboardPeriodo periodo,
  ) async {
    if (_periodoSelecionado == periodo) {
      return;
    }

    _periodoSelecionado = periodo;
    await carregarDashboard();
  }

  Future<void> alterarPeriodoPorLabel(
    String label,
  ) async {
    final periodo = DashboardPeriodo.values.firstWhere(
      (item) => item.label == label,
      orElse: () => DashboardPeriodo.geral,
    );

    await alterarPeriodo(periodo);
  }

  Future<String> sincronizarAgora() async {
    _erro = null;
    _notificar();

    try {
      await _syncService.sincronizarAcoesPendentes();

      final resultados = await Future.wait<dynamic>([
        _offlineService.listarAcoesPendentes(),
        _syncService.temInternet(),
      ]);

      final pendentes = resultados[0];
      final conectado = resultados[1];

      _totalPendentes = pendentes.length;
      _totalSincronizadas = _syncService.totalSincronizadas;
      _online = conectado;
      _ultimaSincronizacao = DateTime.now();

      if (_syncService.erro != null) {
        _erro = _syncService.erro;
      }

      await carregarDashboard(notificarInicio: false);

      return _syncService.erro == null
          ? 'Sincronização concluída.'
          : _syncService.erro!;
    } catch (e) {
      _erro = 'Não foi possível concluir a sincronização: $e';
      _notificar();
      return _erro!;
    }
  }

  void limparErro() {
    if (_erro == null) {
      return;
    }

    _erro = null;
    _notificar();
  }

  void _onSyncServiceChanged() {
    _totalSincronizadas = _syncService.totalSincronizadas;

    if (_syncService.erro != null) {
      _erro = _syncService.erro;
    }

    _notificar();
  }

  void _notificar() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _syncService.removeListener(_onSyncServiceChanged);
    _syncService.dispose();
    super.dispose();
  }
}
