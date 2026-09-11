import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/core/services/projeto_catalog_service.dart';
import 'package:geduc_rae_mobile/data/models/projeto_model.dart';

ProjetoModel _projeto({
  required String id,
  required String nome,
  required String codigo,
  required String categoria,
  String descricao = '',
  String objetivo = '',
  String publicoAlvo = '',
  List<String> palavrasChave = const <String>[],
  List<String> aliases = const <String>[],
  int ordem = 0,
  bool ativo = true,
}) {
  return ProjetoModel(
    id: id,
    nome: nome,
    codigo: codigo,
    categoria: categoria,
    descricao: descricao,
    objetivo: objetivo,
    publicoAlvo: publicoAlvo,
    palavrasChave: palavrasChave,
    aliases: aliases,
    ordem: ordem,
    ativo: ativo,
  );
}

void main() {
  group('ProjetoCatalogService', () {
    final projetos = <ProjetoModel>[
      _projeto(
        id: 'amc-kids',
        nome: 'AMC Kids',
        codigo: 'AE-005',
        categoria: 'Ação Educativa',
        descricao: 'Atividade educativa lúdica.',
        objetivo: 'Promover educação para o trânsito.',
        publicoAlvo: 'Crianças',
        palavrasChave: const <String>[
          'educação',
          'crianças',
        ],
        aliases: const <String>[
          'Minicircuito',
          'Tabuleiro',
        ],
        ordem: 2,
      ),
      _projeto(
        id: 'ciclista-seguro',
        nome: 'Ciclista Seguro',
        codigo: 'CE-006',
        categoria: 'Comando Educativo',
        palavrasChave: const <String>[
          'bicicleta',
          'segurança',
        ],
        ordem: 1,
      ),
      _projeto(
        id: 'curso-pilotagem',
        nome: 'Curso de Pilotagem Segura para Ciclista',
        codigo: 'CPSC',
        categoria: 'Curso',
        aliases: const <String>[
          'Pilotagem de Bike',
        ],
      ),
      _projeto(
        id: 'inativo',
        nome: 'Projeto Inativo',
        codigo: 'INAT-001',
        categoria: 'Curso',
        ativo: false,
      ),
      const ProjetoModel(
        id: 'legado',
        nome: 'Projeto Legado',
        codigo: 'LEG-001',
        categoria: '',
        ativo: true,
      ),
    ];

    test(
      'listarAtivos exclui inativos e registros sem contrato institucional',
      () async {
        final service = ProjetoCatalogService(
          carregarProjetos: () async => projetos,
        );

        final resultado = await service.listarAtivos();

        expect(
          resultado.map((item) => item.id),
          <String>[
            'ciclista-seguro',
            'amc-kids',
            'curso-pilotagem',
          ],
        );
      },
    );

    test(
      'pesquisa por nome',
      () {
        final resultado = ProjetoCatalogService.pesquisarLocal(
          projetos,
          'Ciclista Seguro',
        );

        expect(
          resultado.map((item) => item.id),
          <String>[
            'ciclista-seguro',
          ],
        );
      },
    );

    test(
      'pesquisa por codigo',
      () {
        final resultado = ProjetoCatalogService.pesquisarLocal(
          projetos,
          'CPSC',
        );

        expect(
          resultado.single.id,
          'curso-pilotagem',
        );
      },
    );

    test(
      'pesquisa por categoria',
      () {
        final resultado = ProjetoCatalogService.pesquisarLocal(
          projetos,
          'acao educativa',
        );

        expect(
          resultado.single.id,
          'amc-kids',
        );
      },
    );

    test(
      'pesquisa por alias',
      () {
        final resultado = ProjetoCatalogService.pesquisarLocal(
          projetos,
          'Minicircuito',
        );

        expect(
          resultado.single.id,
          'amc-kids',
        );
      },
    );

    test(
      'pesquisa por palavra-chave ignora acentos',
      () {
        final resultado = ProjetoCatalogService.pesquisarLocal(
          projetos,
          'seguranca',
        );

        expect(
          resultado.map((item) => item.id),
          contains(
            'ciclista-seguro',
          ),
        );
      },
    );

    test(
      'pesquisa com varios termos exige todos os tokens',
      () {
        final resultado = ProjetoCatalogService.pesquisarLocal(
          projetos,
          'curso ciclista',
        );

        expect(
          resultado.single.id,
          'curso-pilotagem',
        );
      },
    );

    test(
      'consulta vazia devolve catalogo ordenado',
      () {
        final resultado = ProjetoCatalogService.pesquisarLocal(
          projetos,
          '   ',
        );

        expect(
          resultado.map((item) => item.id),
          <String>[
            'ciclista-seguro',
            'amc-kids',
            'curso-pilotagem',
          ],
        );
      },
    );

    test(
      'buscarAtivoPorId encontra somente projeto institucional ativo',
      () async {
        final service = ProjetoCatalogService(
          carregarProjetos: () async => projetos,
        );

        expect(
          (await service.buscarAtivoPorId(
            'amc-kids',
          ))
              ?.nome,
          'AMC Kids',
        );

        expect(
          await service.buscarAtivoPorId(
            'inativo',
          ),
          isNull,
        );

        expect(
          await service.buscarAtivoPorId(
            'legado',
          ),
          isNull,
        );
      },
    );

    test(
      'contextoFaixita usa somente texto institucional cadastrado',
      () async {
        final service = ProjetoCatalogService(
          carregarProjetos: () async => projetos,
        );

        final contexto = await service.contextoFaixita(
          'amc-kids',
        );

        expect(
          contexto,
          'Atividade educativa lúdica. '
          'Objetivo: Promover educação para o trânsito. '
          'Publico-alvo: Crianças',
        );
      },
    );

    test(
      'contextoFaixita retorna vazio quando conhecimento nao existe',
      () async {
        final service = ProjetoCatalogService(
          carregarProjetos: () async => projetos,
        );

        expect(
          await service.contextoFaixita(
            'ciclista-seguro',
          ),
          isEmpty,
        );

        expect(
          await service.contextoFaixita(
            'nao-existe',
          ),
          isEmpty,
        );
      },
    );
  });
}
