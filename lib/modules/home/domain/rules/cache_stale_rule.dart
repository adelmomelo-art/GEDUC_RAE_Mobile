import '../alert_level.dart';
import '../operational_alert.dart';
import '../operational_rule.dart';

/// Detecta cache inexistente ou desatualizado.
class CacheStaleRule implements OperationalRule {
  const CacheStaleRule({
    this.warningAfter = const Duration(hours: 12),
    this.criticalAfter = const Duration(hours: 24),
  });

  final Duration warningAfter;
  final Duration criticalAfter;

  @override
  String get id => 'stale-cache';

  @override
  OperationalAlert? evaluate(OperationalRuleContext context) {
    final cacheAge = context.cacheAge;

    if (cacheAge == null) {
      return OperationalAlert(
        id: id,
        level: AlertLevel.warning,
        title: 'Cache ainda não atualizado',
        message: 'Não há registro de atualização do cache operacional.',
        recommendation:
            'Conecte o dispositivo e atualize os dados antes da operação offline.',
        createdAt: context.now,
        category: 'cache',
      );
    }

    if (cacheAge < warningAfter) {
      return null;
    }

    final level =
        cacheAge >= criticalAfter ? AlertLevel.critical : AlertLevel.warning;
    final hours = cacheAge.inHours;

    return OperationalAlert(
      id: id,
      level: level,
      title: 'Cache operacional desatualizado',
      message: 'A última atualização do cache ocorreu há $hours hora(s).',
      recommendation: level == AlertLevel.critical
          ? 'Atualize imediatamente os dados para reduzir o risco de informações divergentes.'
          : 'Atualize o cache assim que houver conectividade disponível.',
      createdAt: context.now,
      category: 'cache',
      metadata: <String, Object?>{
        'cacheAgeHours': hours,
      },
    );
  }
}
