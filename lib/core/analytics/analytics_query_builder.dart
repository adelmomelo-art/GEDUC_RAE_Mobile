import 'analytics_filters.dart';
import 'analytics_query.dart';

/// Builder fluente para criação de consultas analíticas.
///
/// Não executa consultas.
/// Apenas facilita a construção de um AnalyticsQuery.
final class AnalyticsQueryBuilder {
  String? _id;
  String? _domain;
  String? _description;

  AnalyticsFilters _filters = AnalyticsFilters.empty();

  final List<String> _groupBy = [];

  int _offset = 0;

  final Map<String, Object?> _metadata = {};

  AnalyticsQueryBuilder id(String value) {
    _id = value;
    return this;
  }

  AnalyticsQueryBuilder domain(String value) {
    _domain = value;
    return this;
  }

  AnalyticsQueryBuilder description(String value) {
    _description = value;
    return this;
  }

  AnalyticsQueryBuilder between(
    DateTime start,
    DateTime end,
  ) {
    _filters = _filters.copyWith(
      startDate: start,
      endDate: end,
    );

    return this;
  }

  AnalyticsQueryBuilder startAt(DateTime value) {
    _filters = _filters.copyWith(
      startDate: value,
    );

    return this;
  }

  AnalyticsQueryBuilder endAt(DateTime value) {
    _filters = _filters.copyWith(
      endDate: value,
    );

    return this;
  }

  AnalyticsQueryBuilder status(String value) {
    _filters = _filters.copyWith(
      status: value,
    );

    return this;
  }

  AnalyticsQueryBuilder dimension(
    String key,
    String value,
  ) {
    _filters = _filters.withDimension(
      key: key,
      value: value,
    );

    return this;
  }

  AnalyticsQueryBuilder limit(int value) {
    _filters = _filters.copyWith(
      limit: value,
    );

    return this;
  }

  AnalyticsQueryBuilder includeInvalidRecords(
    bool value,
  ) {
    _filters = _filters.copyWith(
      includeInvalidRecords: value,
    );

    return this;
  }

  AnalyticsQueryBuilder orderBy(
    AnalyticsSortField field, {
    AnalyticsSortDirection direction =
        AnalyticsSortDirection.descending,
  }) {
    _filters = _filters.copyWith(
      sortField: field,
      sortDirection: direction,
    );

    return this;
  }

  AnalyticsQueryBuilder groupBy(
    String dimension,
  ) {
    final normalized = dimension.trim();

    if (normalized.isEmpty) {
      return this;
    }

    if (!_groupBy.contains(normalized)) {
      _groupBy.add(normalized);
    }

    return this;
  }

  AnalyticsQueryBuilder offset(int value) {
    _offset = value;
    return this;
  }

  AnalyticsQueryBuilder metadata(
    String key,
    Object? value,
  ) {
    _metadata[key] = value;
    return this;
  }

  AnalyticsQuery build() {
    return AnalyticsQuery(
      id: _id ?? 'default',
      domain: _domain ?? 'general',
      description: _description,
      filters: _filters.copyWith(
        domain: _domain,
      ),
      groupBy: List.unmodifiable(_groupBy),
      offset: _offset,
      metadata: Map.unmodifiable(_metadata),
    );
  }

  void reset() {
    _id = null;
    _domain = null;
    _description = null;

    _filters = AnalyticsFilters.empty();

    _groupBy.clear();

    _offset = 0;

    _metadata.clear();
  }
}