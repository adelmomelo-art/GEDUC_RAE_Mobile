import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/config/acl_feature_flags.dart';
import 'package:geduc_rae_mobile/core/security/authorization_policy.dart';
import 'package:geduc_rae_mobile/core/security/permission.dart';

void main() {
  test('integração ACL permanece desativada no APK padrão', () {
    expect(AclFeatureFlags.scopedAccessEnabled, isFalse);
  });

  test('Gestor e Gerente possuem capacidade somente de leitura', () {
    for (final perfil in ['gestor', 'gerente']) {
      expect(_permite(perfil, Permission.consultarRae), isTrue);
      expect(_permite(perfil, Permission.compartilharPdfRae), isTrue);
      expect(_permite(perfil, Permission.criarRae), isFalse);
      expect(_permite(perfil, Permission.editarRae), isFalse);
      expect(_permite(perfil, Permission.finalizarRae), isFalse);
    }
  });

  test('capacidades do Gerente exigem escopo completo na autorização', () {
    expect(
      AuthorizationPolicy.exigeEscopoCompletoDoGerente(
        Permission.consultarRae,
      ),
      isTrue,
    );
    expect(
      AuthorizationPolicy.exigeEscopoCompletoDoGerente(
        Permission.acessarCioEscopo,
      ),
      isTrue,
    );
    expect(
      AuthorizationPolicy.exigeEscopoCompletoDoGerente(Permission.criarRae),
      isFalse,
    );
  });

  test('Coordenador e Agente recebem capacidades operacionais distintas', () {
    expect(_permite('coordenador', Permission.finalizarRae), isTrue);
    expect(_permite('coordenador', Permission.revisarRae), isTrue);
    expect(_permite('agente', Permission.criarRae), isTrue);
    expect(_permite('agente', Permission.editarRae), isTrue);
    expect(_permite('agente', Permission.finalizarRae), isFalse);
  });
}

bool _permite(String perfil, Permission permissao) {
  return AuthorizationPolicy.possuiPermissao(
    perfilAcesso: perfil,
    permissao: permissao,
  );
}
