import 'alert_level.dart';

/// Alerta produzido pelo motor de regras operacionais.
///
/// O modelo é imutável e não possui dependência de Flutter, Firebase
/// ou qualquer camada de apresentação.
class OperationalAlert {
  const OperationalAlert({
    required this.id,
    required this.level,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.createdAt,
    this.category = 'operational',
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final AlertLevel level;
  final String title;
  final String message;
  final String recommendation;
  final DateTime createdAt;
  final String category;
  final Map<String, Object?> metadata;

  bool get isCritical => level == AlertLevel.critical;
  bool get requiresAttention => level != AlertLevel.info;

  OperationalAlert copyWith({
    String? id,
    AlertLevel? level,
    String? title,
    String? message,
    String? recommendation,
    DateTime? createdAt,
    String? category,
    Map<String, Object?>? metadata,
  }) {
    return OperationalAlert(
      id: id ?? this.id,
      level: level ?? this.level,
      title: title ?? this.title,
      message: message ?? this.message,
      recommendation: recommendation ?? this.recommendation,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OperationalAlert &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            level == other.level &&
            title == other.title &&
            message == other.message &&
            recommendation == other.recommendation &&
            createdAt == other.createdAt &&
            category == other.category;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      level,
      title,
      message,
      recommendation,
      createdAt,
      category,
    );
  }

  @override
  String toString() {
    return 'OperationalAlert('
        'id: $id, '
        'level: ${level.name}, '
        'title: $title, '
        'category: $category'
        ')';
  }
}
