import 'operational_alert.dart';

/// Retrato imutável do estado necessário para avaliação operacional.
///
/// Este contrato pertence ao domínio. Na CE-032C.3B.2, o HomeController
/// será responsável por converter o estado real da aplicação neste modelo.
class OperationalRuleContext {
  const OperationalRuleContext({
    required this.now,
    required this.isConnected,
    required this.pendingSyncCount,
    required this.consecutiveSyncFailures,
    this.offlineSince,
    this.lastCacheUpdate,
    this.lastOperationalUpdate,
    this.lastSuccessfulSync,
  });

  final DateTime now;
  final bool isConnected;
  final int pendingSyncCount;
  final int consecutiveSyncFailures;
  final DateTime? offlineSince;
  final DateTime? lastCacheUpdate;
  final DateTime? lastOperationalUpdate;
  final DateTime? lastSuccessfulSync;

  Duration? get offlineDuration {
    final since = offlineSince;
    if (isConnected || since == null) {
      return null;
    }
    return now.difference(since);
  }

  Duration? get cacheAge {
    final updatedAt = lastCacheUpdate;
    if (updatedAt == null) {
      return null;
    }
    return now.difference(updatedAt);
  }

  Duration? get operationalUpdateAge {
    final updatedAt = lastOperationalUpdate;
    if (updatedAt == null) {
      return null;
    }
    return now.difference(updatedAt);
  }

  Duration? get successfulSyncAge {
    final syncedAt = lastSuccessfulSync;
    if (syncedAt == null) {
      return null;
    }
    return now.difference(syncedAt);
  }
}

/// Contrato de uma regra operacional.
///
/// Cada regra avalia o contexto e retorna zero ou um alerta.
/// O retorno nulo indica que a condição monitorada não exige comunicação.
abstract interface class OperationalRule {
  String get id;

  OperationalAlert? evaluate(OperationalRuleContext context);
}
