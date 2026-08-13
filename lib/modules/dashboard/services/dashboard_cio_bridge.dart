import '../../../core/services/dashboard_service.dart';
import '../../../data/models/acao_model.dart';
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
  });

  final DashboardService dashboardService;
  final CIOAnalyticsService analyticsService;

  DashboardCIOResult processar(List<AcaoModel> acoes) {
    final indicadores = dashboardService.calcularIndicadores(
      acoes,
      periodo: DashboardPeriodo.geral,
    );
    final resumo = _criarResumo(indicadores);
    final agregados = _criarAgregados(indicadores);
    final referencia = _criarReferencia(agregados);
    final ranking = analyticsService.gerarRanking(
      agregados: agregados,
      categoria: RankingCategoria.regional,
      referencia: referencia,
    );

    return DashboardCIOResult(
      indicadores: indicadores,
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

  CIOAnalyticsSummary _criarResumo(DashboardIndicadores indicadores) {
    return CIOAnalyticsSummary(
      totalAcoes: indicadores.totalAcoes,
      pessoasAlcancadas: indicadores.pessoasAlcancadas,
      veiculosAbordados: indicadores.veiculosAbordados,
      credenciaisEmitidas: indicadores.credenciaisEmitidas,
      percentualMetasAtingidas: indicadores.percentualMetasAtingidas,
    );
  }

  List<CIOAnalyticsAggregate> _criarAgregados(
    DashboardIndicadores indicadores,
  ) {
    return indicadores.rankingRegionais
        .map(
          (item) => CIOAnalyticsAggregate(
            id: _normalizarId(item.nome),
            nome: item.nome,
            acoes: item.quantidade,
            pessoasAlcancadas: item.pessoasAlcancadas,
            veiculosAbordados: item.veiculosAbordados,
            credenciaisEmitidas: item.credenciaisEmitidas,
            percentualMetasAtingidas: indicadores.percentualMetasAtingidas,
          ),
        )
        .toList(growable: false);
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
    required this.indicadoresEstrategicos,
    required this.rankingRegionais,
    required this.insights,
    required this.alertas,
    required this.recomendacoes,
  });

  final DashboardIndicadores indicadores;
  final List<IndicadorEstrategico> indicadoresEstrategicos;
  final List<RankingItem> rankingRegionais;
  final List<InsightOperacional> insights;
  final List<AlertaOperacional> alertas;
  final List<String> recomendacoes;
}
