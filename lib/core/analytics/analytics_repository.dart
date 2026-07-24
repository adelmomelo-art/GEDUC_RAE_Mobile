import 'analytics_dashboard_model.dart';
import 'analytics_indicator_value.dart';
import 'analytics_metrics.dart';
import 'analytics_query.dart';
import 'analytics_result.dart';

/// Contrato institucional do Framework Atlas.
///
/// Define a API oficial utilizada pelos consumidores do núcleo
/// analítico.
///
/// Esta interface não conhece:
/// - Firebase;
/// - Firestore;
/// - SQLite;
/// - REST;
/// - CSV;
/// - BI;
/// - Flutter.
///
/// Cada módulo deverá fornecer sua própria implementação.
abstract interface class AnalyticsRepository {
  /// Executa uma consulta analítica completa.
  Future<AnalyticsResult> execute(
    AnalyticsQuery query,
  );

  /// Produz um dashboard institucional.
  Future<AnalyticsDashboardModel> dashboard(
    AnalyticsQuery query,
  );

  /// Retorna apenas os indicadores calculados.
  Future<List<AnalyticsIndicatorValue>> indicators(
    AnalyticsQuery query,
  );

  /// Retorna somente as métricas consolidadas.
  Future<AnalyticsMetrics> metrics(
    AnalyticsQuery query,
  );

  /// Verifica se existem registros para a consulta.
  Future<bool> exists(
    AnalyticsQuery query,
  );

  /// Retorna a quantidade de registros encontrados.
  Future<int> count(
    AnalyticsQuery query,
  );

  /// Informa se o repositório suporta determinado domínio.
  bool supportsDomain(
    String domain,
  );

  /// Identificador institucional da implementação.
  String get repositoryName;

  /// Versão da implementação.
  String get repositoryVersion;
}