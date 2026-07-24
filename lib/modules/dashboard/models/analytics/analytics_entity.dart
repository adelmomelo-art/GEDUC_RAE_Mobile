import 'analytics_enums.dart';

abstract class AnalyticsEntity {
  const AnalyticsEntity({
    required this.id,
    required this.dataGeracao,
    required this.origem,
    this.observacao,
  });

  final String id;
  final DateTime dataGeracao;
  final OrigemAnalise origem;
  final String? observacao;

  Map<String, dynamic> baseToMap() {
    return <String, dynamic>{
      'id': id,
      'dataGeracao': dataGeracao.toIso8601String(),
      'origem': origem.name,
      'observacao': observacao,
    };
  }

  static DateTime parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnalyticsEntity &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            dataGeracao == other.dataGeracao &&
            origem == other.origem &&
            observacao == other.observacao;
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      dataGeracao,
      origem,
      observacao,
    );
  }
}
