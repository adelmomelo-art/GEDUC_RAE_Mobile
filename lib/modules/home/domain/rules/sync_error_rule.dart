import '../alert_level.dart';
import '../operational_alert.dart';
import '../operational_rule.dart';

/// Detecta falhas consecutivas no processo de sincronização.
class SyncErrorRule implements OperationalRule {
  const SyncErrorRule({
    this.warningThreshold = 1,
    this.criticalThreshold = 3,
  });

  final int warningThreshold;
  final int criticalThreshold;

  @override
  String get id => 'sync-failures';

  @override
  OperationalAlert? evaluate(OperationalRuleContext context) {
    final failures = context.consecutiveSyncFailures;
    if (failures < warningThreshold) {
      return null;
    }

    final level = failures >= criticalThreshold
        ? AlertLevel.critical
        : AlertLevel.warning;

    return OperationalAlert(
      id: id,
      level: level,
      title: 'Falha de sincronização',
      message: failures == 1
          ? 'A última tentativa de sincronização falhou.'
          : 'Foram registradas $failures falhas consecutivas de sincronização.',
      recommendation: level == AlertLevel.critical
          ? 'Verifique a conexão e os serviços antes de repetir o envio.'
          : 'Aguarde alguns instantes e tente sincronizar novamente.',
      createdAt: context.now,
      category: 'synchronization',
      metadata: <String, Object?>{
        'consecutiveFailures': failures,
      },
    );
  }
}
