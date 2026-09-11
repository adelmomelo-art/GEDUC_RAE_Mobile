import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/projeto_model.dart';

typedef ProjetoCatalogLoader = Future<List<ProjetoModel>> Function();

class ProjetoCatalogService {
  ProjetoCatalogService({
    FirebaseFirestore? firestore,
    ProjetoCatalogLoader? carregarProjetos,
  })  : _firestore = firestore,
        _carregarProjetos = carregarProjetos;

  final FirebaseFirestore? _firestore;
  final ProjetoCatalogLoader? _carregarProjetos;

  Future<List<ProjetoModel>> listarAtivos() async {
    final projetos = await _carregar();

    return normalizarCatalogo(
      projetos,
    );
  }

  Future<List<ProjetoModel>> pesquisar(
    String termo,
  ) async {
    final projetos = await listarAtivos();

    return pesquisarLocal(
      projetos,
      termo,
    );
  }

  Future<ProjetoModel?> buscarAtivoPorId(
    String projetoId,
  ) async {
    final id = projetoId.trim();

    if (id.isEmpty) {
      return null;
    }

    final projetos = await listarAtivos();

    for (final projeto in projetos) {
      if (projeto.id == id) {
        return projeto;
      }
    }

    return null;
  }

  /// Retorna somente o conhecimento institucional cadastrado.
  ///
  /// Se o projeto nao existir, estiver inativo, for estruturalmente
  /// incompleto ou nao possuir descricao institucional, retorna vazio.
  Future<String> contextoFaixita(
    String projetoId,
  ) async {
    final projeto = await buscarAtivoPorId(
      projetoId,
    );

    return projeto?.contextoFaixita ?? '';
  }

  Future<List<ProjetoModel>> _carregar() async {
    final carregarProjetos = _carregarProjetos;

    if (carregarProjetos != null) {
      return carregarProjetos();
    }

    final firestore = _firestore ?? FirebaseFirestore.instance;

    final snapshot = await firestore.collection('projetos').get();

    return snapshot.docs
        .map(
          (doc) => ProjetoModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList(growable: false);
  }

  static List<ProjetoModel> normalizarCatalogo(
    Iterable<ProjetoModel> projetos,
  ) {
    final resultado = projetos
        .where(
          (projeto) => projeto.ativo && projeto.validoInstitucional,
        )
        .toList(growable: false);

    resultado.sort(_compararProjetos);

    return List<ProjetoModel>.unmodifiable(
      resultado,
    );
  }

  static List<ProjetoModel> pesquisarLocal(
    Iterable<ProjetoModel> projetos,
    String termo,
  ) {
    final catalogo = normalizarCatalogo(projetos);

    final consulta = _normalizarTexto(termo).trim();

    if (consulta.isEmpty) {
      return catalogo;
    }

    final tokens = consulta
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final resultado = catalogo.where(
      (projeto) {
        final indice = _indicePesquisa(
          projeto,
        );

        return tokens.every(
          indice.contains,
        );
      },
    ).toList(growable: false);

    return List<ProjetoModel>.unmodifiable(
      resultado,
    );
  }

  static int _compararProjetos(
    ProjetoModel a,
    ProjetoModel b,
  ) {
    final ordemA = a.ordem > 0 ? a.ordem : 1 << 30;

    final ordemB = b.ordem > 0 ? b.ordem : 1 << 30;

    final porOrdem = ordemA.compareTo(ordemB);

    if (porOrdem != 0) {
      return porOrdem;
    }

    final porCategoria = _normalizarTexto(
      a.categoria,
    ).compareTo(
      _normalizarTexto(
        b.categoria,
      ),
    );

    if (porCategoria != 0) {
      return porCategoria;
    }

    final porNome = _normalizarTexto(
      a.nome,
    ).compareTo(
      _normalizarTexto(
        b.nome,
      ),
    );

    if (porNome != 0) {
      return porNome;
    }

    return a.id.compareTo(b.id);
  }

  static String _indicePesquisa(
    ProjetoModel projeto,
  ) {
    final valores = <String>[
      projeto.nome,
      projeto.codigo,
      projeto.categoria,
      ...projeto.aliases,
      ...projeto.palavrasChave,
    ];

    return _normalizarTexto(
      valores.join(' '),
    );
  }

  static String _normalizarTexto(
    String valor,
  ) {
    var texto = valor.trim().toLowerCase();

    const substituicoes = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    for (final entrada in substituicoes.entries) {
      texto = texto.replaceAll(
        entrada.key,
        entrada.value,
      );
    }

    return texto;
  }
}
