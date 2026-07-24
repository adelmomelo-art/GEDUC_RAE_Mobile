/// Representa o conjunto oficial de indicadores produzidos pelo
/// Analytics Engine.
///
/// Esta classe pertence ao Core Institucional da Plataforma Fênix.
/// Ela não conhece módulos operacionais, interface gráfica,
/// banco de dados ou serviços externos.
///
/// Todos os consumidores do Analytics (Dashboard, BI, Faxita e
/// Decision Engine) deverão utilizar esta mesma estrutura.
final class AnalyticsMetrics {
  /// Quantidade total de registros processados.
  final int totalRecords;

  /// Quantidade total de pessoas relacionadas aos registros.
  final int totalPeople;

  /// Quantidade total de veículos relacionados aos registros.
  final int totalVehicles;

  /// Quantidade total de recursos humanos envolvidos.
  final int totalHumanResources;

  /// Média de pessoas por registro.
  final double averagePeople;

  /// Média de veículos por registro.
  final double averageVehicles;

  /// Média de recursos humanos por registro.
  final double averageHumanResources;

  /// Quantidade de registros que possuíam metas.
  final int recordsWithTarget;

  /// Quantidade de registros que atingiram suas metas.
  final int recordsTargetAchieved;

  /// Percentual de metas atingidas.
  final double targetAchievementRate;

  /// Média de avaliação dos registros.
  ///
  /// Escala recomendada: 0 a 5.
  final double averageRating;

  const AnalyticsMetrics({
    this.totalRecords = 0,
    this.totalPeople = 0,
    this.totalVehicles = 0,
    this.totalHumanResources = 0,
    this.averagePeople = 0,
    this.averageVehicles = 0,
    this.averageHumanResources = 0,
    this.recordsWithTarget = 0,
    this.recordsTargetAchieved = 0,
    this.targetAchievementRate = 0,
    this.averageRating = 0,
  });

  /// Indica se existem registros processados.
  bool get hasData => totalRecords > 0;

  /// Indica se existem metas analisadas.
  bool get hasTargets => recordsWithTarget > 0;

  /// Indica se existem avaliações.
  bool get hasRatings => averageRating > 0;

  /// Retorna uma nova instância alterando apenas os campos desejados.
  AnalyticsMetrics copyWith({
    int? totalRecords,
    int? totalPeople,
    int? totalVehicles,
    int? totalHumanResources,
    double? averagePeople,
    double? averageVehicles,
    double? averageHumanResources,
    int? recordsWithTarget,
    int? recordsTargetAchieved,
    double? targetAchievementRate,
    double? averageRating,
  }) {
    return AnalyticsMetrics(
      totalRecords: totalRecords ?? this.totalRecords,
      totalPeople: totalPeople ?? this.totalPeople,
      totalVehicles: totalVehicles ?? this.totalVehicles,
      totalHumanResources:
          totalHumanResources ?? this.totalHumanResources,
      averagePeople: averagePeople ?? this.averagePeople,
      averageVehicles: averageVehicles ?? this.averageVehicles,
      averageHumanResources:
          averageHumanResources ?? this.averageHumanResources,
      recordsWithTarget:
          recordsWithTarget ?? this.recordsWithTarget,
      recordsTargetAchieved:
          recordsTargetAchieved ?? this.recordsTargetAchieved,
      targetAchievementRate:
          targetAchievementRate ?? this.targetAchievementRate,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnalyticsMetrics &&
            other.totalRecords == totalRecords &&
            other.totalPeople == totalPeople &&
            other.totalVehicles == totalVehicles &&
            other.totalHumanResources ==
                totalHumanResources &&
            other.averagePeople == averagePeople &&
            other.averageVehicles == averageVehicles &&
            other.averageHumanResources ==
                averageHumanResources &&
            other.recordsWithTarget ==
                recordsWithTarget &&
            other.recordsTargetAchieved ==
                recordsTargetAchieved &&
            other.targetAchievementRate ==
                targetAchievementRate &&
            other.averageRating == averageRating;
  }

  @override
  int get hashCode => Object.hash(
        totalRecords,
        totalPeople,
        totalVehicles,
        totalHumanResources,
        averagePeople,
        averageVehicles,
        averageHumanResources,
        recordsWithTarget,
        recordsTargetAchieved,
        targetAchievementRate,
        averageRating,
      );

  @override
  String toString() {
    return 'AnalyticsMetrics('
        'totalRecords: $totalRecords, '
        'totalPeople: $totalPeople, '
        'totalVehicles: $totalVehicles, '
        'totalHumanResources: $totalHumanResources, '
        'averagePeople: $averagePeople, '
        'averageVehicles: $averageVehicles, '
        'averageHumanResources: $averageHumanResources, '
        'recordsWithTarget: $recordsWithTarget, '
        'recordsTargetAchieved: $recordsTargetAchieved, '
        'targetAchievementRate: $targetAchievementRate, '
        'averageRating: $averageRating'
        ')';
  }
}