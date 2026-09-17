import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/security/escala_access_policy.dart';
import 'package:geduc_rae_mobile/modules/escala/security/escala_permission.dart';

void main() {
  bool autoriza({
    required String perfil,
    required String uid,
    required EscalaPermission permissao,
    String responsavel = 'responsavel',
    bool participante = false,
    bool coordenador = false,
  }) {
    return EscalaAccessPolicy.autoriza(
      perfilAcesso: perfil,
      usuarioId: uid,
      responsavelEscalaUsuarioId: responsavel,
      permissao: permissao,
      ehParticipanteAtividade: participante,
      ehCoordenadorAtividade: coordenador,
    );
  }

  group('EscalaAccessPolicy', () {
    test('todos os perfis reconhecidos da escala consultam escala geral', () {
      for (final perfil in [
        'administrador',
        'gestor',
        'gerente',
        'coordenador',
        'agente',
      ]) {
        expect(
          autoriza(
            perfil: perfil,
            uid: 'uid-$perfil',
            permissao: EscalaPermission.consultarEscalaGeral,
          ),
          isTrue,
        );
      }
    });

    test('agente comum não gerencia escala', () {
      expect(
        autoriza(
          perfil: 'agente',
          uid: 'agente-comum',
          permissao: EscalaPermission.editarEscala,
        ),
        isFalse,
      );
    });

    test('agente responsável cria edita revisa e publica', () {
      for (final permissao in [
        EscalaPermission.criarEscala,
        EscalaPermission.editarEscala,
        EscalaPermission.revisarEscala,
        EscalaPermission.publicarEscala,
      ]) {
        expect(
          autoriza(perfil: 'agente', uid: 'responsavel', permissao: permissao),
          isTrue,
        );
      }
    });

    test('agente responsável não designa a si próprio', () {
      expect(
        autoriza(
          perfil: 'agente',
          uid: 'responsavel',
          permissao: EscalaPermission.designarResponsavelEscala,
        ),
        isFalse,
      );
    });

    test('gerente gerencia escala e designa responsável', () {
      for (final permissao in [
        EscalaPermission.criarEscala,
        EscalaPermission.editarEscala,
        EscalaPermission.revisarEscala,
        EscalaPermission.publicarEscala,
        EscalaPermission.designarResponsavelEscala,
      ]) {
        expect(
          autoriza(perfil: 'gerente', uid: 'gerente', permissao: permissao),
          isTrue,
        );
      }
    });

    test('gestor permanece somente leitura nesta matriz', () {
      expect(
        autoriza(
          perfil: 'gestor',
          uid: 'gestor',
          permissao: EscalaPermission.publicarEscala,
        ),
        isFalse,
      );
    });

    test('coordenador atua na execução, não na gestão da escala', () {
      expect(
        autoriza(
          perfil: 'coordenador',
          uid: 'coord',
          permissao: EscalaPermission.editarEscala,
          coordenador: true,
        ),
        isFalse,
      );
      expect(
        autoriza(
          perfil: 'coordenador',
          uid: 'coord',
          permissao: EscalaPermission.registrarExecucaoMissao,
          coordenador: true,
        ),
        isTrue,
      );
    });

    test('agente participante registra própria execução e evidência', () {
      expect(
        autoriza(
          perfil: 'agente',
          uid: 'agente',
          permissao: EscalaPermission.registrarExecucaoMissao,
          participante: true,
        ),
        isTrue,
      );
      expect(
        autoriza(
          perfil: 'agente',
          uid: 'agente',
          permissao: EscalaPermission.anexarEvidenciaMissao,
          participante: true,
        ),
        isTrue,
      );
    });

    test('perfil desconhecido e uid vazio falham fechado', () {
      expect(
        autoriza(
          perfil: 'superusuario',
          uid: 'x',
          permissao: EscalaPermission.consultarEscalaGeral,
        ),
        isFalse,
      );
      expect(
        autoriza(
          perfil: 'agente',
          uid: '',
          permissao: EscalaPermission.consultarEscalaGeral,
        ),
        isFalse,
      );
    });
  });
}
