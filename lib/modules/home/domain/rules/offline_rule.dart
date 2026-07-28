import '../alert_level.dart';
import '../operational_alert.dart';
import '../operational_rule.dart';

/// Detecta operação sem conectividade por tempo relevante.
class OfflineRule implements OperationalRule {
  const OfflineRule({
    this.warningAfter = const Duration(minutes: 10),
    this.criticalAfter = const Duration(minutes: 30),
  });

  final Duration warningAfter;
  final Duration criticalAfter;

  @override
  String get id => 'offline-operation';

  @override
  OperationalAlert? evaluate(OperationalRuleContext context) {
    if (context.isConnected) {
      return null;
    }

    final duration = context.offlineDuration ?? Duration.zero;
    final minutes = duration.inMinutes;

    final level = duration >= criticalAfter
        ? AlertLevel.critical
        : duration >= warningAfter
            ? AlertLevel.warning
            : AlertLevel.info;

    return OperationalAlert(
      id: id,
      level: level,
      title: 'Operação sem conexão',
      message: minutes <= 0
          ? 'O dispositivo está operando sem acesso à internet.'
          : 'O dispositivo está sem conexão há $minutes minuto(s).',
      recommendation: level == AlertLevel.critical
          ? 'Restabeleça a conexão antes de ampliar o volume de novos registros.'
          : 'Os registros permanecem protegidos localmente e serão sincronizados após a reconexão.',
      createdAt: context.now,
      category: 'connectivity',
      metadata: <String, Object?>{
        'offlineMinutes': minutes,
      },
    );
  }
}
