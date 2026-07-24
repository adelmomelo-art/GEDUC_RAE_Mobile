import 'dashboard_definition.dart';

/// Catálogo institucional de dashboards do Framework Atlas.
///
/// O DashboardRegistry é responsável exclusivamente por registrar,
/// localizar e consultar definições de dashboards.
///
/// Não constrói dashboards e não executa cálculos analíticos.
final class DashboardRegistry {
  DashboardRegistry();

  final Map<String, DashboardDefinition> _definitions = {};

  /// Registra uma definição.
  ///
  /// Lança [StateError] caso já exista um dashboard com o mesmo id.
  void register(DashboardDefinition definition) {
    if (_definitions.containsKey(definition.id)) {
      throw StateError(
        'Já existe um dashboard registrado com id "${definition.id}".',
      );
    }

    _definitions[definition.id] = definition;
  }

  /// Registra diversas definições.
  void registerAll(
    Iterable<DashboardDefinition> definitions,
  ) {
    for (final definition in definitions) {
      register(definition);
    }
  }

  /// Retorna verdadeiro quando o dashboard existir.
  bool contains(String id) {
    return _definitions.containsKey(id.trim());
  }

  /// Localiza um dashboard.
  DashboardDefinition? find(String id) {
    return _definitions[id.trim()];
  }

  /// Remove um dashboard.
  ///
  /// Retorna verdadeiro quando houve remoção.
  bool remove(String id) {
    return _definitions.remove(id.trim()) != null;
  }

  /// Remove todos os dashboards registrados.
  void clear() {
    _definitions.clear();
  }

  /// Todos os dashboards registrados.
  List<DashboardDefinition> all() {
    return List.unmodifiable(
      _definitions.values,
    );
  }

  /// Apenas dashboards habilitados.
  List<DashboardDefinition> enabled() {
    return List.unmodifiable(
      _definitions.values.where(
        (dashboard) => dashboard.enabled,
      ),
    );
  }

  /// Dashboards de um domínio.
  List<DashboardDefinition> byDomain(
    String domain,
  ) {
    final normalized = domain.trim().toLowerCase();

    return List.unmodifiable(
      _definitions.values.where(
        (dashboard) =>
            dashboard.domain.toLowerCase() == normalized,
      ),
    );
  }

  /// Dashboards por público.
  List<DashboardDefinition> byAudience(
    DashboardAudience audience,
  ) {
    return List.unmodifiable(
      _definitions.values.where(
        (dashboard) =>
            dashboard.audience == audience,
      ),
    );
  }

  /// Dashboards por categoria.
  List<DashboardDefinition> byCategory(
    DashboardCategory category,
  ) {
    return List.unmodifiable(
      _definitions.values.where(
        (dashboard) =>
            dashboard.category == category,
      ),
    );
  }

  /// Quantidade registrada.
  int get count => _definitions.length;

  /// Indica se o registro está vazio.
  bool get isEmpty => _definitions.isEmpty;

  /// Indica se existem dashboards registrados.
  bool get isNotEmpty => _definitions.isNotEmpty;

  @override
  String toString() {
    return 'DashboardRegistry('
        'count: $count'
        ')';
  }
}