import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/acoes/controllers/acao_controller.dart';
import 'package:geduc_rae_mobile/repositories/acao_repository.dart';

import '../../../support/acao_fixture.dart';

class _FakeAcaoRepository extends Fake implements AcaoRepository {
  int rascunhosSalvos = 0;

  @override
  Future<void> salvarRascunho(acao) async {
    rascunhosSalvos++;
  }
}

void main() {
  group('Equipe operacional - identidades canonicas', () {
    test('controller normaliza deduplica e persiste usuarioIds', () async {
      final repository = _FakeAcaoRepository();

      final controller = AcaoController(
        acaoRepository: repository,
      )..acaoAtual = criarAcaoTeste();

      controller.preencherRecursosOperacionais(
        agentesTransito: 2,
        equipeTerceirizada: 1,
        agenteEquipeIds: const <String>[
          'membro-coordenador',
          'membro-agente',
        ],
        agenteEquipeNomes: const <String>[
          'Coordenador',
          'Agente',
        ],
        agenteEquipeUserIds: const <String>[
          ' uid-agente ',
          'uid-coordenador',
          'uid-agente',
        ],
        terceirizadoEquipeIds: const <String>[
          'membro-terceiro',
        ],
        terceirizadoEquipeNomes: const <String>[
          'Terceiro',
        ],
        terceirizadoEquipeUserIds: const <String>[
          ' uid-terceiro ',
        ],
        materialUtilizadoIds: const <String>[
          'material_cone',
        ],
        coberturaMidia: false,
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        controller.acaoAtual!.agenteEquipeUserIds,
        const <String>[
          'uid-agente',
          'uid-coordenador',
        ],
      );

      expect(
        controller.acaoAtual!.terceirizadoEquipeUserIds,
        const <String>[
          'uid-terceiro',
        ],
      );

      expect(
        repository.rascunhosSalvos,
        greaterThanOrEqualTo(1),
      );
    });

    test('round-trip preserva identidades canonicas da equipe', () {
      final original = criarAcaoTeste().copyWith(
        agenteEquipeUserIds: const <String>[
          'uid-coordenador',
          'uid-agente',
        ],
        terceirizadoEquipeUserIds: const <String>[
          'uid-terceiro',
        ],
      );

      final restaurada = AcaoModel.fromMap(
        original.toMap(),
      );

      expect(
        restaurada.agenteEquipeUserIds,
        const <String>[
          'uid-coordenador',
          'uid-agente',
        ],
      );

      expect(
        restaurada.terceirizadoEquipeUserIds,
        const <String>[
          'uid-terceiro',
        ],
      );
    });

    test('RAE legado permanece compativel sem usuarioIds canonicos', () {
      final legado = AcaoModel.fromMap(
        <String, dynamic>{
          'id': 'rae-legado',
          'agenteEquipeIds': <String>[
            'membro-antigo',
          ],
          'agenteEquipeNomes': <String>[
            'Nome Historico',
          ],
        },
      );

      expect(
        legado.agenteEquipeIds,
        const <String>[
          'membro-antigo',
        ],
      );

      expect(
        legado.agenteEquipeUserIds,
        isEmpty,
      );

      expect(
        legado.terceirizadoEquipeUserIds,
        isEmpty,
      );
    });
  });
}
