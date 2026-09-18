import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/security/escala_navigation_policy.dart';

void main() {
  test('todos os perfis reconhecidos consultam escala', () {
    for (final perfil in [
      'administrador',
      'gestor',
      'gerente',
      'coordenador',
      'agente',
    ]) {
      expect(
        EscalaNavigationPolicy.podeConsultar(
          perfilAcesso: perfil,
          usuarioId: 'uid-$perfil',
        ),
        isTrue,
      );
    }
  });

  test('gestao e somente gerente ou agente responsavel', () {
    expect(
      EscalaNavigationPolicy.podeGerenciar(
        perfilAcesso: 'gerente',
        usuarioId: 'gerente',
        responsavelEscalaUsuarioId: 'responsavel',
      ),
      isTrue,
    );
    expect(
      EscalaNavigationPolicy.podeGerenciar(
        perfilAcesso: 'agente',
        usuarioId: 'responsavel',
        responsavelEscalaUsuarioId: 'responsavel',
      ),
      isTrue,
    );
    expect(
      EscalaNavigationPolicy.podeGerenciar(
        perfilAcesso: 'agente',
        usuarioId: 'agente',
        responsavelEscalaUsuarioId: 'responsavel',
      ),
      isFalse,
    );
    expect(
      EscalaNavigationPolicy.podeGerenciar(
        perfilAcesso: 'administrador',
        usuarioId: 'admin',
        responsavelEscalaUsuarioId: 'responsavel',
      ),
      isFalse,
    );
  });

  test('configuracao e somente gerente ou administrador', () {
    for (final perfil in ['gerente', 'administrador']) {
      expect(
        EscalaNavigationPolicy.podeConfigurar(
          perfilAcesso: perfil,
          usuarioId: perfil,
        ),
        isTrue,
      );
    }

    for (final perfil in ['gestor', 'coordenador', 'agente']) {
      expect(
        EscalaNavigationPolicy.podeConfigurar(
          perfilAcesso: perfil,
          usuarioId: perfil,
        ),
        isFalse,
      );
    }
  });
}
