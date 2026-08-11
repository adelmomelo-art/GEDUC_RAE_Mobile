import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/regional_model.dart';

/// Resultado da identificação territorial de uma Regional.
class RegionalResult {
  const RegionalResult({
    required this.encontrada,
    this.id = '',
    this.nome = '',
    this.bairroConsultado = '',
    this.ambigua = false,
    this.correspondencias = const <RegionalModel>[],
  });

  final bool encontrada;
  final String id;
  final String nome;
  final String bairroConsultado;
  final bool ambigua;
  final List<RegionalModel> correspondencias;

  factory RegionalResult.naoEncontrada({
    required String bairroConsultado,
  }) {
    return RegionalResult(
      encontrada: false,
      bairroConsultado: bairroConsultado,
    );
  }

  @override
  String toString() {
    return 'RegionalResult('
        'encontrada: $encontrada, '
        'id: $id, '
        'nome: $nome, '
        'bairroConsultado: $bairroConsultado'
        ')';
  }
}

/// Serviço responsável por identificar a Regional vinculada a um bairro.
///
/// A consulta ao Firestore fica isolada neste serviço, impedindo que a
/// página conheça diretamente a estrutura da coleção `regionais`.
class RegionalService {
  RegionalService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<RegionalModel>> listarAtivas({
    TipoRegional tipo = TipoRegional.administrativa,
  }) async {
    final snapshot = await _firestore
        .collection('regionais')
        .where('ativo', isEqualTo: true)
        .get();

    final regionais = snapshot.docs
        .map((doc) => RegionalModel.fromMap(doc.id, doc.data()))
        .where((regional) => regional.tipo == tipo && regional.nome.isNotEmpty)
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
    return regionais;
  }

  Future<RegionalResult> buscarPorBairro(String bairro) async {
    final regionais = await listarAtivas();
    return resolverPorBairro(bairro, regionais);
  }

  static RegionalResult resolverPorBairro(
    String bairro,
    List<RegionalModel> regionais,
  ) {
    final bairroNormalizado = _normalizarTexto(bairro);

    if (bairroNormalizado.isEmpty) {
      return RegionalResult.naoEncontrada(
        bairroConsultado: bairro.trim(),
      );
    }

    final correspondencias = regionais.where((regional) {
      return regional.bairros.any(
        (item) => _normalizarTexto(item) == bairroNormalizado,
      );
    }).toList(growable: false);

    if (correspondencias.length == 1) {
      final regional = correspondencias.single;
      return RegionalResult(
        encontrada: true,
        id: regional.id,
        nome: regional.nome,
        bairroConsultado: bairro.trim(),
        correspondencias: correspondencias,
      );
    }

    if (correspondencias.length > 1) {
      return RegionalResult(
        encontrada: false,
        ambigua: true,
        bairroConsultado: bairro.trim(),
        correspondencias: correspondencias,
      );
    }

    return RegionalResult.naoEncontrada(
      bairroConsultado: bairro.trim(),
    );
  }

  static String _normalizarTexto(String valor) {
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

    substituicoes.forEach((origem, destino) {
      texto = texto.replaceAll(origem, destino);
    });

    texto = texto.replaceAll(RegExp(r'\s+'), ' ');

    return texto;
  }
}
