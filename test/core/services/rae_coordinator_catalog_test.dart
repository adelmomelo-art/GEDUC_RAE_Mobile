import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/rae_coordinator_catalog.dart';
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
  group('RaeCoordinatorCatalog', () {
    test('aceita somente coordenador ativo habilitado e com usuarioId', () {
      final resultado = RaeCoordinatorCatalog.fromMembers([
        _membro(
          id: 'membro-melo',
          usuarioId: 'uid-melo',
          nome: 'Melo',
        ),
        _membro(
          id: 'inativo',
          usuarioId: 'uid-inativo',
          nome: 'Inativo',
          ativo: false,
        ),
        _membro(
          id: 'sem-permissao',
          usuarioId: 'uid-sem-permissao',
          nome: 'Sem Permissao',
          podeCoordenar: false,
        ),
        _membro(
          id: 'legado',
          usuarioId: '',
          nome: 'Legado',
        ),
      ]);

      expect(resultado, hasLength(1));
      expect(resultado.single.nome, 'Melo');
      expect(resultado.single.usuarioId, 'uid-melo');
      expect(resultado.single.membroId, 'membro-melo');
    });

    test('ID persistido para novo RAE e o usuarioId canonico', () {
      final resultado = RaeCoordinatorCatalog.fromMembers([
        _membro(
          id: 'membro-operacional-1',
          usuarioId: 'usuario-coordenador-1',
          nome: 'Coordenadora Ana',
        ),
      ]);

      expect(
        resultado.single.usuarioId,
        'usuario-coordenador-1',
      );
      expect(
        resultado.single.usuarioId,
        isNot('membro-operacional-1'),
      );
    });

    test('converte id operacional conhecido para usuarioId canonico', () {
      final coordenadores = RaeCoordinatorCatalog.fromMembers([
        _membro(
          id: 'membro-operacional-1',
          usuarioId: 'usuario-coordenador-1',
          nome: 'Coordenadora Ana',
        ),
      ]);

      final restaurado = RaeCoordinatorCatalog.resolveExisting(
        coordenadorId: 'membro-operacional-1',
        coordenadores: coordenadores,
      );

      expect(restaurado, isNotNull);
      expect(restaurado!.usuarioId, 'usuario-coordenador-1');
    });

    test('restaura diretamente por usuarioId canonico', () {
      final coordenadores = RaeCoordinatorCatalog.fromMembers([
        _membro(
          id: 'membro-melo',
          usuarioId: 'uid-melo',
          nome: 'Melo',
        ),
      ]);

      final restaurado = RaeCoordinatorCatalog.resolveExisting(
        coordenadorId: 'uid-melo',
        coordenadores: coordenadores,
      );

      expect(restaurado, isNotNull);
      expect(restaurado!.nome, 'Melo');
    });

    test('nao resolve identidade legado apenas por nome', () {
      final coordenadores = RaeCoordinatorCatalog.fromMembers([
        _membro(
          id: 'membro-melo',
          usuarioId: 'uid-melo',
          nome: 'Melo',
        ),
      ]);

      final restaurado = RaeCoordinatorCatalog.resolveExisting(
        coordenadorId: 'coord-legado-melo',
        coordenadores: coordenadores,
      );

      expect(restaurado, isNull);
    });

    test('remove duplicidade pelo mesmo usuarioId', () {
      final resultado = RaeCoordinatorCatalog.fromMembers([
        _membro(
          id: 'membro-a',
          usuarioId: 'uid-unico',
          nome: 'Melo',
        ),
        _membro(
          id: 'membro-b',
          usuarioId: 'uid-unico',
          nome: 'Melo duplicado',
        ),
      ]);

      expect(resultado, hasLength(1));
      expect(resultado.single.usuarioId, 'uid-unico');
    });
  });
}
