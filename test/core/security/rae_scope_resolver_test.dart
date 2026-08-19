import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/security/rae_scope_resolver.dart';
import 'package:geduc_rae_mobile/data/models/equipe_model.dart';
import 'package:geduc_rae_mobile/data/models/projeto_model.dart';

EquipeModel _equipe({
  required String id,
  required List<String> regionalIds,
  required List<String> coordenadorUserIds,
  bool ativo = true,
}) {
  return EquipeModel(
    id: id,
    nome: 'Equipe $id',
    regionalIds: regionalIds,
    coordenadorUserIds: coordenadorUserIds,
    ativo: ativo,
  );
}

ProjetoModel _projeto({
  required String id,
  required List<String> regionalIds,
  required List<String> equipeIds,
  bool ativo = true,
}) {
  return ProjetoModel(
    id: id,
    nome: 'Projeto $id',
    regionalIds: regionalIds,
    equipeIds: equipeIds,
    ativo: ativo,
  );
}

void main() {
  group('RaeScopeResolver', () {
    test('resolve equipe e projeto únicos', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
        ],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
        ],
        projetos: [
          _projeto(
            id: 'projeto-1',
            regionalIds: const [
              'regional-1',
            ],
            equipeIds: const [
              'equipe-1',
            ],
          ),
        ],
      );

      expect(
        resultado.status,
        RaeScopeResolutionStatus.resolvido,
      );

      expect(
        resultado.equipeId,
        'equipe-1',
      );

      expect(
        resultado.projetoId,
        'projeto-1',
      );

      expect(
        resultado.resolvido,
        isTrue,
      );
    });

    test('não resolve sem regionalId', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: '   ',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
        ],
        equipes: const [],
        projetos: const [],
      );

      expect(
        resultado.naoResolvido,
        isTrue,
      );

      expect(
        resultado.equipeId,
        isEmpty,
      );

      expect(
        resultado.projetoId,
        isEmpty,
      );
    });

    test('não resolve sem coordenadorUserId', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: '',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
        ],
        equipes: const [],
        projetos: const [],
      );

      expect(
        resultado.naoResolvido,
        isTrue,
      );
    });

    test('ignora equipe fora da regional da ação', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
        ],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-2',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
        ],
        projetos: const [],
      );

      expect(
        resultado.naoResolvido,
        isTrue,
      );

      expect(
        resultado.equipeId,
        isEmpty,
      );
    });

    test('ignora equipe sem vínculo com coordenador', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
        ],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'outro-coordenador',
            ],
          ),
        ],
        projetos: const [],
      );

      expect(
        resultado.naoResolvido,
        isTrue,
      );
    });

    test('ignora equipe fora do escopo permitido', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-permitida',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
        ],
        equipes: [
          _equipe(
            id: 'equipe-fora-escopo',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
        ],
        projetos: const [],
      );

      expect(
        resultado.naoResolvido,
        isTrue,
      );
    });

    test('duas equipes compatíveis produzem ambiguidade', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
          'equipe-2',
        ],
        projetoIdsPermitidos: const [],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
          _equipe(
            id: 'equipe-2',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
        ],
        projetos: const [],
      );

      expect(
        resultado.ambiguo,
        isTrue,
      );

      expect(
        resultado.equipeId,
        isEmpty,
      );

      expect(
        resultado.equipesCandidatas,
        containsAll([
          'equipe-1',
          'equipe-2',
        ]),
      );
    });

    test('equipe única sem projeto compatível fica não resolvida', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
        ],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
        ],
        projetos: [
          _projeto(
            id: 'projeto-1',
            regionalIds: const [
              'regional-2',
            ],
            equipeIds: const [
              'equipe-1',
            ],
          ),
        ],
      );

      expect(
        resultado.naoResolvido,
        isTrue,
      );

      expect(
        resultado.equipeId,
        'equipe-1',
      );

      expect(
        resultado.projetoId,
        isEmpty,
      );
    });

    test('ignora projeto fora do escopo permitido', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-permitido',
        ],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
        ],
        projetos: [
          _projeto(
            id: 'projeto-fora-escopo',
            regionalIds: const [
              'regional-1',
            ],
            equipeIds: const [
              'equipe-1',
            ],
          ),
        ],
      );

      expect(
        resultado.naoResolvido,
        isTrue,
      );

      expect(
        resultado.projetoId,
        isEmpty,
      );
    });

    test('dois projetos compatíveis produzem ambiguidade', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
          'projeto-2',
        ],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
        ],
        projetos: [
          _projeto(
            id: 'projeto-1',
            regionalIds: const [
              'regional-1',
            ],
            equipeIds: const [
              'equipe-1',
            ],
          ),
          _projeto(
            id: 'projeto-2',
            regionalIds: const [
              'regional-1',
            ],
            equipeIds: const [
              'equipe-1',
            ],
          ),
        ],
      );

      expect(
        resultado.ambiguo,
        isTrue,
      );

      expect(
        resultado.equipeId,
        'equipe-1',
      );

      expect(
        resultado.projetoId,
        isEmpty,
      );

      expect(
        resultado.projetosCandidatos,
        containsAll([
          'projeto-1',
          'projeto-2',
        ]),
      );
    });

    test('ignora equipe e projeto inativos', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: 'regional-1',
        coordenadorUserId: 'usuario-coord-1',
        equipeIdsPermitidas: const [
          'equipe-1',
        ],
        projetoIdsPermitidos: const [
          'projeto-1',
        ],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
            ativo: false,
          ),
        ],
        projetos: [
          _projeto(
            id: 'projeto-1',
            regionalIds: const [
              'regional-1',
            ],
            equipeIds: const [
              'equipe-1',
            ],
            ativo: false,
          ),
        ],
      );

      expect(
        resultado.naoResolvido,
        isTrue,
      );
    });

    test('normaliza espaços externos dos identificadores', () {
      final resultado = RaeScopeResolver.resolve(
        regionalId: '  regional-1  ',
        coordenadorUserId: '  usuario-coord-1  ',
        equipeIdsPermitidas: const [
          '  equipe-1  ',
        ],
        projetoIdsPermitidos: const [
          '  projeto-1  ',
        ],
        equipes: [
          _equipe(
            id: 'equipe-1',
            regionalIds: const [
              'regional-1',
            ],
            coordenadorUserIds: const [
              'usuario-coord-1',
            ],
          ),
        ],
        projetos: [
          _projeto(
            id: 'projeto-1',
            regionalIds: const [
              'regional-1',
            ],
            equipeIds: const [
              'equipe-1',
            ],
          ),
        ],
      );

      expect(
        resultado.resolvido,
        isTrue,
      );

      expect(
        resultado.equipeId,
        'equipe-1',
      );

      expect(
        resultado.projetoId,
        'projeto-1',
      );
    });
  });
  test('escopo de equipes vazio não concede resolução implícita', () {
    final resultado = RaeScopeResolver.resolve(
      regionalId: 'regional-1',
      coordenadorUserId: 'usuario-coord-1',
      equipeIdsPermitidas: const [],
      projetoIdsPermitidos: const [
        'projeto-1',
      ],
      equipes: [
        _equipe(
          id: 'equipe-1',
          regionalIds: const [
            'regional-1',
          ],
          coordenadorUserIds: const [
            'usuario-coord-1',
          ],
        ),
      ],
      projetos: [
        _projeto(
          id: 'projeto-1',
          regionalIds: const [
            'regional-1',
          ],
          equipeIds: const [
            'equipe-1',
          ],
        ),
      ],
    );

    expect(
      resultado.naoResolvido,
      isTrue,
    );

    expect(
      resultado.equipeId,
      isEmpty,
    );

    expect(
      resultado.projetoId,
      isEmpty,
    );
  });

  test('escopo de projetos vazio não concede resolução implícita', () {
    final resultado = RaeScopeResolver.resolve(
      regionalId: 'regional-1',
      coordenadorUserId: 'usuario-coord-1',
      equipeIdsPermitidas: const [
        'equipe-1',
      ],
      projetoIdsPermitidos: const [],
      equipes: [
        _equipe(
          id: 'equipe-1',
          regionalIds: const [
            'regional-1',
          ],
          coordenadorUserIds: const [
            'usuario-coord-1',
          ],
        ),
      ],
      projetos: [
        _projeto(
          id: 'projeto-1',
          regionalIds: const [
            'regional-1',
          ],
          equipeIds: const [
            'equipe-1',
          ],
        ),
      ],
    );

    expect(
      resultado.naoResolvido,
      isTrue,
    );

    expect(
      resultado.equipeId,
      'equipe-1',
    );

    expect(
      resultado.projetoId,
      isEmpty,
    );
  });
}
