import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/security/escala_home_shortcuts_policy.dart';

void main() {
  test('agente comum recebe somente um atalho de consulta da escala', () {
    final atalhos = EscalaHomeShortcutsPolicy.resolver(
      perfilAcesso: 'agente',
      usuarioId: 'agente',
      responsavelEscalaUsuarioId: 'responsavel',
    );

    expect(atalhos, contains(EscalaHomeShortcut.escalaGeduc));
    expect(atalhos, isNot(contains(EscalaHomeShortcut.gestaoEscala)));
    expect(atalhos, isNot(contains(EscalaHomeShortcut.configuracaoEscala)));
  });

  test('responsavel recebe gestao e nao configuracao', () {
    final atalhos = EscalaHomeShortcutsPolicy.resolver(
      perfilAcesso: 'agente',
      usuarioId: 'responsavel',
      responsavelEscalaUsuarioId: 'responsavel',
    );

    expect(atalhos, contains(EscalaHomeShortcut.gestaoEscala));
    expect(atalhos, isNot(contains(EscalaHomeShortcut.configuracaoEscala)));
  });

  test('gerente recebe gestao e configuracao', () {
    final atalhos = EscalaHomeShortcutsPolicy.resolver(
      perfilAcesso: 'gerente',
      usuarioId: 'gerente',
      responsavelEscalaUsuarioId: 'responsavel',
    );

    expect(atalhos, contains(EscalaHomeShortcut.escalaGeduc));
    expect(atalhos, contains(EscalaHomeShortcut.gestaoEscala));
    expect(atalhos, contains(EscalaHomeShortcut.configuracaoEscala));
  });

  test('administrador recebe configuracao mas nao gestao operacional', () {
    final atalhos = EscalaHomeShortcutsPolicy.resolver(
      perfilAcesso: 'administrador',
      usuarioId: 'admin',
      responsavelEscalaUsuarioId: 'responsavel',
    );

    expect(atalhos, contains(EscalaHomeShortcut.configuracaoEscala));
    expect(atalhos, isNot(contains(EscalaHomeShortcut.gestaoEscala)));
  });
}
