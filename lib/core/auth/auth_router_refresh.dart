import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Notifica o GoRouter sempre que o estado de autenticação mudar.
///
/// Mantém a proteção de rotas sincronizada com a sessão do Firebase,
/// inclusive após retomada ou reconstrução do aplicativo no Android.
class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
