import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/rae_identity_resolver.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';

MembroEquipeModel _membro({
  required String id,
  required String usuarioId,
  required String nome,
  bool ativo = true,
  bool podeCoordenar = true,
}) {
  return MembroEquipeModel(
    id: id,
    usuarioId: usuarioId,
    nome: nome,
    vinculo: VinculoOperacional.agente,
    podeCoordenar: podeCoordenar,
    ativo: ativo,
    origem: 'usuario',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('RaeIdentityResolver', () {
    final coordenadora = _membro(
      id: 'membro-1',
      usuarioId: 'usuario-coord-1',
      nome: 'Coordenadora Ana',
    );

    final agente = _membro(
      id: 'membro-2',
      usuarioId: 'usuario-agente-1',
      nome: 'Agente Bruno',
      podeCoordenar: false,
    );

    test('resolve responsável e coordenador pelo id operacional', () {
      final resultado = RaeIdentityResolver.resolve(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorId: 'membro-1',
        membros: [
          coordenadora,
          agente,
        ],
      );

      expect(
        resultado.responsavelUserId,
        'usuario-responsavel-1',
      );

      expect(
        resultado.coordenadorUserId,
        'usuario-coord-1',
      );

      expect(
        resultado.completa,
        isTrue,
      );
    });

    test('resolve coordenador diretamente pelo usuarioId canônico', () {
      final resultado = RaeIdentityResolver.resolve(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorId: 'usuario-coord-1',
        membros: [
          coordenadora,
          agente,
        ],
      );

      expect(
        resultado.coordenadorUserId,
        'usuario-coord-1',
      );

      expect(
        resultado.completa,
        isTrue,
      );
    });

    test('normaliza espaços externos das identidades', () {
      final resultado = RaeIdentityResolver.resolve(
        responsavelUserId: '  usuario-responsavel-1  ',
        coordenadorId: '  membro-1  ',
        membros: [
          coordenadora,
        ],
      );

      expect(
        resultado.responsavelUserId,
        'usuario-responsavel-1',
      );

      expect(
        resultado.coordenadorUserId,
        'usuario-coord-1',
      );

      expect(
        resultado.completa,
        isTrue,
      );
    });

    test('responsável vazio produz resolução incompleta', () {
      final resultado = RaeIdentityResolver.resolve(
        responsavelUserId: '   ',
        coordenadorId: 'membro-1',
        membros: [
          coordenadora,
        ],
      );

      expect(
        resultado.responsavelUserId,
        isEmpty,
      );

      expect(
        resultado.coordenadorUserId,
        isEmpty,
      );

      expect(
        resultado.completa,
        isFalse,
      );
    });

    test('coordenador vazio produz resolução incompleta', () {
      final resultado = RaeIdentityResolver.resolve(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorId: '   ',
        membros: [
          coordenadora,
        ],
      );

      expect(
        resultado.responsavelUserId,
        'usuario-responsavel-1',
      );

      expect(
        resultado.coordenadorUserId,
        isEmpty,
      );

      expect(
        resultado.completa,
        isFalse,
      );
    });

    test('coordenador inexistente não inventa identidade', () {
      final resultado = RaeIdentityResolver.resolve(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorId: 'membro-inexistente',
        membros: [
          coordenadora,
          agente,
        ],
      );

      expect(
        resultado.coordenadorUserId,
        isEmpty,
      );

      expect(
        resultado.completa,
        isFalse,
      );
    });

    test('não resolve coordenador por nome', () {
      final resultado = RaeIdentityResolver.resolve(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorId: 'Coordenadora Ana',
        membros: [
          coordenadora,
        ],
      );

      expect(
        resultado.coordenadorUserId,
        isEmpty,
      );

      expect(
        resultado.completa,
        isFalse,
      );
    });

    test('id operacional é convertido para usuarioId canônico', () {
      final resultado = RaeIdentityResolver.resolve(
        responsavelUserId: 'usuario-responsavel-1',
        coordenadorId: 'membro-1',
        membros: [
          coordenadora,
        ],
      );

      expect(
        resultado.coordenadorUserId,
        isNot('membro-1'),
      );

      expect(
        resultado.coordenadorUserId,
        'usuario-coord-1',
      );
    });
  });
}
