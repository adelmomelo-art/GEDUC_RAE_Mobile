import '../alert_level.dart';
import '../operational_alert.dart';
import '../operational_rule.dart';

/// Detecta ausência prolongada de atualização do estado operacional.
class LastUpdateRule implements OperationalRule {
  const LastUpdateRule({
    this.warningAfter = const Duration(hours: 6),
    this.criticalAfter = const Duration(hours: 12),
  });

  final Duration warningAfter;
  final Duration criticalAfter;

  @override
  String get id => 'last-operational-update';

  @override
  OperationalAlert? evaluate(OperationalRuleContext context) {
    final updateAge = context.operationalUpdateAge;

    if (updateAge == null) {
      return OperationalAlert(
        id: id,
        level: AlertLevel.info,
        title: 'Atualização operacional não registrada',
        message: 'Ainda não há referência da última atualização do painel.',
        recommendation:
            'Atualize o Centro de Operações quando houver conectividade.',
        createdAt: context.now,
        category: 'operational-data',
      );
    }

    if (updateAge < warningAfter) {
      return null;
    }

    final level =
        updateAge >= criticalAfter ? AlertLevel.critical : AlertLevel.warning;
    final hours = updateAge.inHours;

    return OperationalAlert(
      id: id,
      level: level,
      title: 'Dados operacionais sem atualização recente',
      message: 'O painel não recebe atualização há $hours hora(s).',
      recommendation: level == AlertLevel.critical
          ? 'Verifique a origem dos dados e execute uma atualização completa.'
          : 'Atualize o painel para manter os indicadores operacionais confiáveis.',
      createdAt: context.now,
      category: 'operational-data',
      metadata: <String, Object?>{
        'operationalUpdateAgeHours': hours,
      },
    );
  }
}
