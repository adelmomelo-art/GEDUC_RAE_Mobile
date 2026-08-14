import 'package:flutter/foundation.dart';

import '../../../core/analytics/analytics_metrics.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../core/services/firebase_acao_service.dart';
import '../../../core/services/offline_service.dart';
import '../../../core/services/localizacao/regional_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../data/models/acao_model.dart';
import '../../../data/models/regional_model.dart';
import '../models/cio_dashboard_filters.dart';
import '../models/cartography/cio_cartographic_models.dart';
import '../models/cartography/cio_geometry_models.dart';
import '../models/analytics/alerta_operacional.dart';
import '../models/analytics/indicador_estrategico.dart';
import '../models/analytics/insight_operacional.dart';
import '../models/analytics/ranking_item.dart';
import '../services/dashboard_cio_bridge.dart';
import '../services/cio_historical_territorial_service.dart';
import '../services/cio_cartographic_exclusion_repository.dart';
import '../services/cio_geometry_repository.dart';
import '../services/cio_territorial_aggregation_service.dart';
import '../services/cio_territorial_governance_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    FirebaseAcaoService? firebaseService,
    OfflineService? offlineService,
    DashboardCIOBridge? cioBridge,
    Future<List<RegionalModel>> Function()? regionalCatalogLoader,
    Future<CioGeometryDataset> Function()? geometryLoader,
    Future<List<CioCartographicExclusion>> Function()? exclusionLoader,
    CioTerritorialAggregationService? cartographicAggregationService,
    this.cartographyEnabled = false,
  })  : _firebaseService = firebaseService ?? FirebaseAcaoService(),
        _offlineService = offlineService ?? OfflineService(),
        _cioBridge = cioBridge ?? const DashboardCIOBridge(),
        _regionalCatalogLoader =
            regionalCatalogLoader ?? RegionalService().listarTodas,
        _geometryLoader = geometryLoader ?? CioGeometryRepository().load,
        _exclusionLoader =
            exclusionLoader ?? CioCartographicExclusionRepository().load,
        _cartographicAggregationService = cartographicAggregationService ??
            const CioTerritorialAggregationService() {
    _syncService = SyncService(
      offlineService: _offlineService,
      firebaseService: _firebaseService,
    );

    _syncService.addListener(_onSyncServiceChanged);
  }

  final FirebaseAcaoService _firebaseService;
  final OfflineService _offlineService;
  final DashboardCIOBridge _cioBridge;
  final Future<List<RegionalModel>> Function() _regionalCatalogLoader;
  final Future<CioGeometryDataset> Function() _geometryLoader;
  final Future<List<CioCartographicExclusion>> Function() _exclusionLoader;
  final CioTerritorialAggregationService _cartographicAggregationService;
  final bool cartographyEnabled;

  late final SyncService _syncService;

  DashboardIndicadores _indicadores = DashboardIndicadores.vazio();
  DashboardIndicadores? _indicadoresComparacao;
  AnalyticsMetrics _metricasOficiais = const AnalyticsMetrics();
  AnalyticsMetrics? _metricasComparacao;
  DashboardPeriodo _periodoSelecionado = DashboardPeriodo.geral;
  List<AcaoModel> _todasAsAcoes = const <AcaoModel>[];
  CioDashboardFilters _filtros = const CioDashboardFilters();
  List<IndicadorEstrategico> _indicadoresEstrategicos = const [];
  List<RankingItem> _rankingRegionais = const [];
  List<InsightOperacional> _insights = const [];
  List<AlertaOperacional> _alertasCio = const [];
  List<String> _recomendacoesCio = const [];
  CioTemporalAnalysis? _serieHistorica;
  CioTrendComparison? _comparacaoHistorica;
  CioDataQualityReport _qualidadeDados = const CioDataQualityReport(
    totalRecords: 0,
    recordsWithRegionalId: 0,
    recordsWithNeighborhood: 0,
    recordsWithValidCoordinates: 0,
    recordsWithValidatedLocation: 0,
    legacyTerritorialRecords: 0,
    unresolvedTerritorialRecords: 0,
    firstOccurrence: null,
    lastOccurrence: null,
  );
  List<CioTerritorialGroup> _territorios = const [];
  CioTerritorialCatalogSnapshot? _catalogoTerritorial;
  CioTerritorialGovernanceReport? _governancaTerritorial;
  CioTerritorialDiagnostic? _diagnosticoTerritorialDozeMeses;
  bool _catalogoTerritorialIndisponivel = false;
  CioGeometryDataset? _cartographicGeometry;
  List<CioCartographicExclusion> _cartographicExclusions = const [];
  CioCartographicAggregation? _cartographicAggregation;
  bool _cartographicFoundationUnavailable = false;

  bool _carregando = false;
  bool _online = false;
  String? _erro;
  int _totalPendentes = 0;
  int _totalSincronizadas = 0;
  DateTime? _ultimaSincronizacao;
  bool _disposed = false;

  DashboardIndicadores get indicadores => _indicadores;
  DashboardIndicadores? get indicadoresComparacao => _indicadoresComparacao;
  AnalyticsMetrics get metricasOficiais => _metricasOficiais;
  AnalyticsMetrics? get metricasComparacao => _metricasComparacao;
  DashboardPeriodo get periodoSelecionado => _periodoSelecionado;
  CioDashboardFilters get filtros => _filtros;
  List<AcaoModel> get todasAsAcoes => _todasAsAcoes;
  List<IndicadorEstrategico> get indicadoresEstrategicos =>
      _indicadoresEstrategicos;
  List<RankingItem> get rankingRegionais => _rankingRegionais;
  List<InsightOperacional> get insights => _insights;
  List<AlertaOperacional> get alertasCio => _alertasCio;
  List<String> get recomendacoesCio => _recomendacoesCio;
  CioTemporalAnalysis? get serieHistorica => _serieHistorica;
  CioTrendComparison? get comparacaoHistorica => _comparacaoHistorica;
  CioDataQualityReport get qualidadeDados => _qualidadeDados;
  List<CioTerritorialGroup> get territorios => _territorios;
  CioTerritorialGovernanceReport? get governancaTerritorial =>
      _governancaTerritorial;
  bool get catalogoTerritorialIndisponivel => _catalogoTerritorialIndisponivel;
  CioTerritorialDiagnostic? get diagnosticoTerritorialDozeMeses =>
      _diagnosticoTerritorialDozeMeses;
  CioGeometryDataset? get cartographicGeometry => _cartographicGeometry;
  CioCartographicAggregation? get cartographicAggregation =>
      _cartographicAggregation;
  bool get cartographicFoundationUnavailable =>
      _cartographicFoundationUnavailable;

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
        _carregarCatalogoTerritorialSeguro(),
        cartographyEnabled
            ? _carregarFundacaoCartograficaSegura()
            : Future<_CioCartographicFoundation?>.value(),
      ]);

      final acoes = resultados[0];
      final pendentes = resultados[1];
      final conectado = resultados[2];
      final regionais = resultados[3] as List<RegionalModel>?;
      final cartographic = resultados[4] as _CioCartographicFoundation?;

      _todasAsAcoes = List<AcaoModel>.from(acoes);
      _catalogoTerritorial = regionais == null
          ? null
          : CioTerritorialCatalogSnapshot(
              capturedAt: DateTime.now(),
              regionals: regionais,
            );
      _cartographicGeometry = cartographic?.geometry;
      _cartographicExclusions = cartographic?.exclusions ?? const [];
      _recalcularIndicadores();

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

  void aplicarFiltros(CioDashboardFilters filtros) {
    _filtros = filtros;
    _recalcularIndicadores();
    _notificar();
  }

  void limparFiltrosSecundarios() {
    _filtros = _filtros.copyWith(
      regional: '',
      tipoAcao: '',
      status: '',
      coordenador: '',
    );
    _recalcularIndicadores();
    _notificar();
  }

  void _recalcularIndicadores() {
    final agora = DateTime.now();
    final filtradas = _filtros.aplicar(_todasAsAcoes, agora);
    final faixaAtual = _filtros.intervalo(agora);
    final catalogo = _catalogoTerritorial;
    _diagnosticoTerritorialDozeMeses = catalogo == null
        ? null
        : _cioBridge.diagnosticarUltimosDozeMeses(
            _todasAsAcoes,
            catalogo,
            referencia: agora,
          );
    final resultado = _cioBridge.processar(
      filtradas,
      intervalo: faixaAtual,
      catalogoTerritorial: _catalogoTerritorial,
    );
    _indicadores = resultado.indicadores;
    _metricasOficiais = resultado.metricasOficiais;
    _indicadoresEstrategicos = resultado.indicadoresEstrategicos;
    _rankingRegionais = resultado.rankingRegionais;
    _insights = resultado.insights;
    _alertasCio = resultado.alertas;
    _recomendacoesCio = resultado.recomendacoes;
    _serieHistorica = resultado.serieHistorica;
    _qualidadeDados = resultado.qualidadeDados;
    _territorios = resultado.territorios;
    _governancaTerritorial = resultado.governancaTerritorial;
    final geometry = _cartographicGeometry;
    _cartographicAggregation = geometry == null
        ? null
        : _cartographicAggregationService.aggregate(
            filtradas,
            geometry,
            _cartographicExclusions,
          );
    final faixaComparacao = _filtros.intervaloComparacao(agora);
    if (faixaComparacao == null) {
      _indicadoresComparacao = null;
      _metricasComparacao = null;
      _comparacaoHistorica = null;
    } else {
      final comparacao = _cioBridge.processar(
        _filtros.aplicarFaixa(_todasAsAcoes, faixaComparacao),
        intervalo: faixaComparacao,
        catalogoTerritorial: _catalogoTerritorial,
      );
      _indicadoresComparacao = comparacao.indicadores;
      _metricasComparacao = comparacao.metricasOficiais;
      final serieAtual = resultado.serieHistorica;
      final serieAnterior = comparacao.serieHistorica;
      _comparacaoHistorica = serieAtual == null || serieAnterior == null
          ? null
          : _cioBridge.compararSeries(serieAtual, serieAnterior);
    }
  }

  Future<List<RegionalModel>?> _carregarCatalogoTerritorialSeguro() async {
    try {
      final regionais = await _regionalCatalogLoader();
      _catalogoTerritorialIndisponivel = false;
      return regionais;
    } catch (_) {
      _catalogoTerritorialIndisponivel = true;
      return null;
    }
  }

  Future<_CioCartographicFoundation?>
      _carregarFundacaoCartograficaSegura() async {
    try {
      final results = await Future.wait<dynamic>([
        _geometryLoader(),
        _exclusionLoader(),
      ]);
      _cartographicFoundationUnavailable = false;
      return _CioCartographicFoundation(
        geometry: results[0] as CioGeometryDataset,
        exclusions: List<CioCartographicExclusion>.from(results[1] as List),
      );
    } catch (_) {
      _cartographicFoundationUnavailable = true;
      return null;
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

class _CioCartographicFoundation {
  const _CioCartographicFoundation({
    required this.geometry,
    required this.exclusions,
  });

  final CioGeometryDataset geometry;
  final List<CioCartographicExclusion> exclusions;
}
