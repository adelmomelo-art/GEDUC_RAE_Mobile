import 'analytics_filters.dart';

/// Representa uma consulta analítica padronizada do Framework Atlas.
///
/// Define o que deve ser consultado sem conhecer a tecnologia
/// de persistência utilizada pela aplicação.
final class AnalyticsQuery {
  /// Identificador único da consulta.
  final String id;

  /// Domínio institucional da consulta.
  ///
  /// Exemplos:
  /// - educacao
  /// - fiscalizacao
  /// - rpas
  /// - engenharia
  final String domain;

  /// Descrição opcional da consulta.
  final String? description;

  /// Filtros aplicados à consulta.
  final AnalyticsFilters filters;

  /// Dimensões utilizadas para agrupamento.
  final List<String> groupBy;

  /// Deslocamento utilizado para paginação.
  final int offset;

  /// Metadados adicionais da consulta.
  final Map<String, Object?> metadata;

  AnalyticsQuery({
    required String id,
    required String domain,
    this.description,
    AnalyticsFilters? filters,
    List<String> groupBy = const [],
    this.offset = 0,
    Map<String, Object?> metadata = const {},
  })  : id = _normalizeRequiredValue(
          id,
          parameterName: 'id',
        ),
        domain = _normalizeRequiredValue(
          domain,
          parameterName: 'domain',
        ),
        filters = filters ?? AnalyticsFilters.empty(),
        groupBy = List<String>.unmodifiable(
          _normalizeGroupBy(groupBy),
        ),
        metadata = Map<String, Object?>.unmodifiable(
          metadata,
        ) {
    _validate();
  }

  /// Data inicial definida no filtro.
  DateTime? get startDate => filters.startDate;

  /// Data final definida no filtro.
  DateTime? get endDate => filters.endDate;

  /// Campo utilizado para ordenação.
  AnalyticsSortField get sortField => filters.sortField;

  /// Direção utilizada para ordenação.
  AnalyticsSortDirection get sortDirection =>
      filters.sortDirection;

  /// Limite máximo de registros.
  int? get limit => filters.limit;

  /// Indica se existe um período definido.
  bool get hasPeriod => filters.hasDateRange;

  /// Indica se existem critérios efetivos de seleção.
  bool get hasFilters => filters.hasSelectionCriteria;

  /// Indica se existem dimensões para agrupamento.
  bool get hasGrouping => groupBy.isNotEmpty;

  /// Indica se existe limite máximo de registros.
  bool get hasLimit => filters.hasLimit;

  /// Indica se existem metadados adicionais.
  bool get hasMetadata => metadata.isNotEmpty;

  /// Retorna um valor dos metadados.
  Object? metadataValue(String key) => metadata[key];

  /// Cria uma nova instância preservando valores não modificados.
  AnalyticsQuery copyWith({
    String? id,
    String? domain,
    String? description,
    bool clearDescription = false,
    AnalyticsFilters? filters,
    List<String>? groupBy,
    int? offset,
    Map<String, Object?>? metadata,
  }) {
    return AnalyticsQuery(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      description: clearDescription
          ? null
          : description ?? this.description,
      filters: filters ?? this.filters,
      groupBy: groupBy ?? this.groupBy,
      offset: offset ?? this.offset,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Retorna uma nova consulta com um metadado adicionado
  /// ou substituído.
  AnalyticsQuery withMetadata({
    required String key,
    required Object? value,
  }) {
    final normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(
        key,
        'key',
        'A chave do metadado não pode estar vazia.',
      );
    }

    final updatedMetadata =
        Map<String, Object?>.from(metadata)
          ..[normalizedKey] = value;

    return copyWith(metadata: updatedMetadata);
  }

  /// Retorna uma nova consulta sem o metadado informado.
  AnalyticsQuery withoutMetadata(String key) {
    final normalizedKey = key.trim();

    if (!metadata.containsKey(normalizedKey)) {
      return this;
    }

    final updatedMetadata =
        Map<String, Object?>.from(metadata)
          ..remove(normalizedKey);

    return copyWith(metadata: updatedMetadata);
  }

  void _validate() {
    if (offset < 0) {
      throw ArgumentError.value(
        offset,
        'offset',
        'O deslocamento não pode ser negativo.',
      );
    }
  }

  static String _normalizeRequiredValue(
    String value, {
    required String parameterName,
  }) {
    final normalizedValue = value.trim().toLowerCase();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        parameterName,
        'O valor não pode estar vazio.',
      );
    }

    return normalizedValue;
  }

  static List<String> _normalizeGroupBy(
    Iterable<String> source,
  ) {
    final normalizedValues = <String>[];
    final registeredValues = <String>{};

    for (final value in source) {
      final normalizedValue = value.trim().toLowerCase();

      if (normalizedValue.isEmpty) {
        throw ArgumentError.value(
          value,
          'groupBy',
          'Os campos de agrupamento não podem estar vazios.',
        );
      }

      if (registeredValues.add(normalizedValue)) {
        normalizedValues.add(normalizedValue);
      }
    }

    return normalizedValues;
  }

  static bool _listsAreEqual(
    List<String> first,
    List<String> second,
  ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }

    return true;
  }

  static bool _mapsAreEqual(
    Map<String, Object?> first,
    Map<String, Object?> second,
  ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (final entry in first.entries) {
      if (!second.containsKey(entry.key) ||
          second[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  static int _mapHashCode(
    Map<String, Object?> map,
  ) {
    final entries = map.entries.toList()
      ..sort(
        (first, second) =>
            first.key.compareTo(second.key),
      );

    return Object.hashAll(
      entries.map(
        (entry) => Object.hash(
          entry.key,
          entry.value,
        ),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AnalyticsQuery &&
        other.id == id &&
        other.domain == domain &&
        other.description == description &&
        other.filters == filters &&
        _listsAreEqual(other.groupBy, groupBy) &&
        other.offset == offset &&
        _mapsAreEqual(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      domain,
      description,
      filters,
      Object.hashAll(groupBy),
      offset,
      _mapHashCode(metadata),
    );
  }

  @override
  String toString() {
    return 'AnalyticsQuery('
        'id: $id, '
        'domain: $domain, '
        'hasFilters: $hasFilters, '
        'groupBy: $groupBy, '
        'offset: $offset'
        ')';
  }
}