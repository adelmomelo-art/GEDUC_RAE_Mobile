import '../analytics_indicator.dart';
import '../analytics_indicator_catalog.dart';
import '../analytics_indicator_value.dart';
import '../analytics_metrics.dart';

/// Calculadora institucional de indicadores do Framework Atlas.
///
/// Responsabilidades:
/// - receber métricas consolidadas pelo Analytics Engine;
/// - transformar métricas brutas em KPIs institucionais;
/// - associar cada resultado ao catálogo oficial de indicadores;
/// - disponibilizar consultas por categoria e identificador.
///
/// Esta classe não conhece:
/// - Flutter;
/// - Firebase;
/// - módulos operacionais;
/// - dashboards;
/// - banco de dados.
final class IndicatorCalculator {
  const IndicatorCalculator();

  /// Calcula todos os indicadores institucionais disponíveis.
  ///
  /// A lista resultante é imutável e segue a ordem definida
  /// pelo [AnalyticsIndicatorCatalog].
  List<AnalyticsIndicatorValue> calculateAll(
    AnalyticsMetrics metrics, {
    DateTime? referenceDate,
  }) {
    final peoplePerAgent = _safeDivision(
      metrics.totalPeople,
      metrics.totalHumanResources,
    );

    final vehiclesPerAgent = _safeDivision(
      metrics.totalVehicles,
      metrics.totalHumanResources,
    );

    final peoplePerAction = _safeDivision(
      metrics.totalPeople,
      metrics.totalRecords,
    );

    final vehiclesPerAction = _safeDivision(
      metrics.totalVehicles,
      metrics.totalRecords,
    );

    final operationalEfficiency = _calculateOperationalEfficiency(
      peoplePerAgent: peoplePerAgent,
      vehiclesPerAgent: vehiclesPerAgent,
    );

    final overallPerformance = _calculateOverallPerformance(
      metrics: metrics,
      operationalEfficiency: operationalEfficiency,
    );

    return List<AnalyticsIndicatorValue>.unmodifiable([
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.peopleReached,
        value: metrics.totalPeople.toDouble(),
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.vehiclesApproached,
        value: metrics.totalVehicles.toDouble(),
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.totalActions,
        value: metrics.totalRecords.toDouble(),
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.humanResources,
        value: metrics.totalHumanResources.toDouble(),
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.peoplePerAgent,
        value: peoplePerAgent,
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.vehiclesPerAgent,
        value: vehiclesPerAgent,
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.peoplePerAction,
        value: peoplePerAction,
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.vehiclesPerAction,
        value: vehiclesPerAction,
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.targetAchievement,
        value: metrics.targetAchievementRate,
        status: metrics.hasTargets
            ? _statusFromPercentage(
                metrics.targetAchievementRate,
              )
            : null,
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.synchronizationRate,
        value: 0,
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.operationalEfficiency,
        value: operationalEfficiency,
        referenceDate: referenceDate,
      ),
      AnalyticsIndicatorValue(
        indicator: AnalyticsIndicatorCatalog.overallPerformance,
        value: overallPerformance,
        status: metrics.hasTargets
            ? _statusFromPercentage(overallPerformance)
            : null,
        referenceDate: referenceDate,
      ),
    ]);
  }

  /// Calcula apenas os indicadores pertencentes à categoria informada.
  List<AnalyticsIndicatorValue> calculateByCategory(
    AnalyticsMetrics metrics,
    AnalyticsIndicatorCategory category, {
    DateTime? referenceDate,
  }) {
    final indicators = calculateAll(
      metrics,
      referenceDate: referenceDate,
    );

    return List<AnalyticsIndicatorValue>.unmodifiable(
      indicators.where(
        (value) => value.indicator.category == category,
      ),
    );
  }

  /// Calcula e localiza um indicador por seu identificador institucional.
  ///
  /// Retorna `null` quando o identificador não pertence ao catálogo
  /// ou não possui cálculo implementado nesta versão.
  AnalyticsIndicatorValue? findIndicator(
    AnalyticsMetrics metrics,
    String indicatorId, {
    DateTime? referenceDate,
  }) {
    final normalizedId = indicatorId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final value in calculateAll(
      metrics,
      referenceDate: referenceDate,
    )) {
      if (value.indicator.id == normalizedId) {
        return value;
      }
    }

    return null;
  }

  /// Divide dois valores de forma segura.
  ///
  /// Retorna zero quando o divisor é igual ou inferior a zero.
  double _safeDivision(
    num dividend,
    num divisor,
  ) {
    if (divisor <= 0) {
      return 0;
    }

    return dividend / divisor;
  }

  /// Calcula a eficiência operacional inicial do Atlas.
  ///
  /// Fórmula da versão 1.0:
  ///
  /// média entre:
  /// - pessoas alcançadas por recurso humano;
  /// - veículos abordados por recurso humano.
  ///
  /// Este indicador representa a produção operacional média
  /// por profissional envolvido.
  double _calculateOperationalEfficiency({
    required double peoplePerAgent,
    required double vehiclesPerAgent,
  }) {
    if (peoplePerAgent == 0 &&
        vehiclesPerAgent == 0) {
      return 0;
    }

    return (
      peoplePerAgent + vehiclesPerAgent
    ) / 2;
  }

  /// Calcula o Índice Geral de Desempenho.
  ///
  /// Quando existem metas, combina:
  /// - cumprimento da meta;
  /// - eficiência operacional.
  ///
  /// Quando não existem metas, utiliza apenas a eficiência
  /// operacional disponível.
  double _calculateOverallPerformance({
    required AnalyticsMetrics metrics,
    required double operationalEfficiency,
  }) {
    if (!metrics.hasData) {
      return 0;
    }

    if (!metrics.hasTargets) {
      return operationalEfficiency;
    }

    return (
      metrics.targetAchievementRate +
      operationalEfficiency
    ) / 2;
  }

  /// Classifica percentuais segundo faixas institucionais iniciais.
  AnalyticsIndicatorStatus _statusFromPercentage(
    double value,
  ) {
    if (value >= 90) {
      return AnalyticsIndicatorStatus.excellent;
    }

    if (value >= 75) {
      return AnalyticsIndicatorStatus.good;
    }

    if (value >= 50) {
      return AnalyticsIndicatorStatus.attention;
    }

    return AnalyticsIndicatorStatus.critical;
  }
}