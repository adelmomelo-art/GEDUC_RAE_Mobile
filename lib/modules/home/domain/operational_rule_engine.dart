import 'operational_alert.dart';
import 'operational_rule.dart';
import 'rules/cache_stale_rule.dart';
import 'rules/last_update_rule.dart';
import 'rules/offline_rule.dart';
import 'rules/pending_sync_rule.dart';
import 'rules/sync_error_rule.dart';

/// Executa um conjunto de regras operacionais e consolida os alertas.
class OperationalRuleEngine {
  OperationalRuleEngine({
    required Iterable<OperationalRule> rules,
  }) : _rules = List<OperationalRule>.unmodifiable(rules);

  /// Configuração padrão da CE-032C.3B.1.
  factory OperationalRuleEngine.standard() {
    return OperationalRuleEngine(
      rules: const <OperationalRule>[
        OfflineRule(),
        PendingSyncRule(),
        CacheStaleRule(),
        SyncErrorRule(),
        LastUpdateRule(),
      ],
    );
  }

  final List<OperationalRule> _rules;

  List<OperationalRule> get rules => _rules;

  /// Avalia todas as regras, remove duplicidades e ordena por prioridade.
  List<OperationalAlert> evaluate(OperationalRuleContext context) {
    final alertsById = <String, OperationalAlert>{};

    for (final rule in _rules) {
      final alert = rule.evaluate(context);
      if (alert != null) {
        alertsById[alert.id] = alert;
      }
    }

    final alerts = alertsById.values.toList(growable: false)
      ..sort((a, b) {
        final severityComparison = b.level.priority.compareTo(a.level.priority);
        if (severityComparison != 0) {
          return severityComparison;
        }

        return a.title.compareTo(b.title);
      });

    return List<OperationalAlert>.unmodifiable(alerts);
  }
}
