import 'analytics_dashboard_model.dart';
import 'analytics_result.dart';
import 'calculators/indicator_calculator.dart';

/// Contrato institucional para construção de dashboards.
///
/// Permite que o [DashboardFactory] dependa de uma abstração,
/// facilitando testes unitários e futuras implementações alternativas.
///
/// Implementações deste contrato devem apenas transformar um
/// [AnalyticsResult] em um [AnalyticsDashboardModel].
abstract interface class DashboardBuilderBase {
  /// Constrói um dashboard institucional.
  AnalyticsDashboardModel build({
    required String id,
    required String title,
    required String domain,
    required AnalyticsResult result,
    String? description,
    DateTime? referenceStartDate,
    DateTime? referenceEndDate,
  });
}

/// Responsável por montar um [AnalyticsDashboardModel] a partir
/// do resultado produzido pelo Analytics Engine.
///
/// Não realiza cálculos analíticos diretamente.
/// Apenas orquestra os componentes do Core.
final class DashboardBuilder implements DashboardBuilderBase {
  const DashboardBuilder({
    IndicatorCalculator calculator =
        const IndicatorCalculator(),
  }) : _calculator = calculator;

  final IndicatorCalculator _calculator;

  /// Constrói um dashboard institucional.
  @override
  AnalyticsDashboardModel build({
    required String id,
    required String title,
    required String domain,
    required AnalyticsResult result,
    String? description,
    DateTime? referenceStartDate,
    DateTime? referenceEndDate,
  }) {
    final indicators = _calculator.calculateAll(
      result.metrics,
      referenceDate: result.processedAt,
    );

    return AnalyticsDashboardModel(
      id: id,
      title: title,
      description: description,
      domain: domain,
      generatedAt: result.processedAt,
      referenceStartDate: referenceStartDate,
      referenceEndDate: referenceEndDate,
      indicators: indicators,
      processedRecords: result.processedRecords,
      ignoredRecords: result.ignoredRecords,
      processingTime: result.processingTime,
      metadata: Map<String, Object?>.from(
        result.metadata,
      ),
    );
  }
}