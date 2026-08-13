import '../../../core/analytics/analytics_engine.dart';
import '../../../core/analytics/analytics_metrics.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../data/models/acao_model.dart';
import '../../educacao/analytics/educacao_analytics_adapter.dart';
import '../models/analytics/alerta_operacional.dart';
import '../models/analytics/analytics_enums.dart';
import '../models/analytics/indicador_estrategico.dart';
import '../models/analytics/insight_operacional.dart';
import '../models/analytics/ranking_item.dart';
import 'cio_analytics_service.dart';
import 'performance_score_engine.dart';

/// Fachada única entre os dados filtrados do CIO e os motores analíticos.
class DashboardCIOBridge {
  const DashboardCIOBridge({
    this.dashboardService = const DashboardService(),
    this.analyticsService = const CIOAnalyticsService(),
    this.analyticsEngine = const AnalyticsEngine(),
    this.educacaoAdapter = const EducacaoAnalyticsAdapter(),
  });

  final DashboardService dashboardService;
  final CIOAnalyticsService analyticsService;
  final AnalyticsEngine analyticsEngine;
  final EducacaoAnalyticsAdapter educacaoAdapter;

  DashboardCIOResult processar(List<AcaoModel> acoes) {
    final indicadores = dashboardService.calcularIndicadores(
      acoes,
      periodo: DashboardPeriodo.geral,
    );
    final resultadoOficial = analyticsEngine.process(
      records: educacaoAdapter.toAnalyticsRecords(acoes),
    );
    final resumo = _criarResumo(
      resultadoOficial.metrics,
      indicadores,
    );
    final agregados = _criarAgregados(acoes);
    final referencia = _criarReferencia(agregados);
    final ranking = analyticsService.gerarRanking(
      agregados: agregados,
      categoria: RankingCategoria.regional,
      referencia: referencia,
    );

    return DashboardCIOResult(
      indicadores: indicadores,
      metricasOficiais: resultadoOficial.metrics,
      indicadoresEstrategicos:
          analyticsService.gerarIndicadores(resumo: resumo),
      rankingRegionais: ranking,
      insights: analyticsService.gerarInsights(
        resumo: resumo,
        ranking: ranking,
      ),
      alertas: analyticsService.gerarAlertas(
        resumo: resumo,
        ranking: ranking,
      ),
      recomendacoes: analyticsService.gerarRecomendacoes(
        resumo: resumo,
        ranking: ranking,
      ),
    );
  }

  CIOAnalyticsSummary _criarResumo(
    AnalyticsMetrics metricas,
    DashboardIndicadores indicadores,
  ) {
    return CIOAnalyticsSummary(
      totalAcoes: metricas.totalRecords,
      pessoasAlcancadas: metricas.totalPeople,
      veiculosAbordados: metricas.totalVehicles,
      credenciaisEmitidas: indicadores.credenciaisEmitidas,
      percentualMetasAtingidas: metricas.targetAchievementRate * 100,
    );
  }

  List<CIOAnalyticsAggregate> _criarAgregados(List<AcaoModel> acoes) {
    final grupos = <String, List<AcaoModel>>{};
    for (final acao in acoes) {
      final regional =
          acao.regional.trim().isEmpty ? 'Não informado' : acao.regional.trim();
      grupos.putIfAbsent(regional, () => <AcaoModel>[]).add(acao);
    }

    return grupos.entries.map((entry) {
      final acoesRegionais = entry.value;
      final metricas = analyticsEngine
          .process(
            records: educacaoAdapter.toAnalyticsRecords(acoesRegionais),
          )
          .metrics;

      return CIOAnalyticsAggregate(
        id: _normalizarId(entry.key),
        nome: entry.key,
        acoes: metricas.totalRecords,
        pessoasAlcancadas: metricas.totalPeople,
        veiculosAbordados: metricas.totalVehicles,
        credenciaisEmitidas: acoesRegionais.fold<int>(
          0,
          (total, acao) => total + acao.credenciaisEmitidas,
        ),
        percentualMetasAtingidas: metricas.targetAchievementRate * 100,
      );
    }).toList(growable: false);
  }

  PerformanceScoreReference _criarReferencia(
    List<CIOAnalyticsAggregate> agregados,
  ) {
    int maximo(int Function(CIOAnalyticsAggregate item) valor) {
      return agregados.fold<int>(0, (atual, item) {
        final candidato = valor(item);
        return candidato > atual ? candidato : atual;
      });
    }

    return PerformanceScoreReference(
      actions: maximo((item) => item.acoes),
      peopleReached: maximo((item) => item.pessoasAlcancadas),
      vehiclesApproached: maximo((item) => item.veiculosAbordados),
      credentialsIssued: maximo((item) => item.credenciaisEmitidas),
    );
  }

  String _normalizarId(String valor) {
    return valor
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}

class DashboardCIOResult {
  const DashboardCIOResult({
    required this.indicadores,
    required this.metricasOficiais,
    required this.indicadoresEstrategicos,
    required this.rankingRegionais,
    required this.insights,
    required this.alertas,
    required this.recomendacoes,
  });

  final DashboardIndicadores indicadores;
  final AnalyticsMetrics metricasOficiais;
  final List<IndicadorEstrategico> indicadoresEstrategicos;
  final List<RankingItem> rankingRegionais;
  final List<InsightOperacional> insights;
  final List<AlertaOperacional> alertas;
  final List<String> recomendacoes;
}
