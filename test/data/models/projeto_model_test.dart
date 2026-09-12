import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/projeto_model.dart';

void main() {
  group('ProjetoModel - catalogo institucional', () {
    test('le catalogo enriquecido', () {
      final projeto = ProjetoModel.fromMap(
        'acao-amc-kids',
        <String, dynamic>{
          'nome': 'AMC Kids',
          'codigo': 'AE-AMC-KIDS',
          'categoria': 'Acao Educativa',
          'descricao': 'Atividade educativa de abordagem ludica.',
          'objetivo': 'Promover educacao para o transito.',
          'publicoAlvo': 'Criancas',
          'palavrasChave': <String>[
            'educacao',
            'criancas',
          ],
          'aliases': <String>[
            'Minicircuito',
            'Tabuleiro',
          ],
          'regionalIds': <String>[
            'regional-1',
          ],
          'ordem': 5,
          'ativo': true,
        },
      );

      expect(projeto.id, 'acao-amc-kids');
      expect(projeto.nome, 'AMC Kids');
      expect(projeto.codigo, 'AE-AMC-KIDS');
      expect(projeto.categoria, 'Acao Educativa');
      expect(projeto.ordem, 5);
      expect(projeto.ativo, isTrue);
      expect(projeto.valido, isTrue);
      expect(projeto.validoInstitucional, isTrue);
    });

    test('contexto da Faixita usa somente conhecimento cadastrado', () {
      const projeto = ProjetoModel(
        id: 'projeto-1',
        nome: 'Projeto Um',
        codigo: 'P-001',
        categoria: 'Acao Educativa',
        descricao: 'Descricao institucional.',
        objetivo: 'Orientar o publico.',
        publicoAlvo: 'Condutores.',
      );

      expect(
        projeto.contextoFaixita,
        'Descricao institucional. '
        'Objetivo: Orientar o publico. '
        'Publico-alvo: Condutores.',
      );

      expect(
        projeto.possuiConhecimentoInstitucional,
        isTrue,
      );
    });

    test('Faixita nao inventa contexto quando catalogo esta vazio', () {
      const projeto = ProjetoModel(
        id: 'projeto-1',
        nome: 'Projeto Um',
        codigo: 'P-001',
        categoria: 'Curso',
      );

      expect(
        projeto.contextoFaixita,
        isEmpty,
      );

      expect(
        projeto.possuiConhecimentoInstitucional,
        isFalse,
      );
    });

    test('normaliza aliases e palavras-chave', () {
      final projeto = ProjetoModel.fromMap(
        'projeto-1',
        <String, dynamic>{
          'nome': 'Projeto Um',
          'codigo': 'P-001',
          'categoria': 'Curso',
          'aliases': <String>[
            ' Apelido B ',
            '',
            'Apelido A',
            'Apelido B',
          ],
          'palavrasChave': <String>[
            ' Seguranca ',
            'educacao',
            'educacao',
          ],
        },
      );

      expect(
        projeto.aliases,
        <String>[
          'Apelido A',
          'Apelido B',
        ],
      );

      expect(
        projeto.palavrasChave,
        <String>[
          'educacao',
          'Seguranca',
        ],
      );
    });

    test('preserva equipeIds legado sem usar como conhecimento', () {
      final projeto = ProjetoModel.fromMap(
        'projeto-legado',
        <String, dynamic>{
          'nome': 'Projeto Legado',
          'codigo': 'LEG-001',
          'categoria': 'Acao Educativa',
          'equipeIds': <String>[
            'equipe-2',
            'equipe-1',
          ],
        },
      );

      expect(
        projeto.equipeIds,
        <String>[
          'equipe-1',
          'equipe-2',
        ],
      );

      expect(
        projeto.contextoFaixita,
        isEmpty,
      );
    });

    test('round-trip preserva catalogo institucional', () {
      const original = ProjetoModel(
        id: 'workshop-alcoolemia',
        nome: 'Workshop Alcoolemia',
        codigo: 'WS-ALCOOLEMIA',
        categoria: 'Workshop',
        descricao: 'Workshop institucional.',
        objetivo: 'Promover sensibilizacao.',
        publicoAlvo: 'Condutores',
        palavrasChave: <String>[
          'alcoolemia',
          'seguranca',
        ],
        aliases: <String>[
          'Dinamica dos Oculos',
        ],
        regionalIds: <String>[
          'regional-1',
          'regional-2',
        ],
        ordem: 2,
        ativo: true,
      );

      final restaurado = ProjetoModel.fromMap(
        original.id,
        original.toMap(),
      );

      expect(restaurado.nome, original.nome);
      expect(restaurado.codigo, original.codigo);
      expect(restaurado.categoria, original.categoria);
      expect(restaurado.descricao, original.descricao);
      expect(restaurado.objetivo, original.objetivo);
      expect(restaurado.publicoAlvo, original.publicoAlvo);
      expect(
        restaurado.palavrasChave,
        original.palavrasChave,
      );
      expect(
        restaurado.aliases,
        original.aliases,
      );
      expect(
        restaurado.regionalIds,
        original.regionalIds,
      );
      expect(restaurado.ordem, original.ordem);
      expect(restaurado.ativo, isTrue);
    });

    test('registro antigo sem novos campos permanece legivel', () {
      final antigo = ProjetoModel.fromMap(
        'projeto-antigo',
        <String, dynamic>{
          'nome': 'Projeto Antigo',
          'codigo': 'ANT-001',
          'regionalIds': <String>[
            'regional-1',
          ],
          'equipeIds': <String>[
            'equipe-antiga',
          ],
          'ativo': true,
        },
      );

      expect(antigo.nome, 'Projeto Antigo');
      expect(antigo.categoria, isEmpty);
      expect(antigo.descricao, isEmpty);
      expect(antigo.objetivo, isEmpty);
      expect(antigo.publicoAlvo, isEmpty);
      expect(antigo.equipeIds, <String>['equipe-antiga']);

      // O registro permanece estruturalmente valido para consumidores
      // legados, mas ainda nao satisfaz o novo contrato institucional.
      expect(antigo.valido, isTrue);
      expect(antigo.validoInstitucional, isFalse);
    });
  });
}
