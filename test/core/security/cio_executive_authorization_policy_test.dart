import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/authorization_policy.dart';
import 'package:geduc_rae_mobile/core/security/permission.dart';

void main() {
  group('permissão da visão executiva do CIO', () {
    for (final profile in [
      'administrador',
      'gestor',
      'coordenador',
    ]) {
      test('autoriza $profile', () {
        expect(
          AuthorizationPolicy.possuiPermissao(
            perfilAcesso: profile,
            permissao: Permission.acessarCioExecutivo,
          ),
          isTrue,
        );
      });
    }

    test('nega agente', () {
      expect(
        AuthorizationPolicy.possuiPermissao(
          perfilAcesso: 'agente',
          permissao: Permission.acessarCioExecutivo,
        ),
        isFalse,
      );
    });

    test('reconhece gerente, mas bloqueia CIO até existir recorte', () {
      expect(AuthorizationPolicy.perfilReconhecido('gerente'), isTrue);
      expect(
        AuthorizationPolicy.possuiPermissao(
          perfilAcesso: 'gerente',
          permissao: Permission.acessarCioExecutivo,
        ),
        isFalse,
      );
      expect(
        AuthorizationPolicy.possuiPermissao(
          perfilAcesso: 'gerente',
          permissao: Permission.acessarAdministracao,
        ),
        isFalse,
      );
      expect(
        AuthorizationPolicy.possuiPermissao(
          perfilAcesso: 'gerente',
          permissao: Permission.gerenciarUsuarios,
        ),
        isFalse,
      );
    });

    test('gestor acessa CIO sem administrar usuários', () {
      expect(
        AuthorizationPolicy.possuiPermissao(
          perfilAcesso: 'gestor',
          permissao: Permission.acessarCioExecutivo,
        ),
        isTrue,
      );
      expect(
        AuthorizationPolicy.possuiPermissao(
          perfilAcesso: 'gestor',
          permissao: Permission.gerenciarUsuarios,
        ),
        isFalse,
      );
    });
  });
}
