import 'escala_navigation_policy.dart';

enum EscalaHomeShortcut {
  escalaGeduc,
  minhaEscala,
  gestaoEscala,
  configuracaoEscala,
}

abstract final class EscalaHomeShortcutsPolicy {
  static Set<EscalaHomeShortcut> resolver({
    required String? perfilAcesso,
    required String usuarioId,
    required String responsavelEscalaUsuarioId,
  }) {
    final atalhos = <EscalaHomeShortcut>{};

    if (EscalaNavigationPolicy.podeConsultar(
      perfilAcesso: perfilAcesso,
      usuarioId: usuarioId,
    )) {
      atalhos
        ..add(EscalaHomeShortcut.escalaGeduc)
        ..add(EscalaHomeShortcut.minhaEscala);
    }

    if (EscalaNavigationPolicy.podeGerenciar(
      perfilAcesso: perfilAcesso,
      usuarioId: usuarioId,
      responsavelEscalaUsuarioId: responsavelEscalaUsuarioId,
    )) {
      atalhos.add(EscalaHomeShortcut.gestaoEscala);
    }

    if (EscalaNavigationPolicy.podeConfigurar(
      perfilAcesso: perfilAcesso,
      usuarioId: usuarioId,
    )) {
      atalhos.add(EscalaHomeShortcut.configuracaoEscala);
    }

    return Set<EscalaHomeShortcut>.unmodifiable(atalhos);
  }
}
