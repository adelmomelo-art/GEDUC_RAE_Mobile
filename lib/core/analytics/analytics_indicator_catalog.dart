import 'analytics_indicator.dart';

/// Catálogo institucional de indicadores do Framework Atlas.
///
/// Centraliza a definição oficial dos KPIs utilizados por todos
/// os módulos da Plataforma Fênix.
///
/// Esta classe não realiza cálculos.
/// Apenas disponibiliza indicadores padronizados.
abstract final class AnalyticsIndicatorCatalog {
  const AnalyticsIndicatorCatalog._();

  // ==========================
  // OPERAÇÃO
  // ==========================

  static const peopleReached = AnalyticsIndicator(
    id: 'people_reached',
    name: 'Pessoas Alcançadas',
    description: 'Quantidade total de pessoas alcançadas.',
    category: AnalyticsIndicatorCategory.operation,
    unit: AnalyticsIndicatorUnit.people,
    format: AnalyticsIndicatorFormat.integer,
  );

  static const vehiclesApproached = AnalyticsIndicator(
    id: 'vehicles_approached',
    name: 'Veículos Abordados',
    description: 'Quantidade total de veículos abordados.',
    category: AnalyticsIndicatorCategory.operation,
    unit: AnalyticsIndicatorUnit.vehicles,
    format: AnalyticsIndicatorFormat.integer,
  );

  static const totalActions = AnalyticsIndicator(
    id: 'total_actions',
    name: 'Total de Ações',
    description: 'Quantidade de ações executadas.',
    category: AnalyticsIndicatorCategory.operation,
    unit: AnalyticsIndicatorUnit.actions,
    format: AnalyticsIndicatorFormat.integer,
  );

  static const humanResources = AnalyticsIndicator(
    id: 'human_resources',
    name: 'Recursos Humanos',
    description: 'Quantidade de profissionais envolvidos.',
    category: AnalyticsIndicatorCategory.operation,
    unit: AnalyticsIndicatorUnit.count,
    format: AnalyticsIndicatorFormat.integer,
  );

  // ==========================
  // PRODUTIVIDADE
  // ==========================

  static const peoplePerAgent = AnalyticsIndicator(
    id: 'people_per_agent',
    name: 'Pessoas por Agente',
    description: 'Produtividade média por agente.',
    category: AnalyticsIndicatorCategory.productivity,
    unit: AnalyticsIndicatorUnit.peoplePerAgent,
    format: AnalyticsIndicatorFormat.decimal,
  );

  static const vehiclesPerAgent = AnalyticsIndicator(
    id: 'vehicles_per_agent',
    name: 'Veículos por Agente',
    description: 'Produtividade média por agente.',
    category: AnalyticsIndicatorCategory.productivity,
    unit: AnalyticsIndicatorUnit.vehiclesPerAgent,
    format: AnalyticsIndicatorFormat.decimal,
  );

  static const peoplePerAction = AnalyticsIndicator(
    id: 'people_per_action',
    name: 'Pessoas por Ação',
    description: 'Média de pessoas alcançadas por ação.',
    category: AnalyticsIndicatorCategory.productivity,
    unit: AnalyticsIndicatorUnit.people,
    format: AnalyticsIndicatorFormat.decimal,
  );

  static const vehiclesPerAction = AnalyticsIndicator(
    id: 'vehicles_per_action',
    name: 'Veículos por Ação',
    description: 'Média de veículos abordados por ação.',
    category: AnalyticsIndicatorCategory.productivity,
    unit: AnalyticsIndicatorUnit.vehicles,
    format: AnalyticsIndicatorFormat.decimal,
  );

  // ==========================
  // QUALIDADE
  // ==========================

  static const targetAchievement = AnalyticsIndicator(
    id: 'target_achievement',
    name: 'Cumprimento da Meta',
    description: 'Percentual de metas atingidas.',
    category: AnalyticsIndicatorCategory.quality,
    unit: AnalyticsIndicatorUnit.percentage,
    format: AnalyticsIndicatorFormat.percentage,
  );

  static const synchronizationRate = AnalyticsIndicator(
    id: 'synchronization_rate',
    name: 'Taxa de Sincronização',
    description: 'Percentual de registros sincronizados.',
    category: AnalyticsIndicatorCategory.quality,
    unit: AnalyticsIndicatorUnit.percentage,
    format: AnalyticsIndicatorFormat.percentage,
  );

  // ==========================
  // ESTRATÉGICOS
  // ==========================

  static const operationalEfficiency = AnalyticsIndicator(
    id: 'operational_efficiency',
    name: 'Eficiência Operacional',
    description: 'Indicador geral de eficiência operacional.',
    category: AnalyticsIndicatorCategory.strategic,
    unit: AnalyticsIndicatorUnit.score,
    format: AnalyticsIndicatorFormat.decimal,
  );

  static const overallPerformance = AnalyticsIndicator(
    id: 'overall_performance',
    name: 'Índice Geral de Desempenho',
    description: 'Indicador consolidado de desempenho.',
    category: AnalyticsIndicatorCategory.strategic,
    unit: AnalyticsIndicatorUnit.score,
    format: AnalyticsIndicatorFormat.decimal,
  );

  /// Relação oficial de indicadores disponíveis.
  static const List<AnalyticsIndicator> all = [
    peopleReached,
    vehiclesApproached,
    totalActions,
    humanResources,
    peoplePerAgent,
    vehiclesPerAgent,
    peoplePerAction,
    vehiclesPerAction,
    targetAchievement,
    synchronizationRate,
    operationalEfficiency,
    overallPerformance,
  ];

  /// Localiza um indicador pelo identificador.
  static AnalyticsIndicator? byId(String id) {
    for (final indicator in all) {
      if (indicator.id == id) {
        return indicator;
      }
    }

    return null;
  }
}