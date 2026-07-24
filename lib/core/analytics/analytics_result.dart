import 'analytics_filters.dart';
import 'analytics_metrics.dart';

/// Resultado oficial produzido pelo Analytics Engine.
///
/// Reúne:
/// - métricas calculadas;
/// - filtros utilizados;
/// - informações de processamento;
/// - metadados para auditoria e rastreabilidade.
final class AnalyticsResult {
  /// Indicadores produzidos pelo processamento.
  final AnalyticsMetrics metrics;

  /// Filtros aplicados durante a consulta.
  final AnalyticsFilters filters;

  /// Data e hora da geração do resultado.
  final DateTime processedAt;

  /// Tempo gasto no processamento.
  final Duration processingTime;

  /// Quantidade total de registros processados.
  final int processedRecords;

  /// Quantidade de registros descartados.
  final int ignoredRecords;

  /// Versão do Analytics Engine.
  final String engineVersion;

  /// Informações adicionais.
  final Map<String, String> metadata;

  const AnalyticsResult({
    required this.metrics,
    required this.filters,
    required this.processedAt,
    this.processingTime = Duration.zero,
    this.processedRecords = 0,
    this.ignoredRecords = 0,
    this.engineVersion = '1.0.0',
    this.metadata = const {},
  });

  /// Quantidade total considerada.
  int get totalRecords =>
      processedRecords + ignoredRecords;

  /// Indica se houve descarte.
  bool get hasIgnoredRecords =>
      ignoredRecords > 0;

  /// Percentual de registros efetivamente utilizados.
  double get processingEfficiency {
    if (totalRecords == 0) return 0;

    return processedRecords / totalRecords;
  }

  /// Indica se existem metadados.
  bool get hasMetadata =>
      metadata.isNotEmpty;

  AnalyticsResult copyWith({
    AnalyticsMetrics? metrics,
    AnalyticsFilters? filters,
    DateTime? processedAt,
    Duration? processingTime,
    int? processedRecords,
    int? ignoredRecords,
    String? engineVersion,
    Map<String, String>? metadata,
  }) {
    return AnalyticsResult(
      metrics: metrics ?? this.metrics,
      filters: filters ?? this.filters,
      processedAt: processedAt ?? this.processedAt,
      processingTime:
          processingTime ?? this.processingTime,
      processedRecords:
          processedRecords ?? this.processedRecords,
      ignoredRecords:
          ignoredRecords ?? this.ignoredRecords,
      engineVersion:
          engineVersion ?? this.engineVersion,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnalyticsResult &&
            other.metrics == metrics &&
            other.filters == filters &&
            other.processedAt == processedAt &&
            other.processingTime == processingTime &&
            other.processedRecords ==
                processedRecords &&
            other.ignoredRecords ==
                ignoredRecords &&
            other.engineVersion ==
                engineVersion &&
            _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
        metrics,
        filters,
        processedAt,
        processingTime,
        processedRecords,
        ignoredRecords,
        engineVersion,
        Object.hashAll(
          metadata.entries.map(
            (e) => Object.hash(e.key, e.value),
          ),
        ),
      );

  @override
  String toString() {
    return 'AnalyticsResult('
        'processedRecords: $processedRecords, '
        'ignoredRecords: $ignoredRecords, '
        'processingTime: $processingTime, '
        'processedAt: $processedAt, '
        'engineVersion: $engineVersion'
        ')';
  }

  static bool _mapEquals(
    Map<String, String> a,
    Map<String, String> b,
  ) {
    if (identical(a, b)) return true;

    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}