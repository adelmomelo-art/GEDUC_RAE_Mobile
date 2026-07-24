import 'package:cloud_firestore/cloud_firestore.dart';

/// Resultado da identificação territorial de uma Regional.
class RegionalResult {
  const RegionalResult({
    required this.encontrada,
    this.id = '',
    this.nome = '',
    this.bairroConsultado = '',
  });

  final bool encontrada;
  final String id;
  final String nome;
  final String bairroConsultado;

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

  Future<RegionalResult> buscarPorBairro(String bairro) async {
    final bairroNormalizado = _normalizarTexto(bairro);

    if (bairroNormalizado.isEmpty) {
      return RegionalResult.naoEncontrada(
        bairroConsultado: bairro.trim(),
      );
    }

    final snapshot = await _firestore
        .collection('regionais')
        .where('ativo', isEqualTo: true)
        .get();

    for (final documento in snapshot.docs) {
      final dados = documento.data();

      final bairrosVinculados = _converterListaDeBairros(
        dados['bairrosVinculados'],
      );

      final possuiBairro = bairrosVinculados.any(
        (item) => _normalizarTexto(item) == bairroNormalizado,
      );

      if (!possuiBairro) {
        continue;
      }

      return RegionalResult(
        encontrada: true,
        id: documento.id,
        nome: _obterNomeRegional(dados),
        bairroConsultado: bairro.trim(),
      );
    }

    return RegionalResult.naoEncontrada(
      bairroConsultado: bairro.trim(),
    );
  }

  List<String> _converterListaDeBairros(dynamic valor) {
    if (valor is! Iterable) {
      return const <String>[];
    }

    return valor
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _obterNomeRegional(Map<String, dynamic> dados) {
    final valoresPossiveis = <dynamic>[
      dados['nomeRegional'],
      dados['nome'],
      dados['descricao'],
    ];

    for (final valor in valoresPossiveis) {
      final texto = valor?.toString().trim() ?? '';

      if (texto.isNotEmpty) {
        return texto;
      }
    }

    return '';
  }

  String _normalizarTexto(String valor) {
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
