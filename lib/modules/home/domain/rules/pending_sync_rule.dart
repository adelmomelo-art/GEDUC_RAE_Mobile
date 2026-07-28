import '../alert_level.dart';
import '../operational_alert.dart';
import '../operational_rule.dart';

/// Detecta volume relevante de registros aguardando sincronização.
class PendingSyncRule implements OperationalRule {
  const PendingSyncRule({
    this.warningThreshold = 5,
    this.criticalThreshold = 15,
  });

  final int warningThreshold;
  final int criticalThreshold;

  @override
  String get id => 'pending-sync';

  @override
  OperationalAlert? evaluate(OperationalRuleContext context) {
    final count = context.pendingSyncCount;
    if (count <= 0) {
      return null;
    }

    final level = count >= criticalThreshold
        ? AlertLevel.critical
        : count >= warningThreshold
            ? AlertLevel.warning
            : AlertLevel.info;

    return OperationalAlert(
      id: id,
      level: level,
      title: 'Registros aguardando sincronização',
      message: count == 1
          ? 'Existe 1 registro pendente de envio.'
          : 'Existem $count registros pendentes de envio.',
      recommendation: level == AlertLevel.critical
          ? 'Priorize a sincronização antes de iniciar novas ações.'
          : 'Mantenha o dispositivo conectado para concluir os envios pendentes.',
      createdAt: context.now,
      category: 'synchronization',
      metadata: <String, Object?>{
        'pendingSyncCount': count,
      },
    );
  }
}
