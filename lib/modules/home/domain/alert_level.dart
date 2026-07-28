/// Nível de severidade de um alerta operacional.
///
/// A ordem declarada representa a progressão de gravidade.
enum AlertLevel {
  info,
  warning,
  critical;

  /// Prioridade numérica usada para ordenação.
  int get priority {
    switch (this) {
      case AlertLevel.info:
        return 1;
      case AlertLevel.warning:
        return 2;
      case AlertLevel.critical:
        return 3;
    }
  }

  /// Nome legível em português.
  String get label {
    switch (this) {
      case AlertLevel.info:
        return 'Informativo';
      case AlertLevel.warning:
        return 'Atenção';
      case AlertLevel.critical:
        return 'Crítico';
    }
  }
}
