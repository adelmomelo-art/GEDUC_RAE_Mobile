/// Representa a menor unidade de informação compreendida pelo
/// núcleo analítico da Plataforma Fênix.
///
/// Esta classe pertence ao Core Institucional e, portanto, não conhece
/// modelos específicos como AcaoModel, AutoInfracaoModel ou MissaoRpasModel.
///
/// Cada módulo operacional deverá converter seus próprios modelos para
/// AnalyticsRecord por meio de um adapter.
final class AnalyticsRecord {
  /// Identificador único do registro no módulo de origem.
  final String id;

  /// Identifica o domínio institucional responsável pelo registro.
  ///
  /// Exemplos:
  /// - educacao
  /// - fiscalizacao
  /// - rpas
  /// - engenharia
  final String domain;

  /// Data e hora de referência do evento ou registro institucional.
  final DateTime occurredAt;

  /// Situação atual do registro.
  ///
  /// O significado dos valores é definido pelo módulo de origem.
  /// O Core apenas utiliza esse campo para filtros e agrupamentos.
  final String status;

  /// Quantidade de pessoas relacionadas ao registro.
  ///
  /// No módulo Educação, poderá representar pessoas alcançadas.
  /// Em outros módulos, poderá representar outro público contabilizado.
  final int peopleCount;

  /// Quantidade de veículos relacionados ao registro.
  ///
  /// No módulo Educação, poderá representar veículos abordados.
  final int vehicleCount;

  /// Quantidade de recursos humanos mobilizados.
  ///
  /// No módulo Educação, poderá representar agentes participantes.
  final int humanResourcesCount;

  /// Valor da meta prevista para o registro.
  ///
  /// Pode ser nulo quando o módulo não trabalhar com metas
  /// ou quando essa informação não estiver disponível.
  final double? targetValue;

  /// Valor efetivamente alcançado.
  ///
  /// Pode ser nulo quando não existir medição correspondente.
  final double? achievedValue;

  /// Avaliação atribuída ao registro.
  ///
  /// A escala deverá ser normalizada pelo adapter do módulo de origem.
  /// Recomenda-se a escala de 0 a 5.
  final double? rating;

  /// Dimensões adicionais usadas para filtros e agrupamentos.
  ///
  /// Diferentemente dos campos institucionais universais, as dimensões
  /// podem armazenar valores específicos dos módulos operacionais.
  ///
  /// Tipos suportados:
  /// - String
  /// - int
  /// - double
  /// - bool
  /// - DateTime
  /// - outros objetos imutáveis necessários ao domínio
  ///
  /// Exemplos no módulo Educação:
  /// - regional: String
  /// - turno: String
  /// - ano_rae: int
  /// - acao_planejada: bool
  /// - meta_atingida: bool
  ///
  /// Essas informações não são interpretadas diretamente pelo Core.
  /// Elas permitem filtros, agrupamentos e segmentações sem criar
  /// dependência entre o Analytics e os módulos operacionais.
  final Map<String, Object?> dimensions;

  AnalyticsRecord({
    required this.id,
    required this.domain,
    required this.occurredAt,
    required this.status,
    this.peopleCount = 0,
    this.vehicleCount = 0,
    this.humanResourcesCount = 0,
    this.targetValue,
    this.achievedValue,
    this.rating,
    Map<String, Object?> dimensions = const {},
  }) : dimensions = Map<String, Object?>.unmodifiable(
          _normalizeDimensions(dimensions),
        ) {
    _validate();
  }

  /// Indica se o registro possui uma meta válida para análise.
  bool get hasTarget => targetValue != null && targetValue! > 0;

  /// Indica se existe um valor alcançado disponível.
  bool get hasAchievedValue => achievedValue != null;

  /// Indica se o registro possui avaliação.
  bool get hasRating => rating != null;

  /// Indica se existem dimensões adicionais.
  bool get hasDimensions => dimensions.isNotEmpty;

  /// Percentual de alcance da meta.
  ///
  /// Retorna nulo quando não existe meta válida ou valor alcançado.
  double? get targetAchievementPercentage {
    if (!hasTarget || !hasAchievedValue) {
      return null;
    }

    return (achievedValue! / targetValue!) * 100;
  }

  /// Indica se a meta prevista foi alcançada.
  ///
  /// Retorna falso quando não existe meta ou valor realizado.
  bool get hasReachedTarget {
    final percentage = targetAchievementPercentage;

    return percentage != null && percentage >= 100;
  }

  /// Retorna o valor original de uma dimensão adicional.
  ///
  /// A chave é normalizada para letras minúsculas e sem espaços
  /// nas extremidades.
  Object? dimension(String key) {
    return dimensions[_normalizeDimensionKey(key)];
  }

  /// Retorna uma dimensão como String.
  ///
  /// Quando o valor armazenado não for String, utiliza `toString()`.
  /// Retorna nulo quando a dimensão não existir ou possuir valor nulo.
  String? dimensionAsString(String key) {
    final value = dimension(key);

    if (value == null) {
      return null;
    }

    if (value is String) {
      return value;
    }

    return value.toString();
  }

  /// Retorna uma dimensão como int.
  ///
  /// Também aceita valores numéricos e textos que possam ser convertidos.
  int? dimensionAsInt(String key) {
    final value = dimension(key);

    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }

  /// Retorna uma dimensão como double.
  ///
  /// Também aceita valores numéricos e textos que possam ser convertidos.
  double? dimensionAsDouble(String key) {
    final value = dimension(key);

    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
        value.trim().replaceAll(',', '.'),
      );
    }

    return null;
  }

  /// Retorna uma dimensão como bool.
  ///
  /// Também reconhece os textos:
  /// - true / false
  /// - 1 / 0
  /// - sim / não
  /// - yes / no
  bool? dimensionAsBool(String key) {
    final value = dimension(key);

    if (value == null) {
      return null;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      if (value == 1) {
        return true;
      }

      if (value == 0) {
        return false;
      }

      return null;
    }

    if (value is String) {
      final normalizedValue = value.trim().toLowerCase();

      switch (normalizedValue) {
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
    }

    return null;
  }

  /// Retorna uma dimensão como DateTime.
  ///
  /// Também aceita textos no formato reconhecido por DateTime.tryParse.
  DateTime? dimensionAsDateTime(String key) {
    final value = dimension(key);

    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value.trim());
    }

    return null;
  }

  /// Indica se uma dimensão está presente no registro.
  bool containsDimension(String key) {
    return dimensions.containsKey(
      _normalizeDimensionKey(key),
    );
  }

  /// Cria uma nova instância preservando os valores que não forem alterados.
  AnalyticsRecord copyWith({
    String? id,
    String? domain,
    DateTime? occurredAt,
    String? status,
    int? peopleCount,
    int? vehicleCount,
    int? humanResourcesCount,
    double? targetValue,
    bool clearTargetValue = false,
    double? achievedValue,
    bool clearAchievedValue = false,
    double? rating,
    bool clearRating = false,
    Map<String, Object?>? dimensions,
  }) {
    return AnalyticsRecord(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      occurredAt: occurredAt ?? this.occurredAt,
      status: status ?? this.status,
      peopleCount: peopleCount ?? this.peopleCount,
      vehicleCount: vehicleCount ?? this.vehicleCount,
      humanResourcesCount:
          humanResourcesCount ?? this.humanResourcesCount,
      targetValue:
          clearTargetValue ? null : targetValue ?? this.targetValue,
      achievedValue:
          clearAchievedValue ? null : achievedValue ?? this.achievedValue,
      rating: clearRating ? null : rating ?? this.rating,
      dimensions: dimensions ?? this.dimensions,
    );
  }

  /// Retorna uma nova instância acrescentando ou substituindo
  /// uma dimensão.
  AnalyticsRecord withDimension({
    required String key,
    required Object? value,
  }) {
    final normalizedKey = _normalizeDimensionKey(key);

    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(
        key,
        'key',
        'A chave da dimensão não pode estar vazia.',
      );
    }

    final updatedDimensions =
        Map<String, Object?>.from(dimensions)
          ..[normalizedKey] = value;

    return copyWith(
      dimensions: updatedDimensions,
    );
  }

  /// Retorna uma nova instância removendo uma dimensão.
  AnalyticsRecord withoutDimension(String key) {
    final normalizedKey = _normalizeDimensionKey(key);

    if (!dimensions.containsKey(normalizedKey)) {
      return this;
    }

    final updatedDimensions =
        Map<String, Object?>.from(dimensions)
          ..remove(normalizedKey);

    return copyWith(
      dimensions: updatedDimensions,
    );
  }

  void _validate() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'O identificador do registro não pode estar vazio.',
      );
    }

    if (domain.trim().isEmpty) {
      throw ArgumentError.value(
        domain,
        'domain',
        'O domínio institucional não pode estar vazio.',
      );
    }

    if (status.trim().isEmpty) {
      throw ArgumentError.value(
        status,
        'status',
        'O status do registro não pode estar vazio.',
      );
    }

    if (peopleCount < 0) {
      throw ArgumentError.value(
        peopleCount,
        'peopleCount',
        'A quantidade de pessoas não pode ser negativa.',
      );
    }

    if (vehicleCount < 0) {
      throw ArgumentError.value(
        vehicleCount,
        'vehicleCount',
        'A quantidade de veículos não pode ser negativa.',
      );
    }

    if (humanResourcesCount < 0) {
      throw ArgumentError.value(
        humanResourcesCount,
        'humanResourcesCount',
        'A quantidade de recursos humanos não pode ser negativa.',
      );
    }

    if (targetValue != null && targetValue! < 0) {
      throw ArgumentError.value(
        targetValue,
        'targetValue',
        'O valor da meta não pode ser negativo.',
      );
    }

    if (achievedValue != null && achievedValue! < 0) {
      throw ArgumentError.value(
        achievedValue,
        'achievedValue',
        'O valor alcançado não pode ser negativo.',
      );
    }

    if (rating != null && (rating! < 0 || rating! > 5)) {
      throw ArgumentError.value(
        rating,
        'rating',
        'A avaliação deve estar entre 0 e 5.',
      );
    }

    for (final entry in dimensions.entries) {
      if (entry.key.trim().isEmpty) {
        throw ArgumentError(
          'As chaves das dimensões adicionais não podem estar vazias.',
        );
      }
    }
  }

  static Map<String, Object?> _normalizeDimensions(
    Map<String, Object?> source,
  ) {
    final normalizedDimensions = <String, Object?>{};

    for (final entry in source.entries) {
      final normalizedKey = _normalizeDimensionKey(
        entry.key,
      );

      if (normalizedKey.isEmpty) {
        throw ArgumentError(
          'As chaves das dimensões adicionais não podem estar vazias.',
        );
      }

      normalizedDimensions[normalizedKey] = entry.value;
    }

    return normalizedDimensions;
  }

  static String _normalizeDimensionKey(String value) {
    return value.trim().toLowerCase();
  }

  @override
  String toString() {
    return 'AnalyticsRecord('
        'id: $id, '
        'domain: $domain, '
        'occurredAt: $occurredAt, '
        'status: $status, '
        'peopleCount: $peopleCount, '
        'vehicleCount: $vehicleCount, '
        'humanResourcesCount: $humanResourcesCount, '
        'targetValue: $targetValue, '
        'achievedValue: $achievedValue, '
        'rating: $rating, '
        'dimensions: $dimensions'
        ')';
  }
}