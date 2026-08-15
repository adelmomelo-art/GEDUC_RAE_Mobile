import 'package:flutter/foundation.dart';

import 'access_scope.dart';
import 'authorization_policy.dart';
import 'authorization_service.dart';

class AccessScopeProvider extends ChangeNotifier {
  AccessScopeProvider({AuthorizationService? authorizationService})
      : _authorizationService =
            authorizationService ?? AuthorizationService.instance {
    _authorizationService.addListener(_propagarIdentidade);
  }

  final AuthorizationService _authorizationService;

  AccessScope get escopo => _authorizationService.escopoAtual;
  String get perfil => _authorizationService.perfilAtual;

  bool get pronto {
    if (!_authorizationService.identidadeValida) return false;
    if (perfil != 'gerente') {
      return AuthorizationPolicy.perfilReconhecido(perfil);
    }
    return escopo.completoParaGerente;
  }

  String? get motivoBloqueio {
    if (!_authorizationService.identidadeValida) {
      return 'A identidade ainda não está válida.';
    }
    if (perfil == 'gerente' && !escopo.completoParaGerente) {
      return 'O escopo do Gerente está incompleto.';
    }
    return null;
  }

  void _propagarIdentidade() => notifyListeners();

  @override
  void dispose() {
    _authorizationService.removeListener(_propagarIdentidade);
    super.dispose();
  }
}
