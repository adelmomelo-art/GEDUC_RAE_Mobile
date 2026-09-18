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

  group('EscalaAccessPolicy ESC-001D.1', () {
    test('todos os perfis reconhecidos consultam escala geral', () {
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

    test('somente agente responsavel cria nova escala', () {
      expect(
        autoriza(
          perfil: 'agente',
          uid: 'responsavel',
          permissao: EscalaPermission.criarEscala,
        ),
        isTrue,
      );
      for (final perfil in [
        'administrador',
        'gestor',
        'gerente',
        'coordenador',
      ]) {
        expect(
          autoriza(
            perfil: perfil,
            uid: perfil,
            permissao: EscalaPermission.criarEscala,
          ),
          isFalse,
          reason: '$perfil nao deve criar nova escala',
        );
      }
      expect(
        autoriza(
          perfil: 'agente',
          uid: 'agente-comum',
          permissao: EscalaPermission.criarEscala,
        ),
        isFalse,
      );
    });

    test('responsavel edita revisa e publica', () {
      for (final permissao in [
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

    test('gerente edita revisa publica e designa, mas nao cria', () {
      expect(
        autoriza(
          perfil: 'gerente',
          uid: 'gerente',
          permissao: EscalaPermission.criarEscala,
        ),
        isFalse,
      );
      for (final permissao in [
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

    test('administrador configura, mas nao opera a escala', () {
      expect(
        autoriza(
          perfil: 'administrador',
          uid: 'admin',
          permissao: EscalaPermission.designarResponsavelEscala,
        ),
        isTrue,
      );
      for (final permissao in [
        EscalaPermission.criarEscala,
        EscalaPermission.editarEscala,
        EscalaPermission.revisarEscala,
        EscalaPermission.publicarEscala,
      ]) {
        expect(
          autoriza(perfil: 'administrador', uid: 'admin', permissao: permissao),
          isFalse,
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

    test('coordenador atua na execucao, nao na gestao', () {
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

    test('agente participante registra propria execucao e evidencia', () {
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

    test('agente participante registra somente as proprias horas realizadas',
        () {
      expect(
        autoriza(
          perfil: 'agente',
          uid: 'agente',
          permissao: EscalaPermission.registrarHorasRealizadas,
          participante: true,
        ),
        isTrue,
      );
      expect(
        autoriza(
          perfil: 'coordenador',
          uid: 'coord',
          permissao: EscalaPermission.registrarHorasRealizadas,
          coordenador: true,
        ),
        isFalse,
      );
      expect(
        autoriza(
          perfil: 'coordenador',
          uid: 'coord',
          permissao: EscalaPermission.registrarHorasRealizadas,
          participante: true,
          coordenador: true,
        ),
        isTrue,
      );
    });

    test('agente participante registra somente as proprias horas realizadas',
        () {
      expect(
        autoriza(
          perfil: 'agente',
          uid: 'agente',
          permissao: EscalaPermission.registrarHorasRealizadas,
          participante: true,
        ),
        isTrue,
      );
      expect(
        autoriza(
          perfil: 'coordenador',
          uid: 'coord',
          permissao: EscalaPermission.registrarHorasRealizadas,
          coordenador: true,
        ),
        isFalse,
      );
      expect(
        autoriza(
          perfil: 'coordenador',
          uid: 'coord',
          permissao: EscalaPermission.registrarHorasRealizadas,
          participante: true,
          coordenador: true,
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
