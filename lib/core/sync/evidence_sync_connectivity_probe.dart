import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class EvidenceSyncConnectivityProbe {
  Future<bool> possuiRede();
}

/// Adaptador de sinal de conectividade.
///
/// `connectivity_plus` informa disponibilidade de interface/rota de rede, nao
/// prova acesso efetivo a Internet. Por isso esta porta funciona apenas como
/// gate antecipado; falhas reais continuam sendo classificadas pelo transporte.
class ConnectivityPlusEvidenceSyncConnectivityProbe
    implements EvidenceSyncConnectivityProbe {
  ConnectivityPlusEvidenceSyncConnectivityProbe({
    Connectivity? connectivity,
    this.timeout = const Duration(seconds: 5),
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final Duration timeout;

  @override
  Future<bool> possuiRede() async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(timeout);
      return results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
