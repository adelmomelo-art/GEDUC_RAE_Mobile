import 'analytics_indicator.dart';

/// Situação institucional do indicador.
enum AnalyticsIndicatorStatus {
  excellent,
  good,
  attention,
  critical,
}

/// Representa o resultado calculado de um indicador institucional.
///
/// Esta classe contém apenas dados.
/// Toda a lógica de cálculo permanece nos calculators.
final class AnalyticsIndicatorValue {
  const AnalyticsIndicatorValue({
    required this.indicator,
    required this.value,
    this.target,
    this.variation,
    this.status,
    this.referenceDate,
  });

  /// Definição institucional do indicador.
  final AnalyticsIndicator indicator;

  /// Valor calculado.
  final double value;

  /// Meta institucional.
  final double? target;

  /// Variação percentual em relação ao período anterior.
  ///
  /// Exemplo:
  /// +8.4
  /// -3.1
  final double? variation;

  /// Situação do indicador.
  final AnalyticsIndicatorStatus? status;

  /// Data de referência do cálculo.
  final DateTime? referenceDate;

  /// Indica se existe meta definida.
  bool get hasTarget => target != null;

  /// Indica se existe variação calculada.
  bool get hasVariation => variation != null;

  /// Diferença absoluta entre o valor atual e a meta.
  double? get differenceToTarget {
    if (target == null) {
      return null;
    }

    return value - target!;
  }

  /// Percentual de cumprimento da meta.
  double? get targetAchievement {
    if (target == null || target == 0) {
      return null;
    }

    return (value / target!) * 100;
  }

  AnalyticsIndicatorValue copyWith({
    AnalyticsIndicator? indicator,
    double? value,
    double? target,
    double? variation,
    AnalyticsIndicatorStatus? status,
    DateTime? referenceDate,
  }) {
    return AnalyticsIndicatorValue(
      indicator: indicator ?? this.indicator,
      value: value ?? this.value,
      target: target ?? this.target,
      variation: variation ?? this.variation,
      status: status ?? this.status,
      referenceDate:
          referenceDate ?? this.referenceDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnalyticsIndicatorValue &&
            other.indicator == indicator &&
            other.referenceDate == referenceDate;
  }

  @override
  int get hashCode =>
      Object.hash(indicator, referenceDate);

  @override
  String toString() {
    return 'AnalyticsIndicatorValue('
        'indicator: ${indicator.id}, '
        'value: $value'
        ')';
  }
}