import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/access_scope.dart';
import 'package:geduc_rae_mobile/core/security/permission.dart';
import 'package:geduc_rae_mobile/core/security/rae_access_policy.dart';
import 'package:geduc_rae_mobile/core/security/rae_access_record.dart';

void main() {
  const completo = RaeAccessRecord(
    aclClassificacaoCompleta: true,
    responsavelUserId: 'agente-1',
    coordenadorUserId: 'coordenador-1',
    regionalId: 'regional-1',
    equipeId: 'equipe-1',
    projetoId: 'projeto-1',
  );
  const q1 = RaeAccessRecord(
    aclClassificacaoCompleta: false,
    responsavelUserId: '',
    coordenadorUserId: '',
    regionalId: 'regional-1',
    equipeId: '',
    projetoId: '',
  );

  group('matriz ACL-001 Etapa 4A', () {
    test('flag falsa bloqueia registro mesmo com dimensões preenchidas', () {
      const inconsistente = RaeAccessRecord(
        aclClassificacaoCompleta: false,
        responsavelUserId: 'agente-1',
        coordenadorUserId: 'coordenador-1',
        regionalId: 'regional-1',
        equipeId: 'equipe-1',
        projetoId: 'projeto-1',
      );

      expect(
        _autoriza(
          'agente',
          'agente-1',
          Permission.consultarRae,
          inconsistente,
        ),
        isFalse,
      );
    });

    test('Q1 é visível somente ao Administrador', () {
      expect(
        _autoriza('administrador', 'admin-1', Permission.consultarRae, q1),
        isTrue,
      );
      for (final perfil in ['gestor', 'gerente', 'coordenador', 'agente']) {
        expect(
          _autoriza(perfil, '$perfil-1', Permission.consultarRae, q1),
          isFalse,
        );
      }
    });

    test('Gestor consulta registro completo, mas não edita', () {
      expect(
        _autoriza('gestor', 'gestor-1', Permission.consultarRae, completo),
        isTrue,
      );
      expect(
        _autoriza('gestor', 'gestor-1', Permission.editarRae, completo),
        isFalse,
      );
    });

    test('Gerente exige interseção integral do escopo', () {
      final escopo = AccessScope(
        regionalIds: const ['regional-1'],
        equipeIds: const ['equipe-1'],
        projetoIds: const ['projeto-1'],
      );
      expect(
        RaeAccessPolicy.autoriza(
          perfilAcesso: 'gerente',
          usuarioId: 'gerente-1',
          permissao: Permission.consultarRae,
          rae: completo,
          escopo: escopo,
        ),
        isTrue,
      );
      expect(
        RaeAccessPolicy.autoriza(
          perfilAcesso: 'gerente',
          usuarioId: 'gerente-1',
          permissao: Permission.editarRae,
          rae: completo,
          escopo: escopo,
        ),
        isFalse,
      );
    });

    test('Coordenador revisa somente o RAE que coordena', () {
      expect(
        _autoriza(
          'coordenador',
          'coordenador-1',
          Permission.finalizarRae,
          completo,
        ),
        isTrue,
      );
      expect(
        _autoriza(
          'coordenador',
          'coordenador-2',
          Permission.finalizarRae,
          completo,
        ),
        isFalse,
      );
    });

    test('Agente consulta e edita somente o próprio RAE', () {
      expect(
        _autoriza('agente', 'agente-1', Permission.editarRae, completo),
        isTrue,
      );
      expect(
        _autoriza('agente', 'agente-2', Permission.consultarRae, completo),
        isFalse,
      );
      expect(
        _autoriza('agente', 'agente-1', Permission.finalizarRae, completo),
        isFalse,
      );
    });

    test('somente Admin, Coordenador e Agente iniciam RAE', () {
      for (final perfil in ['administrador', 'coordenador', 'agente']) {
        expect(
          RaeAccessPolicy.autorizaCriacao(
            perfilAcesso: perfil,
            usuarioId: '$perfil-1',
          ),
          isTrue,
        );
      }
      for (final perfil in ['gestor', 'gerente']) {
        expect(
          RaeAccessPolicy.autorizaCriacao(
            perfilAcesso: perfil,
            usuarioId: '$perfil-1',
          ),
          isFalse,
        );
      }
    });
  });
}

bool _autoriza(
  String perfil,
  String usuarioId,
  Permission permissao,
  RaeAccessRecord rae,
) {
  return RaeAccessPolicy.autoriza(
    perfilAcesso: perfil,
    usuarioId: usuarioId,
    permissao: permissao,
    rae: rae,
  );
}
