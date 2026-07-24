import 'analytics_dashboard_model.dart';
import 'analytics_result.dart';
import 'dashboard_builder.dart';
import 'dashboard_definition.dart';
import 'dashboard_registry.dart';

/// Factory responsável por construir [AnalyticsDashboardModel]
/// a partir das definições registradas no [DashboardRegistry].
///
/// Não realiza cálculos analíticos.
/// Não conhece módulos específicos, como GEDUC ou RPAS.
///
/// Apenas orquestra:
///
/// DashboardRegistry
///        ↓
/// DashboardDefinition
///        ↓
/// DashboardBuilderBase
///        ↓
/// AnalyticsDashboardModel
final class DashboardFactory {
  DashboardFactory({
    required DashboardRegistry registry,
    DashboardBuilderBase builder =
        const DashboardBuilder(),
  })  : _registry = registry,
        _builder = builder;

  final DashboardRegistry _registry;
  final DashboardBuilderBase _builder;

  /// Indica se um dashboard pode ser criado.
  ///
  /// Retorna `true` somente quando a definição estiver registrada
  /// e habilitada.
  bool canCreate(String dashboardId) {
    final definition = _registry.find(dashboardId);

    return definition != null && definition.enabled;
  }

  /// Obtém a definição registrada.
  ///
  /// Retorna `null` quando o dashboard não estiver registrado.
  DashboardDefinition? definition(
    String dashboardId,
  ) {
    return _registry.find(dashboardId);
  }

  /// Lista todas as definições registradas e habilitadas.
  List<DashboardDefinition> availableDashboards() {
    return _registry.enabled();
  }

  /// Constrói um dashboard institucional.
  ///
  /// Lança [StateError] quando:
  ///
  /// - o dashboard não estiver registrado;
  /// - o dashboard estiver desabilitado.
  AnalyticsDashboardModel create({
    required String dashboardId,
    required AnalyticsResult result,
    DateTime? referenceStartDate,
    DateTime? referenceEndDate,
  }) {
    final definition = _registry.find(
      dashboardId,
    );

    if (definition == null) {
      throw StateError(
        'Dashboard "$dashboardId" não está registrado.',
      );
    }

    if (!definition.enabled) {
      throw StateError(
        'Dashboard "$dashboardId" está desabilitado.',
      );
    }

    return _builder.build(
      id: definition.id,
      title: definition.title,
      description: definition.description,
      domain: definition.domain,
      result: result,
      referenceStartDate: referenceStartDate,
      referenceEndDate: referenceEndDate,
    );
  }

  @override
  String toString() {
    return 'DashboardFactory('
        'registered: ${_registry.count}'
        ')';
  }
}