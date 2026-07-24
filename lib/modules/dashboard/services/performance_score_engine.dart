/// Motor responsável pelo cálculo do Índice de Desempenho Operacional (IDO).
///
/// O cálculo utiliza cinco dimensões normalizadas:
/// - ações realizadas;
/// - pessoas alcançadas;
/// - veículos abordados;
/// - credenciais emitidas;
/// - percentual de metas atingidas.
///
/// Cada dimensão possui peso configurável. O resultado final é limitado
/// ao intervalo entre 0 e 100.
class PerformanceScoreEngine {
  const PerformanceScoreEngine({
    this.weights = const PerformanceScoreWeights(),
  });

  final PerformanceScoreWeights weights;

  /// Calcula o IDO a partir dos dados operacionais e das referências usadas
  /// para normalização.
  ///
  /// Valores negativos são tratados como zero. Referências iguais ou menores
  /// que zero não geram pontuação para a respectiva dimensão.
  PerformanceScoreResult calculate({
    required PerformanceScoreInput input,
    required PerformanceScoreReference reference,
  }) {
    final normalizedWeights = weights.normalized;

    final actionsScore = _normalize(
      input.actions,
      reference.actions,
    );

    final peopleScore = _normalize(
      input.peopleReached,
      reference.peopleReached,
    );

    final vehiclesScore = _normalize(
      input.vehiclesApproached,
      reference.vehiclesApproached,
    );

    final credentialsScore = _normalize(
      input.credentialsIssued,
      reference.credentialsIssued,
    );

    final goalsScore = _normalizePercentage(
      input.goalsAchievementPercentage,
      reference.goalsAchievementPercentage,
    );

    final totalScore = _clampScore(
      (actionsScore * normalizedWeights.actions) +
          (peopleScore * normalizedWeights.peopleReached) +
          (vehiclesScore * normalizedWeights.vehiclesApproached) +
          (credentialsScore * normalizedWeights.credentialsIssued) +
          (goalsScore * normalizedWeights.goalsAchievement),
    );

    return PerformanceScoreResult(
      score: totalScore,
      classification: PerformanceScoreClassification.fromScore(totalScore),
      actionsScore: actionsScore,
      peopleReachedScore: peopleScore,
      vehiclesApproachedScore: vehiclesScore,
      credentialsIssuedScore: credentialsScore,
      goalsAchievementScore: goalsScore,
      weights: normalizedWeights,
    );
  }

  /// Atalho para calcular apenas o valor numérico do IDO.
  double calculateScore({
    required PerformanceScoreInput input,
    required PerformanceScoreReference reference,
  }) {
    return calculate(
      input: input,
      reference: reference,
    ).score;
  }

  double _normalize(num value, num reference) {
    final safeValue = value < 0 ? 0.0 : value.toDouble();
    final safeReference = reference.toDouble();

    if (safeReference <= 0) {
      return 0;
    }

    return _clampScore((safeValue / safeReference) * 100);
  }

  double _normalizePercentage(num value, num reference) {
    final safeValue = value < 0 ? 0.0 : value.toDouble();
    final safeReference = reference.toDouble();

    if (safeReference <= 0) {
      return 0;
    }

    return _clampScore((safeValue / safeReference) * 100);
  }

  double _clampScore(num value) {
    return value.toDouble().clamp(0.0, 100.0);
  }
}

/// Pesos utilizados no cálculo do IDO.
///
/// Os valores podem ser informados em qualquer escala positiva.
/// Antes do cálculo, os pesos são automaticamente normalizados para que
/// a soma seja igual a 1.
class PerformanceScoreWeights {
  const PerformanceScoreWeights({
    this.actions = 0.20,
    this.peopleReached = 0.25,
    this.vehiclesApproached = 0.15,
    this.credentialsIssued = 0.10,
    this.goalsAchievement = 0.30,
  });

  final double actions;
  final double peopleReached;
  final double vehiclesApproached;
  final double credentialsIssued;
  final double goalsAchievement;

  double get total {
    return _safe(actions) +
        _safe(peopleReached) +
        _safe(vehiclesApproached) +
        _safe(credentialsIssued) +
        _safe(goalsAchievement);
  }

  PerformanceScoreWeights get normalized {
    final sum = total;

    if (sum <= 0) {
      return const PerformanceScoreWeights();
    }

    return PerformanceScoreWeights(
      actions: _safe(actions) / sum,
      peopleReached: _safe(peopleReached) / sum,
      vehiclesApproached: _safe(vehiclesApproached) / sum,
      credentialsIssued: _safe(credentialsIssued) / sum,
      goalsAchievement: _safe(goalsAchievement) / sum,
    );
  }

  PerformanceScoreWeights copyWith({
    double? actions,
    double? peopleReached,
    double? vehiclesApproached,
    double? credentialsIssued,
    double? goalsAchievement,
  }) {
    return PerformanceScoreWeights(
      actions: actions ?? this.actions,
      peopleReached: peopleReached ?? this.peopleReached,
      vehiclesApproached:
          vehiclesApproached ?? this.vehiclesApproached,
      credentialsIssued:
          credentialsIssued ?? this.credentialsIssued,
      goalsAchievement:
          goalsAchievement ?? this.goalsAchievement,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'actions': actions,
      'peopleReached': peopleReached,
      'vehiclesApproached': vehiclesApproached,
      'credentialsIssued': credentialsIssued,
      'goalsAchievement': goalsAchievement,
    };
  }

  factory PerformanceScoreWeights.fromMap(
    Map<String, dynamic> map,
  ) {
    return PerformanceScoreWeights(
      actions: (map['actions'] as num?)?.toDouble() ?? 0.20,
      peopleReached:
          (map['peopleReached'] as num?)?.toDouble() ?? 0.25,
      vehiclesApproached:
          (map['vehiclesApproached'] as num?)?.toDouble() ?? 0.15,
      credentialsIssued:
          (map['credentialsIssued'] as num?)?.toDouble() ?? 0.10,
      goalsAchievement:
          (map['goalsAchievement'] as num?)?.toDouble() ?? 0.30,
    );
  }

  static double _safe(double value) {
    return value < 0 ? 0 : value;
  }

  @override
  String toString() {
    return 'PerformanceScoreWeights('
        'actions: $actions, '
        'peopleReached: $peopleReached, '
        'vehiclesApproached: $vehiclesApproached, '
        'credentialsIssued: $credentialsIssued, '
        'goalsAchievement: $goalsAchievement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PerformanceScoreWeights &&
            actions == other.actions &&
            peopleReached == other.peopleReached &&
            vehiclesApproached == other.vehiclesApproached &&
            credentialsIssued == other.credentialsIssued &&
            goalsAchievement == other.goalsAchievement;
  }

  @override
  int get hashCode {
    return Object.hash(
      actions,
      peopleReached,
      vehiclesApproached,
      credentialsIssued,
      goalsAchievement,
    );
  }
}

/// Dados operacionais usados no cálculo do IDO.
class PerformanceScoreInput {
  const PerformanceScoreInput({
    required this.actions,
    required this.peopleReached,
    required this.vehiclesApproached,
    required this.credentialsIssued,
    required this.goalsAchievementPercentage,
  });

  final int actions;
  final int peopleReached;
  final int vehiclesApproached;
  final int credentialsIssued;
  final double goalsAchievementPercentage;

  PerformanceScoreInput copyWith({
    int? actions,
    int? peopleReached,
    int? vehiclesApproached,
    int? credentialsIssued,
    double? goalsAchievementPercentage,
  }) {
    return PerformanceScoreInput(
      actions: actions ?? this.actions,
      peopleReached: peopleReached ?? this.peopleReached,
      vehiclesApproached:
          vehiclesApproached ?? this.vehiclesApproached,
      credentialsIssued:
          credentialsIssued ?? this.credentialsIssued,
      goalsAchievementPercentage:
          goalsAchievementPercentage ??
              this.goalsAchievementPercentage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'actions': actions,
      'peopleReached': peopleReached,
      'vehiclesApproached': vehiclesApproached,
      'credentialsIssued': credentialsIssued,
      'goalsAchievementPercentage': goalsAchievementPercentage,
    };
  }

  factory PerformanceScoreInput.fromMap(
    Map<String, dynamic> map,
  ) {
    return PerformanceScoreInput(
      actions: (map['actions'] as num?)?.toInt() ?? 0,
      peopleReached:
          (map['peopleReached'] as num?)?.toInt() ?? 0,
      vehiclesApproached:
          (map['vehiclesApproached'] as num?)?.toInt() ?? 0,
      credentialsIssued:
          (map['credentialsIssued'] as num?)?.toInt() ?? 0,
      goalsAchievementPercentage:
          (map['goalsAchievementPercentage'] as num?)
                  ?.toDouble() ??
              0,
    );
  }

  @override
  String toString() {
    return 'PerformanceScoreInput('
        'actions: $actions, '
        'peopleReached: $peopleReached, '
        'vehiclesApproached: $vehiclesApproached, '
        'credentialsIssued: $credentialsIssued, '
        'goalsAchievementPercentage: '
        '$goalsAchievementPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PerformanceScoreInput &&
            actions == other.actions &&
            peopleReached == other.peopleReached &&
            vehiclesApproached == other.vehiclesApproached &&
            credentialsIssued == other.credentialsIssued &&
            goalsAchievementPercentage ==
                other.goalsAchievementPercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      actions,
      peopleReached,
      vehiclesApproached,
      credentialsIssued,
      goalsAchievementPercentage,
    );
  }
}

/// Valores de referência utilizados para normalizar o desempenho.
///
/// As referências podem representar metas, médias históricas, melhores
/// resultados ou valores definidos pela gestão.
class PerformanceScoreReference {
  const PerformanceScoreReference({
    required this.actions,
    required this.peopleReached,
    required this.vehiclesApproached,
    required this.credentialsIssued,
    this.goalsAchievementPercentage = 100,
  });

  final int actions;
  final int peopleReached;
  final int vehiclesApproached;
  final int credentialsIssued;
  final double goalsAchievementPercentage;

  PerformanceScoreReference copyWith({
    int? actions,
    int? peopleReached,
    int? vehiclesApproached,
    int? credentialsIssued,
    double? goalsAchievementPercentage,
  }) {
    return PerformanceScoreReference(
      actions: actions ?? this.actions,
      peopleReached: peopleReached ?? this.peopleReached,
      vehiclesApproached:
          vehiclesApproached ?? this.vehiclesApproached,
      credentialsIssued:
          credentialsIssued ?? this.credentialsIssued,
      goalsAchievementPercentage:
          goalsAchievementPercentage ??
              this.goalsAchievementPercentage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'actions': actions,
      'peopleReached': peopleReached,
      'vehiclesApproached': vehiclesApproached,
      'credentialsIssued': credentialsIssued,
      'goalsAchievementPercentage': goalsAchievementPercentage,
    };
  }

  factory PerformanceScoreReference.fromMap(
    Map<String, dynamic> map,
  ) {
    return PerformanceScoreReference(
      actions: (map['actions'] as num?)?.toInt() ?? 0,
      peopleReached:
          (map['peopleReached'] as num?)?.toInt() ?? 0,
      vehiclesApproached:
          (map['vehiclesApproached'] as num?)?.toInt() ?? 0,
      credentialsIssued:
          (map['credentialsIssued'] as num?)?.toInt() ?? 0,
      goalsAchievementPercentage:
          (map['goalsAchievementPercentage'] as num?)
                  ?.toDouble() ??
              100,
    );
  }

  @override
  String toString() {
    return 'PerformanceScoreReference('
        'actions: $actions, '
        'peopleReached: $peopleReached, '
        'vehiclesApproached: $vehiclesApproached, '
        'credentialsIssued: $credentialsIssued, '
        'goalsAchievementPercentage: '
        '$goalsAchievementPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PerformanceScoreReference &&
            actions == other.actions &&
            peopleReached == other.peopleReached &&
            vehiclesApproached == other.vehiclesApproached &&
            credentialsIssued == other.credentialsIssued &&
            goalsAchievementPercentage ==
                other.goalsAchievementPercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      actions,
      peopleReached,
      vehiclesApproached,
      credentialsIssued,
      goalsAchievementPercentage,
    );
  }
}

/// Resultado detalhado do cálculo do IDO.
class PerformanceScoreResult {
  const PerformanceScoreResult({
    required this.score,
    required this.classification,
    required this.actionsScore,
    required this.peopleReachedScore,
    required this.vehiclesApproachedScore,
    required this.credentialsIssuedScore,
    required this.goalsAchievementScore,
    required this.weights,
  });

  final double score;
  final PerformanceScoreClassification classification;

  final double actionsScore;
  final double peopleReachedScore;
  final double vehiclesApproachedScore;
  final double credentialsIssuedScore;
  final double goalsAchievementScore;

  final PerformanceScoreWeights weights;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'score': score,
      'classification': classification.name,
      'actionsScore': actionsScore,
      'peopleReachedScore': peopleReachedScore,
      'vehiclesApproachedScore': vehiclesApproachedScore,
      'credentialsIssuedScore': credentialsIssuedScore,
      'goalsAchievementScore': goalsAchievementScore,
      'weights': weights.toMap(),
    };
  }

  @override
  String toString() {
    return 'PerformanceScoreResult('
        'score: $score, '
        'classification: $classification)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PerformanceScoreResult &&
            score == other.score &&
            classification == other.classification &&
            actionsScore == other.actionsScore &&
            peopleReachedScore == other.peopleReachedScore &&
            vehiclesApproachedScore ==
                other.vehiclesApproachedScore &&
            credentialsIssuedScore ==
                other.credentialsIssuedScore &&
            goalsAchievementScore ==
                other.goalsAchievementScore &&
            weights == other.weights;
  }

  @override
  int get hashCode {
    return Object.hash(
      score,
      classification,
      actionsScore,
      peopleReachedScore,
      vehiclesApproachedScore,
      credentialsIssuedScore,
      goalsAchievementScore,
      weights,
    );
  }
}

/// Classificação executiva do IDO.
enum PerformanceScoreClassification {
  excellent,
  good,
  attention,
  critical;

  static PerformanceScoreClassification fromScore(double score) {
    if (score >= 85) {
      return PerformanceScoreClassification.excellent;
    }

    if (score >= 70) {
      return PerformanceScoreClassification.good;
    }

    if (score >= 50) {
      return PerformanceScoreClassification.attention;
    }

    return PerformanceScoreClassification.critical;
  }

  String get label {
    switch (this) {
      case PerformanceScoreClassification.excellent:
        return 'Excelente';
      case PerformanceScoreClassification.good:
        return 'Bom';
      case PerformanceScoreClassification.attention:
        return 'Atenção';
      case PerformanceScoreClassification.critical:
        return 'Crítico';
    }
  }
}
