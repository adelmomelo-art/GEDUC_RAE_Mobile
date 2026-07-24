import 'analytics_filters.dart';
import 'analytics_record.dart';
import 'analytics_result.dart';
import 'calculators/productivity_calculator.dart';

/// Núcleo de processamento analítico da Plataforma Fênix.
///
/// Responsabilidades:
/// - receber registros;
/// - aplicar filtros;
/// - delegar cálculos especializados;
/// - produzir um AnalyticsResult.
///
/// O AnalyticsEngine não conhece Flutter, Firebase,
/// banco de dados ou módulos específicos.
final class AnalyticsEngine {
  const AnalyticsEngine();

  static const ProductivityCalculator _productivityCalculator =
      ProductivityCalculator();

  /// Processa os registros analíticos utilizando os filtros informados.
  ///
  /// Quando nenhum filtro for fornecido, utiliza um filtro institucional
  /// vazio, preservando as configurações padrão do Core.
  AnalyticsResult process({
    required Iterable<AnalyticsRecord> records,
    AnalyticsFilters? filters,
  }) {
    final effectiveFilters =
        filters ?? AnalyticsFilters.empty();

    final startedAt = DateTime.now();

    /// Materializa a coleção somente uma vez.
    ///
    /// Isso garante:
    /// - contagem consistente;
    /// - suporte seguro a Iterables lazy;
    /// - ausência de múltiplas leituras da fonte original.
    final sourceRecords =
        records.toList(growable: false);

    final filteredRecords = _applyFilters(
      sourceRecords,
      effectiveFilters,
    );

    final metrics =
        _productivityCalculator.calculate(filteredRecords);

    final finishedAt = DateTime.now();

    return AnalyticsResult(
      metrics: metrics,
      filters: effectiveFilters,
      processedAt: finishedAt,
      processingTime:
          finishedAt.difference(startedAt),
      processedRecords: filteredRecords.length,
      ignoredRecords:
          sourceRecords.length - filteredRecords.length,
      engineVersion: '2.0.0',
    );
  }

  /// Aplica os critérios de seleção definidos no filtro.
  ///
  /// As dimensões dos registros utilizam valores tipados:
  ///
  /// Map<String, Object?>
  ///
  /// Enquanto as dimensões dos filtros permanecem textuais:
  ///
  /// Map<String, String>
  ///
  /// A compatibilidade entre esses contratos é tratada exclusivamente
  /// pelo Engine, preservando a responsabilidade de cada componente.
  List<AnalyticsRecord> _applyFilters(
    List<AnalyticsRecord> records,
    AnalyticsFilters filters,
  ) {
    final filteredRecords = records.where((record) {
      if (!_matchesDomain(record, filters)) {
        return false;
      }

      if (!_matchesStatus(record, filters)) {
        return false;
      }

      if (!_matchesDateRange(record, filters)) {
        return false;
      }

      if (!_matchesDimensions(record, filters)) {
        return false;
      }

      return true;
    }).toList(growable: true);

    _sortRecords(
      filteredRecords,
      filters,
    );

    return _applyLimit(
      filteredRecords,
      filters.limit,
    );
  }

  /// Verifica a correspondência do domínio institucional.
  bool _matchesDomain(
    AnalyticsRecord record,
    AnalyticsFilters filters,
  ) {
    final expectedDomain = filters.domain;

    if (expectedDomain == null) {
      return true;
    }

    return record.domain.trim().toLowerCase() ==
        expectedDomain;
  }

  /// Verifica a correspondência do status institucional.
  bool _matchesStatus(
    AnalyticsRecord record,
    AnalyticsFilters filters,
  ) {
    final expectedStatus = filters.status;

    if (expectedStatus == null) {
      return true;
    }

    return record.status.trim().toLowerCase() ==
        expectedStatus;
  }

  /// Verifica se o registro pertence ao período definido.
  ///
  /// As datas inicial e final são inclusivas.
  bool _matchesDateRange(
    AnalyticsRecord record,
    AnalyticsFilters filters,
  ) {
    final startDate = filters.startDate;
    final endDate = filters.endDate;

    if (startDate != null &&
        record.occurredAt.isBefore(startDate)) {
      return false;
    }

    if (endDate != null &&
        record.occurredAt.isAfter(endDate)) {
      return false;
    }

    return true;
  }

  /// Verifica as dimensões específicas solicitadas pelo filtro.
  ///
  /// O valor armazenado no AnalyticsRecord mantém seu tipo original.
  /// Para comparação com o filtro textual, o Engine converte o valor
  /// de maneira controlada e previsível.
  bool _matchesDimensions(
    AnalyticsRecord record,
    AnalyticsFilters filters,
  ) {
    for (final filterEntry
        in filters.dimensions.entries) {
      final recordValue =
          record.dimension(filterEntry.key);

      if (!_dimensionValuesAreEquivalent(
        recordValue,
        filterEntry.value,
      )) {
        return false;
      }
    }

    return true;
  }

  /// Compara uma dimensão tipada com o valor textual do filtro.
  ///
  /// Regras:
  /// - null nunca corresponde a um filtro preenchido;
  /// - String é comparada sem espaços nas extremidades;
  /// - bool aceita true/false e sim/não;
  /// - números são comparados numericamente quando possível;
  /// - DateTime aceita representação ISO-8601;
  /// - demais tipos utilizam sua representação textual.
  bool _dimensionValuesAreEquivalent(
    Object? recordValue,
    String filterValue,
  ) {
    if (recordValue == null) {
      return false;
    }

    final normalizedFilterValue =
        filterValue.trim();

    if (recordValue is String) {
      return recordValue.trim() ==
          normalizedFilterValue;
    }

    if (recordValue is bool) {
      final parsedFilterValue =
          _parseBoolean(normalizedFilterValue);

      return parsedFilterValue != null &&
          recordValue == parsedFilterValue;
    }

    if (recordValue is num) {
      final parsedFilterValue = double.tryParse(
        normalizedFilterValue.replaceAll(',', '.'),
      );

      return parsedFilterValue != null &&
          recordValue.toDouble() == parsedFilterValue;
    }

    if (recordValue is DateTime) {
      final parsedFilterValue =
          DateTime.tryParse(normalizedFilterValue);

      return parsedFilterValue != null &&
          recordValue.isAtSameMomentAs(
            parsedFilterValue,
          );
    }

    return recordValue.toString().trim() ==
        normalizedFilterValue;
  }

  /// Converte representações textuais comuns em booleano.
  bool? _parseBoolean(String value) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'sim':
      case 'yes':
        return true;

      case 'false':
      case '0':
      case 'não':
      case 'nao':
      case 'no':
        return false;
    }

    return null;
  }

  /// Ordena os registros de acordo com as configurações do filtro.
  void _sortRecords(
    List<AnalyticsRecord> records,
    AnalyticsFilters filters,
  ) {
    records.sort((first, second) {
      final comparison = _compareRecords(
        first,
        second,
        filters.sortField,
      );

      if (filters.sortDirection ==
          AnalyticsSortDirection.ascending) {
        return comparison;
      }

      return -comparison;
    });
  }

  /// Compara dois registros pelo campo institucional selecionado.
  int _compareRecords(
    AnalyticsRecord first,
    AnalyticsRecord second,
    AnalyticsSortField sortField,
  ) {
    switch (sortField) {
      case AnalyticsSortField.occurredAt:
        return first.occurredAt.compareTo(
          second.occurredAt,
        );

      case AnalyticsSortField.domain:
        return first.domain.compareTo(
          second.domain,
        );

      case AnalyticsSortField.status:
        return first.status.compareTo(
          second.status,
        );

      case AnalyticsSortField.peopleCount:
        return first.peopleCount.compareTo(
          second.peopleCount,
        );

      case AnalyticsSortField.vehicleCount:
        return first.vehicleCount.compareTo(
          second.vehicleCount,
        );

      case AnalyticsSortField.humanResourcesCount:
        return first.humanResourcesCount.compareTo(
          second.humanResourcesCount,
        );

      case AnalyticsSortField.rating:
        return _compareNullableDouble(
          first.rating,
          second.rating,
        );
    }
  }

  /// Compara valores double opcionais.
  ///
  /// Valores nulos são considerados menores que valores preenchidos.
  int _compareNullableDouble(
    double? first,
    double? second,
  ) {
    if (first == null && second == null) {
      return 0;
    }

    if (first == null) {
      return -1;
    }

    if (second == null) {
      return 1;
    }

    return first.compareTo(second);
  }

  /// Aplica o limite máximo definido pelo filtro.
  List<AnalyticsRecord> _applyLimit(
    List<AnalyticsRecord> records,
    int? limit,
  ) {
    if (limit == null ||
        records.length <= limit) {
      return List<AnalyticsRecord>.unmodifiable(
        records,
      );
    }

    return List<AnalyticsRecord>.unmodifiable(
      records.take(limit),
    );
  }
}