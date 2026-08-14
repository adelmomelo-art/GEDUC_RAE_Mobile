import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Serializa uma troca de rota para que o frame atual termine antes de
/// desmontar widgets que ainda dependem de elementos herdados.
class SafeRouteTransition {
  bool _scheduled = false;

  bool get isScheduled => _scheduled;

  void goAfterFrame(
    BuildContext context,
    String location, {
    VoidCallback? beforeNavigation,
  }) {
    if (_scheduled) {
      return;
    }

    _scheduled = true;
    FocusManager.instance.primaryFocus?.unfocus();
    beforeNavigation?.call();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        _scheduled = false;
        return;
      }

      context.go(location);
    });
  }
}
