/// Define a direção utilizada na ordenação dos registros analíticos.
enum AnalyticsSortDirection {
  ascending,
  descending,
}

/// Define o campo institucional utilizado na ordenação.
///
/// O Core trabalha apenas com propriedades universais.
/// Ordenações específicas de cada módulo deverão ser tratadas
/// por suas respectivas camadas de adaptação.
enum AnalyticsSortField {
  occurredAt,
  domain,
  status,
  peopleCount,
  vehicleCount,
  humanResourcesCount,
  rating,
}

/// Representa os critérios utilizados para selecionar e ordenar
/// registros processados pelo núcleo analítico da Plataforma Fênix.
///
/// Esta classe pertence ao Core Institucional e não conhece conceitos
/// específicos dos módulos operacionais, como regional, turno, projeto,
/// escola, tipo de auto ou aeronave.
///
/// Critérios específicos devem ser informados por meio de [dimensions].
final class AnalyticsFilters {
  /// Data e hora inicial do período analisado.
  ///
  /// O valor é inclusivo: registros ocorridos exatamente neste instante
  /// poderão fazer parte da análise.
  final DateTime? startDate;

  /// Data e hora final do período analisado.
  ///
  /// O valor é inclusivo: registros ocorridos exatamente neste instante
  /// poderão fazer parte da análise.
  final DateTime? endDate;

  /// Domínio institucional que será analisado.
  ///
  /// Exemplos:
  /// - educacao
  /// - fiscalizacao
  /// - rpas
  /// - engenharia
  ///
  /// Quando nulo, registros de todos os domínios poderão ser processados.
  final String? domain;

  /// Situação institucional utilizada como critério.
  ///
  /// O significado do status é definido pelo módulo de origem.
  /// Quando nulo, registros com qualquer status poderão ser processados.
  final String? status;

  /// Dimensões adicionais utilizadas na seleção dos registros.
  ///
  /// Exemplos:
  ///
  /// Educação:
  /// - regional
  /// - turno
  /// - tipo_acao
  /// - projeto
  ///
  /// Fiscalização:
  /// - tipo_auto
  /// - local_operacao
  /// - equipe
  ///
  /// As chaves são normalizadas para letras minúsculas e sem espaços
  /// nas extremidades.
  final Map<String, String> dimensions;

  /// Campo utilizado para ordenar os registros.
  final AnalyticsSortField sortField;

  /// Direção utilizada na ordenação.
  final AnalyticsSortDirection sortDirection;

  /// Número máximo de registros que poderão ser processados.
  ///
  /// Quando nulo, não existe limitação definida pelo filtro.
  final int? limit;

  /// Indica se registros classificados como inválidos poderão permanecer
  /// no conjunto enviado ao processamento.
  ///
  /// A definição de registro inválido será responsabilidade do
  /// Analytics Engine e de suas políticas de validação.
  final bool includeInvalidRecords;

  AnalyticsFilters({
    this.startDate,
    this.endDate,
    String? domain,
    String? status,
    Map<String, String> dimensions = const {},
    this.sortField = AnalyticsSortField.occurredAt,
    this.sortDirection = AnalyticsSortDirection.descending,
    this.limit,
    this.includeInvalidRecords = false,
  })  : domain = _normalizeOptionalValue(domain),
        status = _normalizeOptionalValue(status),
        dimensions = Map<String, String>.unmodifiable(
          _normalizeDimensions(dimensions),
        ) {
    _validate();
  }

  /// Cria um filtro sem critérios de período, domínio, status ou dimensão.
  ///
  /// A ordenação padrão permanece por data decrescente.
  factory AnalyticsFilters.empty() {
    return AnalyticsFilters();
  }

  /// Indica se foi definido um período inicial ou final.
  bool get hasDateRange => startDate != null || endDate != null;

  /// Indica se existe filtro por domínio institucional.
  bool get hasDomain => domain != null;

  /// Indica se existe filtro por status.
  bool get hasStatus => status != null;

  /// Indica se existem dimensões adicionais.
  bool get hasDimensions => dimensions.isNotEmpty;

  /// Indica se existe limite máximo de registros.
  bool get hasLimit => limit != null;

  /// Indica se existe pelo menos um critério efetivo de seleção.
  ///
  /// Ordenação e inclusão de registros inválidos não são consideradas
  /// critérios de seleção.
  bool get hasSelectionCriteria {
    return hasDateRange ||
        hasDomain ||
        hasStatus ||
        hasDimensions ||
        hasLimit;
  }

  /// Quantidade de critérios principais definidos.
  ///
  /// Cada grupo é contado uma única vez:
  /// período, domínio, status, dimensões e limite.
  int get criteriaCount {
    var count = 0;

    if (hasDateRange) {
      count++;
    }

    if (hasDomain) {
      count++;
    }

    if (hasStatus) {
      count++;
    }

    if (hasDimensions) {
      count++;
    }

    if (hasLimit) {
      count++;
    }

    return count;
  }

  /// Retorna o valor de uma dimensão utilizando uma chave normalizada.
  String? dimension(String key) {
    return dimensions[_normalizeDimensionKey(key)];
  }

  /// Indica se uma determinada dimensão está definida.
  bool containsDimension(String key) {
    return dimensions.containsKey(_normalizeDimensionKey(key));
  }

  /// Cria uma nova instância preservando os valores não modificados.
  ///
  /// Os parâmetros `clear...` permitem remover valores opcionais,
  /// diferenciando a remoção da simples ausência de alteração.
  AnalyticsFilters copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? domain,
    bool clearDomain = false,
    String? status,
    bool clearStatus = false,
    Map<String, String>? dimensions,
    bool clearDimensions = false,
    AnalyticsSortField? sortField,
    AnalyticsSortDirection? sortDirection,
    int? limit,
    bool clearLimit = false,
    bool? includeInvalidRecords,
  }) {
    return AnalyticsFilters(
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      domain: clearDomain ? null : domain ?? this.domain,
      status: clearStatus ? null : status ?? this.status,
      dimensions: clearDimensions
          ? const {}
          : dimensions ?? this.dimensions,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
      limit: clearLimit ? null : limit ?? this.limit,
      includeInvalidRecords:
          includeInvalidRecords ?? this.includeInvalidRecords,
    );
  }

  /// Retorna uma nova instância acrescentando ou substituindo
  /// uma dimensão.
  AnalyticsFilters withDimension({
    required String key,
    required String value,
  }) {
    final updatedDimensions = Map<String, String>.from(dimensions)
      ..[_normalizeDimensionKey(key)] = value.trim();

    return copyWith(dimensions: updatedDimensions);
  }

  /// Retorna uma nova instância removendo uma dimensão.
  AnalyticsFilters withoutDimension(String key) {
    final normalizedKey = _normalizeDimensionKey(key);

    if (!dimensions.containsKey(normalizedKey)) {
      return this;
    }

    final updatedDimensions = Map<String, String>.from(dimensions)
      ..remove(normalizedKey);

    return copyWith(dimensions: updatedDimensions);
  }

  /// Retorna uma nova instância sem critérios de seleção,
  /// preservando somente as configurações de ordenação e validação.
  AnalyticsFilters clearSelectionCriteria() {
    return AnalyticsFilters(
      sortField: sortField,
      sortDirection: sortDirection,
      includeInvalidRecords: includeInvalidRecords,
    );
  }

  void _validate() {
    if (startDate != null &&
        endDate != null &&
        startDate!.isAfter(endDate!)) {
      throw ArgumentError(
        'A data inicial não pode ser posterior à data final.',
      );
    }

    if (limit != null && limit! <= 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'O limite de registros deve ser maior que zero.',
      );
    }

    for (final entry in dimensions.entries) {
      if (entry.key.isEmpty) {
        throw ArgumentError(
          'As chaves das dimensões não podem estar vazias.',
        );
      }

      if (entry.value.isEmpty) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'Os valores das dimensões não podem estar vazios.',
        );
      }
    }
  }

  static String? _normalizeOptionalValue(String? value) {
    final normalizedValue = value?.trim().toLowerCase();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }

  static String _normalizeDimensionKey(String value) {
    return value.trim().toLowerCase();
  }

  static Map<String, String> _normalizeDimensions(
    Map<String, String> source,
  ) {
    final normalizedDimensions = <String, String>{};

    for (final entry in source.entries) {
      final key = _normalizeDimensionKey(entry.key);
      final value = entry.value.trim();

      if (key.isEmpty) {
        throw ArgumentError(
          'As chaves das dimensões não podem estar vazias.',
        );
      }

      if (value.isEmpty) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'Os valores das dimensões não podem estar vazios.',
        );
      }

      normalizedDimensions[key] = value;
    }

    return normalizedDimensions;
  }

  static bool _mapsAreEqual(
    Map<String, String> first,
    Map<String, String> second,
  ) {
    if (identical(first, second)) {
      return true;
    }

    if (first.length != second.length) {
      return false;
    }

    for (final entry in first.entries) {
      if (second[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  static int _mapHashCode(Map<String, String> map) {
    final entries = map.entries.toList()
      ..sort((first, second) => first.key.compareTo(second.key));

    return Object.hashAll(
      entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AnalyticsFilters &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.domain == domain &&
        other.status == status &&
        _mapsAreEqual(other.dimensions, dimensions) &&
        other.sortField == sortField &&
        other.sortDirection == sortDirection &&
        other.limit == limit &&
        other.includeInvalidRecords == includeInvalidRecords;
  }

  @override
  int get hashCode {
    return Object.hash(
      startDate,
      endDate,
      domain,
      status,
      _mapHashCode(dimensions),
      sortField,
      sortDirection,
      limit,
      includeInvalidRecords,
    );
  }

  @override
  String toString() {
    return 'AnalyticsFilters('
        'startDate: $startDate, '
        'endDate: $endDate, '
        'domain: $domain, '
        'status: $status, '
        'dimensions: $dimensions, '
        'sortField: $sortField, '
        'sortDirection: $sortDirection, '
        'limit: $limit, '
        'includeInvalidRecords: $includeInvalidRecords'
        ')';
  }
}