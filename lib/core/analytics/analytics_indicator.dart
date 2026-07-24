/// Categoria institucional do indicador.
enum AnalyticsIndicatorCategory {
  operation,
  productivity,
  quality,
  management,
  strategic,
}

/// Unidade de apresentação do indicador.
enum AnalyticsIndicatorUnit {
  count,
  percentage,
  people,
  vehicles,
  peoplePerAgent,
  vehiclesPerAgent,
  actions,
  hours,
  score,
}

/// Formato de apresentação.
enum AnalyticsIndicatorFormat {
  integer,
  decimal,
  percentage,
}

/// Define um KPI institucional do Framework Atlas.
///
/// Esta classe descreve um indicador.
///
/// Não realiza cálculos.
final class AnalyticsIndicator {
  const AnalyticsIndicator({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.unit,
    required this.format,
  });

  /// Identificador único.
  final String id;

  /// Nome institucional.
  final String name;

  /// Descrição funcional.
  final String description;

  /// Categoria.
  final AnalyticsIndicatorCategory category;

  /// Unidade.
  final AnalyticsIndicatorUnit unit;

  /// Formato.
  final AnalyticsIndicatorFormat format;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnalyticsIndicator &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnalyticsIndicator('
        'id: $id, '
        'name: $name'
        ')';
  }
}